/*
 * fast_testbench.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/12/2018
 *
 * This is a fast simulation testbench. It is fast in terms of simulation
 * speed. This module should only be used to verify the functionality of your
 * design. And it is not guaranteed that your design can pass the full
 * simulation if it passes the fast simulation. You still need to run the full
 * simulation to make sure everything works. Performance measurement should also
 * be done with the full simulation.
 *
 * See wiki page "Speed up Simulation" for details.
 */
`timescale 1 ns / 1 ps
`include "mips_cpu.svh"

module fast_testbench ();

	logic clk, rst_n;
	mem_read_ifc  i_cache_read();
	mem_write_ifc d_cache_write();
	mem_read_ifc  d_cache_read();

	pass_done_ifc pass_done();


	mips_core MIPS_CORE (
		.clk, .rst_n,

		.i_cache_read,
		.d_cache_write,
		.d_cache_read,

		.pass_done
	);

	fast_sdram FAST_SDRAM (
		.clk, .rst_n,

		.i_cache_read,
		.d_cache_write,
		.d_cache_read
	);
	defparam FAST_SDRAM.DELAY = 20;

	// Generate reference clock
	always
	begin
		#5 clk = ~clk;
	end

	initial
	begin
		clk = 1'b0;
		rst_n = 1'b0;

		repeat (10) @(posedge clk);	// Wait for 10 cycles
		rst_n = 1'b1;				// Release reset

		// Load binary code
		$readmemh("../../../hexfiles/nqueens.hex", FAST_SDRAM.mem);

		/*
		 * Stop the simulation so that you can step through from the beginning.
		 * Click run to step and run all again to continue the simulation.
		 * Comment out the following line if you don't want to break here.
		 */
		$stop;

		// Wait for the mips_core to report a fail or done MTC0 instruction
		wait(pass_done.code == MTC0_FAIL || pass_done.code == MTC0_DONE);
		$stop;
	end
endmodule

