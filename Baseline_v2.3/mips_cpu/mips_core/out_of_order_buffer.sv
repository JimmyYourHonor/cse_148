`include "mips_core.svh"

typedef enum logic [1:0] {
    not_ready = 2'b00,
    ready = 2'b01,
    executing = 2'b10,
    done = 2'b11
} status;

module ooo_buffer (
    input clk,

    // inputs
    reg_file_output_ifc.in reg_ready,
    decoder_output_ifc.in decoded_insn,
    pc_ifc.in i_pc,

    // outputs
    decoder_output_ifc.out out
);

    // issue queue (pending instructions)
    decoder_output_ifc issue_queue[8]();

    logic [2:0] head_ptr = 0;
    logic [2:0] tail_ptr = 0;
    logic [2:0] size = 0;

    status status_list[8];

    always_ff @(posedge clk) begin

        // case: issue queue empty, 0 pending instructions
        if (size == 0) begin

        end

        // case: issue queue full - hazard
        else if (size == 8) begin

        end

        // partially filled queue
        else

        end

    end

endmodule