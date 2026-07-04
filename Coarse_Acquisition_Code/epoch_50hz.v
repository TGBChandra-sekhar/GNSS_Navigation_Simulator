`timescale 1ns / 1ps

module epoch_50hz (
            clk,
            rst,
            epoch_50hz
        );    
    
    input clk;
    input rst;
    output reg epoch_50hz;

    reg [19:0]count;
        
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            epoch_50hz <= 1'b0;
            count <= 20'd0;     
        end
        else begin
            if (count == 20'd818399) begin
                count <= 20'd0;          
            end
            else begin
                count <= count + 20'd1;  
            end

            epoch_50hz <= (count == 20'd0); 
        end            
    end
 endmodule 
