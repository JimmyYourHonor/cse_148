/*
 * mips_core_pkg.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/09/2018
 *
 * This package defines all the enum types used across different units within
 * mips_core.
 *
 * See wiki page "Systemverilog Primer" section package and enum for details.
 */
package mips_core_pkg;

typedef enum logic [4:0] {
	zero = 5'd0,
	at = 5'd1,
	v0 = 5'd2,
	v1 = 5'd3,
	a0 = 5'd4,
	a1 = 5'd5,
	a2 = 5'd6,
	a3 = 5'd7,
	t0 = 5'd8,
	t1 = 5'd9,
	t2 = 5'd10,
	t3 = 5'd11,
	t4 = 5'd12,
	t5 = 5'd13,
	t6 = 5'd14,
	t7 = 5'd15,
	s0 = 5'd16,
	s1 = 5'd17,
	s2 = 5'd18,
	s3 = 5'd19,
	s4 = 5'd20,
	s5 = 5'd21,
	s6 = 5'd22,
	s7 = 5'd23,
	t8 = 5'd24,
	t9 = 5'd25,
	k0 = 5'd26,
	k1 = 5'd27,
	gp = 5'd28,
	sp = 5'd29,
	s8 = 5'd30,
	ra = 5'd31
} MipsReg;

typedef enum logic [4:0] {
	ALUCTL_NOP,			// No Operation (noop)
	ALUCTL_ADD,			// Add (signed)
	ALUCTL_ADDU,		// Add (unsigned)
	ALUCTL_SUB,			// Subtract (signed)
	ALUCTL_SUBU,		// Subtract (unsigned)
	ALUCTL_AND,			// AND
	ALUCTL_OR,			// OR
	ALUCTL_XOR,			// XOR
	ALUCTL_SLT,			// Set on Less Than
	ALUCTL_SLTU,		// Set on Less Than (unsigned)
	ALUCTL_SLL,			// Shift Left Logical
	ALUCTL_SRL,			// Shift Right Logical
	ALUCTL_SRA,			// Shift Right Arithmetic
	ALUCTL_SLLV,		// Shift Left Logical Variable
	ALUCTL_SRLV,		// Shift Right Logical Variable
	ALUCTL_SRAV,		// Shift Right Arithmetic Variable
	ALUCTL_NOR,			// NOR
	ALUCTL_MTCO_PASS,	// Move to Coprocessor (PASS)
	ALUCTL_MTCO_FAIL,	// Move to Coprocessor (FAIL)
	ALUCTL_MTCO_DONE,	// Move to Coprocessor (DONE)

	ALUCTL_BA,			// Unconditional branch
	ALUCTL_BEQ,
	ALUCTL_BNE,
	ALUCTL_BLEZ,
	ALUCTL_BGTZ,
	ALUCTL_BGEZ,
	ALUCTL_BLTZ
} AluCtl;

typedef enum logic {
	WRITE,
	READ
} MemAccessType;

typedef enum logic {
	NOT_TAKEN,
	TAKEN
} BranchOutcome;

typedef enum logic [1:0] {
	NOT_ATOMIC,
	ATOMIC_FAIL,
	ATOMIC_PASS
}	AtomicStatus;

endpackage
