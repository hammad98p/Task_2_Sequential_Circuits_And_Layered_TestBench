module shift_reg #(
	parameter N = 32
)(
	input  logic         clk,
	input  logic         rst_n,
	input  logic         shift_en,
	input  logic         dir,      // 0 = left, 1 = right
	input  logic         d_in,      // serial input
	output logic [N-1:0] q
);

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		q <= '0;
	else if (shift_en) begin
		if (dir == 1'b0)        // LEFT SHIFT
			q <= {q[N-2:0], d_in};
		else                   // RIGHT SHIFT
			q <= {d_in, q[N-1:1]};
	end
	else
		q <= q; // hold
end

endmodule

