/*
 * reg_file.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/09/2018
 *
 * A 32-bit wide, 32-word deep register file with two asynchronous read port
 * and one synchronous write port.
 *
 * Register file needs to output '0 if uses_r* signal is low. In this case,
 * either reg zero is requested for read or the register is unused.
 *
 * See wiki page "Branch and Jump" for details.
 */
`include "mips_core.svh"

interface reg_file_output_ifc ();
	logic [`DATA_WIDTH - 1 : 0] rs_data;
	logic [`DATA_WIDTH - 1 : 0] rt_data;

	modport in  (input rs_data, rt_data);
	modport out (output rs_data, rt_data);
endinterface

module reg_file (
	input clk,    // Clock

	// Input from decoder
	decoder_output_ifc.in i_decoded,

	// Input from write back stage
	write_back_ifc.in i_wb,

	// Output data
	reg_file_output_ifc.out out
);

	logic availability[64] = 1'b0;

	// physical registers
	logic [`DATA_WIDTH - 1 : 0] regs [64];

	// mapping from virtual registers to physical registers
	logic [5 : 0] map [32];

	assign out.rs_data = i_decoded.uses_rs ? regs[map[i_decoded.rs_addr]] : '0;
	assign out.rt_data = i_decoded.uses_rt ? regs[map[i_decoded.rt_addr]] : '0;

	always_ff @(posedge clk) begin
		if(i_wb.uses_rw)
		begin
			// recycle the old spot
			availability[map[i_wb.rw_addr]] = 1'b0;
			// find an empty spot in availability list
			for (i = 0; i < 64; i++) begin
				if (availability[i] == 1'b0) begin
					availability[i] = 1'b1;
					map[i_wb.rw_addr] = i;
					break;
				end
			end
			regs[map[i_wb.rw_addr]] = i_wb.rw_data;
		end
	end

endmodule
