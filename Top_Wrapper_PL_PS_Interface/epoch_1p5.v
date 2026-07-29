`timescale 1ns / 1ps


module epoch_1p5 (
            clk,
            rst,
            epoch_1p5
       );

    input clk;
    input rst;
    output reg epoch_1p5;

    reg [25:0]count;  //  1.5s / 24ns = 61380000
        
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            epoch_1p5 <= 1'b0;
            count <= 26'd0;     
        end 
        else begin
            if (count == 26'd61379999) begin
                epoch_1p5 <= 1'b1;
                count <= 26'd0;          
            end
            else begin
                epoch_1p5 <= 1'b0;
                count <= count + 26'd1;  
            end
        end   
             
    end
 endmodule   




