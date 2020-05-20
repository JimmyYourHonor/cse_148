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
	logic [5:0] rs_addr;
	logic [5:0] rt_addr;
	logic [5:0] rw_addr;

	modport in  (input rs_data, rt_data, rs_addr, rt_addr, rw_addr);
	modport out (output rs_data, rt_data, rs_addr, rt_addr, rw_addr);
endinterface

module reg_file (
	input clk,    // Clock

	// Input from decoder
	decoder_output_ifc.in i_decoded,

	// Input from write back stage
	write_back_ifc.in i_wb,
	// input from out of order buffer
	write_back_ifc.in retired_reg[8],

	// Output data
	reg_file_output_ifc.out out,
	output logic free_list [64]
);

	logic availability [64] = '{'0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0,
								'0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0};

	// regs and map snapshots
	logic [`DATA_WIDTH - 1 : 0] regs_snapshot [4][64];
	logic [5 : 0] map_snapshot [4][64];
	logic [2 : 0] snapshot_size;

	// physical registers
	logic [`DATA_WIDTH - 1 : 0] regs [64];

	// mapping from virtual registers to physical registers
	logic [5 : 0] map [32];

	assign out.rs_data = i_decoded.uses_rs ? regs[map[i_decoded.rs_addr]] : '0;
	assign out.rt_data = i_decoded.uses_rt ? regs[map[i_decoded.rt_addr]] : '0;

	assign out.rs_addr = i_decoded.uses_rs ? map[i_decoded.rs_addr] : '0;
	assign out.rt_addr = i_decoded.uses_rt ? map[i_decoded.rt_addr] : '0;
	assign out.rw_addr = i_decoded.uses_rw ? map[i_decoded.rw_addr] : '0;

	assign free_list = availability;

	logic[5:0] i = 0;
	logic[5:0] index = 0;

	always_ff @(posedge clk) begin
		// recycle the old spot TODO - change to recycle only after instruction is done
		for(int i = 0; i < 8; i++)
		begin
			if(retired_reg[i].uses_rw)
				availability[map[retired_reg[i].rw_addr]] = 1'b0;
		end
		if (i_wb.uses_rw)
		begin

			// find an empty spot in availability list
			for (i = 63; i >= 0; i = i-1) begin
				if (availability[i] == 1'b0) begin
					index = i;
				end
			end

			availability[index] = 1'b1;
			map[i_wb.rw_addr] = index;
			regs[map[i_wb.rw_addr]] = i_wb.rw_data;
		end

		// saves reg & map for branch mispredicts
		if (i_decoded.is_branch && !i_decoded.is_jump) begin
			regs_snapshot[snapshot_size] = regs;
			map_snapshot[snapshot_size] = map;
			snapshot_size++;
		end
	end

endmodule
