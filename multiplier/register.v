module register #(parameter WIDTH = 8)(
	input clk,
	input rst_n,
	input [WIDTH-1:0] d,
	output reg [WIDTH-1:0] q);
	
	
always @(posedge clk or negedge rst_n) begin

	if (~rst_n) 
		q <= 0;
	else 
		q <= d;

end	
	
endmodule
