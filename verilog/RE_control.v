`timescale 1us / 1ns

module RE_control(
    input increase,
    input decrease,
    input clk,
    input reset,
    input init,
    output NRE_1,
    output NRE_2,
    output ADC,
    output expose,
    output erase
    );
    
    parameter [1:0] idle = 2'b00;
    parameter [1:0] exposure = 2'b01;
    parameter [1:0] readout = 2'b10;
    parameter [1:0] others = 2'b11;
    
    reg [1:0] state;
    reg [1:0] next_state;
    reg [4:0] t_exp;
    reg [4:0] t_read; 
    reg [4:0] exp_counter ;
    reg [4:0] read_counter;
    reg ofv4;
    reg ofv5;
    reg NRE_1_r;
    reg NRE_2_r;
    reg ADC_r;
    reg expose_r;
    reg erase_r;
    reg [2:0] R [9:0];
    reg exp_plus;
    reg exp_minus;
    
    initial begin
        state = idle;
        next_state = idle;
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
                    ofv5 = 1;
                end
            readout: begin
                if (read_counter < t_read )
                    read_counter = read_counter +1;
                else
                    ofv4 = 1;
                end
            default: begin 
                exp_counter = 0;
                read_counter = 0;
                ofv4 = 0;
                ofv5 = 0;
                end   
        endcase
        
    //outputs
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
         
    // exposure control
    always @(posedge clk)
        if ((increase == 1)&& (t_exp < 30 && t_exp >= 2))
                t_exp = t_exp + 1;
        else if((decrease == 1)&& (t_exp <= 30 && t_exp > 2))
                t_exp = t_exp - 1;
                
endmodule
