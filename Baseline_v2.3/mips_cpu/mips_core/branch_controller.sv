/*
 * branch_controller.sv
 * Author: Zinsser Zhang
 * Last Revision: 04/08/2018
 *
 * branch_controller is a bridge between branch predictor to hazard controller.
 * Two simple predictors are also provided as examples.
 *
 * See wiki page "Branch and Jump" for details.
 */
`include "mips_core.svh"

module branch_controller (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Request
	pc_ifc.in dec_pc,
	branch_decoded_ifc.hazard dec_branch_decoded,

	// Feedback
	pc_ifc.in ex_pc,
	branch_result_ifc.in ex_branch_result
);
	logic request_prediction;

	// Change the following line to switch predictor
	branch_predictor_tournament PREDICTOR (
		.clk, .rst_n,

		.i_req_valid     (request_prediction),
		.i_req_pc        (dec_pc.pc),
		.i_req_target    (dec_branch_decoded.target),
		.o_req_prediction(dec_branch_decoded.prediction),

		.i_fb_valid      (ex_branch_result.valid),
		.i_fb_pc         (ex_pc.pc),
		.i_fb_prediction (ex_branch_result.prediction),
		.i_fb_outcome    (ex_branch_result.outcome)
	);

	always_comb
	begin
		request_prediction = dec_branch_decoded.valid & ~dec_branch_decoded.is_jump;
		dec_branch_decoded.recovery_target =
			(dec_branch_decoded.prediction == TAKEN)
			? dec_pc.pc + `ADDR_WIDTH'd8
			: dec_branch_decoded.target;
	end

endmodule

module branch_predictor_always_not_taken (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Request
	input logic i_req_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_pc,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_target,
	output mips_core_pkg::BranchOutcome o_req_prediction,

	// Feedback
	input logic i_fb_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_fb_pc,
	input mips_core_pkg::BranchOutcome i_fb_prediction,
	input mips_core_pkg::BranchOutcome i_fb_outcome
);

	always_comb
	begin
		o_req_prediction = NOT_TAKEN;
	end

endmodule

