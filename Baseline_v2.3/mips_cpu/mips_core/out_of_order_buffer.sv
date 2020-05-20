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
    decoder_output_ifc issue_queue[8]();

    logic [2:0] head_ptr = 0;
    logic [2:0] tail_ptr = 0;
    logic full = 0;
    logic empty = 1;

    status status_list[8];

    reg_file_output_ifc address_list[8]();

    // task for queues: push, pop, and clear
    task push(decoder_output_ifc.in insn_in);
        begin
            if (full == 0) begin
                issue_queue[tail_ptr] <= insn_in;
                status_list[tail_ptr] <= free_list[address_list[tail_ptr].rs_addr] & free_list[address_list[tail_ptr].rt_addr];
                tail_ptr <= tail_ptr + 1;
                if (head_ptr == tail_ptr) full <= 1;

            end
        end
    endtask

    task find(output decoder_output_ifc insn_out, output logic found);
        begin
            if (empty == 0) begin
                found <= 1;
                if (status_list[head_ptr] == status.ready) begin
                    insn_out <= issue_queue[head_ptr];
                    status_list[head_ptr] <= status.executing;
                end
                else if (tail_ptr >= head_ptr + 1 && status_list[head_ptr + 1] == status.ready) begin
                    insn_out <= issue_queue[head_ptr + 1];
                    status_list[head_ptr + 1] <= status.executing;
                end
                else if (tail_ptr >= head_ptr + 2 && status_list[head_ptr + 2] == status.ready) begin
                    insn_out <= issue_queue[head_ptr + 2];
                    status_list[head_ptr + 2] <= status.executing;
                end
                else if (tail_ptr >= head_ptr + 3 && status_list[head_ptr + 3] == status.ready) begin
                    insn_out <= issue_queue[head_ptr + 3];
                    status_list[head_ptr + 3] <= status.executing;
                end
                else if (tail_ptr >= head_ptr + 4 && status_list[head_ptr + 4] == status.ready) begin
                    insn_out <= issue_queue[head_ptr + 4];
                    status_list[head_ptr + 4] <= status.executing;
                end
                else if (tail_ptr >= head_ptr + 5 && status_list[head_ptr + 5] == status.ready) begin
                    insn_out <= issue_queue[head_ptr + 5];
                    status_list[head_ptr + 5] <= status.executing;
                end
                else if (tail_ptr >= head_ptr + 6 && status_list[head_ptr + 6] == status.ready) begin
                    insn_out <= issue_queue[head_ptr + 6];
                    status_list[head_ptr + 6] <= status.executing;
                end
                else if (tail_ptr >= head_ptr + 7 && status_list[head_ptr + 7] == status.ready) begin
                    insn_out <= issue_queue[head_ptr + 7];
                    status_list[head_ptr + 7] <= status.executing;
                end
                else begin
                    found <= 0;
                end

            end
            else begin
                found <= 0;
            end
        end
    endtask

    // clear from index to end of queue (for branch mispredicts)
    task clear(input logic [2:0] index);
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
                if(status_list[head_ptr] == status.done)
                begin
                    head_ptr <= head_ptr + 1;
                    retired_reg[i].uses_rw <= issue_queue[head_ptr].uses_rw;
                    retired_reg[i].rw_addr <= address_list[head_ptr].rw_addr;
                end
            end
        end
    endtask

    always_ff @(posedge clk) begin

        logic found;
        decoder_output_ifc found_insn;

        instruction_id <= tail_ptr;

        push(decoded_insn); // add decoded instruction to queue

        find(found_insn, found); // find next instruction to execute

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

        else begin
            out <= found_insn;
        end

    end

    always_comb begin
        if (empty == 0) begin

            if (status_list[head_ptr] == status.not_ready) begin
                if (free_list[address_list[head_ptr].rs_addr] == 1 & free_list[address_list[head_ptr].rt_addr] == 1) begin
                    status_list[head_ptr] = status.ready;
                end
            end
            else if (tail_ptr >= head_ptr + 1 & status_list[head_ptr + 1] == status.not_ready) begin
                if (free_list[address_list[head_ptr + 1].rs_addr] == 1 & free_list[address_list[head_ptr + 1].rt_addr] == 1) begin
                    status_list[head_ptr + 1] = status.ready;
                end
            end
            else if (tail_ptr >= head_ptr + 2 & status_list[head_ptr + 2] == status.not_ready) begin
                if (free_list[address_list[head_ptr + 2].rs_addr] == 1 & free_list[address_list[head_ptr + 2].rt_addr] == 1) begin
                    status_list[head_ptr + 2] = status.ready;
                end
            end
            else if (tail_ptr >= head_ptr + 3 & status_list[head_ptr + 3] == status.not_ready) begin
                if (free_list[address_list[head_ptr + 3].rs_addr] == 1 & free_list[address_list[head_ptr + 3].rt_addr] == 1) begin
                    status_list[head_ptr + 3] = status.ready;
                end
            end
            else if (tail_ptr >= head_ptr + 4 & status_list[head_ptr + 4] == status.not_ready) begin
                if (free_list[address_list[head_ptr + 4].rs_addr] == 1 & free_list[address_list[head_ptr + 4].rt_addr] == 1) begin
                    status_list[head_ptr + 4] = status.ready;
                end
            end
            else if (tail_ptr >= head_ptr + 5 & status_list[head_ptr + 5] == status.not_ready) begin
                if (free_list[address_list[head_ptr + 5].rs_addr] == 1 & free_list[address_list[head_ptr + 5].rt_addr] == 1) begin
                    status_list[head_ptr + 5] = status.ready;
                end
            end
            else if (tail_ptr >= head_ptr + 6 & status_list[head_ptr + 6] == status.not_ready) begin
                if (free_list[address_list[head_ptr + 6].rs_addr] == 1 & free_list[address_list[head_ptr + 6].rt_addr] == 1) begin
                    status_list[head_ptr + 6] = status.ready;
                end
            end
            else if (tail_ptr >= head_ptr + 7 & status_list[head_ptr + 7] == status.not_ready) begin
                if (free_list[address_list[head_ptr + 7].rs_addr] == 1 & free_list[address_list[head_ptr + 7].rt_addr] == 1) begin
                    status_list[head_ptr + 7] = status.ready;
                end
            end
        end
    end

endmodule