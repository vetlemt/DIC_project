`timescale 1us / 1ns

module RE_control_tb();
    
    reg increase;
    reg decrease;
    reg clk;
    reg reset;
    reg init;
    wire NRE_1;
    wire NRE_2;
    wire ADC;
    wire expose;
    wire erase;
    
  RE_control RE(//
        .increase(increase),
        .decrease(decrease),
        .clk(clk), .reset(reset),
        .init(init),
        .NRE_1(NRE_1), 
        .NRE_2(NRE_2), 
        .ADC(ADC), 
        .expose(expose), 
        .erase(erase));
    
    initial begin
    clk = 0;
    forever #500 clk = ~clk;
    end
    
    initial begin  
    init = 0;  
    #1000 init = 1;
    #2000 init = 0;
    #17000 init = 1;
    #1500 init = 0;
    end
    
    initial begin
    increase = 0;
    #10000 increase = 1;
    #1000 increase = 0;
    #1000 increase = 1;
    #1000 increase = 0;
    end
    
    initial begin
    decrease = 0;
    reset = 0;
    end
    
endmodule
