module Clock_Divider_by_4 (
    input      i_pll_clk,          // Input clock from PLL (800 MHz)
    input      i_rst_n,            // Active-low reset
    output     o_divided_clk       // Divided clock (100 MHz)
);

/*------------------------------------------------------------------------------
-- INTERNAL WIRES & REGS   
------------------------------------------------------------------------------*/
reg [1:0] shift_reg;   

/*------------------------------------------------------------------------------
-- Clock Divider logic   
------------------------------------------------------------------------------*/
always @(posedge i_pll_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        shift_reg <= 0;
    end else begin
        shift_reg <= {~shift_reg[0],shift_reg[1]};
    end
end

assign o_divided_clk = shift_reg[0];

endmodule
