`timescale 1us/1us

module re_control_tb();
	
	parameter PERIOD = 1000;
	
	reg clk = 0;
	reg reset = 0;
	reg init = 0;
	reg exp_inc = 0;
	reg exp_dec = 0;
	wire expose;
	wire erase;
	wire adc;
	wire nre1;
	wire nre2;
	
	re_control re_control(.Expose(expose), .Erase(erase), .ADC(adc), 
			.NRE_1(nre1), .NRE_2(nre2), .Init(init), .Exp_inc(exp_inc), 
			.Exp_dec(exp_dec), .Reset(reset), .Clk(clk));
			
	initial begin
		reset = 1;
		#PERIOD;
		reset = 0;
	end
	
	always #(PERIOD/2) 	clk = ~clk;	
		
	initial begin 
		#(PERIOD/2);
		#PERIOD exp_dec = 1;
		// #PERIOD exp_inc = 1;
		#PERIOD;
		#PERIOD exp_dec = 0;
		//#(3*PERIOD) exp_inc = 0;
		#PERIOD init = 1;
		#PERIOD init = 0;
		// #20000  reset = 1;	
		// #PERIOD reset = 0;
		#30000;
		$finish;
	end
	
endmodule