`include "mips_core.svh"

typedef enum logic [1:0] {
    not_ready = 2'b00,
    ready = 2'b01,
    executing = 2'b10,
    done = 2'b11
} status;

module ooo_buffer (
    input clk,

    input logic free_list [64],

    // inputs - from decoder stage
    reg_file_output_ifc.in reg_ready,
    decoder_output_ifc.in decoded_insn,
    pc_ifc.in i_pc,

    // from execution glue stage
    input logic[19:0] instruction_id_in,
    branch_result_ifc.in branch_result,

    // for retiring instructions
    alu_output_ifc alu_result,
    input logic[19:0] instruction_id_alu,

    // outputs
    decoder_output_ifc.out out,
    output logic hazard_flag,

    output logic[19:0] instruction_id_out, // position in issue_queue
    output logic[5:0] retired_rw,
    output logic retired_uses_rw,
    output logic retired,
    output logic[19:0] instruction_id_retired
);

    // issue queue (pending instructions)
    decoder_output_ifc issue_queue[7:0]();

    logic [19:0] instruction_id = 0;

    logic [2:0] head_ptr = 0;
    logic [2:0] tail_ptr = 0;
    logic full = 0;
    logic empty = 1;

    status status_list[8] = '{not_ready, not_ready, not_ready, not_ready, not_ready, not_ready, not_ready, not_ready};

    //reg_file_output_ifc address_list[7:0]();
    
    logic [5:0] rs_addr[7:0];
	logic [5:0] rt_addr[7:0];
	logic [5:0] rw_addr[7:0];



    // task for queues: push, pop, and clear
    task push;
        begin
            if (full == 0) begin
                case(tail_ptr)
                0: 
                begin
                    issue_queue[0].valid <= decoded_insn.valid;
                    issue_queue[0].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[0].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[0].is_jump <= decoded_insn.is_jump;
                    issue_queue[0].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[0].branch_target <= decoded_insn.branch_target;
                    issue_queue[0].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[0].mem_action <= decoded_insn.mem_action;

                    issue_queue[0].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[0].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[0].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[0].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[0].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[0].rw_addr <= decoded_insn.rw_addr;

                    issue_queue[0].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[0].immediate <= decoded_insn.immediate;
                    issue_queue[0].is_ll <= decoded_insn.is_ll;
                    issue_queue[0].is_sc <= decoded_insn.is_sc;
                    issue_queue[0].is_sw <= decoded_insn.is_sw;
                end
                1:
                begin
                    issue_queue[1].valid <= decoded_insn.valid;
                    issue_queue[1].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[1].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[1].is_jump <= decoded_insn.is_jump;
                    issue_queue[1].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[1].branch_target <= decoded_insn.branch_target;
                    issue_queue[1].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[1].mem_action <= decoded_insn.mem_action;

                    issue_queue[1].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[1].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[1].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[1].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[1].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[1].rw_addr <= decoded_insn.rw_addr;

                    issue_queue[1].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[1].immediate <= decoded_insn.immediate;
                    issue_queue[1].is_ll <= decoded_insn.is_ll;
                    issue_queue[1].is_sc <= decoded_insn.is_sc;
                    issue_queue[1].is_sw <= decoded_insn.is_sw;

                end
                2:
                begin
                    issue_queue[2].valid <= decoded_insn.valid;
                    issue_queue[2].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[2].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[2].is_jump <= decoded_insn.is_jump;
                    issue_queue[2].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[2].branch_target <= decoded_insn.branch_target;
                    issue_queue[2].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[2].mem_action <= decoded_insn.mem_action;

                    issue_queue[2].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[2].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[2].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[2].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[2].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[2].rw_addr <= decoded_insn.rw_addr;

                    issue_queue[2].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[2].immediate <= decoded_insn.immediate;
                    issue_queue[2].is_ll <= decoded_insn.is_ll;
                    issue_queue[2].is_sc <= decoded_insn.is_sc;
                    issue_queue[2].is_sw <= decoded_insn.is_sw;

                end
                3:
                begin
                    issue_queue[3].valid <= decoded_insn.valid;
                    issue_queue[3].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[3].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[3].is_jump <= decoded_insn.is_jump;
                    issue_queue[3].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[3].branch_target <= decoded_insn.branch_target;
                    issue_queue[3].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[3].mem_action <= decoded_insn.mem_action;

                    issue_queue[3].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[3].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[3].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[3].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[3].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[3].rw_addr <= decoded_insn.rw_addr;

                    issue_queue[3].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[3].immediate <= decoded_insn.immediate;
                    issue_queue[3].is_ll <= decoded_insn.is_ll;
                    issue_queue[3].is_sc <= decoded_insn.is_sc;
                    issue_queue[3].is_sw <= decoded_insn.is_sw;

                end
                4:
                begin
                    issue_queue[4].valid <= decoded_insn.valid;
                    issue_queue[4].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[4].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[4].is_jump <= decoded_insn.is_jump;
                    issue_queue[4].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[4].branch_target <= decoded_insn.branch_target;
                    issue_queue[4].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[4].mem_action <= decoded_insn.mem_action;
                    issue_queue[4].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[4].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[4].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[4].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[4].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[4].rw_addr <= decoded_insn.rw_addr;
                    issue_queue[4].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[4].immediate <= decoded_insn.immediate;
                    issue_queue[4].is_ll <= decoded_insn.is_ll;
                    issue_queue[4].is_sc <= decoded_insn.is_sc;
                    issue_queue[4].is_sw <= decoded_insn.is_sw;

                end
                5:
                begin
                    issue_queue[5].valid <= decoded_insn.valid;
                    issue_queue[5].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[5].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[5].is_jump <= decoded_insn.is_jump;
                    issue_queue[5].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[5].branch_target <= decoded_insn.branch_target;
                    issue_queue[5].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[5].mem_action <= decoded_insn.mem_action;
                    issue_queue[5].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[5].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[5].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[5].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[5].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[5].rw_addr <= decoded_insn.rw_addr;
                    issue_queue[5].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[5].immediate <= decoded_insn.immediate;
                    issue_queue[5].is_ll <= decoded_insn.is_ll;
                    issue_queue[5].is_sc <= decoded_insn.is_sc;
                    issue_queue[5].is_sw <= decoded_insn.is_sw;

                end
                6:
                begin
                    issue_queue[6].valid <= decoded_insn.valid;
                    issue_queue[6].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[6].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[6].is_jump <= decoded_insn.is_jump;
                    issue_queue[6].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[6].branch_target <= decoded_insn.branch_target;
                    issue_queue[6].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[6].mem_action <= decoded_insn.mem_action;
                    issue_queue[6].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[6].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[6].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[6].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[6].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[6].rw_addr <= decoded_insn.rw_addr;
                    issue_queue[6].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[6].immediate <= decoded_insn.immediate;
                    issue_queue[6].is_ll <= decoded_insn.is_ll;
                    issue_queue[6].is_sc <= decoded_insn.is_sc;
                    issue_queue[6].is_sw <= decoded_insn.is_sw;

                end
                7:
                begin
                    issue_queue[7].valid <= decoded_insn.valid;
                    issue_queue[7].alu_ctl <= decoded_insn.alu_ctl;
                    issue_queue[7].is_branch_jump <= decoded_insn.is_branch_jump;
                    issue_queue[7].is_jump <= decoded_insn.is_jump;
                    issue_queue[7].is_jump_reg <= decoded_insn.is_jump_reg;
                    issue_queue[7].branch_target <= decoded_insn.branch_target;
                    issue_queue[7].is_mem_access <= decoded_insn.is_mem_access;
                    issue_queue[7].mem_action <= decoded_insn.mem_action;
                    issue_queue[7].uses_rs <= decoded_insn.uses_rs;
                    issue_queue[7].rs_addr <= decoded_insn.rs_addr;
                    issue_queue[7].uses_rt <= decoded_insn.uses_rt;
                    issue_queue[7].rt_addr <= decoded_insn.rt_addr;
                    issue_queue[7].uses_rw <= decoded_insn.uses_rw;
                    issue_queue[7].rw_addr <= decoded_insn.rw_addr;
                    issue_queue[7].uses_immediate <= decoded_insn.uses_immediate;
                    issue_queue[7].immediate <= decoded_insn.immediate;
                    issue_queue[7].is_ll <= decoded_insn.is_ll;
                    issue_queue[7].is_sc <= decoded_insn.is_sc;
                    issue_queue[7].is_sw <= decoded_insn.is_sw;

                end
                endcase

                rs_addr[tail_ptr] = reg_ready.rs_addr;
                rt_addr[tail_ptr] = reg_ready.rt_addr;
                rw_addr[tail_ptr] = reg_ready.rw_addr;

                status_list[7] <= free_list[rs_addr[tail_ptr]] & free_list[rt_addr[tail_ptr]] ? ready : not_ready;

                tail_ptr <= tail_ptr + 1;
                if (head_ptr == tail_ptr) full <= 1;

            end
        end
    endtask

    task find;
        begin
            if (empty == 0) begin
                
                if (status_list[head_ptr] == ready) begin
                    status_list[head_ptr] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else if (tail_ptr >= head_ptr + 1 && status_list[head_ptr + 1] == ready) begin
                    status_list[head_ptr + 1] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr + 1)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else if (tail_ptr >= head_ptr + 2 && status_list[head_ptr + 2] == ready) begin
                    status_list[head_ptr + 2] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr + 2)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else if (tail_ptr >= head_ptr + 3 && status_list[head_ptr + 3] == ready) begin
                    status_list[head_ptr + 3] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr + 3)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else if (tail_ptr >= head_ptr + 4 && status_list[head_ptr + 4] == ready) begin
                    status_list[head_ptr + 4] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr + 4)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else if (tail_ptr >= head_ptr + 5 && status_list[head_ptr + 5] == ready) begin
                    status_list[head_ptr + 5] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr + 5)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else if (tail_ptr >= head_ptr + 6 && status_list[head_ptr + 6] == ready) begin
                    status_list[head_ptr + 6] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr + 6)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else if (tail_ptr >= head_ptr + 7 && status_list[head_ptr + 7] == ready) begin
                    status_list[head_ptr + 7] <= executing;
                    instruction_id <= instruction_id + 1;
                    instruction_id_out <= instruction_id;

                    case (head_ptr + 7)
                    0:
                    begin
                        out.valid           <= issue_queue[0].valid;
                        out.alu_ctl         <= issue_queue[0].alu_ctl;
                        out.is_branch_jump  <= issue_queue[0].is_branch_jump;
                        out.is_jump         <= issue_queue[0].is_jump;
                        out.is_jump_reg     <= issue_queue[0].is_jump_reg;
                        out.is_mem_access   <= issue_queue[0].is_mem_access;
                        out.branch_target   <= issue_queue[0].branch_target;
                        out.mem_action      <= issue_queue[0].mem_action;

                        out.uses_rs <= issue_queue[0].uses_rs;
                        out.rs_addr <= issue_queue[0].rs_addr;
                        out.uses_rt <= issue_queue[0].uses_rt;
                        out.rt_addr <= issue_queue[0].rt_addr;
                        out.uses_rw <= issue_queue[0].uses_rw;
                        out.rw_addr <= issue_queue[0].rw_addr;

                        out.uses_immediate  <= issue_queue[0].uses_immediate;
                        out.immediate       <= issue_queue[0].immediate;

                        out.is_ll <= issue_queue[0].is_ll;
                        out.is_sc <= issue_queue[0].is_sc;
                        out.is_sw <= issue_queue[0].is_sw;
                    end
                    1:
                    begin
                        out.valid           <= issue_queue[1].valid;
                        out.alu_ctl         <= issue_queue[1].alu_ctl;
                        out.is_branch_jump  <= issue_queue[1].is_branch_jump;
                        out.is_jump         <= issue_queue[1].is_jump;
                        out.is_jump_reg     <= issue_queue[1].is_jump_reg;
                        out.is_mem_access   <= issue_queue[1].is_mem_access;
                        out.branch_target   <= issue_queue[1].branch_target;
                        out.mem_action      <= issue_queue[1].mem_action;

                        out.uses_rs <= issue_queue[1].uses_rs;
                        out.rs_addr <= issue_queue[1].rs_addr;
                        out.uses_rt <= issue_queue[1].uses_rt;
                        out.rt_addr <= issue_queue[1].rt_addr;
                        out.uses_rw <= issue_queue[1].uses_rw;
                        out.rw_addr <= issue_queue[1].rw_addr;

                        out.uses_immediate  <= issue_queue[1].uses_immediate;
                        out.immediate       <= issue_queue[1].immediate;

                        out.is_ll <= issue_queue[1].is_ll;
                        out.is_sc <= issue_queue[1].is_sc;
                        out.is_sw <= issue_queue[1].is_sw;
                    end
                    2:
                    begin
                        out.valid           <= issue_queue[2].valid;
                        out.alu_ctl         <= issue_queue[2].alu_ctl;
                        out.is_branch_jump  <= issue_queue[2].is_branch_jump;
                        out.is_jump         <= issue_queue[2].is_jump;
                        out.is_jump_reg     <= issue_queue[2].is_jump_reg;
                        out.is_mem_access   <= issue_queue[2].is_mem_access;
                        out.branch_target   <= issue_queue[2].branch_target;
                        out.mem_action      <= issue_queue[2].mem_action;

                        out.uses_rs <= issue_queue[2].uses_rs;
                        out.rs_addr <= issue_queue[2].rs_addr;
                        out.uses_rt <= issue_queue[2].uses_rt;
                        out.rt_addr <= issue_queue[2].rt_addr;
                        out.uses_rw <= issue_queue[2].uses_rw;
                        out.rw_addr <= issue_queue[2].rw_addr;

                        out.uses_immediate  <= issue_queue[2].uses_immediate;
                        out.immediate       <= issue_queue[2].immediate;

                        out.is_ll <= issue_queue[2].is_ll;
                        out.is_sc <= issue_queue[2].is_sc;
                        out.is_sw <= issue_queue[2].is_sw;
                    end
                    3:
                    begin
                        out.valid           <= issue_queue[3].valid;
                        out.alu_ctl         <= issue_queue[3].alu_ctl;
                        out.is_branch_jump  <= issue_queue[3].is_branch_jump;
                        out.is_jump         <= issue_queue[3].is_jump;
                        out.is_jump_reg     <= issue_queue[3].is_jump_reg;
                        out.is_mem_access   <= issue_queue[3].is_mem_access;
                        out.branch_target   <= issue_queue[3].branch_target;
                        out.mem_action      <= issue_queue[3].mem_action;

                        out.uses_rs <= issue_queue[3].uses_rs;
                        out.rs_addr <= issue_queue[3].rs_addr;
                        out.uses_rt <= issue_queue[3].uses_rt;
                        out.rt_addr <= issue_queue[3].rt_addr;
                        out.uses_rw <= issue_queue[3].uses_rw;
                        out.rw_addr <= issue_queue[3].rw_addr;

                        out.uses_immediate  <= issue_queue[3].uses_immediate;
                        out.immediate       <= issue_queue[3].immediate;

                        out.is_ll <= issue_queue[3].is_ll;
                        out.is_sc <= issue_queue[3].is_sc;
                        out.is_sw <= issue_queue[3].is_sw;
                    end
                    4:
                    begin
                        out.valid           <= issue_queue[4].valid;
                        out.alu_ctl         <= issue_queue[4].alu_ctl;
                        out.is_branch_jump  <= issue_queue[4].is_branch_jump;
                        out.is_jump         <= issue_queue[4].is_jump;
                        out.is_jump_reg     <= issue_queue[4].is_jump_reg;
                        out.is_mem_access   <= issue_queue[4].is_mem_access;
                        out.branch_target   <= issue_queue[4].branch_target;
                        out.mem_action      <= issue_queue[4].mem_action;

                        out.uses_rs <= issue_queue[4].uses_rs;
                        out.rs_addr <= issue_queue[4].rs_addr;
                        out.uses_rt <= issue_queue[4].uses_rt;
                        out.rt_addr <= issue_queue[4].rt_addr;
                        out.uses_rw <= issue_queue[4].uses_rw;
                        out.rw_addr <= issue_queue[4].rw_addr;

                        out.uses_immediate  <= issue_queue[4].uses_immediate;
                        out.immediate       <= issue_queue[4].immediate;

                        out.is_ll <= issue_queue[4].is_ll;
                        out.is_sc <= issue_queue[4].is_sc;
                        out.is_sw <= issue_queue[4].is_sw;   
                    end
                    5:
                    begin
                        out.valid <= issue_queue[5].valid;
                        out.alu_ctl <= issue_queue[5].alu_ctl;
                        out.is_branch_jump <= issue_queue[5].is_branch_jump;
                        out.is_jump <= issue_queue[5].is_jump;
                        out.is_jump_reg <= issue_queue[5].is_jump_reg;
                        out.is_mem_access <= issue_queue[5].is_mem_access;
                        out.branch_target <= issue_queue[5].branch_target;
                        out.mem_action <= issue_queue[5].mem_action;

                        out.uses_rs <= issue_queue[5].uses_rs;
                        out.rs_addr <= issue_queue[5].rs_addr;
                        out.uses_rt <= issue_queue[5].uses_rt;
                        out.rt_addr <= issue_queue[5].rt_addr;
                        out.uses_rw <= issue_queue[5].uses_rw;
                        out.rw_addr <= issue_queue[5].rw_addr;

                        out.uses_immediate <= issue_queue[5].uses_immediate;
                        out.immediate <= issue_queue[5].immediate;
                        out.is_ll <= issue_queue[5].is_ll;
                        out.is_sc <= issue_queue[5].is_sc;
                        out.is_sw <= issue_queue[5].is_sw;
                    end
                    6:
                    begin
                        out.valid           <= issue_queue[6].valid;
                        out.alu_ctl         <= issue_queue[6].alu_ctl;
                        out.is_branch_jump  <= issue_queue[6].is_branch_jump;
                        out.is_jump         <= issue_queue[6].is_jump;
                        out.is_jump_reg     <= issue_queue[6].is_jump_reg;
                        out.is_mem_access   <= issue_queue[6].is_mem_access;
                        out.branch_target   <= issue_queue[6].branch_target;
                        out.mem_action      <= issue_queue[6].mem_action;

                        out.uses_rs <= issue_queue[6].uses_rs;
                        out.rs_addr <= issue_queue[6].rs_addr;
                        out.uses_rt <= issue_queue[6].uses_rt;
                        out.rt_addr <= issue_queue[6].rt_addr;
                        out.uses_rw <= issue_queue[6].uses_rw;
                        out.rw_addr <= issue_queue[6].rw_addr;

                        out.uses_immediate  <= issue_queue[6].uses_immediate;
                        out.immediate       <= issue_queue[6].immediate;

                        out.is_ll <= issue_queue[6].is_ll;
                        out.is_sc <= issue_queue[6].is_sc;
                        out.is_sw <= issue_queue[6].is_sw;   
                    end
                    7:
                    begin
                        out.valid           <= issue_queue[7].valid;
                        out.alu_ctl         <= issue_queue[7].alu_ctl;
                        out.is_branch_jump  <= issue_queue[7].is_branch_jump;
                        out.is_jump         <= issue_queue[7].is_jump;
                        out.is_jump_reg     <= issue_queue[7].is_jump_reg;
                        out.is_mem_access   <= issue_queue[7].is_mem_access;
                        out.branch_target   <= issue_queue[7].branch_target;
                        out.mem_action      <= issue_queue[7].mem_action;

                        out.uses_rs <= issue_queue[7].uses_rs;
                        out.rs_addr <= issue_queue[7].rs_addr;
                        out.uses_rt <= issue_queue[7].uses_rt;
                        out.rt_addr <= issue_queue[7].rt_addr;
                        out.uses_rw <= issue_queue[7].uses_rw;
                        out.rw_addr <= issue_queue[7].rw_addr;

                        out.uses_immediate  <= issue_queue[7].uses_immediate;
                        out.immediate       <= issue_queue[7].immediate;

                        out.is_ll <= issue_queue[7].is_ll;
                        out.is_sc <= issue_queue[7].is_sc;
                        out.is_sw <= issue_queue[7].is_sw;  
                    end

                    endcase
                end
                else begin
                    out.alu_ctl <= ALUCTL_NOP;
                    out.valid <= 1;
                end
            end
            else begin
                out.alu_ctl <= ALUCTL_NOP;
                out.valid <= 1;
            end
        end
    endtask

    // clear from index to end of queue (for branch mispredicts)
    task clear(logic [2:0] index);
        begin
            tail_ptr <= index;
            full <= 0;
            if (tail_ptr == head_ptr) empty <= 1;
        end
    endtask

    // retires instructions in order
    task retire();
        begin
            status_list[tail_ptr - (instruction_id - instruction_id_alu)] <= done;

            if (status_list[head_ptr] == done) begin
                retired <= 1'b1;
                instruction_id_retired <= instruction_id_alu;
                case (head_ptr)
                0:
                begin
                    retired_uses_rw <= issue_queue[0].uses_rw;
                    retired_rw <= rw_addr[0];
                end
                1:
                begin
                    retired_uses_rw <= issue_queue[1].uses_rw;
                    retired_rw <= rw_addr[1];
                end
                2:
                begin
                    retired_uses_rw <= issue_queue[2].uses_rw;
                    retired_rw <= rw_addr[2];
                end
                3:
                begin
                    retired_uses_rw <= issue_queue[3].uses_rw;
                    retired_rw <= rw_addr[3];
                end
                4:
                begin
                    retired_uses_rw <= issue_queue[4].uses_rw;
                    retired_rw <= rw_addr[4];
                end
                5:
                begin
                    retired_uses_rw <= issue_queue[5].uses_rw;
                    retired_rw <= rw_addr[5];
                end
                6:
                begin
                    retired_uses_rw <= issue_queue[6].uses_rw;
                    retired_rw <= rw_addr[6];
                end
                7:
                begin
                    retired_uses_rw <= issue_queue[7].uses_rw;
                    retired_rw <= rw_addr[7];
                end
                endcase

                head_ptr <= head_ptr + 1;
            end
            else
            begin
                retired <= 1'b0;
                instruction_id_retired <= 0;
                head_ptr <= head_ptr;
            end
        end
    endtask

    always_ff @(posedge clk) begin

        push(); // add decoded instruction to queue

        // branch mispredicts
        if (branch_result.valid && branch_result.prediction != branch_result.outcome) begin
            tail_ptr <= head_ptr - (instruction_id - instruction_id_in);
        end
        
        find(); // find next instruction to execute

        // hazard
        if (full) begin
            hazard_flag <= 1;
        end
        else begin
            hazard_flag <= 0;
        end

        retire();

        if (empty == 0) begin

            if (status_list[head_ptr] == not_ready) begin
                if (free_list[rs_addr[head_ptr]] == 1 & free_list[rt_addr[head_ptr]] == 1) begin
                    status_list[head_ptr] <= ready;
                end
            end
            else if (tail_ptr >= head_ptr + 1 & status_list[head_ptr + 1] == not_ready) begin
                if (free_list[rs_addr[head_ptr + 1]] == 1 & free_list[rt_addr[head_ptr + 1]] == 1) begin
                    status_list[head_ptr + 1] <= ready;
                end
            end
            else if (tail_ptr >= head_ptr + 2 & status_list[head_ptr + 2] == not_ready) begin
                if (free_list[rs_addr[head_ptr + 2]] == 1 & free_list[rt_addr[head_ptr + 2]] == 1) begin
                    status_list[head_ptr + 2] <= ready;
                end
            end
            else if (tail_ptr >= head_ptr + 3 & status_list[head_ptr + 3] == not_ready) begin
                if (free_list[rs_addr[head_ptr + 3]] == 1 & free_list[rt_addr[head_ptr + 3]] == 1) begin
                    status_list[head_ptr + 3] <= ready;
                end
            end
            else if (tail_ptr >= head_ptr + 4 & status_list[head_ptr + 4] == not_ready) begin
                if (free_list[rs_addr[head_ptr + 4]] == 1 & free_list[rt_addr[head_ptr + 4]] == 1) begin
                    status_list[head_ptr + 4] <= ready;
                end
            end
            else if (tail_ptr >= head_ptr + 5 & status_list[head_ptr + 5] == not_ready) begin
                if (free_list[rs_addr[head_ptr + 5]] == 1 & free_list[rt_addr[head_ptr + 5]] == 1) begin
                    status_list[head_ptr + 5] <= ready;
                end
            end
            else if (tail_ptr >= head_ptr + 6 & status_list[head_ptr + 6] == not_ready) begin
                if (free_list[rs_addr[head_ptr + 6]] == 1 & free_list[rt_addr[head_ptr + 6]] == 1) begin
                    status_list[head_ptr + 6] <= ready;
                end
            end
            else if (tail_ptr >= head_ptr + 7 & status_list[head_ptr + 7] == not_ready) begin
                if (free_list[rs_addr[head_ptr + 7]] == 1 & free_list[rt_addr[head_ptr + 7]] == 1) begin
                    status_list[head_ptr + 7] <= ready;
                end
            end
        end

    end
        

endmodule
