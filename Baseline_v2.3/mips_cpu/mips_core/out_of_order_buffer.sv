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
    input logic[19:0] instruction_id_branch,
    branch_result_ifc.in branch_result,

    // for retiring instructions
    input logic mem_done,
    input logic[19:0] instruction_id_result,

    // outputs
    decoder_output_ifc.out out,
    output logic hazard_flag,

    output logic[19:0] instruction_id_out, // position in issue_queue
    output logic[5:0] retired_rw,
    output logic retired_uses_rw,
    output logic retired,
    output logic[19:0] instruction_id_retired,

    // output for reg file to reset registers
    output logic [1:0] entry,
    output logic reset
);

    // issue queue (pending instructions)
    // ------------------------------------------------------------

    logic [19:0] ids[8];

    logic valid[8];
	mips_core_pkg::AluCtl alu_ctl[8];
	logic is_branch_jump[8];
	logic is_jump[8];
	logic is_jump_reg[8];
	logic [`ADDR_WIDTH - 1 : 0] branch_target[8];

	logic is_mem_access[8];
	mips_core_pkg::MemAccessType mem_action[8];

	logic uses_rs[8];
	mips_core_pkg::MipsReg rs_addr[8];

	logic uses_rt[8];
	mips_core_pkg::MipsReg rt_addr[8];

	logic uses_immediate[8];
	logic [`DATA_WIDTH - 1 : 0] immediate[8];

	logic uses_rw[8];
	mips_core_pkg::MipsReg rw_addr[8];
	
	logic is_ll[8];
	logic is_sc[8];
	logic is_sw[8];

    // -------------------------------------------------------------

    logic [19:0] instruction_id = 0;
    logic [19:0] instruction_id_head = 0;

    logic [2:0] test;

    logic [19:0] stores [8];
    logic [2:0] store_head = 0;
    logic [2:0] store_tail = 0;

    logic [2:0] head_ptr = 0;
    logic [2:0] tail_ptr = 0;
    logic full = 0;
    logic empty = 1;

    logic found = 0;
    logic [2:0] offset;

    status status_list[8];

    logic [5:0] reg_rs_addr[7:0];
	logic [5:0] reg_rt_addr[7:0];
	logic [5:0] reg_rw_addr[7:0];

    // stall when a store before a load is not finished
    logic stall_load = 0;
    logic stall_store = 0;

    // Save all the branch entries
    logic [19:0] branch_entries[4];
    logic [1:0] entry_tail = 0;
    logic [1:0] entry_head = 0;

    // task for queues: push, pop, and clear
    task push;
        begin

            if (full == 0) begin

                $display("OOO push: id = %d, ALU_CTL = %d\n", instruction_id, decoded_insn.alu_ctl);

                empty <= 0;

                instruction_id <= instruction_id + 1;

                ids[tail_ptr] <= instruction_id;

                valid[tail_ptr] <= decoded_insn.valid;
                alu_ctl[tail_ptr] <= decoded_insn.alu_ctl;
                is_branch_jump[tail_ptr] <= decoded_insn.is_branch_jump;
                is_jump[tail_ptr] <= decoded_insn.is_jump;
                is_jump_reg[tail_ptr] <= decoded_insn.is_jump_reg;
                branch_target[tail_ptr] <= decoded_insn.branch_target;
                is_mem_access[tail_ptr] <= decoded_insn.is_mem_access;
                mem_action[tail_ptr] <= decoded_insn.mem_action;

                uses_rs[tail_ptr] <= decoded_insn.uses_rs;
                rs_addr[tail_ptr] <= decoded_insn.rs_addr;
                uses_rt[tail_ptr] <= decoded_insn.uses_rt;
                rt_addr[tail_ptr] <= decoded_insn.rt_addr;
                uses_rw[tail_ptr] <= decoded_insn.uses_rw;
                rw_addr[tail_ptr] <= decoded_insn.rw_addr;

                uses_immediate[tail_ptr] <= decoded_insn.uses_immediate;
                immediate[tail_ptr] <= decoded_insn.immediate;
                is_ll[tail_ptr] <= decoded_insn.is_ll;
                is_sc[tail_ptr] <= decoded_insn.is_sc;
                is_sw[tail_ptr] <= decoded_insn.is_sw;

                reg_rs_addr[tail_ptr] <= reg_ready.rs_addr;
                reg_rt_addr[tail_ptr] <= reg_ready.rt_addr;
                reg_rw_addr[tail_ptr] <= reg_ready.rw_addr;

                status_list[tail_ptr] <= not_ready;

                if (head_ptr == tail_ptr + 1 || (head_ptr == 0 && tail_ptr == 7)) full <= 1;
                tail_ptr <= tail_ptr + 1;

                // check for memory access
                if(decoded_insn.is_mem_access)
                begin
                    if(decoded_insn.mem_action == WRITE)
                    begin
                        stores[store_tail] <= instruction_id;
                        store_tail <= store_tail + 1;
                    end
                end

                // check for branches
                if(decoded_insn.is_branch_jump && !decoded_insn.is_jump)
                begin
                    branch_entries[entry_tail] <= instruction_id;
                    entry_tail <= entry_tail + 1;
                end
            end 
        end
    endtask

    task find;
        begin
            if (found == 1) begin

                status_list[head_ptr + offset] <= executing;

                out.valid           <= valid[head_ptr + offset];
                out.alu_ctl         <= alu_ctl[head_ptr + offset];
                out.is_branch_jump  <= is_branch_jump[head_ptr + offset];
                out.is_jump         <= is_jump[head_ptr + offset];
                out.is_jump_reg     <= is_jump_reg[head_ptr + offset];
                out.is_mem_access   <= is_mem_access[head_ptr + offset];
                out.branch_target   <= branch_target[head_ptr + offset];
                out.mem_action      <= mem_action[head_ptr + offset];

                out.uses_rs <= uses_rs[head_ptr + offset];
                out.rs_addr <= rs_addr[head_ptr + offset];
                out.uses_rt <= uses_rt[head_ptr + offset];
                out.rt_addr <= rt_addr[head_ptr + offset];
                out.uses_rw <= uses_rw[head_ptr + offset];
                out.rw_addr <= rw_addr[head_ptr + offset];

                out.uses_immediate  <= uses_immediate[head_ptr + offset];
                out.immediate       <= immediate[head_ptr + offset];

                out.is_ll <= is_ll[head_ptr + offset];
                out.is_sc <= is_sc[head_ptr + offset];
                out.is_sw <= is_sw[head_ptr + offset];

                instruction_id_out <= instruction_id_head + offset;
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
            if (head_ptr == index) empty <= 1;
            if (branch_entries[0] == instruction_id_branch) begin
                entry <= 0;
                entry_tail <= 0;
            end
            else if (branch_entries[1] == instruction_id_branch) begin 
                entry <= 1;
                entry_tail <= 1;
            end
            else if (branch_entries[2] == instruction_id_branch) begin 
                entry <= 2;
                entry_tail <= 2;
            end
            else if (branch_entries[3] == instruction_id_branch) begin
                entry <= 3;
                entry_tail <= 3;
            end
            else begin
                entry <= 0;
                entry_tail <= 0;
                // not supposed to happen
            end

            if (stores[0] > instruction_id_branch) begin
                store_tail <= 0;
            end
            else if (stores[1] > instruction_id_branch) begin 
                store_tail <= 1;
            end
            else if (stores[2] > instruction_id_branch) begin 
                store_tail <= 2;
            end
            else if (stores[3] > instruction_id_branch) begin
                store_tail <= 3;
            end
            else begin
                store_tail <= store_tail;
                // not supposed to happen
            end
        end
    endtask

    // retires instructions in order
    task retire();
        begin
            
            if (mem_done && !empty) begin
                test <= head_ptr + (instruction_id_result[2:0] - instruction_id_head[2:0]);
                if (status_list[head_ptr + (instruction_id_result[2:0] - instruction_id_head[2:0])] == executing) begin
                    status_list[head_ptr + (instruction_id_result[2:0] - instruction_id_head[2:0])] <= done;
                    $display("OOO set done: head_ptr = %d, instruction_id_head = %d (%d), instruction_id_result = %d, (%d), difference = %d, status list index = %d, old = (%d)\n", head_ptr, instruction_id_head, instruction_id_head[2:0], instruction_id_result, instruction_id_result[2:0], (instruction_id_result[2:0] - instruction_id_head[2:0]), head_ptr + (instruction_id_result[2:0] - instruction_id_head[2:0]), tail_ptr - (instruction_id_result[2:0] - instruction_id_head[2:0]));
                end
            end

            if (status_list[head_ptr] == done) begin
                $display("OOO retire: instruction_id_head = %d, instruction_id_result = %d\n", instruction_id_head, instruction_id_result);
                instruction_id_head <= instruction_id_head + 1;
                retired <= 1'b1;
                instruction_id_retired <= instruction_id_head;
                retired_uses_rw <= uses_rw[head_ptr];
                retired_rw <= rw_addr[head_ptr];
                head_ptr <= head_ptr + 1;
                full <= 0;
                if (head_ptr + 1 == tail_ptr || (head_ptr == 7 && tail_ptr == 0)) empty <= 1;

                if (instruction_id_head == branch_entries[entry_head]) entry_head <= entry_head + 1;
            end
            else
            begin
                retired <= 1'b0;
                instruction_id_retired <= 0;
                head_ptr <= head_ptr;
            end 
        end
    endtask

    always_comb begin
        if (!empty) begin
            if (status_list[head_ptr] == ready) begin
                found = 1;
                offset = 0;
            end
            else if (status_list[head_ptr + 1] == ready) begin
                found = 1;
                offset = 1;
            end
            else if (status_list[head_ptr + 2] == ready) begin
                found = 1;
                offset = 2;
            end
            else if (status_list[head_ptr + 3] == ready) begin
                found = 1;
                offset = 3;
            end
            else if (status_list[head_ptr + 4] == ready) begin
                found = 1;
                offset = 4;
            end
            else if (status_list[head_ptr + 5] == ready) begin
                found = 1;
                offset = 5;
            end
            else if (status_list[head_ptr + 6] == ready) begin
                offset = 6;
                found = 1;
            end
            else if (status_list[head_ptr + 7] == ready) begin
                offset = 7;
                found = 1;
            end
            else 
            begin
                offset = 0;
                found = 0;
            end
        end
        else begin
            offset = 0;
            found = 0;
        end

        stall_load = decoded_insn.is_mem_access && (decoded_insn.mem_action == READ) && (store_head != store_tail && instruction_id > stores[store_head]);
        stall_store = decoded_insn.is_mem_access && (decoded_insn.mem_action == WRITE) && (entry_head != entry_tail && instruction_id > branch_entries[entry_head]);
    end

    always_ff @(posedge clk) begin

        push(); // add decoded instruction to queue

        // branch mispredicts
        if (branch_result.valid && branch_result.prediction != branch_result.outcome) begin
            clear(tail_ptr - (instruction_id - instruction_id_branch));
            reset <= 1;
            $display("OOO: Branch mispredict\n");
        end
        else
        begin
            reset <= 0;
        end
        
        find(); // find next instruction to execute

        // hazard
        if (full || stall_load || stall_store) begin
            $display("OOO hazard: full = %d, stall_load = %d, stall_store = %d\n", full, stall_load, stall_store);
            hazard_flag <= 1;
        end
        else begin
            hazard_flag <= 0;
        end

        retire();

        if (status_list[head_ptr] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr]] == 1 || uses_rs[head_ptr] == 0) && (free_list[reg_rt_addr[head_ptr]] == 1 || uses_rt[head_ptr] == 0)) begin
                status_list[head_ptr] <= ready;
            end
        end
        if (status_list[head_ptr + 1] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr + 1]] == 1 || uses_rs[head_ptr + 1] == 0) && (free_list[reg_rt_addr[head_ptr + 1]] == 1 || uses_rt[head_ptr + 1] == 0)) begin
                status_list[head_ptr + 1] <= ready;
            end
        end
        if (status_list[head_ptr + 2] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr + 2]] == 1 || uses_rs[head_ptr + 2] == 0) && (free_list[reg_rt_addr[head_ptr + 2]] == 1 || uses_rt[head_ptr + 2] == 0)) begin
                status_list[head_ptr + 2] <= ready;
            end
        end
        if (status_list[head_ptr + 3] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr + 3]] == 1 || uses_rs[head_ptr + 3] == 0) && (free_list[reg_rt_addr[head_ptr + 3]] == 1 || uses_rt[head_ptr + 3] == 0)) begin
                status_list[head_ptr + 3] <= ready;
            end
        end
        if (status_list[head_ptr + 4] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr + 4]] == 1 || uses_rs[head_ptr + 4] == 0) && (free_list[reg_rt_addr[head_ptr + 4]] == 1 || uses_rt[head_ptr + 4] == 0)) begin
                status_list[head_ptr + 4] <= ready;
            end
        end
        if (status_list[head_ptr + 5] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr + 5]] == 1 || uses_rs[head_ptr + 5] == 0) && (free_list[reg_rt_addr[head_ptr + 5]] == 1 || uses_rt[head_ptr + 5] == 0)) begin
                status_list[head_ptr + 5] <= ready;
            end
        end
        if (status_list[head_ptr + 6] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr + 6]] == 1 || uses_rs[head_ptr + 6] == 0) && (free_list[reg_rt_addr[head_ptr + 6]] == 1 || uses_rt[head_ptr + 6] == 0)) begin
                status_list[head_ptr + 6] <= ready;
            end
        end
        if (status_list[head_ptr + 7] == not_ready) begin
            if ((free_list[reg_rs_addr[head_ptr + 7]] == 1 || uses_rs[head_ptr + 7] == 0) && (free_list[reg_rt_addr[head_ptr + 7]] == 1 || uses_rt[head_ptr + 7] == 0)) begin
                status_list[head_ptr + 7] <= ready;
            end
        end
    end
endmodule
