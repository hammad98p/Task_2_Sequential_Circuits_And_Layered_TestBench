
`timescale 1ns/1ps
import ltb_comp::*;

interface reg_interface(input logic clk);
	logic             rst_n;
	logic             load;
	logic [31:0]      d;
	logic [31:0]      q;
endinterface


module ltb_reg;
	logic clk = 0;
	always #10 clk = ~clk;

	reg_interface vmif(clk);

	register DUT (
		.clk  (vmif.clk),
		.rst_n(vmif.rst_n),
		.load (vmif.load),
		.d    (vmif.d),
		.q    (vmif.q)
	);

	mailbox #(input_item) gen_to_drv = new();
	mailbox #(input_item) drv_to_scr = new();
	mailbox mon_to_scr = new();

	genrt   generator;
	drv     driver;
	mon     monitor;
	scrbrd  scoreboard;

	initial begin
		generator  = new(gen_to_drv);
		driver     = new(vmif, gen_to_drv, drv_to_scr);
		monitor    = new(vmif, mon_to_scr);
		scoreboard = new(drv_to_scr, mon_to_scr);

		/* RESET */
		vmif.rst_n = 0;
		vmif.load  = 0;
		vmif.d     = '0;
		repeat (2) @(posedge clk);
		vmif.rst_n = 1;

		fork
			generator.gen_items(10);
			driver.drive(10);
			begin
				repeat (1) @(posedge clk); // reg latency
				monitor.obsrv(10);
				
			end
			scoreboard.run();
		join_any

		#200 $finish;
	end
endmodule
