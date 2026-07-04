`timescale 1ns / 1ps

module nav_control_logic(
    sys_diff_clock_clk_n,
    sys_diff_clock_clk_p,
    reset
    );
    input sys_diff_clock_clk_n;
    input sys_diff_clock_clk_p;
    input reset;
    
    
    
    wire clk;
    wire BRAM_PORTB_7_clk;
    wire BRAM_PORTB_7_en;
    wire BRAM_PORTB_7_reset;
    wire [31:0]BRAM_PORTB_7_dout;
    
    reg [31:0]BRAM_PORTB_7_addr;
    reg [31:0]BRAM_PORTB_7_din;
    reg [3:0]BRAM_PORTB_7_we;
    reg     we_7;
    reg epoch_6s;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initial state
            BRAM_PORTB_7_addr <= 32'd0;
            BRAM_PORTB_7_din  <= 32'd0;         // request nav data
            BRAM_PORTB_7_we   <= 4'h0;         // write control word
            we_7              <= 1'b0;         // control-write phase
        end
        else begin
            /* --------------------------------------------------
               STEP 1: Write REQUEST control word (only once)
            -------------------------------------------------- */
            if (epoch_6s) begin
                BRAM_PORTB_7_addr <= 32'd0;
                BRAM_PORTB_7_din  <= 32'hCDCD;
                BRAM_PORTB_7_we   <= 4'hF;

                // Move to wait phase
                we_7 <= 1'b1;
            end

            /* --------------------------------------------------
               STEP 2: Wait for MicroBlaze DONE control word
            -------------------------------------------------- */
            else if ((BRAM_PORTB_7_addr == 32'd0) && (BRAM_PORTB_7_dout != 32'h0CEDCEDC)) begin
                BRAM_PORTB_7_we   <= 4'h0; // read-only
                BRAM_PORTB_7_addr <= 32'd0; // keep polling
            end

            /* --------------------------------------------------
               STEP 3: DONE detected → start reading nav data
            -------------------------------------------------- */
            else if (BRAM_PORTB_7_dout == 32'h0CEDCEDC) begin
                BRAM_PORTB_7_addr <= 32'd4; // first nav data word
                BRAM_PORTB_7_we   <= 4'h0; // read-only
            end

            /* --------------------------------------------------
               STEP 4: Sequentially read nav data frames
            -------------------------------------------------- */
            else if ((BRAM_PORTB_7_addr >= 32'd4) && (BRAM_PORTB_7_addr < 32'd28)) begin
                BRAM_PORTB_7_addr <= BRAM_PORTB_7_addr + 32'd4;
                BRAM_PORTB_7_we   <= 4'h0;
            end
            
             else if(BRAM_PORTB_7_addr == 32'h28) begin
                BRAM_PORTB_7_addr <= 32'd0;
                BRAM_PORTB_7_din  <= 32'd0;
                BRAM_PORTB_7_we   <= 4'hF;
                we_7              <= 1'b1;
            end
            /* --------------------------------------------------
               STEP 5: All data read → restart protocol
            -------------------------------------------------- */
            else begin
                BRAM_PORTB_7_addr <= 32'd0;
                BRAM_PORTB_7_din  <= 32'd0;
                BRAM_PORTB_7_we   <= 4'h0;
                we_7              <= 1'b0;
            end
        end
    end
endmodule