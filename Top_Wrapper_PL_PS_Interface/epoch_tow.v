`timescale 1ns / 1ps

module epoch_tow (
        clk,
        rst,
        epoch_1p5,
        epoch_tow
    );
    
    input clk;
    input rst;
    input epoch_1p5;
    output reg epoch_tow;
    
    reg [1:0]count;
        
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            epoch_tow <= 1'd0;
            count <= 2'd0;
        end
        else begin
            if(epoch_1p5) begin
                if(count == 3) begin
                    count <= 2'b0;
                 end
                 else begin
                    count <= count + 2'd1;  
                 end

                epoch_tow <= (count == 2'd0); 
            end   
        end
     end  
endmodule
