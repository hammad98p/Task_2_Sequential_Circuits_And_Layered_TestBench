`timescale 1ns/1ps
module tb_mul_main;

/* module mul_main (
	input clk,
	input rst_n,
	input [7:0] A,
	input [7:0] B,
	
	output [15:0] P

	); */
	
	reg clk, rst_n;
	reg [7:0] A, B;
	
	wire [15:0] P;
	
	mul_main DUT (clk, rst_n, A, B, P);
	
	always #10 clk <= ~clk;
	
	initial begin
	A = 0; B = 0; rst_n = 1; clk = 0;
	#20
	rst_n = 0; A = 20; B = 10;
	#20
	A = 4; B = 4; rst_n = 1;
	#20
	A = 10; B = 100;
	#20
	A = 78; B = 33;
	#20
	A = 0; B = 8;
	#20
	A = 12; B = 18;
	#20
	A = 16; B = 53;
	#20
	$finish;
	end
endmodule

