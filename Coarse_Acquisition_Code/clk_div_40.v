`timescale 1ns / 1ps

//module clk_div_40 (
//        clk,
//        rst,
//        clk_out
//    );
    
//    input clk,rst;
//    output reg clk_out;
    
//    parameter integer N = 40;
//    localparam integer COUNT_MAX = N - 1;    
//    localparam integer count_w = $clog2(N);  
    
//    reg [count_w-1:0]count;  //[5:0]
    
//    always @(posedge clk or posedge rst) begin
//        if(rst) begin
//            clk_out <= 1'b0;
//            count <= 'b0;
//        end
//        else begin
//            if(count == COUNT_MAX) begin
//                clk_out <= 1'b1;
//                count <= 'd0;
//            end
//            else begin
//                clk_out <= 1'b0;
//                count <= count + 'd1;
//            end
//        end
//    end
//endmodule


module clk_div_40 (
            clk,        
            rst,
            clk_1p023   
        );

    input clk;       // 40.92 MHz
    input rst;
    output reg  clk_1p023; // 1.023 MHz

    reg [5:0] count;  // count => 0 - 39 

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count      <= 6'd0;
            clk_1p023  <= 1'b0;
        end
        else begin
            if (count  == 6'd39) begin
                count  <= 6'd0;          
            end
            else begin
                count  <= count + 6'd1;  
            end
            clk_1p023  <= (count == 6'd0); 
        end
    end

endmodule




