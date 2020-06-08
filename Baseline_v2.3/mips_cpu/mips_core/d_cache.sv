/*
 * d_cache.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * This is a direct-mapped data cache. Line size and depth (number of lines) are
 * set via INDEX_WIDTH and BLOCK_OFFSET_WIDTH parameters. Notice that line size
 * means number of words (each consist of 32 bit) in a line. Because all
 * addresses in mips_core are 26 byte addresses, so the sum of TAG_WIDTH,
 * INDEX_WIDTH and BLOCK_OFFSET_WIDTH is `ADDR_WIDTH - 2.
 *
 * Typical line sizes are from 2 words to 16 words. The memory interfaces only
 * support up to 16 words line size.
 *
 * Because we need a hit latency of 1 cycle, we need an asynchronous read port,
 * i.e. data is ready during the same cycle when address is calculated. However,
 * FPGA on-chip block rams only support synchronous read, i.e. data is ready
 * the cycle after the address is calculated. Due to this conflict, we need to
 * read from the banks on the clock edge at the beginning of the cycle. As a
 * result, we need the both the registered version of address and a
 * non-registered version of address (which will be registered in BRAM).
 *
 * See wiki page "Synchronous Caches" for details.
 */
`include "mips_core.svh"

interface d_cache_input_ifc ();
	logic valid;
	mips_core_pkg::MemAccessType mem_action;
	logic [`ADDR_WIDTH - 1 : 0] addr;
	logic [`ADDR_WIDTH - 1 : 0] addr_next;
	logic [`DATA_WIDTH - 1 : 0] data;
	

	modport in  (input valid, mem_action, addr, addr_next, data);
	modport out (output valid, mem_action, addr, addr_next, data);
endinterface

