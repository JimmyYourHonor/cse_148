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

    // inputs
    reg_file_output_ifc.in reg_ready,
    decoder_output_ifc.in decoded_insn,
    pc_ifc.in i_pc,

    // outputs
    decoder_output_ifc.out out,
    output logic hazard_flag,

    output logic[3:0] instruction_id, // position in issue_queue
    write_back_ifc.out retired_reg[8]
);

    // issue queue (pending instructions)
    decoder_output_ifc issue_queue[7:0]();

    logic [2:0] head_ptr = 0;
    logic [2:0] tail_ptr = 0;
    logic full = 0;
    logic empty = 1;

    status status_list[8];

    reg_file_output_ifc address_list[7:0]();

    logic found = 0;

    logic[2:0] offset = 0;

    // task for queues: push, pop, and clear
    task push;
        begin
            if (full == 0) begin

                issue_queue[tail_ptr].valid <= decoded_insn.valid;
                issue_queue[tail_ptr].alu_ctl <= decoded_insn.alu_ctl;
                issue_queue[tail_ptr].is_branch_jump <= decoded_insn.is_branch_jump;
                issue_queue[tail_ptr].is_jump <= decoded_insn.is_jump;
                issue_queue[tail_ptr].is_jump_reg <= decoded_insn.is_jump_reg;
                issue_queue[tail_ptr].branch_target <= decoded_insn.branch_target;
                issue_queue[tail_ptr].is_mem_access <= decoded_insn.is_mem_access;
                issue_queue[tail_ptr].mem_action <= decoded_insn.mem_action;

                issue_queue[tail_ptr].uses_rs <= decoded_insn.uses_rs;
                issue_queue[tail_ptr].rs_addr <= decoded_insn.rs_addr;
                issue_queue[tail_ptr].uses_rt <= decoded_insn.uses_rt;
                issue_queue[tail_ptr].rt_addr <= decoded_insn.rt_addr;
                issue_queue[tail_ptr].uses_rw <= decoded_insn.uses_rw;
                issue_queue[tail_ptr].rw_addr <= decoded_insn.rw_addr;

                issue_queue[tail_ptr].uses_immediate <= decoded_insn.uses_immediate;
                issue_queue[tail_ptr].immediate <= decoded_insn.immediate;
                issue_queue[tail_ptr].is_ll <= decoded_insn.is_ll;
                issue_queue[tail_ptr].is_sc <= decoded_insn.is_sc;
                issue_queue[tail_ptr].is_sw <= decoded_insn.is_sw;

                status_list[tail_ptr] <= free_list[address_list[tail_ptr].rs_addr] & free_list[address_list[tail_ptr].rt_addr];
                tail_ptr <= tail_ptr + 1;
                if (head_ptr == tail_ptr) full <= 1;

            end
        end
    endtask

    task find;
        begin
            if (empty == 0) begin
                found <= 1;
                if (status_list[head_ptr] == ready) begin
                    offset <= 0;
                    status_list[head_ptr] <= executing;
                end
                else if (tail_ptr >= head_ptr + 1 && status_list[head_ptr + 1] == ready) begin
                    offset <= 1;
                    status_list[head_ptr + 1] <= executing;
                end
                else if (tail_ptr >= head_ptr + 2 && status_list[head_ptr + 2] == ready) begin
                    offset <= 2;
                    status_list[head_ptr + 2] <= executing;
                end
                else if (tail_ptr >= head_ptr + 3 && status_list[head_ptr + 3] == ready) begin
                    offset <= 3;
                    status_list[head_ptr + 3] <= executing;
                end
                else if (tail_ptr >= head_ptr + 4 && status_list[head_ptr + 4] == ready) begin
                    offset <= 4;
                    status_list[head_ptr + 4] <= executing;
                end
                else if (tail_ptr >= head_ptr + 5 && status_list[head_ptr + 5] == ready) begin
                    offset <= 5;
                    status_list[head_ptr + 5] <= executing;
                end
                else if (tail_ptr >= head_ptr + 6 && status_list[head_ptr + 6] == ready) begin
                    offset <= 6;
                    status_list[head_ptr + 6] <= executing;
                end
                else if (tail_ptr >= head_ptr + 7 && status_list[head_ptr + 7] == ready) begin
                    offset <= 7;
                    status_list[head_ptr + 7] <= executing;
                end
                else begin
                    found <= 0;
                end

                if (found == 1) begin

                    out.valid <= issue_queue[head_ptr + offset].valid;
                    out.alu_ctl <= issue_queue[head_ptr + offset].alu_ctl;
                    out.is_branch_jump <= issue_queue[head_ptr + offset].is_branch_jump;
                    out.is_jump <= issue_queue[head_ptr + offset].is_jump;
                    out.is_jump_reg <= issue_queue[head_ptr + offset].is_jump_reg;
                    out.is_mem_access <= issue_queue[head_ptr + offset].is_mem_access;
                    out.branch_target <= issue_queue[head_ptr + offset].branch_target;
                    out.mem_action <= issue_queue[head_ptr + offset].mem_action;

                    out.uses_rs <= issue_queue[head_ptr + offset].uses_rs;
                    out.rs_addr <= issue_queue[head_ptr + offset].rs_addr;
                    out.uses_rt <= issue_queue[head_ptr + offset].uses_rt;
                    out.rt_addr <= issue_queue[head_ptr + offset].rt_addr;
                    out.uses_rw <= issue_queue[head_ptr + offset].uses_rw;
                    out.rw_addr <= issue_queue[head_ptr + offset].rw_addr;

                    out.uses_immediate <= issue_queue[head_ptr + offset].uses_immediate;
                    out.immediate <= issue_queue[head_ptr + offset].immediate;
                    out.is_ll <= issue_queue[head_ptr + offset].is_ll;
                    out.is_sc <= issue_queue[head_ptr + offset].is_sc;
                    out.is_sw <= issue_queue[head_ptr + offset].is_sw;


                end

            end
            else begin
                found <= 0;
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

    // retires instructions in order TODO
    task retire();
        begin
            for(int i = 0; i < 8; i++)
            begin
                if(status_list[head_ptr] == done)
                begin
                    head_ptr <= head_ptr + 1;
                    retired_reg[i].uses_rw <= issue_queue[head_ptr].uses_rw;
                    retired_reg[i].rw_addr <= address_list[head_ptr].rw_addr;
                end
            end
        end
    endtask

    always_ff @(posedge clk) begin

        push(); // add decoded instruction to queue
        
        find(); // find next instruction to execute

        // hazard
        if (full) begin
            hazard_flag <= 1;
        end
        else begin
            hazard_flag <= 0;
        end

        if (found == 0) begin
            out.alu_ctrl <= ALUCTL_NOP;
            out.valid <= 1;
        end

    end

    always_comb begin
        if (empty == 0) begin

            if (status_list[head_ptr] == not_ready) begin
                if (free_list[address_list[head_ptr].rs_addr] == 1 & free_list[address_list[head_ptr].rt_addr] == 1) begin
                    status_list[head_ptr] = ready;
                end
            end
            else if (tail_ptr >= head_ptr + 1 & status_list[head_ptr + 1] == not_ready) begin
                if (free_list[address_list[head_ptr + 1].rs_addr] == 1 & free_list[address_list[head_ptr + 1].rt_addr] == 1) begin
                    status_list[head_ptr + 1] = ready;
                end
            end
            else if (tail_ptr >= head_ptr + 2 & status_list[head_ptr + 2] == not_ready) begin
                if (free_list[address_list[head_ptr + 2].rs_addr] == 1 & free_list[address_list[head_ptr + 2].rt_addr] == 1) begin
                    status_list[head_ptr + 2] = ready;
                end
            end
            else if (tail_ptr >= head_ptr + 3 & status_list[head_ptr + 3] == not_ready) begin
                if (free_list[address_list[head_ptr + 3].rs_addr] == 1 & free_list[address_list[head_ptr + 3].rt_addr] == 1) begin
                    status_list[head_ptr + 3] = ready;
                end
            end
            else if (tail_ptr >= head_ptr + 4 & status_list[head_ptr + 4] == not_ready) begin
                if (free_list[address_list[head_ptr + 4].rs_addr] == 1 & free_list[address_list[head_ptr + 4].rt_addr] == 1) begin
                    status_list[head_ptr + 4] = ready;
                end
            end
            else if (tail_ptr >= head_ptr + 5 & status_list[head_ptr + 5] == not_ready) begin
                if (free_list[address_list[head_ptr + 5].rs_addr] == 1 & free_list[address_list[head_ptr + 5].rt_addr] == 1) begin
                    status_list[head_ptr + 5] = ready;
                end
            end
            else if (tail_ptr >= head_ptr + 6 & status_list[head_ptr + 6] == not_ready) begin
                if (free_list[address_list[head_ptr + 6].rs_addr] == 1 & free_list[address_list[head_ptr + 6].rt_addr] == 1) begin
                    status_list[head_ptr + 6] = ready;
                end
            end
            else if (tail_ptr >= head_ptr + 7 & status_list[head_ptr + 7] == not_ready) begin
                if (free_list[address_list[head_ptr + 7].rs_addr] == 1 & free_list[address_list[head_ptr + 7].rt_addr] == 1) begin
                    status_list[head_ptr + 7] = ready;
                end
            end
        end
    end

endmodule