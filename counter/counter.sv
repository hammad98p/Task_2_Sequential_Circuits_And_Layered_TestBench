module counter #(
	parameter N = 32
)(
	input  logic         clk,
	input  logic         rst_n,
	input  logic         en,
	input  logic         up_dn,
	output logic [N-1:0] count
);

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		count <= '0;
	else if (en) begin
		if (up_dn)
			count <= count + 1;
		else
			count <= count - 1;
	end
	else
		count <= count; // hold
end

endmodule

