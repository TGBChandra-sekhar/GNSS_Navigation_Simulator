`timescale 1ns / 1ps

module tb_gnss_top_wrapper();
    reg clk;
    reg reset;
    
    integer i;
    
    
    gnss_top_wrapper uut_tb (
       .clk        (clk),
       .reset      (reset)
    );
    
    initial begin   
       clk = 0;        
       reset = 1;  
       #25;       
       reset = 0;  
        
    end
    
    always #12.21896 clk = ~clk;
    
 
    
endmodule
