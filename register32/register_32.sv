
module register #(
	parameter WIDTH = 32
)(
	input  logic             clk,
	input  logic             rst_n,
	input  logic             load,
	input  logic [WIDTH-1:0] d,
	output logic [WIDTH-1:0] q
);

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		q <= '0;
	else if (load)
		q <= d;
	else
		q <= q;
end

endmodule
