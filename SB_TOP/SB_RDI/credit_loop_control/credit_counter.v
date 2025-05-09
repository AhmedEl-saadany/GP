module credit_counter (
/**************************************
 * INPUTS
**************************************/
    input           i_clk,
    input           i_rst_n,
    // Adapter related signals
    input           i_lp_cfg_crd,
    // Sideband rdi rx related signals
    input           i_rising_edge_pl_cfg_vld,
/**************************************
 * OUTPUTS
**************************************/
    // Sideband rdi rx related signals
    output          o_adapter_is_full
);
/*******************************************
 * INTERNAL WIRES/REGISTERS
*******************************************/
reg [5:0] adapter_avaliable_credits;
/*******************************************
 * ASSIGN/WIRE STATMENTS
*******************************************/
assign o_adapter_is_full = (~|adapter_avaliable_credits); // this signal will be one only if counter = 0
/*******************************************
 * ADAPTER AVALIABLE CREDITS COUNTER
*******************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        adapter_avaliable_credits <= 6'd32; // initially there is a 32 credits for each side of the interface 
    end else if (i_lp_cfg_crd) begin
        adapter_avaliable_credits <= adapter_avaliable_credits + 1;
    end else if (i_rising_edge_pl_cfg_vld && ~o_adapter_is_full) begin // each rising edge wether for data or not, consumes 1 credit 
        adapter_avaliable_credits <= adapter_avaliable_credits - 1;
    end
end

endmodule