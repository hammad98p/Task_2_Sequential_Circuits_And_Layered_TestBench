package ltb_comp;


class input_item;
	rand logic shift_en;
	rand logic dir;   // 0 = left, 1 = right
	rand logic d_in;

	function void display();
		$display("GEN: ITEM => shift_en=%0b dir=%0b d_in=%0b",
		          shift_en, dir, d_in);
	endfunction
endclass


class genrt;
	mailbox #(input_item) gen_to_drv;

	function new(mailbox #(input_item) mb);
		gen_to_drv = mb;
	endfunction

	task gen_items(int count = 0);
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
	virtual shift_interface vmif;

	function new(
		virtual shift_interface vmif,
		mailbox #(input_item) mb1,
		mailbox #(input_item) mb2
	);
		this.vmif = vmif;
		gen_to_drv = mb1;
		drv_to_scr = mb2;
	endfunction

	task drive(int count = 0);
		input_item it;
		for (int i = 0; i < count; i++) begin
			gen_to_drv.get(it);
			@(posedge vmif.clk);
			vmif.shift_en <= it.shift_en;
			vmif.dir      <= it.dir;
			vmif.d_in     <= it.d_in;
			drv_to_scr.put(it);

			$display("DRV: shift_en=%0b dir=%0b d_in=%0b at %t",
			         it.shift_en, it.dir, it.d_in, $time);
		end
	endtask
endclass

class mon;
	mailbox mon_to_scr;
	virtual shift_interface vmif;

	function new(
		virtual shift_interface vmif,
		mailbox mb
	);
		this.vmif = vmif;
		mon_to_scr = mb;
	endfunction

	task obsrv(int count = 0);
		logic [31:0] q;
		for (int i = 0; i < count; i++) begin
			@(posedge vmif.clk);
			q = vmif.q;
			mon_to_scr.put(q);
			$display("MON: q=%h at %t", q, $time);
		end
	endtask
endclass

class scrbrd;
	mailbox mon_to_scr;
	mailbox #(input_item) drv_to_scr;

	logic [31:0] exp_q;

	function new(
		mailbox #(input_item) mb1,
		mailbox mb2
	);
		drv_to_scr = mb1;
		mon_to_scr = mb2;
		exp_q = '0;
	endfunction

	task run;
		input_item it;
		logic [31:0] act_q;

		forever begin
			drv_to_scr.get(it);
			mon_to_scr.get(act_q);

			/* Reference model */
			if (it.shift_en) begin
				if (it.dir == 0)
					exp_q = {exp_q[30:0], it.d_in};  // shift left
				else
					exp_q = {it.d_in, exp_q[31:1]};  // shift right
			end

			if (act_q !== exp_q)
				$display("SCR: FAIL exp=%h act=%h", exp_q, act_q);
			else
				$display("SCR: PASS q=%h", act_q);
		end
	endtask
endclass

endpackage

