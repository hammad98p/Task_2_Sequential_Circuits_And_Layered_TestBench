`timescale 1ns/1ps
module tb_mul_arr_8x8;

	reg [7:0] a,b;
	wire [15:0] p;
	
	mul_arr_8x8 m0 (a,b,p);
	
	initial begin
			a = 4; b = 4;
			#10
			a = 6; b = 6;
			#10
			a = 9; b = 0;
			#10
			a = 100; b = 100;
			#10;
			$finish;

	end

endmodule
