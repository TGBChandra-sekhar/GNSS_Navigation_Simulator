`timescale 1ns / 1ps

module p_top_wrapper (
        clk,
        rst,
        en_code,
        epoch_x1,
        epoch_x2,
        p_code
      );
      
    input clk;
    input rst;
    input en_code;
    output epoch_x1;
    output epoch_x2;
    output reg [37:1] p_code;
    
    wire        clk_10p23;
    wire        x1_out;
    wire [37:1] x2_out;
    integer     i;
    
    clk_div_4 uut1 (
        .clk       (clk),
        .rst       (rst),
        .clk_10p23 (clk_10p23)
    );
    
    x1_register uut2 (
        .clk        (clk      ),
        .rst        (rst      ),
        .en_code    (en_code  ),
        .clk_10p23  (clk_10p23),
        .x1_out     (x1_out   ),
        .epoch_x1   (epoch_x1 )
    );
    
    x2_register uut3 (
        .clk        (clk      ),
        .rst        (rst      ),
        .en_code    (en_code  ),
        .clk_10p23  (clk_10p23),
        .x2_out     (x2_out   ),
        .epoch_x2   (epoch_x2 )
    );
    
   
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            p_code <= 1'b0;
        end
        else begin
            if(clk_10p23 && en_code) begin
                for ( i= 1; i < 38 ; i = i + 1) begin
                    p_code[i] <= x1_out ^ x2_out[i];  // i-cycle delay
                end                                        
            end
        end
    end  
endmodule
