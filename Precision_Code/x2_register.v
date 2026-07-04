`timescale 1ns / 1ps

module x2_register(
        clk,
        rst,
        en_code,
        epoch_1p5,
        clk_10p23,
        x2_out,
        epoch_x2
    );
    
    input clk,rst;
    input clk_10p23;             // 10.23 MHz Pulse                   
    input en_code;               // Enables P_code                   
    output reg epoch_1p5;        // 1.5 ms Epoch                      
    output reg [37:1]x2_out;     // Output of X2 reg                  
    output reg epoch_x2;         // Epoch at end of each X2 sequence  
    
    reg [37:1]delay;            // x2 sequnce length is 15345037
    
    reg [11:0]x2_a,x2_b;
    
    reg [11:0] count_x2_a;
    reg [11:0] count_x2_b;
    reg [11:0] count_3750;
    reg [23:0] count_24;
    reg [8:0]  count_380;
    

    integer i;
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            // Initial Conditions
            x2_a       <= 12'b101001001001;
            x2_b       <= 12'b001010101010;
            
            x2_out     <= 37'd0; 
            delay      <= 37'h1fffffffff;
            count_x2_a <= 12'd1;
            count_x2_b <= 12'd1;
            count_3750 <= 12'd1;
            count_24   <= 24'd1;  
            count_380  <= 9'd0; 
            epoch_x2   <= 1'b0;
            epoch_1p5  <= 1'b0;
            
        end
        else begin
            if(clk_10p23 && en_code) begin
            
                delay[1]    <= x2_a[0] ^ x2_b[0];      //37-bit shift register for delaying        
                delay[37:2] <= delay[36:1];            
                
                for ( i= 1; i < 38 ; i = i + 1) begin
                    x2_out[i]  <= delay[i];  // i-cycle delay
                end
                        
                if(count_x2_a  == 12'd4092) begin
                    x2_a       <= 12'b101001001001;
                    count_x2_a <= 12'd1;
                end
                else begin
                    x2_a       <= {(x2_a[0]^x2_a[1]^x2_a[4]^x2_a[6]),x2_a[11:1]};
                    count_x2_a <= count_x2_a + 12'd1;
                end
                
                epoch_x2       <= (count_x2_a == 12'd4091);                 

                if(count_24 < 24'd15344657) begin
                    if(count_x2_b  == 12'd4093) begin
                        x2_b       <= 12'b001010101010;
                        count_x2_b <= 12'd1; 
                    end
                    else begin
                        x2_b       <= {(x2_b[0]^x2_b[1]^x2_b[2]^x2_b[3]^x2_b[4]^x2_b[7]^x2_b[10]^x2_b[11]), x2_b[11:1]};
                        count_x2_b <= count_x2_b + 12'd1; 
                    end
                end
                else begin
                    if(count_380 < 9'd381 ) begin                    
                        x2_b       <= x2_b;
                        count_380  <= count_380 + 9'd1;
                        count_x2_b <= (count_x2_b == 12'd4093)? 12'd1 : count_x2_b + 12'd1; 
                    end
                    else begin
                        x2_b       <= 12'b001010101010;
                        count_380  <= 9'd1; 
                        count_x2_b <= 12'd1; 
                    end
                end      
                
            
                if(count_24 == 24'd15345037) begin
                    count_24   <= 24'd1;
                        x2_a   <= 12'b101001001001;
                        x2_b   <= 12'b001010101010;
                        x2_out <= 'd0;
                        
                        count_x2_a <= 12'd1;
                        count_x2_b <= 12'd1;
                        
                        count_24   <= 24'd1;  
                        count_380  <= 9'd0;
                end
                else begin
                    count_24 <= count_24 + 24'd1;
                end
                
//                count_24 <= (count_24 == 24'd15345037)? count_24 <= 24'd1 : count_24 <= count_24 + 24'd1;
                
                if(epoch_x2) begin
                    count_3750 <= (count_3750 == 12'd3750)? 24'd1: count_3750 + 12'd1;
                end  
                    epoch_1p5 <= (count_3750 == 12'd3750);
                                        

            end 
         end  
       end       
endmodule
