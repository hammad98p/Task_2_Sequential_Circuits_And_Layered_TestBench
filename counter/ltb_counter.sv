`timescale 1ns/1ps
import ltb_comp::*;

interface cnt_interface(input logic clk);
	logic         rst_n;
	logic         en;
	logic         up_dn;
	logic [31:0]  count;
endinterface


module ltb_counter;
	logic clk = 0;
	always #10 clk = ~clk;

	cnt_interface vmif(clk);

	counter #(.N(32)) DUT (
		.clk   (vmif.clk),
		.rst_n (vmif.rst_n),
		.en    (vmif.en),
		.up_dn (vmif.up_dn),
		.count (vmif.count)
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
		vmif.en    = 0;
		vmif.up_dn = 0;
		repeat (2) @(posedge clk);
		vmif.rst_n = 1;

		fork
			generator.gen_items(20);
			driver.drive(20);
			begin
				repeat (1) @(posedge clk);
				monitor.obsrv(20);
				
			end
			scoreboard.run();
		join_any

		#300 $finish;
	end
endmodule

