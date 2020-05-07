/*
 * memory_interfaces.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * This file defines the memory interface for reading from and writing to sdram.
 * Detailed documentation can be found in the wiki page "Memory Interfaces"
 */

`include "mips_cpu.svh"

interface mem_write_ifc ();
	logic [`ADDR_WIDTH - 1 : 0] control_base;
	logic [`ADDR_WIDTH - 1 : 0] control_length;
	logic                       control_go;
	logic                       control_done;

	logic                       user_we;	// Write Enable
	logic [`DATA_WIDTH - 1 : 0] user_data;
	logic                       user_full;

	modport request (input control_done, user_full,
		output control_base, control_length, control_go, user_we, user_data);
	modport response (output control_done, user_full,
		input control_base, control_length, control_go, user_we, user_data);
endinterface

interface mem_read_ifc ();
	logic [`ADDR_WIDTH - 1 : 0] control_base;
	logic [`ADDR_WIDTH - 1 : 0] control_length;
	logic                       control_go;
	logic                       control_done;

	logic                       user_re;	// Read Enable
	logic [`DATA_WIDTH - 1 : 0] user_data;
	logic                       user_available;

	modport request (input control_done, user_data, user_available,
		output control_base, control_length, control_go, user_re);
	modport response (output control_done, user_data, user_available,
		input control_base, control_length, control_go, user_re);
endinterface

