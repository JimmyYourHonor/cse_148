/*
 * testbench.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * This is the simulation testbench. It connects mips_cpu to a sdram model, and
 * generates top-level input clock and signals.
 */
`timescale 1 ns / 1 ps
`include "mips_cpu.svh"

module testbench ();
	// Connections to mips_cpu
	logic        CLOCK_50;

	logic [12:0] DRAM_ADDR;
	logic  [1:0] DRAM_BA;
	logic        DRAM_CAS_N;
	logic        DRAM_CKE;
	logic        DRAM_CLK;
	logic        DRAM_CS_N;
	wire  [15:0] DRAM_DQ;
	logic        DRAM_LDQM;
	logic        DRAM_RAS_N;
	logic        DRAM_UDQM;
	logic        DRAM_WE_N;

	logic  [9:0] SW;

	mips_cpu DUT (
		.CLOCK_50,

		.DRAM_ADDR,
		.DRAM_BA,
		.DRAM_CAS_N,
		.DRAM_CKE,
		.DRAM_CLK,
		.DRAM_CS_N,
		.DRAM_DQ,
		.DRAM_LDQM,
		.DRAM_RAS_N,
		.DRAM_UDQM,
		.DRAM_WE_N,

		.SW
	);

	sdr SDR (
		.Dq    (DRAM_DQ),
		.Addr  (DRAM_ADDR),
		.Ba    (DRAM_BA),
		.Clk   (DRAM_CLK),
		.Cke   (DRAM_CKE),
		.Cs_n  (DRAM_CS_N),
		.Ras_n (DRAM_RAS_N),
		.Cas_n (DRAM_CAS_N),
		.We_n  (DRAM_WE_N),
		.Dqm   ({DRAM_UDQM, DRAM_LDQM})
	);

	// Generate reference clock
	always
	begin
		#10 CLOCK_50 = ~CLOCK_50;
	end

	initial
	begin
		CLOCK_50 = 1'b0;
		SW[0] = 1'b0;						// Hard reset
		SW[1] = 1'b0;						// Soft reset

		repeat (10) @(posedge CLOCK_50);	// Wait for 10 cycles
		SW[0] = 1'b1;						// Release hard reset

		/*
		 * Memory controller is set to wait 1us after a hard reset for the
		 * hardware memory to stabilize. In real world this should be 100us.
		 * Wait 2us before releasing the soft reset.
		 */
		#2000 @(posedge DUT.clk);
		// Hack binary code into sdram's bank0. Please change the path
		$readmemh("../../../hexfiles/nqueens.16bit.bank0.hex", SDR.Bank0);
		$readmemh("../../../hexfiles/nqueens.16bit.bank1.hex", SDR.Bank1);
		// Release soft reset
		SW[1] = 1'b1;

		/*
		 * Stop the simulation so that you can step through from the beginning.
		 * Click run to step and run all again to continue the simulation.
		 * Comment out the following line if you don't want to break here.
		 */
		$stop;

		// Wait for the mips_core to report a fail or done MTC0 instruction
		wait(DUT.pass_done.code == MTC0_FAIL || DUT.pass_done.code == MTC0_DONE);
		$display("%m (%t) #Instructions = %d, #Cycles = %d",
			$time, DUT.MIPS_CORE.num_instructions, DUT.MIPS_CORE.num_cycles);
		$stop;
	end
endmodule

