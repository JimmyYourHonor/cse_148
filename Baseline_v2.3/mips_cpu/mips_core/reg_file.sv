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
	input logic [5:0] retired_rw,
	input logic retired_uses_rw,

	input logic[1:0] entry,
    input logic reset,
	
	// Output data
	reg_file_output_ifc.out out,
	output logic free_list [64],
	output logic hazard
);

	logic availability [64] = '{'0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0,
								'0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0, '0};

	// regs and map snapshots
	logic [`DATA_WIDTH - 1 : 0] regs_snapshot [4][64];
	logic [5 : 0] map_snapshot [4][32];
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

	logic[6:0] index = 0;

	always_comb
	begin
		if(availability[0] == 1'b0) index = 0;
		else if(availability[1] == 1'b0) index = 1;
		else if(availability[2] == 1'b0) index = 2;
		else if(availability[3] == 1'b0) index = 3;
		else if(availability[4] == 1'b0) index = 4;
		else if(availability[5] == 1'b0) index = 5;
		else if(availability[6] == 1'b0) index = 6;
		else if(availability[7] == 1'b0) index = 7;
		else if(availability[8] == 1'b0) index = 8;
		else if(availability[9] == 1'b0) index = 9;
		else if(availability[10] == 1'b0) index = 10;
		else if(availability[11] == 1'b0) index = 11;
		else if(availability[12] == 1'b0) index = 12;
		else if(availability[13] == 1'b0) index = 13;
		else if(availability[14] == 1'b0) index = 14;
		else if(availability[15] == 1'b0) index = 15;
		else if(availability[16] == 1'b0) index = 16;
		else if(availability[17] == 1'b0) index = 17;
		else if(availability[18] == 1'b0) index = 18;
		else if(availability[19] == 1'b0) index = 19;
		else if(availability[12] == 1'b0) index = 20;
		else if(availability[21] == 1'b0) index = 21;
		else if(availability[22] == 1'b0) index = 22;
		else if(availability[23] == 1'b0) index = 23;
		else if(availability[24] == 1'b0) index = 24;
		else if(availability[25] == 1'b0) index = 25;
		else if(availability[26] == 1'b0) index = 26;
		else if(availability[27] == 1'b0) index = 27;
		else if(availability[28] == 1'b0) index = 28;
		else if(availability[29] == 1'b0) index = 29;
		else if(availability[30] == 1'b0) index = 30;
		else if(availability[31] == 1'b0) index = 31;
		else if(availability[32] == 1'b0) index = 32;
		else if(availability[33] == 1'b0) index = 33;
		else if(availability[34] == 1'b0) index = 34;
		else if(availability[35] == 1'b0) index = 35;
		else if(availability[36] == 1'b0) index = 36;
		else if(availability[37] == 1'b0) index = 37;
		else if(availability[38] == 1'b0) index = 38;
		else if(availability[39] == 1'b0) index = 39;
		else if(availability[40] == 1'b0) index = 40;
		else if(availability[41] == 1'b0) index = 41;
		else if(availability[42] == 1'b0) index = 42;
		else if(availability[43] == 1'b0) index = 43;
		else if(availability[44] == 1'b0) index = 44;
		else if(availability[45] == 1'b0) index = 45;
		else if(availability[46] == 1'b0) index = 46;
		else if(availability[47] == 1'b0) index = 47;
		else if(availability[48] == 1'b0) index = 48;
		else if(availability[49] == 1'b0) index = 49;
		else if(availability[50] == 1'b0) index = 50;
		else if(availability[51] == 1'b0) index = 51;
		else if(availability[52] == 1'b0) index = 52;
		else if(availability[53] == 1'b0) index = 53;
		else if(availability[54] == 1'b0) index = 54;
		else if(availability[55] == 1'b0) index = 55;
		else if(availability[56] == 1'b0) index = 56;
		else if(availability[57] == 1'b0) index = 57;
		else if(availability[58] == 1'b0) index = 58;
		else if(availability[59] == 1'b0) index = 59;
		else if(availability[60] == 1'b0) index = 60;
		else if(availability[61] == 1'b0) index = 61;
		else if(availability[62] == 1'b0) index = 62;
		else if(availability[63] == 1'b0) index = 63;
		else index = 64;
	end
	always_ff @(posedge clk) begin
	//always_comb begin
		// recycle the old spot TODO - change to recycle only after instruction is done
		if(retired_uses_rw)
			availability[map[retired_rw]] <= 1'b0;
		
		if (i_wb.uses_rw)
		begin

			// // find an empty spot in availability list
			// for (int i = 63; i >= 0; i = i-1) begin
			// 	if (availability[i] == 1'b0) begin
			// 		index <= i;
			// 	end
			// end

			if (index < 64) begin
				availability[index] <= 1'b1;
				map[i_wb.rw_addr] <= index;
				regs[index] <= i_wb.rw_data;
				hazard <= 0;
			end
			else begin
				hazard <= 1;
			end
			
		end

		// saves reg & map for branch mispredicts
		if (i_decoded.is_branch_jump && !i_decoded.is_jump) begin
			regs_snapshot[snapshot_size] <= regs;
			map_snapshot[snapshot_size] <= map;
			snapshot_size <= snapshot_size + 1;
		end

		// reset reg & map when out of order buffer request for it
		if (reset) begin
			regs <= regs_snapshot[entry];
			map <= map_snapshot[entry];
			snapshot_size <= entry + 1;
		end
	end

endmodule
