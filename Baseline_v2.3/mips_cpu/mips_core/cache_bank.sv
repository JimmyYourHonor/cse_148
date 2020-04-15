/*
 * cache_bank.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * cache_bank provides a storage with one synchronous read and one synchronous
 * write port. When reading and writing to the same address, new data is
 * presented at the read port.
 *
 * cache_bank_core is a hint to Quartus's compiler to synthesis it to block ram.
 * Block rams in FPGA only support synchronous read and write (old data is
 * presented at the read port). So we need extra logic in cache_bank to forward
 * the new data.
 *
 * See wiki page "Synchronous Caches" for details.
 */
module cache_bank #(parameter DATA_WIDTH, parameter ADDR_WIDTH)(
	input clk,	// Clock
	input i_we,	// Write enable
	input logic [DATA_WIDTH - 1 : 0] i_wdata,			// Write data
	input logic [ADDR_WIDTH - 1 : 0] i_waddr, i_raddr,	// Write/read address
	output logic [DATA_WIDTH - 1 : 0] o_rdata			// Read data
);

	// A register to store new_data
	logic [DATA_WIDTH - 1 : 0] new_data;

	// The registered output of cache_bank_core
	logic [DATA_WIDTH - 1 : 0] old_data;

	// A flag to determine whether the last cycle write data (new_data) or
	// the read output (old_data) should be presented at the output port.
	logic new_data_flag;

	cache_bank_core #(DATA_WIDTH, ADDR_WIDTH)
		BANK_CORE (
			.clk, .i_we, .i_waddr, .i_raddr, .i_wdata,
			.o_rdata(old_data)
	);

	assign o_rdata = new_data_flag ? new_data : old_data;

	always_ff @(posedge clk)
	begin
		new_data <= i_wdata;
		new_data_flag <= i_we & (i_raddr == i_waddr);
	end
endmodule

module cache_bank_core #(parameter DATA_WIDTH, parameter ADDR_WIDTH)(
	input clk,	// Clock
	input i_we,	// Write enable
	input logic [DATA_WIDTH - 1 : 0] i_wdata,			// Write data
	input logic [ADDR_WIDTH - 1 : 0] i_waddr, i_raddr,	// Write/read address
	output logic [DATA_WIDTH - 1 : 0] o_rdata			// Read data
);
	localparam DEPTH = 1 << ADDR_WIDTH;

	logic [DATA_WIDTH - 1 : 0] data [DEPTH];

	always_ff @(posedge clk)
	begin
		o_rdata <= data[i_raddr];
		if (i_we)
			data[i_waddr] <= i_wdata;
	end
endmodule
