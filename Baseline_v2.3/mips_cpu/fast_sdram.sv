/*
 * fast_sdram.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/12/2018
 *
 * This is a fast sdram simulation model. It is fast in terms of simulation
 * speed. This module should only be used to verify the functionality of your
 * design. And it is not guaranteed that your design can pass the full
 * simulation if it passes the fast simulation. You still need to run the full
 * simulation to make sure everything works. Performance measurement should also
 * be done with the full simulation.
 *
 * See wiki page "Speed up Simulation" for details.
 */
`timescale 1ns / 1ps
`include "mips_cpu.svh"

module fast_sdram #(parameter DELAY = 20)(
	// General signals
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Memory interfaces
	mem_read_ifc.response  i_cache_read,
	mem_write_ifc.response d_cache_write,
	mem_read_ifc.response  d_cache_read
);

	logic [`DATA_WIDTH - 1 : 0] mem [1 << (`ADDR_WIDTH - 2)];

	logic rst;
	assign rst = ~rst_n;

	logic odd_cycle;

	enum {
		STATE_IDLE,
		STATE_DELAY,
		STATE_SERVE_IREAD,
		STATE_SERVE_DREAD,
		STATE_SERVE_DWRITE
	} state, next_state;

	integer delay_counter;
	logic ir_pending, dr_pending, dw_pending;

	assign i_cache_read.control_done = ~ir_pending;
	assign d_cache_read.control_done = ~dr_pending;
	assign d_cache_write.control_done = ~dw_pending;

	logic [`ADDR_WIDTH - 1 : 0] pointer, pending_length;
	logic [`ADDR_WIDTH - 1 : 0] ir_base, ir_length;
	logic [`ADDR_WIDTH - 1 : 0] dr_base, dr_length;
	logic [`ADDR_WIDTH - 1 : 0] dw_base, dw_length;


	logic [`DATA_WIDTH - 1 : 0] iread_data, dread_data, dwrite_data;
	logic iread_empty, iread_full, iread_we;
	logic dread_empty, dread_full, dread_we;
	logic dwrite_empty, dwrite_full, dwrite_re;

	assign iread_data = mem[pointer[2 +: `ADDR_WIDTH - 2]];
	assign dread_data = mem[pointer[2 +: `ADDR_WIDTH - 2]];

	assign i_cache_read.user_available = ~iread_empty;
	scfifo iread_fifo (
		.aclr (rst),
		.clock (clk),
		.empty (iread_empty),
		.full (iread_full),
		.data (iread_data),
		.q (i_cache_read.user_data),
		.rdreq (i_cache_read.user_re),
		.wrreq (iread_we)
	);
	defparam iread_fifo.add_ram_output_register = "OFF",
		iread_fifo.intended_device_family = "Cyclone V",
		iread_fifo.lpm_numwords = 32,
		iread_fifo.lpm_showahead = "ON",
		iread_fifo.lpm_type = "scfifo",
		iread_fifo.lpm_width = `DATA_WIDTH,
		iread_fifo.lpm_widthu = 5,
		iread_fifo.overflow_checking = "OFF",
		iread_fifo.underflow_checking = "OFF",
		iread_fifo.use_eab = "ON";

	assign d_cache_read.user_available = ~dread_empty;
	scfifo dread_fifo (
		.aclr (rst),
		.clock (clk),
		.empty (dread_empty),
		.full (dread_full),
		.data (dread_data),
		.q (d_cache_read.user_data),
		.rdreq (d_cache_read.user_re),
		.wrreq (dread_we)
	);
	defparam dread_fifo.add_ram_output_register = "OFF",
		dread_fifo.intended_device_family = "Cyclone V",
		dread_fifo.lpm_numwords = 32,
		dread_fifo.lpm_showahead = "ON",
		dread_fifo.lpm_type = "scfifo",
		dread_fifo.lpm_width = `DATA_WIDTH,
		dread_fifo.lpm_widthu = 5,
		dread_fifo.overflow_checking = "OFF",
		dread_fifo.underflow_checking = "OFF",
		dread_fifo.use_eab = "ON";

	assign d_cache_write.user_full = dwrite_full;
	scfifo dwrite_fifo (
		.aclr (rst),
		.clock (clk),
		.empty (dwrite_empty),
		.full (dwrite_full),
		.data (d_cache_write.user_data),
		.q (dwrite_data),
		.rdreq (dwrite_re),
		.wrreq (d_cache_write.user_we)
	);
	defparam dwrite_fifo.add_ram_output_register = "OFF",
		dwrite_fifo.intended_device_family = "Cyclone V",
		dwrite_fifo.lpm_numwords = 32,
		dwrite_fifo.lpm_showahead = "ON",
		dwrite_fifo.lpm_type = "scfifo",
		dwrite_fifo.lpm_width = `DATA_WIDTH,
		dwrite_fifo.lpm_widthu = 5,
		dwrite_fifo.overflow_checking = "OFF",
		dwrite_fifo.underflow_checking = "OFF",
		dwrite_fifo.use_eab = "ON";

	assign iread_we  = (state == STATE_SERVE_IREAD ) && (pending_length != '0) && !iread_full && odd_cycle;
	assign dread_we  = (state == STATE_SERVE_DREAD ) && (pending_length != '0) && !dread_full && ~odd_cycle;
	assign dwrite_re = (state == STATE_SERVE_DWRITE) && (pending_length != '0) && !dwrite_empty;

	always_comb
	begin
		next_state <= state;

		case (state)
			STATE_IDLE:
			begin
				if (ir_pending | dr_pending | dw_pending)
					next_state <= STATE_DELAY;
			end

			STATE_DELAY:
			begin
				if (delay_counter == 0)
				begin
					if (ir_pending) next_state <= STATE_SERVE_IREAD;
					else if (dr_pending) next_state <= STATE_SERVE_DREAD;
					else if (dw_pending) next_state <= STATE_SERVE_DWRITE;
				end
			end

			default: if (pending_length == '0) next_state <= STATE_IDLE;
		endcase
	end


	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			state <= STATE_IDLE;
			delay_counter <= 0;
			pending_length <= '0;
			ir_pending <= 1'b0;
			dr_pending <= 1'b0;
			dw_pending <= 1'b0;
			odd_cycle <= 1'b0;
		end
		else
		begin
			odd_cycle <= ~odd_cycle;
			state <= next_state;
			if (i_cache_read.control_go)
			begin
				ir_pending <= 1'b1;
				ir_base <= i_cache_read.control_base;
				ir_length <= i_cache_read.control_length;
			end

			if (d_cache_read.control_go)
			begin
				dr_pending <= 1'b1;
				dr_base <= d_cache_read.control_base;
				dr_length <= d_cache_read.control_length;
			end

			if (d_cache_write.control_go)
			begin
				dw_pending <= 1'b1;
				dw_base <= d_cache_write.control_base;
				dw_length <= d_cache_write.control_length;
			end

			case (state)
				STATE_IDLE:
				begin
					if (next_state == STATE_DELAY)
						delay_counter <= DELAY;
				end

				STATE_DELAY:
				begin
					if (delay_counter > 0)
						delay_counter <= delay_counter - 1;
					else
					begin
						if (next_state == STATE_SERVE_IREAD)
						begin
							pointer <= ir_base;
							pending_length <= ir_length;
						end
						else if (next_state == STATE_SERVE_DREAD)
						begin
							pointer <= dr_base;
							pending_length <= dr_length;
						end
						else if (next_state == STATE_SERVE_DWRITE)
						begin
							pointer <= dw_base;
							pending_length <= dw_length;
						end
					end
				end

				STATE_SERVE_IREAD:
				begin
					if (next_state == STATE_IDLE) ir_pending <= 1'b0;
					else if (iread_we)
					begin
						pointer <= pointer + `ADDR_WIDTH'd4;
						pending_length <= pending_length - `ADDR_WIDTH'd4;
					end
				end

				STATE_SERVE_DREAD:
				begin
					if (next_state == STATE_IDLE) dr_pending <= 1'b0;
					else if (dread_we)
					begin
						pointer <= pointer + `ADDR_WIDTH'd4;
						pending_length <= pending_length - `ADDR_WIDTH'd4;
					end
				end

				STATE_SERVE_DWRITE:
				begin
					if (next_state == STATE_IDLE) dw_pending <= 1'b0;
					else if (dwrite_re)
					begin
						pointer <= pointer + `ADDR_WIDTH'd4;
						pending_length <= pending_length - `ADDR_WIDTH'd4;
						mem[pointer[2 +: `ADDR_WIDTH - 2]] <= dwrite_data;
					end
				end
			endcase
		end
	end
endmodule
