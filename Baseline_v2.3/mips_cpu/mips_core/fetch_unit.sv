/*
 * d_cache.sv
 * Author: Pravin P. Prabhu, Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * This module provides pc to i_cache to fetch the next instruction. Two outputs
 * exist. o_pc_current.pc is registered and represent the current pc, i.e. the
 * address of instruction needed to be fetched during the current cycle.
 * o_pc_next.pc is not registered and represent the next pc.
 *
 * All addresses in mips_core are byte addresses (26-bit), so all pc are also
 * byte addresses. Thus, it increases by 4 every cycle (without hazards).
 *
 * See wiki page "Synchronous Caches" for details.
 */
`include "mips_core.svh"

module fetch_unit (
	// General signals
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Stall
	hazard_control_ifc.in i_hc,

	// Load pc
	load_pc_ifc.in i_load_pc,

	// Output pc
	pc_ifc.out o_pc_current,
	pc_ifc.out o_pc_next
);

	always_comb
	begin
		if (!i_hc.stall)
			o_pc_next.pc = i_load_pc.we
				? i_load_pc.new_pc
				: o_pc_current.pc + `ADDR_WIDTH'd4;
		else
			o_pc_next.pc = o_pc_current.pc;
	end

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
			o_pc_current.pc <= '0;	// Start point of programs are always 0x0
		else
		begin
			o_pc_current.pc <= o_pc_next.pc;
		end
	end

endmodule
