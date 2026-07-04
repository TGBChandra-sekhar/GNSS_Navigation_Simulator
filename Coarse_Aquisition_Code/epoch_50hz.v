`timescale 1ns / 1ps

module epoch_50hz (
            clk,
            rst,
            en_start,
            en_code,
            epoch_50hz,
            epoch_6s_299_1
        );    
    
    input clk;
    input rst;
    input en_start;
    output reg en_code;
    output reg epoch_50hz;
    output reg epoch_6s_299_1;

    reg [19:0]count_50;
        
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            epoch_50hz <= 1'b0;
            count_50 <= 20'd0;     
        end
        else if (en_start) begin
            if (count_50 == 20'd818399) begin
                count_50 <= 20'd0;          
            end
            else begin
                count_50 <= count_50 + 20'd1; 
                if(count_50 == 20'd0) begin
                    epoch_50hz <= 1'b1;
                    en_code <= 1'b1;    // Stay High forever
                end
                else begin
                    epoch_50hz <= 1'b0;
                end
            end
            epoch_6s_299_1 <= (count_50 == 20'd1);
        end            
    end
 endmodule 
