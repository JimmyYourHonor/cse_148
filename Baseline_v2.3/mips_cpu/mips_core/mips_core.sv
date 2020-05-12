/* mips_core.sv
* Author: Pravin P. Prabhu, Dean Tullsen, and Zinsser Zhang
* Last Revision: 04/02/2018
* Abstract:
*   The core module for the MIPS32 processor. This is a classic 5-stage
* MIPS pipeline architecture which is intended to follow heavily from the model
* presented in Hennessy and Patterson's Computer Organization and Design.
* All addresses used in this scope are byte addresses (26-bit)
*/
`include "mips_core.svh"

module mips_core (
	// General signals
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Memory interfaces
	mem_read_ifc.request  i_cache_read,
	mem_write_ifc.request d_cache_write,
	mem_read_ifc.request  d_cache_read,

	// Outputs for Done Flag
	pass_done_ifc.out pass_done
);
	// Set DEBUG to 1 to enable trace dump.
	localparam DEBUG = 0;

	// Interfaces
	// |||| IF Stage
	pc_ifc if_pc_current();
	pc_ifc if_pc_next();
	cache_output_ifc if_i_cache_output();

	// ==== IF to DEC
	pc_ifc i2d_pc();
	cache_output_ifc i2d_inst();

	// |||| DEC Stage
	decoder_output_ifc dec_decoder_output();
	decoder_output_ifc ooo_output();
	reg_file_output_ifc dec_reg_file_output();
	reg_file_output_ifc dec_forward_unit_output();
	branch_decoded_ifc dec_branch_decoded();
	alu_input_ifc dec_alu_input();
	alu_pass_through_ifc dec_alu_pass_through();

	// ==== DEC to EX
	pc_ifc d2e_pc();
	alu_input_ifc d2e_alu_input();
	alu_pass_through_ifc d2e_alu_pass_through();

	// |||| EX Stage
	alu_output_ifc ex_alu_output();
	llsc_input_ifc ex_llsc_input();
	branch_result_ifc ex_branch_result();
	d_cache_input_ifc ex_d_cache_input();
	d_cache_pass_through_ifc ex_d_cache_pass_through();

	// ==== EX to MEM
	pc_ifc e2m_pc();
	llsc_output_ifc llsc_mem_output();
	d_cache_input_ifc e2m_d_cache_input();
	d_cache_pass_through_ifc e2m_d_cache_pass_through();

	// |||| MEM Stage
	cache_output_ifc mem_d_cache_output();
	logic mem_done;
	write_back_ifc mem_write_back();

	// ==== MEM to WB
	write_back_ifc m2w_write_back();

	// xxxx Hazard control
	logic lw_hazard;
	hazard_control_ifc i2i_hc();
	hazard_control_ifc i2d_hc();
	hazard_control_ifc d2e_hc();
	hazard_control_ifc e2m_hc();
	hazard_control_ifc m2w_hc();
	load_pc_ifc load_pc();



	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	// |||| IF Stage
	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	fetch_unit FETCH_UNIT(
		.clk, .rst_n,

		.i_hc         (i2i_hc),
		.i_load_pc    (load_pc),

		.o_pc_current (if_pc_current),
		.o_pc_next    (if_pc_next)
	);

	i_cache #(.INDEX_WIDTH(5), .BLOCK_OFFSET_WIDTH(2)) I_CACHE(
		.clk, .rst_n,
		.mem_read     (i_cache_read),

		.i_pc_current (if_pc_current),
		.i_pc_next    (if_pc_next),

		.out          (if_i_cache_output)
	);
	// If you want to change the line size and total size of instruction cache,
	// uncomment the following two lines and change the parameter.

	// defparam D_CACHE.INDEX_WIDTH = 9,
	// 	D_CACHE.BLOCK_OFFSET_WIDTH = 2;

	// ========================================================================
	// ==== IF to DEC
	// ========================================================================
	pr_i2d PR_I2D(
		.clk, .rst_n,
		.i_hc(i2d_hc),

		.i_pc   (if_pc_current),     .o_pc   (i2d_pc),
		.i_inst (if_i_cache_output), .o_inst (i2d_inst)
	);

	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	// |||| DEC Stage
	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	decoder DECODER(
		.i_pc(i2d_pc),
		.i_inst(i2d_inst),

		.out(dec_decoder_output)
	);

	reg_file REG_FILE(
		.clk,

		.i_decoded(dec_decoder_output),
		.i_wb(m2w_write_back), // WB stage

		.out(dec_reg_file_output)
	);

	out_of_order_buffer OOO_BUFFER (
		.clk,

		.reg_ready (dec_reg_file_output),
		.decoded_insn (dec_decoder_output),
		.i_pc (i2d_pc)

		.out(ooo_output)
	);

	forward_unit FORWARD_UNIT(
		.decoded     (ooo_output),
		.reg_data    (dec_reg_file_output),

		.ex_ctl      (d2e_alu_pass_through),
		.ex_data     (ex_alu_output),
		.mem         (mem_write_back),
		.wb          (m2w_write_back),

		.out         (dec_forward_unit_output),
		.o_lw_hazard (lw_hazard)
	);

	decode_stage_glue DEC_STAGE_GLUE(
		.i_decoded          (dec_decoder_output),
		.i_reg_data         (dec_forward_unit_output),

		.branch_decoded     (dec_branch_decoded),

		.o_alu_input        (dec_alu_input),
		.o_alu_pass_through (dec_alu_pass_through)
	);

	// ========================================================================
	// ==== DEC to EX
	// ========================================================================
	pr_d2e PR_D2E(
		.clk, .rst_n,
		.i_hc(d2e_hc),

		.i_pc(i2d_pc), .o_pc(d2e_pc),

		.i_alu_input        (dec_alu_input),
		.o_alu_input        (d2e_alu_input),
		.i_alu_pass_through (dec_alu_pass_through),
		.o_alu_pass_through (d2e_alu_pass_through)
	);

	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	// |||| EX Stage
	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	alu ALU(
		.in(d2e_alu_input),
		.out(ex_alu_output),
		.pass_done
	);

	llsc_module LLSC_mod(
	.clk(clk),
	.i_llsc(ex_llsc_input),
	.o_llsc(llsc_mem_output)
);


	ex_stage_glue EX_STAGE_GLUE (
		.i_alu_output           (ex_alu_output),
		.i_alu_pass_through     (d2e_alu_pass_through),
		.o_llsc_input           (ex_llsc_input),
		.o_branch_result        (ex_branch_result),
		.o_d_cache_input        (ex_d_cache_input),
		.o_d_cache_pass_through (ex_d_cache_pass_through)
	);

	// ========================================================================
	// ==== EX to MEM
	// ========================================================================
	pr_e2m PR_E2M (
		.clk, .rst_n,
		.i_hc(e2m_hc),

		.i_pc(d2e_pc), .o_pc(e2m_pc),
		.i_d_cache_input       (ex_d_cache_input),
		.i_d_cache_pass_through(ex_d_cache_pass_through),

		.o_d_cache_input       (e2m_d_cache_input),
		.o_d_cache_pass_through(e2m_d_cache_pass_through)
	);

	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	// |||| MEM Stage
	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	d_cache #(.INDEX_WIDTH(5), .BLOCK_OFFSET_WIDTH(2)) D_CACHE (
		.clk, .rst_n,

		.in(e2m_d_cache_input),
		.out(mem_d_cache_output),
		.llsc_mem_in(llsc_mem_output),
		.mem_read(d_cache_read),
		.mem_write(d_cache_write)
	);
	// If you want to change the line size and total size of data cache,
	// uncomment the following two lines and change the parameter.

	// defparam D_CACHE.INDEX_WIDTH = 9,
	// 	D_CACHE.BLOCK_OFFSET_WIDTH = 2;

	mem_stage_glue MEM_STAGE_GLUE (
		.i_d_cache_output      (mem_d_cache_output),
		.i_d_cache_pass_through(e2m_d_cache_pass_through),
		.o_done                (mem_done),
		.o_write_back          (mem_write_back)
	);

	// ========================================================================
	// ==== MEM to WB
	// ========================================================================
	pr_m2w PR_M2W (
		.clk, .rst_n,

		.i_hc (m2w_hc),
		.i_wb (mem_write_back),
		.o_wb (m2w_write_back)
	);

	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	// |||| WB Stage
	// ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
	// NO LOGIC

	// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	// xxxx Hazard Controller
	// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	hazard_controller HAZARD_CONTROLLER (
		.clk, .rst_n,

		.if_i_cache_output,
		.dec_pc(i2d_pc),
		.dec_branch_decoded,
		.ex_pc(d2e_pc),
		.lw_hazard,
		.ex_branch_result,
		.mem_done,

		.i2i_hc,
		.i2d_hc,
		.d2e_hc,
		.e2m_hc,
		.m2w_hc,
		.load_pc
	);

	// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	// xxxx Debug and statistic collect logic (Not synthesizable)
	// xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

	integer pcfile;
	integer wbfile;
	integer num_instructions;
	integer num_cycles;

	initial
	begin
		/*
		 * If DEBUG is set, dump trace to file. These files will be located at
		 * simulation/modelsim/
		 */
		if (DEBUG)
		begin
			pcfile = $fopen("pc.trace", "w");
			wbfile = $fopen("wb.trace", "w");
		end
	end

	always_ff @(posedge clk or negedge rst_n)
	begin
		if (~rst_n)
		begin
			num_cycles = 0;
			num_instructions = 0;
		end
		else
		begin
			num_cycles  = num_cycles + 1;

			/*
			 * If an instruction goes into d2e pipeline register and is not a
			 * nop, we count it as an instruction we executed.
			 */
			if (!i2d_hc.stall
				&& !d2e_hc.flush
				&& dec_decoder_output.valid
				&& i2d_inst.data)
			begin
				num_instructions = num_instructions + 1;

				if (DEBUG)
				begin
					$fwrite(pcfile, "%t %d %h\n", $time, num_instructions,
							i2d_pc.pc);
					$fflush(pcfile);
				end
			end

			if (DEBUG && m2w_write_back.uses_rw)
			begin
				$fwrite(wbfile, "%t %d r%d %h\n", $time, num_instructions,
						m2w_write_back.rw_addr, m2w_write_back.rw_data);
				$fflush(wbfile);
			end
		end
	end
endmodule
