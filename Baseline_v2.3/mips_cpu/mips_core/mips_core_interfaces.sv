/*
 * mips_core_interfaces.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/09/2018
 *
 * These are interfaces that are not the input or output of one specific unit.
 *
 * See wiki page "Systemverilog Primer" section interfaces for details.
 */
`include "mips_core.svh"

interface load_pc_ifc ();
	logic we;	// Write Enable
	logic [`ADDR_WIDTH - 1 : 0] new_pc;

	modport in  (input we, new_pc);
	modport out (output we, new_pc);
endinterface

interface pc_ifc ();
	logic [`ADDR_WIDTH - 1 : 0] pc;

	modport in  (input pc);
	modport out (output pc);
endinterface

interface cache_output_ifc ();
	logic valid;	// Output Valid
	logic [`DATA_WIDTH - 1 : 0] data;

	modport in  (input valid, data);
	modport out (output valid, data);
endinterface

interface branch_decoded_ifc ();
	logic valid;	// High means the instruction is a branch or a jump
	logic is_jump;	// High means the instruction is a jump
	logic [`ADDR_WIDTH - 1 : 0] target;

	mips_core_pkg::BranchOutcome prediction;
	logic [`ADDR_WIDTH - 1 : 0] recovery_target;

	modport decode (output valid, is_jump, target,
		input prediction, recovery_target);
	modport hazard (output prediction, recovery_target,
		input valid, is_jump, target);
endinterface

interface alu_pass_through_ifc ();
	logic is_branch;
	mips_core_pkg::BranchOutcome prediction;
	logic [`ADDR_WIDTH - 1 : 0] recovery_target;

	logic is_mem_access;
	mips_core_pkg::MemAccessType mem_action;
	logic [`DATA_WIDTH - 1 : 0] sw_data;

	logic uses_rw;
	mips_core_pkg::MipsReg rw_addr;

	modport in  (input is_branch, prediction, recovery_target, is_mem_access,
		mem_action, sw_data, uses_rw, rw_addr);
	modport out (output is_branch, prediction, recovery_target, is_mem_access,
		mem_action, sw_data, uses_rw, rw_addr);
endinterface

interface branch_result_ifc ();
	logic valid;
	mips_core_pkg::BranchOutcome prediction;
	mips_core_pkg::BranchOutcome outcome;
	logic [`ADDR_WIDTH - 1 : 0] recovery_target;

	modport in  (input valid, prediction, outcome, recovery_target);
	modport out (output valid, prediction, outcome, recovery_target);
endinterface

interface d_cache_pass_through_ifc ();
	logic is_mem_access;
	logic [`DATA_WIDTH - 1 : 0] alu_result;

	logic uses_rw;
	mips_core_pkg::MipsReg rw_addr;

	modport in  (input is_mem_access, alu_result, uses_rw, rw_addr);
	modport out (output is_mem_access, alu_result, uses_rw, rw_addr);
endinterface

interface write_back_ifc ();
	logic uses_rw;	// Write Enable
	mips_core_pkg::MipsReg rw_addr;
	logic [`DATA_WIDTH - 1 : 0] rw_data;

	modport in  (input uses_rw, rw_addr, rw_data);
	modport out (output uses_rw, rw_addr, rw_data);
endinterface

interface hazard_control_ifc ();
	// Stall signal has higher priority
	logic flush;	// Flush signal of the previous stage
	logic stall;	// Stall signal of the next stage

	modport in  (input flush, stall);
	modport out (output flush, stall);
endinterface


interface decoder_output_ifc ();
	logic valid;
	mips_core_pkg::AluCtl alu_ctl;
	logic is_branch_jump;
	logic is_jump;
	logic is_jump_reg;
	logic [`ADDR_WIDTH - 1 : 0] branch_target;

	logic is_mem_access;
	mips_core_pkg::MemAccessType mem_action;

	logic uses_rs;
	mips_core_pkg::MipsReg rs_addr;

	logic uses_rt;
	mips_core_pkg::MipsReg rt_addr;

	logic uses_immediate;
	logic [`DATA_WIDTH - 1 : 0] immediate;

	logic uses_rw;
	mips_core_pkg::MipsReg rw_addr;
	
	logic is_ll;
	logic is_sc;
	logic is_sw;

	modport in  (input valid, alu_ctl, is_branch_jump, is_jump, is_jump_reg,
		branch_target, is_mem_access, mem_action, uses_rs, rs_addr, uses_rt,
		rt_addr, uses_immediate, immediate, uses_rw, rw_addr, is_ll, is_sc, is_sw);
	modport out (output valid, alu_ctl, is_branch_jump, is_jump, is_jump_reg,
		branch_target, is_mem_access, mem_action, uses_rs, rs_addr, uses_rt,
		rt_addr, uses_immediate, immediate, uses_rw, rw_addr, is_ll, is_sc, is_sw);
endinterface
