module mul_arr_8x8 (
	input [7:0] a,
	input [7:0] b,
	
	output [15:0] p
);

	wire [7:0] a0,a1,a2,a3,a4,a5,a6,a7,c;


	and_add_arr aa0 (.x(a), .y(b[0]), .a(0) ,.s(a0), .c_out(c[0]));
	and_add_arr aa1 (.x(a), .y(b[1]), .a({c[0],a0[7:1]}) ,.s(a1), .c_out(c[1]));
	and_add_arr aa2 (.x(a), .y(b[2]), .a({c[1],a1[7:1]}) ,.s(a2), .c_out(c[2]));
	and_add_arr aa3 (.x(a), .y(b[3]), .a({c[2],a2[7:1]}) ,.s(a3), .c_out(c[3]));
	and_add_arr aa4 (.x(a), .y(b[4]), .a({c[3],a3[7:1]}) ,.s(a4), .c_out(c[4]));
	and_add_arr aa5 (.x(a), .y(b[5]), .a({c[4],a4[7:1]}) ,.s(a5), .c_out(c[5]));
	and_add_arr aa6 (.x(a), .y(b[6]), .a({c[5],a5[7:1]}) ,.s(a6), .c_out(c[6]));
	and_add_arr aa7 (.x(a), .y(b[7]), .a({c[6],a6[7:1]}) ,.s(a7), .c_out(c[7]));
	
	
	assign p = {c[7], a7, a6[0], a5[0], a4[0], a3[0], a2[0], a1[0], a0[0] };


	



endmodule
