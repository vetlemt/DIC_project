`timescale 1us / 1ns

module RE_control(
    input exp_increase,
    input exp_decrease,
    input clk,
    input reset,
    input init,
    output NRE_1,
    output NRE_2,
    output ADC,
    output expose,
    output erase
    );
    // FSM states
    parameter [1:0] idle = 2'b00;
    parameter [1:0] exposure = 2'b01;
    parameter [1:0] readout = 2'b10;
  
    // registers
    reg [1:0] state;        // The current state
    reg [4:0] t_exp;        // Exposure time
    reg [4:0] t_read;       // Readout time
    reg [4:0] exp_counter ; // Counts up to t_exp
    reg [4:0] read_counter; // Counts up to t_read
    reg ofv4;               // triggered when readout complete
    reg ofv5;               // triggered when exposure complete
    //output registers
    reg NRE_1_r;            
    reg NRE_2_r;
    reg ADC_r;
    reg expose_r;
    reg erase_r;
    // R stores the outputs of ADC, NRE_1 and NRE_2 used during the readout state 
    reg [2:0] R [9:0];  
    
    initial begin
        state = idle;
        t_exp = 5;
        t_read = 9; ///maybe 9 
        exp_counter = 0;
        read_counter = 0;
        ofv4 = 0;
        ofv5 = 0;
        NRE_1_r = 1;
        NRE_2_r = 1;
        ADC_r = 0;
        expose_r = 0;
        erase_r = 1; 
        R[0] = 3'b110;
        R[1] = 3'b110;
        R[2] = 3'b010;
        R[3] = 3'b011;
        R[4] = 3'b010;
        R[5] = 3'b110;
        R[6] = 3'b100;
        R[7] = 3'b101;
        R[8] = 3'b100;
        R[9] = 3'b110;       
    end
    
    // assigning the outputs to the output registers
    assign NRE_1 = NRE_1_r;
    assign NRE_2 = NRE_2_r;
    assign ADC = ADC_r;
    assign expose = expose_r;
    assign erase = erase_r; 
    
    // state control
    always @(posedge clk) begin
        case (state)
            idle: begin 
                if (init == 1 && reset == 0)
                    state = exposure;  
                else
                    state = idle;
                end
            exposure: begin 
                if (ofv5 == 1)  
                    state = readout;
                else if (reset == 1) 
                    state = idle;
                else 
                    state = exposure;
                end
            readout: begin 
                if (ofv4 == 1 || reset == 1)
                    state = idle;
                else 
                    state = readout;
                end
            default:  begin state = idle; end
        endcase
    end
 
    // counters   
    always @(posedge clk)
        case (state)
            exposure: begin
                if (exp_counter < t_exp - 1)
                    exp_counter = exp_counter +1;
                else
                    ofv5 = 1; // exposure complete
                end
            readout: begin
                if (read_counter < t_read )
                    read_counter = read_counter +1;
                else
                    ofv4 = 1; // readout complete
                end
            default: begin 
                exp_counter = 0;
                read_counter = 0;
                ofv4 = 0;
                ofv5 = 0;
                end   
        endcase
        
    // exposure control
    always @(posedge clk)
        if ((exp_increase == 1)&& (t_exp < 30 && t_exp >= 2))
            t_exp = t_exp + 1;
        else if((exp_decrease == 1)&& (t_exp <= 30 && t_exp > 2))
            t_exp = t_exp - 1;        
        
    // outputs
    always @(posedge clk)
        case (state)
        exposure: begin
            NRE_1_r = 1;
            NRE_2_r = 1;
            ADC_r = 0;
            expose_r = 1;
            erase_r = 0;
            end
        readout: begin
            NRE_1_r = R[read_counter][2];
            NRE_2_r = R[read_counter][1];
            ADC_r = R[read_counter][0];
            expose_r = 0;
            erase_r = 0;
            end
        default: begin  // this includes idle
            NRE_1_r = 1;
            NRE_2_r = 1;
            ADC_r = 0;
            expose_r = 0;
            erase_r = 1;
            end
         endcase   
                
endmodule
