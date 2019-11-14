//
//
// Top-level verilog module example
//

module re_control(Expose, Erase, ADC, NRE_1, NRE_2,
	Init, Exp_inc, Exp_dec, Reset, Clk);

	input Init, Exp_inc, Exp_dec, Reset, Clk;
	output Expose, Erase, ADC, NRE_1, NRE_2;

	reg [4:0] exposure_time = 4'd15;		// choosen value
	reg [4:0] counter = 4'b0000;
	wire Init, Exp_inc, Exp_dec, RESET, CLK;
	reg Erase, Expose, NRE_1, NRE_2, ADC;  
	reg [1:0] state;  
	reg status_state_change = 0;		// indicates the status that

	// states
	parameter [1:0] idle    = 2'b00;
	parameter [1:0] expose  = 2'b01;		
	parameter [1:0] readout = 2'b10;   
	
	// go to idle state if reset is activated
	always @(posedge Clk) begin	
		if (Reset == 1) begin
			$display("Reset");
			state <= idle; 
			Erase <= 1;
			Expose <= 0;
			ADC <= 0;
			NRE_1 <= 1;
			NRE_2 <= 1;
			exposure_time <= 15; 
		end
	else begin
			case(state)	 
				idle:
				if(status_state_change == 1) begin
					$display("reentering idle");
					Erase <= 1;
					Expose <= 0;
					ADC <= 0;
					NRE_1 <= 1;
					NRE_2 <= 1;
					status_state_change = 0;
					if(Init == 1) begin
						state <= expose;
						status_state_change = 1; 
						counter = 0;
					end	
				end
				
				else if(Init == 1) begin
					state <= expose;
					status_state_change = 1; 
					counter = 0;
				end
				else if(Exp_inc == 1) begin  
					if(exposure_time < 30) begin
						exposure_time = exposure_time + 1; 
						$display("Exposure time inc --> %d ms", exposure_time);
					end
				end
				else if (Exp_dec == 1) begin
					if(exposure_time > 2) begin
						exposure_time = exposure_time - 1;
						$display("Exposure time dec --> %d ms", exposure_time);
					end
				end
				else begin
					Erase <= 1;
					Expose <= 0;
					ADC <= 0;
					NRE_1 <= 1;
					NRE_2 <= 1;
				end
					
				expose:
				if(status_state_change == 1) begin
					Expose <= 1;
					Erase  <= 0;
					status_state_change = 0;
					counter = counter + 1;
				end
				else if (counter	< exposure_time) begin
					counter = counter + 1; 
				end
				else begin
					Expose <= 0;
					state  <= readout;
					status_state_change = 1; 
				end
				
				readout:
				begin
				if(status_state_change == 1) begin
					status_state_change = 0;
					counter = 1;
				end
				else if(counter < 2) begin
					counter = counter + 1;
					NRE_1 <= 0;
				end
				else if(counter < 3) begin
					counter = counter + 1;
					ADC <= 1;
				end
				else if(counter < 4) begin
					counter = counter + 1;
					ADC <= 0; 
				end
				else if(counter < 5) begin
					counter = counter + 1;
					NRE_1 <= 1;	
				end
				else if(counter < 6) begin
					counter = counter + 1;
					NRE_2 <= 0;
				end
				else if(counter < 7) begin
					counter = counter + 1;
					ADC <= 1;
				end
				else if(counter < 8) begin
					counter = counter + 1;
					ADC <= 0;
				end
				else if(counter < 9) begin
					counter = counter + 1;
					NRE_2 <= 1;
				end
				else begin
					state <= idle;
					counter = 0;
					Erase <= 1;
					status_state_change = 1;
				end
				end
			endcase
		end
	end
	
endmodule // re_control

