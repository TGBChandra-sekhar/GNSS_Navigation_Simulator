`timescale 1ns / 1ps

module ca_top_wrapper(
            clk,
            rst,
            prn_sel,
            clk_1p023,
            pulse_1023,
            epoch_50hz,
            epoch_1p5,
            epoch_tow,
            mod_out
    );
    
    input         clk;
    input         rst;
    input   [5:0] prn_sel;
    
    output        clk_1p023;
    output        pulse_1023;
    output        epoch_50hz;
    output        epoch_1p5;
    output        epoch_tow;
    output [15:0] mod_out;
    
    wire clk_1p023;
    wire epoch_1p5;
    
    wire [36:0] ca_code;
    wire [15:0] sine_in;
    
    
       clk_div_40 uut1 (
             .clk        (clk),
             .rst        (rst),
             .clk_1p023  (clk_1p023)
       );
        
       ca_code uut2 (                
             .clk        (clk), 
             .rst        (rst), 
             .clk_1p023  (clk_1p023),
             .pulse_1023 (pulse_1023),
             .ca_code    (ca_code)     
       );
       
       //       dds_compiler_0  uut3 (
//             .aclk               (clk),
//             .m_axis_data_tvalid (   ),
//             .m_axis_data_tdata (sine_in)
//       );
       
       //       ca_sin_mul uut4 (
//             .clk           (clk),             
//             .rst           (rst),             
//             .prn_sel       (prn_sel),    
//             .prn           (ca_code),       
//             .sine_signal   (sine_in),
//             .mul_out       (mod_out)
//       );
           
       epoch_1p5 uut5 (
           .clk         (clk),
           .rst         (rst),
           .epoch_1p5   (epoch_1p5)
       );
       
       epoch_50hz uut6 (
           .clk         (clk),
           .rst         (rst),
           .epoch_50hz  (epoch_50hz)
       );
       
       epoch_tow uut7 (
           .clk         (clk),
           .rst         (rst),
           .epoch_1p5   (epoch_1p5),
           .epoch_tow   (epoch_tow)
       );
        
endmodule
