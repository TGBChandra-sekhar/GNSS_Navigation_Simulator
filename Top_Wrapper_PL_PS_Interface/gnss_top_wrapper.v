`timescale 1ns / 1ps

module gnss_top_wrapper(
    sys_diff_clock_clk_p,
    sys_diff_clock_clk_n,
    reset
    );
    
    input  wire sys_diff_clock_clk_p;
    input  wire sys_diff_clock_clk_n;
    input  wire reset;
    
    wire clk_10p23;      // 10.23 MHz Pulse for C/A
    wire clk_1p023;      // 1.023 MHz Pulse for P
    wire pulse_50;       // 50 Hz Pulse for NAV data
  
    wire epoch_1ms;      // 1ms Epoch of ca_code
    wire epoch_6s;       // 6sec Epoch
    wire epoch_1p5;      // 1.5ms Epoch of P_code

    wire [36:0]ca_code; 
    wire [36:0]p_code;
    wire nav_data;
    reg  [1:0]data_ca;   // Xor of nav data & ca_code
    reg  [1:0]data_p;    // Xor of nav data & p_code
    wire [15:0]sine_out; // 4.092MHz Sine wave
    
    wire clk_40p92;
    wire en_start;
    wire epoch_6s_299_1;
    wire en_code;
    integer i;
    
    
    //wire epoch_tow;       // Time of week 

    
    ca_top_wrapper ca_uut (
            .clk         (clk_40p92 ),
            .rst         (reset     ),
            .clk_1p023   (clk_1p023 ),
            .en_start    (en_start  ),
            .en_code     (en_code   ),
            .ca_code     (ca_code   ),
            .epoch_1ms   (epoch_1ms)
    );
    
    p_top_wrapper p_uut(
            .clk         (clk_40p92),
            .rst         (reset    ),
            .clk_10p23   (clk_10p23),
            .en_start    (en_start ),
            .en_code     (en_code  ),
            .p_code      (p_code   )
            //.epoch_1p5   (epoch_1p5_t)
      );
      
      dds_compiler_0  uut3 (
             .aclk               (clk_40p92),
             .m_axis_data_tvalid (),
             .m_axis_data_tdata  (sine_out)
       );
      
       nav_sim_control uut4 (
            .sys_diff_clock_clk_p   (sys_diff_clock_clk_p),
            .sys_diff_clock_clk_n   (sys_diff_clock_clk_n),
            .reset                  (reset               ),
            .epoch_6s               (epoch_6s            ),
            .epoch_6s_299_1         (epoch_6s_299_1      ),
            .pulse_50               (pulse_50            ),
            .clk_40p92              (clk_40p92           ), // 40.92 MHz
            .en_start               (en_start            ),
            .nav_data               (nav_data            )
       );   
      
       epoch_1p5 uut5 (
           .clk         (clk_40p92),
           .rst         (reset    ),
           .epoch_1p5   (epoch_1p5)
       );
       
       epoch_50hz uut6 (
           .clk          (clk_40p92      ),
           .rst          (reset          ),
           .en_start     (en_start       ),
           .en_code      (en_code        ),
           .epoch_50hz   (pulse_50       ),
           .epoch_6s_299_1(epoch_6s_299_1)
       );
       
       epoch_6sec uut_7 (
           .clk          (clk_40p92),
           .rst          (reset    ),
           .epoch_1p5    (epoch_1p5),
           .epoch_6s     (epoch_6s )
    );
    
    always@(posedge clk_40p92 or posedge reset) begin
        if(reset) begin
            data_ca <= 0;
            data_p  <= 0;
        end
        else begin
            for(i=0; i<2; i=i+1) begin
                data_ca[i] <= nav_data ^ ca_code[i];
                data_p[i]  <= nav_data ^ p_code[i];
            end
        end
    end
    
endmodule



