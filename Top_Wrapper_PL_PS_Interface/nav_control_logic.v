`timescale 1ns / 1ps

module nav_sim_control(
    sys_diff_clock_clk_n,
    sys_diff_clock_clk_p,
    reset,
    epoch_6s,
    epoch_6s_299_1,
    pulse_50,
    clk_out,
    en_start,
    nav_data
    );
    
    input  sys_diff_clock_clk_n;  // 40.92 MHz Diff. Clock
    input  sys_diff_clock_clk_p;
    input  reset;
    input  epoch_6s;              // Will initiates the entire process(for the 1st time)
    input  epoch_6s_299_1;        // Will re-initiates the same process(from 2nd time)
    input  pulse_50;              // Pulse 50 Hz 
    output clk_out;               // Single ended clk (40.92 MHz) from Block design
    output reg en_start;          // To initiate the 50Hz epoch
    output reg nav_data;
    
    
    wire clk_i;                   // used for always block
    reg  en_code;                 // Enables Prn Code
    reg  en_read_nav;             // Enables nav data seriallization  
    reg  nav_epoch;               // Epoch at the end of one frame (5 sub frames)      
    reg  [8:0]count_300;
    reg  [29:0]p_s1,p_s2,p_s3,p_s4,p_s5,p_s6,p_s7,p_s8,p_s9,p_s10;  // Temporary Registers 
    reg  en_load;
    
    wire BRAM_PORTB_0_clk;
    wire BRAM_PORTB_0_en;
    wire BRAM_PORTB_0_rst;
    reg  [31:0]BRAM_PORTB_0_addr;
    reg  [31:0]BRAM_PORTB_0_din;
    reg  [3:0]BRAM_PORTB_0_we;
    wire [31:0]BRAM_PORTB_0_dout;
    //reg [31:0] addr_r ;           //..

        
     design_1 mb_uut (
        .BRAM_PORTB_0_addr     (BRAM_PORTB_0_addr),
        .BRAM_PORTB_0_clk      (BRAM_PORTB_0_clk ),
        .BRAM_PORTB_0_din      (BRAM_PORTB_0_din ),
        .BRAM_PORTB_0_dout     (BRAM_PORTB_0_dout),
        .BRAM_PORTB_0_en       (BRAM_PORTB_0_en  ),
        .BRAM_PORTB_0_rst      (BRAM_PORTB_0_rst ),
        .BRAM_PORTB_0_we       (BRAM_PORTB_0_we  ),
        .clk_out               (clk_out),
        .diff_clock_rtl_2_clk_n(sys_diff_clock_clk_n),
        .diff_clock_rtl_2_clk_p(sys_diff_clock_clk_p),
        .reset_rtl_0           (reset)
        );   
        
        
   assign BRAM_PORTB_0_clk = clk_out;     // PLL/MMCM outputs in Vivado MUST go through a BUFG to be used as a fabric clock
   assign clk_i = clk_out;                // Otherwise it will make net as "Z"
   
    
    //BUFG BUFG_inst1 (
    //  .O(clk_i),             
    //  .I(clk_out)            
    //);
    //
    //BUFG BUFG_inst2 (
    //   .O(BRAM_PORTB_0_clk), 
    //   .I(clk_out)           
    //);
    //
    assign clk_out = clk_i;  // To extract out
    assign BRAM_PORTB_0_en = 1;
    assign BRAM_PORTB_0_rst = reset;
    
    always @(posedge clk_i or posedge reset) begin
        if (reset) begin
            BRAM_PORTB_0_addr <= 32'd0;
            BRAM_PORTB_0_din  <= 32'd0;        
            BRAM_PORTB_0_we   <= 4'h0; 
        end
        else begin
            // FPGA -> MB Request
            
            //epoch_6s && !en_read_nav    >> Initial Condition to write the FPGA control word
            //(epoch_6s_299_1)&&(en_read_nav)&&(count_300 == 9'd299)  >> Writing the FPGA control word at 299th bit (it avoids delay)
            
            if ((epoch_6s && !en_read_nav) || 
               (epoch_6s_299_1)&&(en_read_nav)&&(count_300 == 9'd299)) begin
                BRAM_PORTB_0_addr <= 32'd0;
                BRAM_PORTB_0_din  <= 32'hCDCD;      // FPGA Control Word to MB
                BRAM_PORTB_0_we   <= 4'hF;          // Write into 0th location
                count_300         <= 9'd0; //..
            end
            
            // Poll for MB Done 
            else if ((BRAM_PORTB_0_addr == 32'd0) && (BRAM_PORTB_0_dout != 32'h0CEDCEDC)) begin
                BRAM_PORTB_0_addr <= 32'd0;            // FPGA keep polling to 0th location for MB control word
                BRAM_PORTB_0_we   <= 4'h0;  // read-only
            end
            
            // MB done -> Start Reading
            else if (BRAM_PORTB_0_dout == 32'h0CEDCEDC && BRAM_PORTB_0_addr != 32'd4) begin
                BRAM_PORTB_0_addr <= 32'd4;           // first nav data sub frame starts at 4
                BRAM_PORTB_0_we   <= 4'h0;   // read only
            end
            
            // Read Nav Data
            else if ((BRAM_PORTB_0_addr >= 32'd4) && (BRAM_PORTB_0_addr < 32'd44)) begin
                BRAM_PORTB_0_addr <= BRAM_PORTB_0_addr + 32'd4;  // (+4 increment for each subframe)
                BRAM_PORTB_0_we   <= 4'h0;   // Read only
            end
            
            // End of Frame
             else if(BRAM_PORTB_0_addr == 32'h44) begin
                BRAM_PORTB_0_addr <= 32'd0;
                BRAM_PORTB_0_din  <= 32'd0;
                BRAM_PORTB_0_we   <= 4'hF;
            end
            
            else begin
                BRAM_PORTB_0_addr <= 32'd0;
                BRAM_PORTB_0_din  <= 32'd0;
                BRAM_PORTB_0_we   <= 4'h0;
            end
            
        end
    end
    
    // Parallel loading of 30bit data into registers(10)
    always @(posedge clk_i or posedge reset) begin
        if(reset) begin
            {p_s1,p_s2,p_s3,p_s4,p_s5,p_s6,p_s7,p_s8,p_s9,p_s10} <= 300'd0; 
            en_read_nav <= 1'b0;  
            en_load <= 1'b0;
            nav_data  <= 1'b0;
            count_300 <= 9'd0;
        end
        else begin
        
            case (BRAM_PORTB_0_addr && en_load)
                32'd8  : begin 
                            p_s1 <= BRAM_PORTB_0_dout[29:0];
                            en_read_nav <= 1'b0;  // Stays at "1" forever
                            en_start <= 1'b1;     // Stays at "1" forever
                         end 
                32'd12 : p_s2 <= BRAM_PORTB_0_dout[29:0];
                32'd16 : p_s3 <= BRAM_PORTB_0_dout[29:0];
                32'd20 : p_s4 <= BRAM_PORTB_0_dout[29:0];
                32'd24 : p_s5 <= BRAM_PORTB_0_dout[29:0];
                32'd28 : p_s6 <= BRAM_PORTB_0_dout[29:0];
                32'd32 : p_s7 <= BRAM_PORTB_0_dout[29:0];
                32'd36 : p_s8 <= BRAM_PORTB_0_dout[29:0];
                32'd40 : p_s9 <= BRAM_PORTB_0_dout[29:0];
                32'd44 : p_s10 <= BRAM_PORTB_0_dout[29:0];
            endcase
            
            if(pulse_50) begin   
            if(count_300 == 9'd299) begin   // Total nav data frame = 300 bits
                count_300   <= 9'd0;
            end
            else begin
                count_300 <= count_300 + 1;
                
                // Parallel to Serial Conversion
                if(count_300 >= 9'd0 && count_300<= 9'd29) begin
                    nav_data <= p_s1[29];
                    p_s1     <= {p_s1[28:0],1'b0};
                end
                else if(count_300 >= 9'd30 && count_300<= 9'd59) begin
                    nav_data <= p_s2[29];
                    p_s2     <= {p_s2[28:0],1'b0};
                end
                else if(count_300 >= 9'd60 && count_300<= 9'd89) begin
                    nav_data <= p_s3[29];
                    p_s3     <= {p_s3[28:0],1'b0};
                end
                else if(count_300 >= 9'd90 && count_300<= 9'd119) begin
                    nav_data <= p_s4[29];
                    p_s4     <= {p_s4[28:0],1'b0};
                end
                else if(count_300 >= 9'd120 && count_300<= 9'd149) begin
                    nav_data <= p_s5[29];
                    p_s5     <= {p_s5[28:0],1'b0};
                end
                else if(count_300 >= 9'd150 && count_300<= 9'd179) begin
                    nav_data <= p_s6[29];
                    p_s6     <= {p_s6[28:0],1'b0};
                end
                else if(count_300 >= 9'd180 && count_300<= 9'd209) begin
                    nav_data <= p_s7[29];
                    p_s7     <= {p_s7[28:0],1'b0};
                end
                else if(count_300 >= 9'd210 && count_300<= 9'd239) begin
                    nav_data <= p_s8[29];
                    p_s8     <= {p_s8[28:0],1'b0};
                end
                else if(count_300 >= 9'd240 && count_300<= 9'd269) begin
                    nav_data <= p_s9[29];
                    p_s9     <= {p_s9[28:0],1'b0};
                end
                else if(count_300 >= 9'd270 && count_300<= 9'd299) begin
                    nav_data <= p_s10[29];
                    p_s10    <= {p_s10[28:0],1'b0};
                    
                    
                end
                else begin
                    nav_data <= 1'b0;
                end
            end  // end- else
        end      // end- else if(pulse_50)
                             
        nav_epoch <= count_300 == 9'd0;
        end    
    end
    
    
endmodule
