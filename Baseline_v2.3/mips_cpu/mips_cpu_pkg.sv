/*
 * mips_cpu_pkg.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * This file defines types that are used across the entire MIPS FPGA design.
 */

package mips_cpu_pkg;

/*
 * MTC0Code defines the meaning of a MTC0 instruction. Used in the pass_done
 * interface. See wiki page "Pass Done Interface" for details.
 */
typedef enum bit [1:0] {
	MTC0_NOOP = 2'd0,
	MTC0_PASS = 2'd1,
	MTC0_FAIL = 2'd2,
	MTC0_DONE = 2'd3
} MTC0Code;

endpackage
