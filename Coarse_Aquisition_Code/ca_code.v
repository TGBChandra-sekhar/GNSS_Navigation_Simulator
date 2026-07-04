`timescale 1ns / 1ps

module ca_code(                
         clk, 
         rst, 
         en_code,
         clk_1p023,
         epoch_1ms,
         ca_code         
       );
       
    input      clk;
    input      rst;
    input      en_code;      // Enables ca_code when High
    input      clk_1p023; 
    output reg epoch_1ms;    // pulse at every 1 ms (end of one prn)
    output reg [36:0]ca_code;

    reg [9:0] g1;
    reg [9:0] g2;
    reg [9:0] count_1ms;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            ca_code     <= 37'd0;
            count_1ms       <= 10'd0;
            epoch_1ms  <= 1'b0;
            // Initial Conditions( All 1's)
            g1          <= 10'h3ff;  
            g2          <= 10'h3ff;
        end
        else if(clk_1p023 && en_code)begin
        
            // G1 with 0th bit as output and G2 have different Tap Combinations  
            ca_code[0]  <= g1[0]^g2[4]^g2[8]; 
            ca_code[1]  <= g1[0]^g2[7]^g2[3];
            ca_code[2]  <= g1[0]^g2[6]^g2[2];
            ca_code[3]  <= g1[0]^g2[5]^g2[1];
            ca_code[4]  <= g1[0]^g2[9]^g2[1];
            ca_code[5]  <= g1[0]^g2[8]^g2[0];
            ca_code[6]  <= g1[0]^g2[9]^g2[2];
            ca_code[7]  <= g1[0]^g2[8]^g2[1];
            ca_code[8]  <= g1[0]^g2[7]^g2[0];
            ca_code[9]  <= g1[0]^g2[8]^g2[7];
            
            ca_code[10] <= g1[0]^g2[7]^g2[6];
            ca_code[11] <= g1[0]^g2[5]^g2[4];
            ca_code[12] <= g1[0]^g2[4]^g2[3];
            ca_code[13] <= g1[0]^g2[3]^g2[2];
            ca_code[14] <= g1[0]^g2[2]^g2[1];
            ca_code[15] <= g1[0]^g2[1]^g2[0];
            ca_code[16] <= g1[0]^g2[9]^g2[6];
            ca_code[17] <= g1[0]^g2[8]^g2[5];
            ca_code[18] <= g1[0]^g2[7]^g2[4];
            ca_code[19] <= g1[0]^g2[6]^g2[3];
            
            ca_code[20] <= g1[0]^g2[5]^g2[2];
            ca_code[21] <= g1[0]^g2[4]^g2[1];
            ca_code[22] <= g1[0]^g2[9]^g2[7];
            ca_code[23] <= g1[0]^g2[6]^g2[4];
            ca_code[24] <= g1[0]^g2[5]^g2[3];
            ca_code[25] <= g1[0]^g2[4]^g2[2];
            ca_code[26] <= g1[0]^g2[3]^g2[1];
            ca_code[27] <= g1[0]^g2[2]^g2[0];
            ca_code[28] <= g1[0]^g2[9]^g2[4];
            ca_code[29] <= g1[0]^g2[8]^g2[3];
           
            ca_code[30] <= g1[0]^g2[7]^g2[2];
            ca_code[31] <= g1[0]^g2[6]^g2[1];
            ca_code[32] <= g1[0]^g2[5]^g2[0];
            ca_code[33] <= g1[0]^g2[6]^g2[0];
            ca_code[34] <= g1[0]^g2[9]^g2[3];
            ca_code[35] <= g1[0]^g2[8]^g2[2];
            ca_code[36] <= g1[0]^g2[6]^g2[0];            
            
            g1 <= {(g1[0]^g1[7]),g1[9:1]};                          //feed_g1 = g1[8]^g1[4];
            g2 <= {(g2[0]^g2[1]^g2[2]^g2[4]^g2[7]^g2[8]),g2[9:1]};  //feed_g2 = g2[0]^g2[1]^g2[2]^g2[4]^g2[7]^g2[8];

            if(count_1ms  == 10'd1022) begin        
                count_1ms <= 10'd0;                 
            end                                 
            else begin
                count_1ms <= count_1ms+1;
            end
            epoch_1ms <= (count_1ms== 10'd1022);   // 1ms EPoch at end of each Prn Sequence
        end
    end  
endmodule

