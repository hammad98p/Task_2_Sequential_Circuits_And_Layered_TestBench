package ltb_comp;

class input_item;
	rand logic        load;
	rand logic [31:0] d;

	function void display();
		$display("GEN: load=%0b d=%0h", load, d);
	endfunction
endclass


class genrt;
	mailbox #(input_item) gen_to_drv;

	function new(mailbox #(input_item) mb);
		this.gen_to_drv = mb;
	endfunction

	task gen_items(int count);
		input_item it;
		for (int i = 0; i < count; i++) begin
			it = new();
			assert(it.randomize())
				else $fatal("GEN: Randomization failed");
			it.display();
			gen_to_drv.put(it);
		end
	endtask
endclass



class drv;
	mailbox #(input_item) gen_to_drv;
	mailbox #(input_item) drv_to_scr;
	virtual reg_interface vmif;

	function new(
		virtual reg_interface vmif,
		mailbox #(input_item) mb1,
		mailbox #(input_item) mb2
	);
		this.vmif = vmif;
		this.gen_to_drv = mb1;
		this.drv_to_scr = mb2;
	endfunction

	task drive(int count);
		input_item it;

		for (int i = 0; i < count; i++) begin
			gen_to_drv.get(it);
			@(posedge vmif.clk);

			vmif.load <= it.load;
			vmif.d    <= it.d;

			drv_to_scr.put(it);

			$display("DRV: load=%0b d=%0h @%0t",
			         it.load, it.d, $time);

			/* Driver stability assertion */
			#1;
			assert(vmif.load === it.load &&
			       vmif.d    === it.d)
				else $error("DRV_ASSERT: input instability");
		end
	endtask
endclass



class mon;
	mailbox mon_to_scr;
	virtual reg_interface vmif;

	function new(
		virtual reg_interface vmif,
		mailbox mb
	);
		this.vmif = vmif;
		this.mon_to_scr = mb;
	endfunction

	task obsrv(int count);
		logic [31:0] q;

		for (int i = 0; i < count; i++) begin
			@(posedge vmif.clk);
			q = vmif.q;
			mon_to_scr.put(q);

			$display("MON: q=%0h @%0t", q, $time);

			/* Monitor assertion */
			if (vmif.rst_n)
				assert(^q !== 1'bX)
					else $error("MON_ASSERT: q contains X");
		end
	endtask
endclass



class scrbrd;
	mailbox #(input_item) drv_to_scr;
	mailbox mon_to_scr;

	function new(
		mailbox #(input_item) mb1,
		mailbox mb2
	);
		this.drv_to_scr = mb1;
		this.mon_to_scr = mb2;
	endfunction

	task run;
		input_item it;
		logic [31:0] q;
		logic [31:0] expected_q = '0;

		forever begin
			drv_to_scr.get(it);
			mon_to_scr.get(q);

			/* Reference register model */
			if (it.load)
				expected_q = it.d;

			assert(q === expected_q)
				else begin
					$error("SCR_ASSERT FAIL:");
					$error("  load=%0b d=%0h", it.load, it.d);
					$error("  q=%0h expected=%0h", q, expected_q);
				end

			$display("SCR: PASS | load=%0b q=%0h",
			         it.load, q);
		end
	endtask
endclass

endpackage

