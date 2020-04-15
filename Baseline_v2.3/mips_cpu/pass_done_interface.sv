/*
 * pass_done_interface.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * This file defines the pass_done interface
 */
`include "mips_cpu.svh"

/*
 * We customized MTC0 instructions to report the results of programs. This
 * is the interface for reporting a MTC0 instruction from mips_core.
 * See wiki page "Pass Done Interface" for details.
 */
interface pass_done_ifc ();
	logic [15:0] value;
	mips_cpu_pkg::MTC0Code code;

	modport in  (input value, code);
	modport out (output value, code);
endinterface
