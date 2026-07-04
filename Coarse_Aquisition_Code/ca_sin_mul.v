`timescale 1ns / 1ps

module ca_sin_mul(
             clk,             
             rst,             
             prn_sel,    
             prn,       
             sine_signal,
             mul_out
       );
       
    input             clk;             
    input             rst;
    input      [5:0]  prn_sel;       // 0 - 36 prn_codes
    input      [36:0] prn;           // C/A code
    input      [15:0] sine_signal;   // Sine carrier of 4.092 MHz
    output reg [15:0] mul_out;       // BPSK Modulated Output

    
    always@(posedge clk or posedge rst) begin
        if(rst) 
            mul_out <= 16'd0;
        else begin
            case(prn_sel)
                6'd0 : begin                          // BPSK Logic 
                    if(prn[0] == 0)                   
                        mul_out <= sine_signal;       // Sine wave as it is
                    else 
                        mul_out <= ~sine_signal + 1;  // 2's Complement of Sine
                end
                6'd1 : begin
                    if(prn[1] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd2 : begin
                    if(prn[2] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd3 : begin
                    if(prn[3] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd4 : begin
                    if(prn[4] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd5 : begin
                    if(prn[5] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd6 : begin
                    if(prn[6] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd7 : begin
                    if(prn[7] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd8 : begin
                    if(prn[8] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd9 : begin
                    if(prn[9] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd10 : begin
                    if(prn[10] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd11 : begin
                    if(prn[11] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd12 : begin
                    if(prn[12] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd13 : begin
                    if(prn[13] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd14 : begin
                    if(prn[14] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd15 : begin
                    if(prn[15] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd16 : begin
                    if(prn[16] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd17 : begin
                    if(prn[17] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd18 : begin
                    if(prn[18] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd19 : begin
                    if(prn[19] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd20 : begin
                    if(prn[20] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd21 : begin
                    if(prn[21] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd22 : begin
                    if(prn[22] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd23 : begin
                    if(prn[23] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd24 : begin
                    if(prn[24] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd25 : begin
                    if(prn[25] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd26 : begin
                    if(prn[26] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd27 : begin
                    if(prn[27] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd28 : begin
                    if(prn[28] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd29 : begin
                    if(prn[29] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd30 : begin
                    if(prn[30] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd31 : begin
                    if(prn[31] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd32 : begin
                    if(prn[32] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd33 : begin
                    if(prn[33] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd34 : begin
                    if(prn[34] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end
                6'd35 : begin
                    if(prn[35] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end 
                6'd36 : begin
                    if(prn[36] == 0)
                        mul_out <= sine_signal;
                    else 
                        mul_out <= ~sine_signal + 1;
                end  
                default: mul_out <= mul_out;
             endcase        
         end
    end 
endmodule
