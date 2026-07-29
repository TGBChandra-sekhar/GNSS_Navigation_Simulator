`timescale 1ns / 1ps

module tb_gnss_top_wrapper();
    reg sys_diff_clock_clk_n; 
    reg sys_diff_clock_clk_p;
    reg reset;
    
    
    gnss_top_wrapper uut_tb(
       .sys_diff_clock_clk_n (sys_diff_clock_clk_n),
       .sys_diff_clock_clk_p (sys_diff_clock_clk_p),
       .reset                (reset)
    );
    
    initial begin   
       sys_diff_clock_clk_n = 0; 
       sys_diff_clock_clk_p = 1;       
       reset = 1;  
       #25;       
       reset = 0;  
        
    end
    
    always #5 sys_diff_clock_clk_n = ~sys_diff_clock_clk_n;
    always #5 sys_diff_clock_clk_p = ~sys_diff_clock_clk_p;
    
    
endmodule
