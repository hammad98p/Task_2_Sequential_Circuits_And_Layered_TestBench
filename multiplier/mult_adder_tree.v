module mult_adder_tree(
	input [7:0] a,
	input [7:0] b,
	output [15:0] p
	);

	wire [15:0] level1 [3:0];
	wire [15:0] level2 [1:0];
	wire [15:0]	pp     [8:0];
	

	assign pp[0] = (b[0]) ? a : 16'h0;
	assign pp[1] = (b[1]) ? (a << 1) : 16'h0;
	assign pp[2] = (b[2]) ? (a << 2) : 16'h0;
	assign pp[3] = (b[3]) ? (a << 3) : 16'h0;
	assign pp[4] = (b[4]) ? (a << 4) : 16'h0;
	assign pp[5] = (b[5]) ? (a << 5) : 16'h0;
	assign pp[6] = (b[6]) ? (a << 6) : 16'h0;
	assign pp[7] = (b[7]) ? (a << 7) : 16'h0;

	
	 assign level1[0] = pp[0] + pp[1];
    assign level1[1] = pp[2] + pp[3];
    assign level1[2] = pp[4] + pp[5];
    assign level1[3] = pp[6] + pp[7];
	 
	 assign level2[0] = level1[0] + level1[1];
    assign level2[1] = level1[2] + level1[3];
	 
	 assign p = level2[0] + level2[1];
	
	
endmodule


