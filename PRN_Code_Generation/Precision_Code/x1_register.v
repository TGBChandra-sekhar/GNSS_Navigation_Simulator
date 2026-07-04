`timescale 1ns / 1ps

module x1_register(
        clk,
        rst,
        en_code,
        clk_10p23,
        x1_out,
        epoch_x1
    );
    
    input clk,rst;
    input en_code;
    input clk_10p23;
    output reg x1_out;
    output reg epoch_x1;
    
    reg [11:0]x1_a,x1_b;
    
    reg [11:0] count_x1_a;
    reg [11:0] count_x1_b;
    reg [11:0] count_3750;
    reg [23:0] count_24;
    reg [8:0]  count_343;
    
    reg pulse_1p5;
    
    wire clk_10p23;
    
//    clk_div_4 uut (
//            .clk       (clk),
//            .rst       (rst),
//            .clk_10p23 (clk_10p23)
//    );
    
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
          
            x1_a   <= 12'b000100100100;
            x1_b   <= 12'b001010101010;
            x1_out <= 1'b0;
            
            count_x1_a <= 12'd1;
            count_x1_b <= 12'd1;
            count_3750 <= 12'd1;
            count_24   <= 24'd1;  
            count_343  <= 9'd0; 
            epoch_x1   <= 1'b0;
            pulse_1p5  <= 1'b0;
            
        end
        else begin
            if(clk_10p23 && en_code) begin
            
                x1_out <= x1_a[0] ^ x1_b[0];
                
                        
                if(count_x1_a == 12'd4092) begin
                    x1_a <= 12'b000100100100;
                    count_x1_a <= 12'd1;
                end
                else begin
                    x1_a <= {(x1_a[0]^x1_a[1]^x1_a[4]^x1_a[6]),x1_a[11:1]};
                    count_x1_a <= count_x1_a + 12'd1;
                end
                
                epoch_x1 <= (count_x1_a == 12'd4091);                 

                if(count_24 < 24'd15344657) begin
                    if(count_x1_b == 12'd4093) begin
                        x1_b <= 12'b001010101010;
                        count_x1_b <= 12'd1; 
                    end
                    else begin
                        x1_b <= {(x1_b[0]^x1_b[1]^x1_b[2]^x1_b[3]^x1_b[4]^x1_b[7]^x1_b[10]^x1_b[11]), x1_b[11:1]};
                        count_x1_b <= count_x1_b + 12'd1; 
                    end
                end
                else begin
                    if(count_343 < 9'd344 ) begin                    
                        x1_b <= x1_b;
                        count_343 <= count_343 + 9'd1;
                        count_x1_b <= (count_x1_b == 12'd4093)? 12'd1 : count_x1_b + 12'd1; 
                    end
                    else begin
                        x1_b <= 12'b001010101010;
                        count_343 <= 9'd1; 
                        count_x1_b <= 12'd1; 
                    end
                end      
            
//                if(count_24 == 24'd15345000) begin
//                    count_24 <= 24'd1;
//                end
//                else begin
//                    count_24 <= count_24 + 24'd1;
//                end
                
                count_24 <= (count_24 == 24'd15345000)? count_24 <= 24'd1 : count_24 <= count_24 + 24'd1;
                
                if(epoch_x1) begin
                    if(count_3750 == 12'd3750) begin
                        x1_a <= 12'b000100100100;
                        x1_b <= 12'b001010101010;
                        x1_out <= 1'b0;
                        
                        count_x1_a <= 12'd1;
                        count_x1_b <= 12'd1;
                        count_3750 <= 24'd1;
                        count_24   <= 24'd1;  
                        count_343  <= 9'd0; 
                        //epoch_x1   <= 1'b0;
                        //pulse_1p5  <= 1'b1;
                    end
                    else begin
                        count_3750 <= count_3750 + 12'd1;
                    end
                    pulse_1p5 <= (count_3750 == 12'd3750);
                end                        

            end 
         end  
       end       
endmodule
