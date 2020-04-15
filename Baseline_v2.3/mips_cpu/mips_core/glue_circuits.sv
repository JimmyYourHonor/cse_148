/*
 * branch_controller.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * These are glue circuits in each stage. They select data between different
 * sources for particular signals (e.g. alu's op2). They also re-combine the
 * signals to different interfaces that are passed to the next stage or hazard
 * controller.
 */
`include "mips_core.svh"

module decode_stage_glue (
	decoder_output_ifc.in i_decoded,
	reg_file_output_ifc.in i_reg_data,

	branch_decoded_ifc.decode branch_decoded,	// Contains both i/o

	alu_input_ifc.out o_alu_input,
	alu_pass_through_ifc.out o_alu_pass_through
);

	always_comb
	begin
		o_alu_input.valid =   i_decoded.valid;
		o_alu_input.alu_ctl = i_decoded.alu_ctl;
		o_alu_input.op1 =     i_reg_data.rs_data;
		o_alu_input.op2 =     i_decoded.uses_immediate
									? i_decoded.immediate
									: i_reg_data.rt_data;
		o_alu_input.is_ll =   i_decoded.is_ll;
		o_alu_input.is_sc =   i_decoded.is_sc;
		o_alu_input.is_sw =   i_decoded.is_sw;
		

		branch_decoded.valid =   i_decoded.is_branch_jump;
		branch_decoded.is_jump = i_decoded.is_jump;
		branch_decoded.target =  i_decoded.is_jump_reg
			? i_reg_data.rs_data[`ADDR_WIDTH - 1 : 0]
			: i_decoded.branch_target;


		o_alu_pass_through.is_branch =     i_decoded.is_branch_jump & ~i_decoded.is_jump;
		o_alu_pass_through.prediction =    branch_decoded.prediction;
		o_alu_pass_through.recovery_target = branch_decoded.recovery_target;

		o_alu_pass_through.is_mem_access = i_decoded.is_mem_access;
		o_alu_pass_through.mem_action =    i_decoded.mem_action;

		o_alu_pass_through.sw_data =       i_reg_data.rt_data;

		o_alu_pass_through.uses_rw =       i_decoded.uses_rw;
		o_alu_pass_through.rw_addr =       i_decoded.rw_addr;
	end
endmodule

module ex_stage_glue (
	alu_output_ifc.in i_alu_output,
	alu_pass_through_ifc.in i_alu_pass_through,
	
	llsc_input_ifc.out o_llsc_input,
	branch_result_ifc.out o_branch_result,
	d_cache_input_ifc.out o_d_cache_input,
	d_cache_pass_through_ifc.out o_d_cache_pass_through
);

	always_comb
	begin
		o_llsc_input.is_sw = i_alu_output.is_sw;
		o_llsc_input.lladdr_wr = i_alu_output.is_ll;
		o_llsc_input.is_sc = i_alu_output.is_sc;
		o_llsc_input.wr_reg_val = {6'b0,i_alu_output.result[`ADDR_WIDTH - 1 : 0]};
		
		o_branch_result.valid = i_alu_output.valid
			& i_alu_pass_through.is_branch;
		o_branch_result.prediction = i_alu_pass_through.prediction;
		o_branch_result.outcome =    i_alu_output.branch_outcome;
		o_branch_result.recovery_target =     i_alu_pass_through.recovery_target;

		o_d_cache_input.valid =      i_alu_pass_through.is_mem_access;
		o_d_cache_input.mem_action = i_alu_pass_through.mem_action;
		o_d_cache_input.addr =       i_alu_output.result[`ADDR_WIDTH - 1 : 0];
		o_d_cache_input.addr_next =  i_alu_output.result[`ADDR_WIDTH - 1 : 0];
		o_d_cache_input.data =       i_alu_pass_through.sw_data;

		o_d_cache_pass_through.is_mem_access = i_alu_pass_through.is_mem_access;
		o_d_cache_pass_through.alu_result =    i_alu_output.result;
		o_d_cache_pass_through.uses_rw =       i_alu_pass_through.uses_rw;
		o_d_cache_pass_through.rw_addr =       i_alu_pass_through.rw_addr;
	end
endmodule

module mem_stage_glue (
	cache_output_ifc.in i_d_cache_output,
	d_cache_pass_through_ifc.in i_d_cache_pass_through,
	
	output logic o_done,
	write_back_ifc.out o_write_back
);

	always_comb
	begin
		o_done = i_d_cache_pass_through.is_mem_access
			? i_d_cache_output.valid
			: 1'b1;
		o_write_back.uses_rw = i_d_cache_pass_through.uses_rw;
		o_write_back.rw_addr = i_d_cache_pass_through.rw_addr;
		o_write_back.rw_data = i_d_cache_pass_through.is_mem_access
			? i_d_cache_output.data
			: i_d_cache_pass_through.alu_result;
	end
endmodule
