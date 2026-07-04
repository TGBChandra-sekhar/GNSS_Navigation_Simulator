`timescale 1ns / 1ps

module ca_top_wrapper(
            clk,
            rst,
            en_code,
            en_start,
            clk_1p023,
            ca_code,
            epoch_1ms
            //prn_sel,
            //mod_out
    );
    
    input         clk;
    input         rst;
    input         en_code;
    input         en_start;
    output        clk_1p023;
    output [36:0] ca_code;
    output        epoch_1ms;
    
    //input   [5:0] prn_sel;
    //output [15:0] mod_out;
    
    // wire         sine_wave;
    
    
       clk_div_40 uut1 (
             .clk        (clk),
             .rst        (rst),
             .en_start   (en_start),
             .clk_1p023  (clk_1p023)
       );
        
       ca_code uut2 (                
             .clk        (clk), 
             .rst        (rst), 
             .en_code    (en_code),
             .clk_1p023  (clk_1p023),
             .epoch_1ms  (epoch_1ms),
             .ca_code    (ca_code)     
       );
       
//       dds_compiler_0  uut3 (
//             .aclk               (clk),
//             .m_axis_data_tvalid (   ),
//             .m_axis_data_tdata (sine_wave)
//       );
      
       
//       ca_sin_mul uut4 (
//             .clk           (clk),             
//             .rst           (rst),             
//             .prn_sel       (prn_sel),    
//             .prn           (ca_code),       
//             .sine_signal   (sine_wave),
//             .mul_out       (mod_out)
//       );
           
      
        
endmodule
