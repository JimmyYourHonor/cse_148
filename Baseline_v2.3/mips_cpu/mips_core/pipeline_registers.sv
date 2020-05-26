/*
 * pipeline_registers.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/09/2018
 *
 * These are the pipeline registers between each two adjacent stages. All
 * pipeline registers are pure registers except for pr_e2m. pr_e2m needs to pass
 * through and select for addr_next signal. The reason is that we are using
 * synchronous BRAM to implement asynchronous d_cache.
 *
 * See wiki page "Synchronous Caches" for details.
 */
`include "mips_core.svh"

module pr_i2d (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	hazard_control_ifc.in i_hc,

	// Pipelined interfaces
	pc_ifc.in  i_pc,
	pc_ifc.out o_pc,

	cache_output_ifc.in  i_inst,
	cache_output_ifc.out o_inst
);

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			o_pc.pc <= '0;
			o_inst.valid <= 1'b0;
			o_inst.data <= '0;
		end
		else
		begin
			if (!i_hc.stall)
			begin
				if (i_hc.flush)
				begin
					o_pc.pc <= '0;
					o_inst.valid <= 1'b0;
					o_inst.data <= '0;
				end
				else
				begin
					o_pc.pc <= i_pc.pc;
					o_inst.valid <= i_inst.valid;
					o_inst.data <= i_inst.data;
				end
			end
		end
	end
endmodule

module pr_d2e (
	// instruction id input
	input logic[19:0] instruction_id,
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	hazard_control_ifc.in i_hc,

	// Pipelined interfaces
	pc_ifc.in  i_pc,
	pc_ifc.out o_pc,

	alu_input_ifc.in  i_alu_input,
	alu_input_ifc.out o_alu_input,
	alu_pass_through_ifc.in  i_alu_pass_through,
	alu_pass_through_ifc.out o_alu_pass_through,
	output logic[19:0] instruction_id_out
);

	always_ff @(posedge clk or negedge rst_n)
	begin
		instruction_id_out <= instruction_id;
		if(~rst_n)
		begin
			o_pc.pc <= '0;

			o_alu_input.valid <= '0;
			o_alu_input.alu_ctl <= ALUCTL_NOP;
			o_alu_input.op1 <= '0;
			o_alu_input.op2 <= '0;
			o_alu_input.is_ll <= '0;
   			o_alu_input.is_sc <= '0;
			o_alu_input.is_sw <= '0;


			o_alu_pass_through.is_branch <= 1'b0;
			o_alu_pass_through.prediction <= NOT_TAKEN;
			o_alu_pass_through.recovery_target <= '0;

			o_alu_pass_through.is_mem_access <= 1'b0;
			o_alu_pass_through.mem_action <= READ;

			o_alu_pass_through.sw_data <= '0;

			o_alu_pass_through.uses_rw <= 1'b0;
			o_alu_pass_through.rw_addr <= zero;
		end
		else
		begin
			if (!i_hc.stall)
			begin
				if (i_hc.flush)
				begin
					o_pc.pc <= '0;

					o_alu_input.valid <= '0;
					o_alu_input.alu_ctl <= ALUCTL_NOP;
					o_alu_input.op1 <= '0;
					o_alu_input.op2 <= '0;
					o_alu_input.is_ll <= '0;
					o_alu_input.is_sc <= '0;
					o_alu_input.is_sw <= '0;


					o_alu_pass_through.is_branch <= 1'b0;
					o_alu_pass_through.prediction <= NOT_TAKEN;
					o_alu_pass_through.recovery_target <= '0;

					o_alu_pass_through.is_mem_access <= 1'b0;
					o_alu_pass_through.mem_action <= READ;

					o_alu_pass_through.sw_data <= '0;

					o_alu_pass_through.uses_rw <= 1'b0;
					o_alu_pass_through.rw_addr <= zero;
				end
				else
				begin
					o_pc.pc <= i_pc.pc;

					o_alu_input.valid <= i_alu_input.valid;
					o_alu_input.alu_ctl <= i_alu_input.alu_ctl;
					o_alu_input.op1 <= i_alu_input.op1;
					o_alu_input.op2 <= i_alu_input.op2;
					o_alu_input.is_ll <= i_alu_input.is_ll;
					o_alu_input.is_sc <= i_alu_input.is_sc;					
					o_alu_input.is_sw <= i_alu_input.is_sw;	

					o_alu_pass_through.is_branch <= i_alu_pass_through.is_branch;
					o_alu_pass_through.prediction <= i_alu_pass_through.prediction;
					o_alu_pass_through.recovery_target <= i_alu_pass_through.recovery_target;

					o_alu_pass_through.is_mem_access <= i_alu_pass_through.is_mem_access;
					o_alu_pass_through.mem_action <= i_alu_pass_through.mem_action;

					o_alu_pass_through.sw_data <= i_alu_pass_through.sw_data;

					o_alu_pass_through.uses_rw <= i_alu_pass_through.uses_rw;
					o_alu_pass_through.rw_addr <= i_alu_pass_through.rw_addr;
				end
			end
		end
	end
endmodule

module pr_e2m (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	hazard_control_ifc.in i_hc,

	input logic [19:0] instruction_id,
	output logic[19:0] instruction_id_out,

	// Pipelined interfaces
	pc_ifc.in  i_pc,
	pc_ifc.out o_pc,
	d_cache_input_ifc.in  i_d_cache_input,
	d_cache_input_ifc.out o_d_cache_input,
	d_cache_pass_through_ifc.in  i_d_cache_pass_through,
	d_cache_pass_through_ifc.out o_d_cache_pass_through
);
	// Does not register addr_next. See d_cache for details.
	always_comb
	begin
		instruction_id_out = instruction_id;
		if (i_hc.stall)
			o_d_cache_input.addr_next = o_d_cache_input.addr;
		else
			o_d_cache_input.addr_next = i_d_cache_input.addr_next;
	end

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			o_pc.pc <= '0;

			o_d_cache_input.valid <= 1'b0;
			o_d_cache_input.mem_action <= READ;
			o_d_cache_input.addr <= '0;
			o_d_cache_input.data <= '0;

			o_d_cache_pass_through.is_mem_access <= 1'b0;
			o_d_cache_pass_through.alu_result <= '0;
			o_d_cache_pass_through.uses_rw <= 1'b0;
			o_d_cache_pass_through.rw_addr <= zero;
		end
		else
		begin
			if (!i_hc.stall)
			begin
				if (i_hc.flush)
				begin
					o_pc.pc <= '0;

					o_d_cache_input.valid <= 1'b0;
					o_d_cache_input.mem_action <= READ;
					o_d_cache_input.addr <= '0;
					o_d_cache_input.data <= '0;

					o_d_cache_pass_through.is_mem_access <= 1'b0;
					o_d_cache_pass_through.alu_result <= '0;
					o_d_cache_pass_through.uses_rw <= 1'b0;
					o_d_cache_pass_through.rw_addr <= zero;
				end
				else
				begin
					o_pc.pc <= i_pc.pc;

					o_d_cache_input.valid <= i_d_cache_input.valid;
					o_d_cache_input.mem_action <= i_d_cache_input.mem_action;
					o_d_cache_input.addr <= i_d_cache_input.addr;
					o_d_cache_input.data <= i_d_cache_input.data;

					o_d_cache_pass_through.is_mem_access <= i_d_cache_pass_through.is_mem_access;
					o_d_cache_pass_through.alu_result <= i_d_cache_pass_through.alu_result;
					o_d_cache_pass_through.uses_rw <= i_d_cache_pass_through.uses_rw;
					o_d_cache_pass_through.rw_addr <= i_d_cache_pass_through.rw_addr;
				end
			end
		end
	end
endmodule

module pr_m2w (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	hazard_control_ifc.in i_hc,

	// Pipelined interfaces
	write_back_ifc.in  i_wb,
	write_back_ifc.out o_wb
);

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			o_wb.uses_rw <= 1'b0;
			o_wb.rw_addr <= zero;
			o_wb.rw_data <= '0;
		end
		else
		begin
			if (!i_hc.stall)
			begin
				if (i_hc.flush)
				begin
					o_wb.uses_rw <= 1'b0;
					o_wb.rw_addr <= zero;
					o_wb.rw_data <= '0;
				end
				else
				begin
					o_wb.uses_rw <= i_wb.uses_rw;
					o_wb.rw_addr <= i_wb.rw_addr;
					o_wb.rw_data <= i_wb.rw_data;
				end
			end
		end
	end
endmodule