module branch_predictor_2bit (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Request
	input logic i_req_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_pc,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_target,
	output mips_core_pkg::BranchOutcome o_req_prediction,

	// Feedback
	input logic i_fb_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_fb_pc,
	input mips_core_pkg::BranchOutcome i_fb_prediction,
	input mips_core_pkg::BranchOutcome i_fb_outcome
);

	logic [1:0] counter;
	logic [19:0] correct = 20'b0, total = 20'b0;

	task incr;
		begin
			if (counter != 2'b11)
				counter <= counter + 2'b01;
		end
	endtask

	task decr;
		begin
			if (counter != 2'b00)
				counter <= counter - 2'b01;
		end
	endtask

	always_ff @(posedge clk or negedge rst_n)
	begin
		if(~rst_n)
		begin
			counter <= 2'b01;	// Weakly not taken
		end
		else
		begin
			if (i_fb_valid)
			begin
				case (i_fb_outcome)
					NOT_TAKEN: decr();
					TAKEN:     incr();
				endcase

				if (i_fb_outcome == i_fb_prediction) correct++;
				total++;

				$display(i_fb_outcome == NOT_TAKEN ? "2 bit: Not taken" : "2 bit: Taken");
			end
		end
	end

	always_comb
	begin
		o_req_prediction = counter[1] ? TAKEN : NOT_TAKEN;
	end

endmodule


module branch_predictor_local (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Request
	input logic i_req_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_pc,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_target,
	output mips_core_pkg::BranchOutcome o_req_prediction,

	// Feedback
	input logic i_fb_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_fb_pc,
	input mips_core_pkg::BranchOutcome i_fb_prediction,
	input mips_core_pkg::BranchOutcome i_fb_outcome
);

	logic [9:0] pht [1024];
	logic [2:0] counter [1024];

	logic [9:0] hash;

	logic [19:0] correct = 20'b0, total = 20'b0;
	task incr(logic[9:0] index);
		begin
			if (counter[index] != 3'b111)
				counter[index] <= counter[index] + 3'b01;
		end
	endtask

	task decr(logic[9:0] index);
		begin
			if (counter[index] != 3'b000)
				counter[index] <= counter[index] - 3'b01;
		end
	endtask

	always_ff @(posedge clk or negedge rst_n)
	begin

		if(~rst_n)
		begin
			for (int i = 0; i < 1024; i++)
			begin
				counter[i] <= 3'b1;
				pht[i] <= 10'b0;
			end
		end

		else
		begin
			pht[hash] <= (pht[hash][2:0] << 1) | i_fb_outcome;

			if (i_fb_valid)
			begin
				case (i_fb_outcome)
					NOT_TAKEN: decr(pht[hash]);
					TAKEN:     incr(pht[hash]);
				endcase

				if (i_fb_outcome == i_fb_prediction) correct++;
				total++;

				$display(i_fb_outcome == NOT_TAKEN ? "Local: Not taken" : "Local: Taken");
				//$display();
			end
		end
	end

	always_comb
	begin
		hash = i_req_pc[9:0];
		o_req_prediction = counter[pht[hash]][1] ? TAKEN : NOT_TAKEN;
	end

endmodule

module branch_predictor_bimodal (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Request
	input logic i_req_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_pc,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_target,
	output mips_core_pkg::BranchOutcome o_req_prediction,

	// Feedback
	input logic i_fb_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_fb_pc,
	input mips_core_pkg::BranchOutcome i_fb_prediction,
	input mips_core_pkg::BranchOutcome i_fb_outcome
);


	logic [1:0] counter [16];

	logic [3:0] hash;

	logic [19:0] correct = 20'b0, total = 20'b0;

	task incr(logic[3:0] index);
		begin
			if (counter[index] != 2'b11)
				counter[index] <= counter[index] + 2'b01;
		end
	endtask

	task decr(logic[3:0] index);
		begin
			if (counter[index] != 2'b00)
				counter[index] <= counter[index] - 2'b01;
		end
	endtask

	always_ff @(posedge clk or negedge rst_n)
	begin

		if(~rst_n)
		begin
			counter <= '{2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1, 2'b1};	// Weakly not taken
		end

		else
		begin

			if (i_fb_valid)
			begin
				case (i_fb_outcome)
					NOT_TAKEN: decr(hash);
					TAKEN:     incr(hash);
				endcase

				if (i_fb_outcome == i_fb_prediction) correct++;
				total++;

				$display(i_fb_outcome == NOT_TAKEN ? "Bimodal: Not taken" : "Bimodal: Taken");
			end
		end
	end

	always_comb
	begin
		hash = i_req_pc[3:0];
		o_req_prediction = counter[hash][1] ? TAKEN : NOT_TAKEN;
	end

endmodule

module branch_predictor_global (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Request
	input logic i_req_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_pc,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_target,
	output mips_core_pkg::BranchOutcome o_req_prediction,

	// Feedback
	input logic i_fb_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_fb_pc,
	input mips_core_pkg::BranchOutcome i_fb_prediction,
	input mips_core_pkg::BranchOutcome i_fb_outcome
);

	logic [1:0] counter [4096];

	logic [11:0] GR; // prediction history

	logic [19:0] correct = 20'b0, total = 20'b0;

	task incr(logic[11:0] index);
		begin
			if (counter[index] != 2'b11)
				counter[index] <= counter[index] + 2'b01;
		end
	endtask

	task decr(logic[11:0] index);
		begin
			if (counter[index] != 2'b00)
				counter[index] <= counter[index] - 2'b01;
		end
	endtask

	always_ff @(posedge clk or negedge rst_n)
	begin

		if(~rst_n)
		begin
			for (int i = 0; i < 4096; i++)
			begin
				counter[i] <= 2'b1;
			end
			GR <= 12'b0;
			// Weakly not taken
		end

		else
		begin

			if (i_fb_valid)
			begin
				case (i_fb_outcome)
					NOT_TAKEN:
					begin
						GR = {GR[11:1], 1'b0};
						decr(GR);
					end
					TAKEN:
					begin
						GR = {GR[11:1], 1'b1};
						incr(GR);
					end
				endcase

				if (i_fb_outcome == i_fb_prediction) correct++;
				total++;

				$display(i_fb_outcome == NOT_TAKEN ? "Global: Not taken" : "Global: Taken");
			end
		end
	end

	always_comb
	begin
		// hash = i_req_pc[3:0];
		o_req_prediction = counter[GR][1] ? TAKEN : NOT_TAKEN;
	end

endmodule

module branch_predictor_tournament (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	// Request
	input logic i_req_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_pc,
	input logic [`ADDR_WIDTH - 1 : 0] i_req_target,
	output mips_core_pkg::BranchOutcome o_req_prediction,

	// Feedback
	input logic i_fb_valid,
	input logic [`ADDR_WIDTH - 1 : 0] i_fb_pc,
	input mips_core_pkg::BranchOutcome i_fb_prediction,
	input mips_core_pkg::BranchOutcome i_fb_outcome
);

	mips_core_pkg::BranchOutcome prediction_local, prediction_global;

	logic [19:0] correct = 20'b0, total = 20'b0;

	branch_predictor_local b_l(
		.clk, .rst_n,

		.i_req_valid,
		.i_req_pc,
		.i_req_target,
		.o_req_prediction(prediction_local),

		.i_fb_valid,
		.i_fb_pc,
		.i_fb_prediction,
		.i_fb_outcome
	);

	branch_predictor_global b_g(
		.clk, .rst_n,

		.i_req_valid,
		.i_req_pc,
		.i_req_target,
		.o_req_prediction(prediction_global),

		.i_fb_valid,
		.i_fb_pc,
		.i_fb_prediction,
		.i_fb_outcome
	);

	// global when choice_prediction[1] == 1
	logic [1:0] choice_prediction [4096];

	logic [11:0] G_R; // prediction histrory

	task incr(logic[11:0] index);
		begin
			if (choice_prediction[index] != 2'b11)
				choice_prediction[index] <= choice_prediction[index] + 2'b01;
		end
	endtask

	task decr(logic[11:0] index);
		begin
			if (choice_prediction[index] != 2'b00)
				choice_prediction[index] <= choice_prediction[index] - 2'b01;
		end
	endtask

	always_ff @(posedge clk or negedge rst_n)
	begin

		if(~rst_n)
		begin
			choice_prediction <= '{default:0}; // strongly take local
			G_R = '{'0};
		end

		else
		begin

			if (i_fb_valid)
			begin
				case (i_fb_outcome)
					NOT_TAKEN:
					begin
						G_R = {G_R[11:1], 1'b0};
					end
					TAKEN:
					begin
						G_R = {G_R[11:1], 1'b1};
					end
				endcase

				// local correct and global incorrect
				if (prediction_local == i_fb_outcome && prediction_global != i_fb_outcome) begin
					decr(G_R);
				end

				// global correct and local incorrect
				if (prediction_local != i_fb_outcome && prediction_global == i_fb_outcome) begin
					incr(G_R);
				end

				if (i_fb_outcome == i_fb_prediction) correct++;
				total++;

				$display(i_fb_outcome == NOT_TAKEN ? "Tournament: Not taken" : "Tournament: Taken");
			end
		end
	end

	always_comb
	begin

		o_req_prediction = choice_prediction[G_R][1] ? prediction_global : prediction_local;
	end

endmodule