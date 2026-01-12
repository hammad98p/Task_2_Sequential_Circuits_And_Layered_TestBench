module and_add_arr (
	input [7:0] x,
	input y,
	input [7:0] a,
	output [7:0] s,
	output c_out);

	
	wire [6:0] c;
	
	and_add adder0 (.x(x[0]), .y(y), .a(a[0]), .c_in(0), .sum(s[0]), .c_out(c[0]));
	and_add adder1 (.x(x[1]), .y(y), .a(a[1]), .c_in(c[0]), .sum(s[1]), .c_out(c[1]));
	and_add adder2 (.x(x[2]), .y(y), .a(a[2]), .c_in(c[1]), .sum(s[2]), .c_out(c[2]));
	and_add adder3 (.x(x[3]), .y(y), .a(a[3]), .c_in(c[2]), .sum(s[3]), .c_out(c[3]));
	and_add adder4 (.x(x[4]), .y(y), .a(a[4]), .c_in(c[3]), .sum(s[4]), .c_out(c[4]));
	and_add adder5 (.x(x[5]), .y(y), .a(a[5]), .c_in(c[4]), .sum(s[5]), .c_out(c[5]));
	and_add adder6 (.x(x[6]), .y(y), .a(a[6]), .c_in(c[5]), .sum(s[6]), .c_out(c[6]));
	and_add adder7 (.x(x[7]), .y(y), .a(a[7]), .c_in(c[6]), .sum(s[7]), .c_out(c_out));
	
endmodule 