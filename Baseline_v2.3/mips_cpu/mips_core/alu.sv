/*
 * alu.sv
 * Author: Pravin P. Prabhu & Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * Defines the input and output interface of arithmetic logic unit in execution
 * stage. Implement the alu which can do arithmetic calculations and branch
 * resolution.
 *
 * It is also reponsible for reporting customized MTC0 instructions
 * to pass_done interface. See wiki page "Pass Done Interface" for details.
 */
`include "mips_core.svh"

interface alu_input_ifc ();
	logic valid;
	mips_core_pkg::AluCtl alu_ctl;
	logic signed [`DATA_WIDTH - 1 : 0] op1;
	logic signed [`DATA_WIDTH - 1 : 0] op2;
	logic is_ll;
	logic is_sc;
	logic is_sw;

	modport in  (input valid, alu_ctl, op1, op2, is_ll, is_sc, is_sw);
	modport out (output valid, alu_ctl, op1, op2, is_ll, is_sc, is_sw);
endinterface

interface alu_output_ifc ();
	logic valid;
	logic [`DATA_WIDTH - 1 : 0] result;
	mips_core_pkg::BranchOutcome branch_outcome;
	logic is_ll;
	logic is_sc;
	logic is_sw;


	modport in  (input valid, result, branch_outcome, is_ll, is_sc, is_sw);
	modport out (output valid, result, branch_outcome, is_ll, is_sc, is_sw);
endinterface

module alu (
	alu_input_ifc.in in,
	alu_output_ifc.out out,
	pass_done_ifc.out pass_done
);

	always_comb
	begin
		out.valid <= 1'b0;
		out.result <= '0;
		out.branch_outcome <= NOT_TAKEN;
		
		out.is_ll <= 1'b0;
		out.is_sc <= 1'b0;
		out.is_sw <= 1'b0;
		
		pass_done.value <= '0;
		pass_done.code <= MTC0_NOOP;

		if (in.valid)
		begin
			out.valid <= 1'b1;
			out.is_ll <= in.is_ll;
			out.is_sc <= in.is_sc;
			out.is_sw <= in.is_sw;
			
			case (in.alu_ctl)
				ALUCTL_NOP:  out.result <= '0;
				ALUCTL_ADD:  out.result <= in.op1 + in.op2;
				ALUCTL_ADDU: out.result <= in.op1 + in.op2;
				ALUCTL_SUB:  out.result <= in.op1 - in.op2;
				ALUCTL_SUBU: out.result <= in.op1 - in.op2;
				ALUCTL_AND:  out.result <= in.op1 & in.op2;
				ALUCTL_OR:   out.result <= in.op1 | in.op2;
				ALUCTL_XOR:  out.result <= in.op1 ^ in.op2;
				ALUCTL_SLT:  out.result <= in.op1 < in.op2;
				ALUCTL_SLTU: out.result <= unsigned'(in.op1) < unsigned'(in.op2);
				ALUCTL_SLL:  out.result <= in.op1 << unsigned'(in.op2);
				ALUCTL_SRL:  out.result <= in.op1 >> unsigned'(in.op2);
				ALUCTL_SRA:  out.result <= in.op1 >>> unsigned'(in.op2);
				ALUCTL_SLLV: out.result <= in.op2 << in.op1[4:0];
				ALUCTL_SRLV: out.result <= in.op2 >> in.op1[4:0];
				ALUCTL_SRAV: out.result <= in.op2 >>> in.op1[4:0];
				ALUCTL_NOR:  out.result <= ~(in.op1 | in.op2);

				ALUCTL_MTCO_PASS:   // MTC0 -- redefined for our purposes.
				begin
					$display("%m (%t) PASS test %x\n", $time, in.op2);
					pass_done.code <= MTC0_PASS;
					pass_done.value <= in.op2[15:0];
				end

				ALUCTL_MTCO_FAIL:
				begin
					$display("%m (%t) FAIL test %x\n", $time, in.op2);
					pass_done.code <= MTC0_FAIL;
					pass_done.value <= in.op2[15:0];
				end

				ALUCTL_MTCO_DONE:
				begin
					$display("%m (%t) DONE test %x\n", $time, in.op2);
					pass_done.code <= MTC0_DONE;
					pass_done.value <= in.op2[15:0];
				end

				ALUCTL_BA:   out.branch_outcome <= TAKEN;
				ALUCTL_BEQ:  out.branch_outcome <= in.op1 == in.op2     ? TAKEN : NOT_TAKEN;
				ALUCTL_BNE:  out.branch_outcome <= in.op1 != in.op2     ? TAKEN : NOT_TAKEN;
				ALUCTL_BLEZ: out.branch_outcome <= in.op1 <= signed'(0) ? TAKEN : NOT_TAKEN;
				ALUCTL_BGTZ: out.branch_outcome <= in.op1 > signed'(0)  ? TAKEN : NOT_TAKEN;
				ALUCTL_BGEZ: out.branch_outcome <= in.op1 >= signed'(0) ? TAKEN : NOT_TAKEN;
				ALUCTL_BLTZ: out.branch_outcome <= in.op1 < signed'(0)  ? TAKEN : NOT_TAKEN;

				default: $display("%m (%t) Illegal ALUCTL code %b", $time, in.alu_ctl);
			endcase
		end
	end
endmodule