module d_cache #(
	parameter INDEX_WIDTH = 9,
	parameter BLOCK_OFFSET_WIDTH = 2
	)(
	// General signals
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	//Input from LLSC module
	llsc_output_ifc.in llsc_mem_in,

	// Request
	d_cache_input_ifc.in in,

	// passing instruction ids
	input logic [19:0] instruction_id,
	output logic [19:0] instruction_id_out,

	// Response
	cache_output_ifc.out out,

	// Memory interfaces
	mem_read_ifc.request mem_read,
	mem_write_ifc.request mem_write
);
	localparam TAG_WIDTH = `ADDR_WIDTH - INDEX_WIDTH - BLOCK_OFFSET_WIDTH - 2;
	localparam LINE_SIZE = 1 << BLOCK_OFFSET_WIDTH;
	localparam DEPTH = 1 << INDEX_WIDTH;

	// Check if the parameters are set correctly
	generate
		if(TAG_WIDTH <= 0 || LINE_SIZE > 16)
		begin
			INVALID_D_CACHE_PARAM invalid_d_cache_param ();
		end
	endgenerate

	// Parsing
	logic [TAG_WIDTH - 1 : 0] i_tag;
	logic [INDEX_WIDTH - 1 : 0] i_index;
	logic [BLOCK_OFFSET_WIDTH - 1 : 0] i_block_offset;

	logic [INDEX_WIDTH - 1 : 0] i_index_next;

	assign {i_tag, i_index, i_block_offset} = in.addr[`ADDR_WIDTH - 1 : 2];
	assign i_index_next = in.addr_next[BLOCK_OFFSET_WIDTH + 2 +: INDEX_WIDTH];
	// Above line uses +: slice, a feature of SystemVerilog
	// See https://stackoverflow.com/questions/18067571

	// States
	enum bit [1:0] {
		STATE_READY,	// Ready for incoming requests
		STATE_FLUSH,	// Writes out a dirty cache line
		STATE_WAIT,		// Wait for flush to be done
		STATE_REFILL	// Loads a cache line from memory
	} state, next_state;

	// Registers for flushing and refilling
	logic [INDEX_WIDTH - 1:0] r_index;
	logic [TAG_WIDTH - 1:0] r_tag;

	// databank signals
	logic [LINE_SIZE - 1 : 0] databank_select;
	logic [LINE_SIZE - 1 : 0] databank_we;
	logic [`DATA_WIDTH - 1 : 0] databank_wdata;
	logic [INDEX_WIDTH - 1 : 0] databank_waddr;
	logic [INDEX_WIDTH - 1 : 0] databank_raddr;
	logic [`DATA_WIDTH - 1 : 0] databank_rdata [LINE_SIZE];

	// databanks
	genvar g;
	generate
		for (g = 0; g < LINE_SIZE; g++)
		begin : databanks
			cache_bank #(
				.DATA_WIDTH (`DATA_WIDTH),
				.ADDR_WIDTH (INDEX_WIDTH)
			) databank (
				.clk,
				.i_we (databank_we[g]),
				.i_wdata(databank_wdata),
				.i_waddr(databank_waddr),
				.i_raddr(databank_raddr),

				.o_rdata(databank_rdata[g])
			);
		end
	endgenerate

	// tagbank signals
	logic tagbank_we;
	logic [TAG_WIDTH - 1 : 0] tagbank_wdata;
	logic [INDEX_WIDTH - 1 : 0] tagbank_waddr;
	logic [INDEX_WIDTH - 1 : 0] tagbank_raddr;
	logic [TAG_WIDTH - 1 : 0] tagbank_rdata;

	cache_bank #(
		.DATA_WIDTH (TAG_WIDTH),
		.ADDR_WIDTH (INDEX_WIDTH)
	) tagbank (
		.clk,
		.i_we    (tagbank_we),
		.i_wdata (tagbank_wdata),
		.i_waddr (tagbank_waddr),
		.i_raddr (tagbank_raddr),

		.o_rdata (tagbank_rdata)
	);

	// Valid bits
	logic [DEPTH - 1 : 0] valid_bits;
	// Dirty bits
	logic [DEPTH - 1 : 0] dirty_bits;

	// Shift registers for flushing
	logic [`DATA_WIDTH - 1 : 0] shift_rdata[LINE_SIZE];

	// Intermediate signals
	logic hit, miss;
	logic last_flush_word;
	logic last_refill_word;

	// Next instruction id out
	logic [19:0] next_instruction_id_out;
	always_ff@(posedge clk)
	begin
		instruction_id_out <= next_instruction_id_out;
		if(hit) begin
			next_instruction_id_out <= instruction_id;
		end else begin
			next_instruction_id_out <= next_instruction_id_out;
		end
	end

	always_comb
	begin
		hit = in.valid
			& valid_bits[i_index]
			& (i_tag == tagbank_rdata)
			& (state == STATE_READY);
		miss = in.valid & ~hit;
		last_flush_word = databank_select[LINE_SIZE - 1] & mem_write.user_we;
		last_refill_word = databank_select[LINE_SIZE - 1] & mem_read.user_available;
	end

	always_comb
	begin
		mem_write.control_base = {tagbank_rdata, i_index, {BLOCK_OFFSET_WIDTH + 2{1'b0}}};
		mem_write.control_length = LINE_SIZE << 2;
		mem_write.control_go = rst_n & (state != STATE_FLUSH) & (next_state == STATE_FLUSH);
		mem_write.user_we = state == STATE_FLUSH;
		mem_write.user_data = shift_rdata[0];
	end

	always_comb
	begin
		mem_read.control_base = {
			(state == STATE_READY
				? {i_tag, i_index}
				: {r_tag, r_index}),
			{BLOCK_OFFSET_WIDTH + 2{1'b0}}
		};
		mem_read.control_length = LINE_SIZE << 2;
		mem_read.control_go =rst_n &  (state != STATE_REFILL) & (next_state == STATE_REFILL);
		mem_read.user_re = mem_read.user_available;
	end

	always @(posedge clk)
	begin
		assert (!mem_write.control_go || mem_write.control_done) else
			$error("%m (%t) ERROR issuing write reqeust when memory hasn't done processing the last request!", $time);

		// If the following assertion failed, your line size is probably too large
		assert (!mem_write.user_we || !mem_write.user_full) else
			$error("%m (%t) ERROR flushing data when buffer is full", $time);

		assert (!mem_read.control_go || mem_read.control_done) else
			$error("%m (%t) ERROR issuing read reqeust when memory hasn't done processing the last request!", $time);
	end

	always_comb
	begin
		databank_we <= '0;
		if (mem_read.user_available)				// We are refilling data
			databank_we <= databank_select;
		else if (hit & (in.mem_action == WRITE) && (llsc_mem_in.atomic != ATOMIC_FAIL))	// We are storing a word
			databank_we[i_block_offset] <= 1'b1;
	end

	always_comb
	begin
		if (state == STATE_READY)
		begin
			databank_wdata = in.data;
			databank_waddr = i_index;
			if (next_state == STATE_FLUSH)
				databank_raddr = i_index;
			else
				databank_raddr = i_index_next;
		end
		else
		begin
			databank_wdata = mem_read.user_data;
			databank_waddr = r_index;
			if (next_state == STATE_READY)
				databank_raddr = i_index_next;
			else
				databank_raddr = r_index;
		end
	end

	always_comb
	begin
		tagbank_we = last_refill_word;
		tagbank_wdata = r_tag;
		tagbank_waddr = r_index;
		tagbank_raddr = i_index_next;
	end

	always_comb
	begin
		out.valid = hit;
		out.data = (llsc_mem_in.atomic == ATOMIC_PASS) ? 32'b1 : (llsc_mem_in.atomic == ATOMIC_FAIL) ? 32'b0 : databank_rdata[i_block_offset];
	end

	always_comb
	begin
		unique case (state)
			STATE_READY:
			begin
				if (miss)
				begin
					if (valid_bits[i_index] & dirty_bits[i_index])
						next_state = STATE_FLUSH;
					else
						next_state = STATE_REFILL;
				end
				else
					next_state = state;
			end

			STATE_FLUSH:
			begin
				if (last_flush_word)
					next_state = STATE_WAIT;
				else
					next_state = state;
			end

			STATE_WAIT:
			begin
				if (mem_write.control_done)
					next_state = STATE_REFILL;
				else
					next_state = state;
			end

			STATE_REFILL:
			begin
				if (last_refill_word)
					next_state = STATE_READY;
				else
					next_state = state;
			end
		endcase
	end

	always_ff @(posedge clk)
	begin
		for (int i = 0; i < LINE_SIZE - 1; i++)
			shift_rdata[i] <= shift_rdata[i+1];

		if (state == STATE_READY && next_state == STATE_FLUSH)
			for (int i = 0; i < LINE_SIZE; i++)
				shift_rdata[i] <= databank_rdata[i];
	end

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			state <= STATE_READY;
			databank_select <= 1;
			valid_bits <= '0;
		end
		else
		begin
			state <= next_state;

			case (state)
				STATE_READY:
				begin
					if (miss)
					begin
						r_tag <= i_tag;
						r_index <= i_index;
					end
					else if (in.mem_action == WRITE)
						dirty_bits[i_index] <= 1'b1;
				end

				STATE_FLUSH:
				begin
					databank_select <= {databank_select[LINE_SIZE - 2 : 0],
						databank_select[LINE_SIZE - 1]};
				end

				STATE_REFILL:
				begin
					if (mem_read.user_available)
						databank_select <= {databank_select[LINE_SIZE - 2 : 0],
							databank_select[LINE_SIZE - 1]};

					if (last_refill_word)
					begin
						valid_bits[r_index] <= 1'b1;
						dirty_bits[r_index] <= 1'b0;
					end
				end
			endcase
		end
	end
endmodule

// connect between pr_e2m and dcache
module write_buffer (
    input logic clk,

    d_cache_input_ifc.in i_write_buffer,
    input logic[19:0] instruction_id,

	input logic[19:0] instruction_id_retired,
	input logic retired,

	// ouput 
	cache_output_ifc.out cache_out,
	output logic[19:0] instruction_id_out, 

	// connected to cache
    d_cache_input_ifc.out o_write_buffer,
	output logic found,
	output logic write
);

    logic[19:0] ids[8];
	logic[`ADDR_WIDTH - 1 : 0] addr_list[8];
	logic[`ADDR_WIDTH - 1 : 0] addr_next_list[8];
	logic[`DATA_WIDTH - 1 : 0] data_list[8];

	logic[2:0] id_to_index_matrix[8];

	// List of addresses that doesn't have duplicates
	logic[`ADDR_WIDTH-1 : 0] addr_to_index[8];

	// index corresponding to an address
	logic [3:0] index_addr;
	// for finding an empty spot in the matrix availibility
	logic [2:0] found_index_addr;

	logic [2:0] index_id;
	// a matrix of index
	logic[2:0] index_matrix[8][8];
	// index into the lists
	logic[2:0] index;

	// list of availible spots
	logic availibility[8] = '{'0, '0, '0, '0, '0, '0, '0, '0};
	logic [2:0] matrix_availibility[8] = '{'0, '0, '0, '0, '0, '0, '0, '0};
	logic availibility_ids[8][8] = '{'{0,0,0,0,0,0,0,0}, '{0,0,0,0,0,0,0,0}, '{0,0,0,0,0,0,0,0}, '{0,0,0,0,0,0,0,0}, '{0,0,0,0,0,0,0,0}, '{0,0,0,0,0,0,0,0}, '{0,0,0,0,0,0,0,0}, '{0,0,0,0,0,0,0,0}};
	// empty spot

	logic[2:0] id_head_ptr = 0;

	always_comb
	begin
		// for store
		if(addr_to_index[0] == i_write_buffer.addr) begin
			index_addr = 0;
		end
		else if (addr_to_index[1] == i_write_buffer.addr) begin
			index_addr = 1;
		end
		else if (addr_to_index[2] == i_write_buffer.addr) begin
			index_addr = 2;
		end
		else if (addr_to_index[3] == i_write_buffer.addr) begin
			index_addr = 3;
		end
		else if (addr_to_index[4] == i_write_buffer.addr) begin
			index_addr = 4;
		end
		else if (addr_to_index[5] == i_write_buffer.addr) begin
			index_addr = 5;
		end
		else if (addr_to_index[6] == i_write_buffer.addr) begin
			index_addr = 6;
		end
		else if (addr_to_index[7] == i_write_buffer.addr) begin
			index_addr = 7;
		end
		else begin
			index_addr = 8;
		end
		
		index_id = instruction_id[2:0];

		if (index_addr == 8) begin
			if (matrix_availibility[0] == 0) begin
				found_index_addr = 0;
			end
			else if (matrix_availibility[1] == 0) begin
				found_index_addr = 1;
			end 
			else if (matrix_availibility[2] == 0) begin
				found_index_addr = 2;
			end
			else if (matrix_availibility[3] == 0) begin
				found_index_addr = 3;
			end
			else if (matrix_availibility[4] == 0) begin
				found_index_addr = 4;
			end
			else if (matrix_availibility[5] == 0) begin
				found_index_addr = 5;
			end
			else if (matrix_availibility[6] == 0) begin
				found_index_addr = 6;
			end
			else begin
				found_index_addr = 7;
			end 
		end
		else begin
			found_index_addr = index_addr;
		end

		// for loads
		index = index_matrix[index_addr][index_id];

		instruction_id_out = instruction_id;
	end
    always_ff @(posedge clk) begin

		// load
        if (i_write_buffer.mem_action == READ && i_write_buffer.valid == 1) begin

			$display("Write buffer: load, id = %d, address = %x, in buffer = %s", instruction_id, i_write_buffer.data, index_addr < 8 ? "true" : "false");

			if (index_addr < 8) begin
				$display("\tData found in buffer\n", instruction_id, i_write_buffer.data, index_addr < 8 ? "true" : "false");

				cache_out.valid <= 1;
				cache_out.data <= data_list[index];

				o_write_buffer.valid <= 0;
				o_write_buffer.data <= 0;
				o_write_buffer.addr <= 0;
				o_write_buffer.addr_next <= 0;

				found <= 1;
			end
			else begin
				$display("\tSending request to cache\n", instruction_id, i_write_buffer.data, index_addr < 8 ? "true" : "false");

				o_write_buffer.valid <= i_write_buffer.valid;
				o_write_buffer.data <= i_write_buffer.data;
				o_write_buffer.addr <= i_write_buffer.addr;
				o_write_buffer.addr_next <= i_write_buffer.addr_next;
				o_write_buffer.mem_action <= READ;

				cache_out.valid <= 0;
				found <= 0;
			end

			write <= 0;
		end

		// store
		else if (i_write_buffer.mem_action == WRITE && i_write_buffer.valid == 1) begin

			$display("Write buffer: store, id = %d, address = %x, found_index_addr = %d, index_id = %d\n", instruction_id, i_write_buffer.addr, found_index_addr, index_id);
			
			ids[index_id] <= instruction_id;
			addr_list[index_id] <= i_write_buffer.addr;
			addr_next_list[index_id] <= i_write_buffer.addr_next;
			data_list[index_id] <= i_write_buffer.data;
			availibility[index_id] <= 1;

			matrix_availibility[found_index_addr] <= matrix_availibility[found_index_addr] + 1;
			
			addr_to_index[index_id] <= i_write_buffer.addr;
			
			availibility_ids[found_index_addr][index_id] <= 1;

			index_matrix[found_index_addr][index_id] <= index_id;
			index_matrix[found_index_addr][index_id + 1] <= (availibility_ids[found_index_addr][index_id + 1] == 0 && index_id + 1 != id_head_ptr) 
															? index_id : index_matrix[found_index_addr][1];
			index_matrix[found_index_addr][index_id + 2] <= (availibility_ids[found_index_addr][index_id + 1] == 0 && index_id + 1 != id_head_ptr && 
															availibility_ids[index_addr][index_id + 2] == 0 && index_id + 2 != id_head_ptr) 
															? index_id : index_matrix[found_index_addr][2];
			index_matrix[found_index_addr][index_id + 3] <= (availibility_ids[found_index_addr][index_id + 1] == 0 && index_id + 1 != id_head_ptr && 
															availibility_ids[index_addr][index_id + 2] == 0 && index_id + 2 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 3] == 0 && index_id + 3 != id_head_ptr) 
															? index_id : index_matrix[found_index_addr][3];
			index_matrix[found_index_addr][index_id + 4] <= (availibility_ids[found_index_addr][index_id + 1] == 0 && index_id + 1 != id_head_ptr && 
															availibility_ids[index_addr][index_id + 2] == 0 && index_id + 2 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 3] == 0 && index_id + 3 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 4] == 0 && index_id + 4 != id_head_ptr) 
															? index_id : index_matrix[found_index_addr][4];
			index_matrix[found_index_addr][index_id + 5] <= (availibility_ids[found_index_addr][index_id + 1] == 0 && index_id + 1 != id_head_ptr && 
															availibility_ids[index_addr][index_id + 2] == 0 && index_id + 2 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 3] == 0 && index_id + 3 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 4] == 0 && index_id + 4 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 5] == 0 && index_id + 5 != id_head_ptr) 
															? index_id : index_matrix[found_index_addr][5];
			index_matrix[found_index_addr][index_id + 6] <= (availibility_ids[found_index_addr][index_id + 1] == 0 && index_id + 1 != id_head_ptr && 
															availibility_ids[index_addr][index_id + 2] == 0 && index_id + 2 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 3] == 0 && index_id + 3 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 4] == 0 && index_id + 4 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 5] == 0 && index_id + 5 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 6] == 0 && index_id + 6 != id_head_ptr) 
															? index_id : index_matrix[found_index_addr][6];
			index_matrix[found_index_addr][index_id + 7] <= (availibility_ids[found_index_addr][index_id + 1] == 0 && index_id + 1 != id_head_ptr && 
															availibility_ids[index_addr][index_id + 2] == 0 && index_id + 2 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 3] == 0 && index_id + 3 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 4] == 0 && index_id + 4 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 5] == 0 && index_id + 5 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 6] == 0 && index_id + 6 != id_head_ptr &&
															availibility_ids[index_addr][index_id + 7] == 0 && index_id + 7 != id_head_ptr) 
															? index_id : index_matrix[found_index_addr][7];

			id_to_index_matrix[index_id] <= found_index_addr;

			cache_out.valid <= 0;
			found <= 0;
			write <= 1;
			o_write_buffer.valid <= 0;
			o_write_buffer.data <= 0;
			o_write_buffer.addr <= 0;
			o_write_buffer.addr_next <= 0;
		end

		else begin
			cache_out.valid <= 0;
			found <= 0;
			write <= 1;
			o_write_buffer.valid <= 0;
			o_write_buffer.data <= 0;
			o_write_buffer.addr <= 0;
			o_write_buffer.addr_next <= 0;
		end

		if (retired) begin
			id_head_ptr <= id_head_ptr + 1;
			
			if (ids[id_head_ptr] == instruction_id_retired) begin
				availibility[id_head_ptr] <= 0;
				o_write_buffer.data <= data_list[id_head_ptr];
				o_write_buffer.addr <= addr_list[id_head_ptr];
				o_write_buffer.addr_next <= addr_next_list[id_head_ptr];
				o_write_buffer.valid <= 1;
				o_write_buffer.mem_action <= WRITE;
				
				availibility_ids[id_to_index_matrix[id_head_ptr]][id_head_ptr] <= 0;
				if(matrix_availibility[id_to_index_matrix[id_head_ptr]] == 1) begin
					addr_to_index[id_to_index_matrix[id_head_ptr]] = 0;
				end
				matrix_availibility[id_to_index_matrix[id_head_ptr]] <= matrix_availibility[id_to_index_matrix[id_head_ptr]] - 1;
			end
			
			index_matrix[0][id_head_ptr] <= index_matrix[0][id_head_ptr - 1];
			index_matrix[1][id_head_ptr] <= index_matrix[1][id_head_ptr - 1];
			index_matrix[2][id_head_ptr] <= index_matrix[2][id_head_ptr - 1];
			index_matrix[3][id_head_ptr] <= index_matrix[3][id_head_ptr - 1];
			index_matrix[4][id_head_ptr] <= index_matrix[4][id_head_ptr - 1];
			index_matrix[5][id_head_ptr] <= index_matrix[5][id_head_ptr - 1];
			index_matrix[6][id_head_ptr] <= index_matrix[6][id_head_ptr - 1];
			index_matrix[7][id_head_ptr] <= index_matrix[7][id_head_ptr - 1];
		end

    end

endmodule