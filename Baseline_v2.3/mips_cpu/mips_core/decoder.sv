/*
 * decoder.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * Decoder decode an instruction to control signals.
 *
 * See wiki page "Branch and Jump" for details about branch/jump instructions.
 * See wiki page "Handle Register Zero" for deatils about instructions reading
 * from or writing to register zero.
 */
`include "mips_core.svh"

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

module decoder (
	pc_ifc.in i_pc,
	cache_output_ifc.in i_inst,

	decoder_output_ifc.out out
);

	task uses_rs;
		begin
			// Only set uses_rs if it is not register zero
			out.uses_rs <= |i_inst.data[25:21];
			out.rs_addr <= mips_core_pkg::MipsReg'(i_inst.data[25:21]);
		end
	endtask

	task uses_rt;
		begin
			// Only set uses_rt if it is not register zero
			out.uses_rt <= |i_inst.data[20:16];
			out.rt_addr <= mips_core_pkg::MipsReg'(i_inst.data[20:16]);
		end
	endtask

	task route_rt_to_rs;
		begin
			// Rerouting rt to rs for sll, srl, sra
			// Only set uses_rs if it is not register zero
			out.uses_rs <= |i_inst.data[20:16];
			out.rs_addr <= mips_core_pkg::MipsReg'(i_inst.data[20:16]);
		end
	endtask

	task uses_immediate_raw;
		input [31:0] immediate;
		begin
			out.uses_immediate <= 1'b1;
			out.immediate <= immediate;
		end
	endtask

	task uses_immediate_zero_extend;
		uses_immediate_raw(32'(unsigned'(i_inst.data[15:0])));
	endtask

	task uses_immediate_signed_extend;
		uses_immediate_raw(32'(signed'(i_inst.data[15:0])));
	endtask

	task uses_immediate_shamt;
		uses_immediate_raw(32'(unsigned'(i_inst.data[10:6])));
	endtask

	task uses_rw_raw;
		input [4:0] rw;
		begin
			// Only set uses_rw if it is not register zero
			out.uses_rw <= |rw;
			out.rw_addr <= mips_core_pkg::MipsReg'(rw);
		end
	endtask

	task uses_rw_rtype;
		uses_rw_raw(i_inst.data[15:11]);
	endtask

	task uses_rw_itype;
		uses_rw_raw(i_inst.data[20:16]);
	endtask

	task typical_rtype;
		begin
			uses_rs();
			uses_rt();
			uses_rw_rtype();
		end
	endtask

	task shamt_rtype;
		begin
			route_rt_to_rs();
			uses_rw_rtype();
			uses_immediate_shamt();
		end
	endtask

	task signed_extend_itype;
		begin
			uses_rs();
			uses_rw_itype();
			uses_immediate_signed_extend();
		end
	endtask

	task zero_extend_itype;
		begin
			uses_rs();
			uses_rw_itype();
			uses_immediate_zero_extend();
		end
	endtask



	always_comb
	begin
		// Set defaults to nop
		out.valid <= i_inst.valid;
		out.alu_ctl <= ALUCTL_NOP;
		out.is_branch_jump <= 1'b0;
		out.is_jump <= 1'b0;
		out.is_jump_reg <= 1'b0;
		out.branch_target <= '0;
		out.is_mem_access <= 1'b0;
		out.mem_action <= READ;

		out.uses_rs <= 1'b0;
		out.rs_addr <= zero;

		out.uses_rt <= 1'b0;
		out.rt_addr <= zero;

		out.uses_immediate <= 1'b0;
		out.immediate <= '0;

		out.uses_rw <= 1'b0;
		out.rw_addr <= zero;
		
		out.is_ll <= 1'b0;
		out.is_sc <= 1'b0;
		out.is_sw <= 1'b0;
		
		if (i_inst.valid)
		begin
			case(i_inst.data[31:26])
				6'h0:  //r-type
				begin
					case (i_inst.data[5:0])
						6'h20:  // add
						begin
							out.alu_ctl <= ALUCTL_ADD;
							typical_rtype();
						end

						6'h21:  // addu
						begin
							out.alu_ctl <= ALUCTL_ADDU;
							typical_rtype();
						end

						6'h22:  // sub
						begin
							out.alu_ctl <= ALUCTL_SUB;
							typical_rtype();
						end

						6'h23:  // subu
						begin
							out.alu_ctl <= ALUCTL_SUBU;
							typical_rtype();
						end

						6'h24:  // and
						begin
							out.alu_ctl <= ALUCTL_AND;
							typical_rtype();
						end

						6'h25:  // or
						begin
							out.alu_ctl <= ALUCTL_OR;
							typical_rtype();
						end

						6'h26:  // xor
						begin
							out.alu_ctl <= ALUCTL_XOR;
							typical_rtype();
						end

						6'h27:  // nor
						begin
							out.alu_ctl <= ALUCTL_NOR;
							typical_rtype();
						end

						6'h00:  // sll
						begin
							out.alu_ctl <= ALUCTL_SLL;
							shamt_rtype();
						end

						6'h02:  // srl
						begin
							out.alu_ctl <= ALUCTL_SRL;
							shamt_rtype();
						end

						6'h03:  // sra
						begin
							out.alu_ctl <= ALUCTL_SRA;
							shamt_rtype();
						end

						6'h04:  // sllv
						begin
							out.alu_ctl <= ALUCTL_SLLV;
							typical_rtype();
						end

						6'h06:  // srlv
						begin
							out.alu_ctl <= ALUCTL_SRLV;
							typical_rtype();
						end

						6'h07:  // srav
						begin
							out.alu_ctl <= ALUCTL_SRAV;
							typical_rtype();
						end

						6'h2a:  // slt
						begin
							out.alu_ctl <= ALUCTL_SLT;
							typical_rtype();
						end

						6'h2b:  // sltu
						begin
							out.alu_ctl <= ALUCTL_SLTU;
							typical_rtype();
						end

						6'h08:  // jr
						begin
							out.alu_ctl <= ALUCTL_NOP;	// jr does not use alu
							uses_rs();
							out.is_branch_jump <= 1'b1;
							out.is_jump <= 1'b1;
							out.is_jump_reg <= 1'b1;
						end

						6'h09:  //jalr
						begin
							out.alu_ctl <= ALUCTL_OR;
							uses_rs();
							uses_rw_raw(ra);	// jalr always write to ra (31)
							uses_immediate_raw(32'(unsigned'(i_pc.pc)) + 8);
							out.is_branch_jump <= 1'b1;
							out.is_jump <= 1'b1;
							out.is_jump_reg <= 1'b1;
						end

						6'h18:  // mul
						begin
							$error("%m (%t) mul not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
							out.valid <= 1'b0;
						end

						6'h19:  //mulu
						begin
							$error("%m (%t) mulu not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
							out.valid <= 1'b0;
						end

						6'h1a:  //div
						begin
							$error("%m (%t) div not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
							out.valid <= 1'b0;
						end

						6'h1b:  //divu
						begin
							$error("%m (%t) divu not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
							out.valid <= 1'b0;
						end

						default:
						begin
							$error("%m (%t) unknown R-type funct code %b. Treated as a NOP. PC=0x%x", $time, i_inst.data[5:0], i_pc.pc);
							out.valid <= 1'b0;
						end
					endcase
				end

				6'h08:  		//addi
				begin
					out.alu_ctl <= ALUCTL_ADD;
					signed_extend_itype();
				end

				6'h09:  //addiu
				begin
					out.alu_ctl <= ALUCTL_ADDU;
					signed_extend_itype();
				end

				6'h0c:  //andi
				begin
					out.alu_ctl <= ALUCTL_AND;
					zero_extend_itype();
				end

				6'h0d:  //ori
				begin
					out.alu_ctl <= ALUCTL_OR;
					zero_extend_itype();
				end

				6'h0e:  //xori
				begin
					out.alu_ctl <= ALUCTL_XOR;
					zero_extend_itype();
				end

				6'h0a:  //slti
				begin
					out.alu_ctl <= ALUCTL_SLT;
					signed_extend_itype();
				end

				6'h0b:  //sltiu
				begin
					out.alu_ctl <= ALUCTL_SLTU;
					signed_extend_itype();
				end

				6'h0f:  //lui Implemented as 0 | Immediate
				begin
					out.alu_ctl <= ALUCTL_OR;
					uses_rw_itype();
					uses_immediate_raw({i_inst.data[15:0], 16'h0000});
				end

				6'h04:  //beq
				begin
					out.alu_ctl <= ALUCTL_BEQ;
					uses_rs();
					uses_rt();
					out.is_branch_jump <= 1'b1;
					out.branch_target <= i_pc.pc + `ADDR_WIDTH'd4 + `ADDR_WIDTH'(signed'(i_inst.data[15:0]) << 2);
				end

				6'h05:  //bne
				begin
					out.alu_ctl <= ALUCTL_BNE;
					uses_rs();
					uses_rt();
					out.is_branch_jump <= 1'b1;
					out.branch_target <= i_pc.pc + `ADDR_WIDTH'd4 + `ADDR_WIDTH'(signed'(i_inst.data[15:0]) << 2);
				end

				6'h06:  //blez
				begin
					out.alu_ctl <= ALUCTL_BLEZ;
					uses_rs();
					uses_rt();
					out.is_branch_jump <= 1'b1;
					out.branch_target <= i_pc.pc + `ADDR_WIDTH'd4 + `ADDR_WIDTH'(signed'(i_inst.data[15:0]) << 2);
				end

				6'h01:  //bgez or bltz
				begin
					if( i_inst.data[16] )
						out.alu_ctl <= ALUCTL_BGEZ;
					else
						out.alu_ctl <= ALUCTL_BLTZ;
					uses_rs();
					uses_rt();
					out.is_branch_jump <= 1'b1;
					out.branch_target <= i_pc.pc + `ADDR_WIDTH'd4 + `ADDR_WIDTH'(signed'(i_inst.data[15:0]) << 2);
				end

				6'h07:  //bgtz
				begin
					out.alu_ctl <= ALUCTL_BGTZ;
					uses_rs();
					uses_rt();
					out.is_branch_jump <= 1'b1;
					out.branch_target <= i_pc.pc + `ADDR_WIDTH'd4 + `ADDR_WIDTH'(signed'(i_inst.data[15:0]) << 2);
				end

				6'h02:  // j
				begin
					out.alu_ctl <= ALUCTL_NOP;	// jr does not use alu
					out.is_branch_jump <= 1'b1;
					out.is_jump <= 1'b1;
					out.branch_target <= {i_inst.data[`ADDR_WIDTH - 3: 0], 2'b00};
				end

				6'h03:  // jal
				begin
					out.alu_ctl <= ALUCTL_OR;
					uses_rw_raw(ra);	// jal always write to ra (31)
					uses_immediate_raw(32'(unsigned'(i_pc.pc)) + 8);
					out.is_branch_jump <= 1'b1;
					out.is_jump <= 1'b1;
					out.branch_target <= {i_inst.data[`ADDR_WIDTH - 3: 0], 2'b00};
				end

				6'h20: //lb
				begin
					$error("%m (%t) lb not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
					out.valid <= 1'b0;
				end

				6'h24: //lbu
				begin
					$error("%m (%t) lbu not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
					out.valid <= 1'b0;
				end

				6'h21: //lh
				begin
					$error("%m (%t) lh not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
					out.valid <= 1'b0;
				end

				6'h25: //lhu
				begin
					$error("%m (%t) lhu not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
					out.valid <= 1'b0;
				end

				6'h23: //lw
				begin
					out.alu_ctl <= ALUCTL_ADD;
					out.is_mem_access <= 1'b1;
					out.mem_action <= READ;
					signed_extend_itype();
				end

				6'h28:  //sb
				begin
					$error("%m (%t) sb not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
					out.valid <= 1'b0;
				end

				6'h29:  //sh
				begin
					$error("%m (%t) sh not supported. Treated as a NOP. PC=0x%x", $time, i_pc.pc);
					out.valid <= 1'b0;
				end

				6'h2b:  //sw
				begin
					out.alu_ctl <= ALUCTL_ADD;
					out.is_mem_access <= 1'b1;
					out.is_sw <= 1'b1;
					out.mem_action <= WRITE;
					uses_rs();
					uses_rt();
					uses_immediate_signed_extend();
				end
				
				6'h30: //ll
				begin
					out.alu_ctl <= ALUCTL_ADD;
					out.is_mem_access <= 1'b1;
					out.is_ll <= 1'b1;
					out.mem_action <= READ;
					signed_extend_itype();
				end
				
				6'h38: //sc
				begin
					out.alu_ctl <= ALUCTL_ADD;
					out.is_mem_access <= 1'b1;
					out.is_sc <= 1'b1;
					out.mem_action <= WRITE;
					signed_extend_itype();
				end

				6'h10:  //mtc0
				begin
					case(i_inst.data[15:11])
						5'h17:
						begin
							out.alu_ctl <= ALUCTL_MTCO_PASS;
							uses_rt();
						end

						5'h18:
						begin
							out.alu_ctl <= ALUCTL_MTCO_FAIL;
							uses_rt();
						end

						5'h19:
						begin
							out.alu_ctl <= ALUCTL_MTCO_DONE;
							uses_rt();
						end

						default:
						begin
							$error("%m (%t) unknown MTC0 value 0x%x. Treated as a NOP. PC=0x%x", $time, i_inst.data[15:11], i_pc.pc);
							out.valid <= 1'b0;
						end
					endcase
				end

				default:
				begin
					$error("%m (%t) unknown opcode %b. Treated as a NOP. PC=0x%x", $time, i_inst.data[31:26], i_pc.pc);
					$stop;
					out.valid <= 1'b0;
				end
			endcase
		end
	end
endmodule
