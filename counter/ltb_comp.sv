package ltb_comp;

class input_item;
	rand logic en;
	rand logic up_dn;   // 1 = up, 0 = down

	function void display();
		$display("GEN: ITEM => en=%0b up_dn=%0b", en, up_dn);
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
	virtual cnt_interface vmif;

	function new(
		virtual cnt_interface vmif,
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
			vmif.en    <= it.en;
			vmif.up_dn <= it.up_dn;
			drv_to_scr.put(it);

			$display("DRV: en=%0b up_dn=%0b at %t",
			         it.en, it.up_dn, $time);
		end
	endtask
endclass


class mon;
	mailbox mon_to_scr;
	virtual cnt_interface vmif;

	function new(
		virtual cnt_interface vmif,
		mailbox mb
	);
		this.vmif = vmif;
		mon_to_scr = mb;
	endfunction

	task obsrv(int count = 0);
		logic [31:0] cnt;
		for (int i = 0; i < count; i++) begin
			@(posedge vmif.clk);
			cnt = vmif.count;
			mon_to_scr.put(cnt);
			$display("MON: count=%0d at %t", cnt, $time);
		end
	endtask
endclass



class scrbrd;
	mailbox mon_to_scr;
	mailbox #(input_item) drv_to_scr;

	logic [31:0] exp_count;

	function new(
		mailbox #(input_item) mb1,
		mailbox mb2
	);
		drv_to_scr = mb1;
		mon_to_scr = mb2;
		exp_count  = '0;
	endfunction

	task run;
		input_item it;
		logic [31:0] act_count;

		forever begin
			drv_to_scr.get(it);
			mon_to_scr.get(act_count);

			/* Reference counter model */
			if (it.en) begin
				if (it.up_dn)
					exp_count++;
				else
					exp_count--;
			end

			if (act_count !== exp_count)
				$display("SCR: FAIL exp=%0d act=%0d",
				          exp_count, act_count);
			else
				$display("SCR: PASS count=%0d", act_count);
		end
	endtask
endclass

endpackage

