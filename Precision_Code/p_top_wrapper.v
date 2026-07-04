`timescale 1ns / 1ps

module p_top_wrapper (
        clk,
        rst,
        clk_10p23,
        en_start,
        en_code,
        epoch_1p5,
        p_code
        //epoch_x1,
        //epoch_x2,
      );
      
    input  clk;
    input  rst;
    input  clk_10p23;
    input  en_start;
    input  en_code;
    output epoch_1p5;
    output reg [37:1] p_code;
    //output epoch_x1;
    //output epoch_x2;
    
    wire epoch_x1;
    wire epoch_x2;
    
    wire        x1_out;
    wire [37:1] x2_out;
    integer     i;
    
    clk_div_4 uut1 (
        .clk       (clk),
        .rst       (rst),
        .en_start  (en_start),
        .clk_10p23 (clk_10p23)
    );
    
    x1_register uut2 (
        .clk        (clk      ),
        .rst        (rst      ),
        .en_code    (en_code  ),
        .epoch_1p5  (epoch_1p5),
        .clk_10p23  (clk_10p23),
        .x1_out     (x1_out   ),
        .epoch_x1   (epoch_x1 )
    );
    
    x2_register uut3 (
        .clk        (clk      ),
        .rst        (rst      ),
        .en_code    (en_code  ),
        .epoch_1p5  (epoch_1p5),
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
