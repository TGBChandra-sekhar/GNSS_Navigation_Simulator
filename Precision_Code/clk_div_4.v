`timescale 1ns / 1ps

module clk_div_4(
        clk,
        rst,
        clk_10p23
        );
    
    input clk,rst;
    output reg clk_10p23;
    
    reg [1:0]count;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            clk_10p23 <= 1'b0;
            count <= 2'd0;
        end
        else begin
            if(count == 2'd3) begin
                count <= 2'd0;
            end
            else begin
                count <= count + 2'd1;
            end
            
            clk_10p23 <= (count == 2'd0);
        end
    end
endmodule
