/*
 * lladdr.sv
 * Author: Sumiran Shubhi
 * Last Revision: 04/03/2020
 *
 * Module to store current LLADDR register value for processing LL and SC
 * instructions.
 */
 `include "mips_core.svh"
 
 interface llsc_input_ifc();
	logic is_sw;
	logic lladdr_wr;
	logic [`DATA_WIDTH - 1 : 0] wr_reg_val;
	logic is_sc;

	modport in (input wr_reg_val, lladdr_wr, is_sw, is_sc);
	modport out (output wr_reg_val, lladdr_wr, is_sw, is_sc);
 endinterface
 
 interface llsc_output_ifc();
	mips_core_pkg::AtomicStatus atomic;
	
	modport in (input atomic);
	modport out (output atomic);
 endinterface
 
 module llsc_module (
	input clk,    // Clock
	// Input from ALU stage
	llsc_input_ifc.in i_llsc,

	// Output to MEM stage
	llsc_output_ifc.out o_llsc
); 
	logic [`DATA_WIDTH - 1 : 0]	LLAddr;
	logic LLbit;

	always_comb begin
		o_llsc.atomic = (LLbit && i_llsc.is_sc && (LLAddr==i_llsc.wr_reg_val)) ? ATOMIC_PASS 
						    : (LLbit && i_llsc.is_sc && (LLAddr!= i_llsc.wr_reg_val)) ? ATOMIC_FAIL
							 : NOT_ATOMIC ;
	end
	
	always_ff @(posedge clk) begin
		if (i_llsc.is_sw && LLbit && (LLAddr==i_llsc.wr_reg_val)) begin
			LLAddr <= 0;
			LLbit <= 0;
		end 
		else if(i_llsc.lladdr_wr) begin
			LLAddr <= i_llsc.wr_reg_val;
			LLbit <= 1;
		end

	end 
endmodule	
