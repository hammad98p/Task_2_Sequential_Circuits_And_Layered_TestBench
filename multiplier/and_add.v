module and_add (
	input x,
	input y,
	input a,
	input c_in,
	
	output sum,
	output c_out);

	wire b;
	and a0 (b, x, y);
	fa f0(a, b, c_in, sum, c_out);


endmodule
