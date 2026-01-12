`timescale 1ns/1ps
import ltb_comp::*;

interface shift_interface(input logic clk);
	logic         rst_n;
	logic         shift_en;
	logic         dir;
	logic         d_in;
	logic [31:0]  q;
endinterface


module ltb_shift_reg;
	logic clk = 0;
	always #10 clk = ~clk;

	shift_interface vmif(clk);

	shift_reg #(.N(32)) DUT (
		.clk     (vmif.clk),
		.rst_n   (vmif.rst_n),
		.shift_en(vmif.shift_en),
		.dir     (vmif.dir),
		.d_in    (vmif.d_in),
		.q       (vmif.q)
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
		vmif.rst_n   = 0;
		vmif.shift_en= 0;
		vmif.dir     = 0;
		vmif.d_in    = 0;
		repeat (2) @(posedge clk);
		vmif.rst_n   = 1;

		fork
			generator.gen_items(25);
			driver.drive(25);
			begin
				repeat (1) @(posedge clk);
				monitor.obsrv(25);
				
			end
			scoreboard.run();
		join_any

		#400 $finish;
	end
endmodule

