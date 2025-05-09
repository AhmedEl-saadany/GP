module clk_handshake (
/**************************************
 * INPUTS
**************************************/
    input               i_clk,         
    input               i_rst_n,    
    // Adapter related signals
    input               i_lp_clk_ack,  
    // RDI FSM related signals
    input               i_en,
/**************************************
 * OUTPUTS
**************************************/
    // Adapter related signals
    output reg          o_pl_clk_req,
    output              o_adapter_is_waked_up
);
/*******************************************
 * FSM STATES
*******************************************/
localparam IDLE = 1'b0;
localparam REQ  = 1'b1;
/*******************************************
 * INTERNAL WIRES/REGISTERS
*******************************************/
reg CS;
reg NS;
/*******************************************
 * ASSIGN/WIRE STATMENTS
*******************************************/
assign o_adapter_is_waked_up = i_lp_clk_ack;
/*******************************************
 * STATE MEMORY
*******************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        CS <= IDLE;
    end else begin
        CS <= NS;
    end
end
/*******************************************
 * NEXT STATE LOGIC
*******************************************/
always @ (*) begin
    case (CS)
    IDLE: NS = (i_en)? REQ : IDLE;
    REQ : NS = (~i_en)? IDLE : REQ;
    endcase
end
/*******************************************
 * OUTPUT LOGIC
*******************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        o_pl_clk_req <= 1'b0;
    end else begin
        o_pl_clk_req <= (CS == REQ);
    end
end




endmodule 