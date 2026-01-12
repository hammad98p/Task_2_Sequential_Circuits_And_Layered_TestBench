
package ltb_comp;

class input_item;
	rand logic [7:0] input_a, input_b;
	function void display();
		$display("GEN: INPUT ITEM CREATED => {a = %d, b = %d}",input_a, input_b);
	endfunction
endclass

class genrt;
	mailbox #(input_item) gen_to_drv;
	function new(mailbox #(input_item) mb);
		this.gen_to_drv = mb;
	endfunction

	task gen_items( int count = 0 );
		input_item it;
		for (int i = 0; i < count; i++) begin
			it = new();
			assert(it.randomize());
			it.display();
			gen_to_drv.put(it);
			
		end
	endtask

endclass 

class drv;
	mailbox #(input_item) gen_to_drv;
	mailbox #(input_item) drv_to_scr;
	virtual mul_interface vmif;
	
	function new(
			virtual mul_interface vmif, 
			mailbox #(input_item) mb1,
			mailbox #(input_item) mb2);
		this.vmif = vmif;
		this.gen_to_drv = mb1;	
		this.drv_to_scr = mb2;
	endfunction

	task drive( int count = 0 );
		input_item it;
		for (int i = 0; i < count; i++) begin
		@(posedge vmif.clk) begin 
			gen_to_drv.get(it);
			drv_to_scr.put(it);
			$display("DRV: ITEM RECIEVED AND SENT => {a = %d, b = %d} at TIME = %t", it.input_a, it.input_b, $time);
			vmif.a <= it.input_a;
			vmif.b <= it.input_b;
			end
		end
	endtask

endclass

class mon;
	mailbox mon_to_scr;
	virtual mul_interface vmif;
	
	function new(
			virtual mul_interface vmif,
			mailbox mb
			);

		this.mon_to_scr = mb;
		this.vmif = vmif;
	endfunction

	task obsrv(int count = 0);
		logic [15:0] p;
		
		for (int i = 0; i < count; i++) begin
	        @(posedge vmif.clk) begin 
			p = vmif.p;
			$display("MON: OUTPUT OBSERVED AND SENT => p = %d at TIME = %t", p, $time);
			mon_to_scr.put(p);
			
		end
		end
		 
	endtask

endclass

class scrbrd;
	mailbox mon_to_scr;
	mailbox #(input_item) drv_to_scr;
	function new(
			mailbox #(input_item) mb1,
			mailbox 	      mb2
			);
		this.mon_to_scr = mb2;
		this.drv_to_scr = mb1;
	endfunction
	task run;
		input_item it;
		logic [15:0] p;
			
		forever begin
			mon_to_scr.get(p);
			drv_to_scr.get(it);
			if (p != (it.input_a * it.input_b)) 
				$display("SCR: TEST FAILED => a = %d, b = %d -> p = %d ... \n	-> EXPECTED p = %d"
					,it.input_a,it.input_b,p, it.input_a*it.input_b);
			else
				$display("SCR: TEST PASSED => a = %d, b = %d -> p = %d"
					,it.input_a,it.input_b,p);
		end	
	endtask
endclass
endpackage

