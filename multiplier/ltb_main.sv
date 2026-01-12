`timescale 1ns/1ps
import ltb_comp::*;
interface mul_interface(input clk);
	logic rst_n;
	logic [7:0] a;
	logic [7:0] b;
	
	logic [15:0] p;
endinterface
module ltb_mul;
	logic clk = 1;
	always #10 clk =~clk;
	
	mul_interface vmif(clk);
	mul_main DUT(
		.clk(vmif.clk),
		.rst_n(vmif.rst_n),
		.A(vmif.a),
		.B(vmif.b),
		.P(vmif.p)
	);

	mailbox #(input_item) gen_to_drv = new();
	mailbox	#(input_item) drv_to_scr = new();
	mailbox 	      mon_to_scr = new();
	

	genrt 	generator;
	drv 	driver;
	mon 	monitor;
	scrbrd  scoreboard;
	
	initial begin
		generator = new(gen_to_drv);
		driver = new(vmif, gen_to_drv, drv_to_scr);
		monitor = new(vmif, mon_to_scr);
		scoreboard = new(drv_to_scr, mon_to_scr);

		fork
		begin
		vmif.rst_n = 1;
		#10 vmif.rst_n = 0;
		#10 vmif.rst_n = 1; end
		fork
			generator.gen_items(5);
			driver.drive(5);
			begin
			repeat (3) @(posedge vmif.clk);
			monitor.obsrv(5); 
			scoreboard.run(); end
		join_any
		join_any
		
		#500 $finish;
	end
endmodule