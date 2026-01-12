module mul_main (
	input clk,
	input rst_n,
	input [7:0] A,
	input [7:0] B,
	
	output [15:0] P

	);

	wire [7:0] reg_A, reg_B;
	wire [15:0] reg_P;
	
register #(.WIDTH(8)) data_A (.clk(clk), .rst_n(rst_n), .d(A), .q(reg_A));
register #(.WIDTH(8)) data_B (.clk(clk), .rst_n(rst_n), .d(B), .q(reg_B));

mult_adder_tree multiplier (.a(reg_A), .b(reg_B), .p(reg_P));

register #(.WIDTH(16)) data_P (.clk(clk), .rst_n(rst_n), .d(reg_P), .q(P));


endmodule 