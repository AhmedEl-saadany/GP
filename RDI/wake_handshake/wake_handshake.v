module wake_handshake (
/**************************************
 * INPUTS
**************************************/
    input           i_clk,
    input           i_rst_n,
    // Adapter related signals
    input   [3:0]   i_lp_state_req,
    input           i_lp_wake_req,
    // RDI FSM related signals
    input   [3:0]   i_pl_state_sts,
    // Sideband related signals
    input           i_sb_msg_valid,
    // LTSM related signals
    input           i_ltsm_is_waked_up, // after passing o_clk_gate_en onto 2-flop sync using dig_clk we will return it back using toggle sync to besure that MB is ungated
    input           i_ltsm_in_reset,
/**************************************
 * OUTPUTS
**************************************/
    // RDI FSM related signals
    output   reg    o_clk_gate_en,
    // Adapter related signals
    output   reg    o_pl_wake_ack
);
/********************************************
 * PARAMETERS
********************************************/
localparam RESET     = 4'b0000; 
localparam L1        = 4'b0100; 
localparam L2        = 4'b1000; 
localparam LINKRESET = 4'b1001; 
localparam DISABLED  = 4'b1100; 
/*******************************************
 * FSM STATES
*******************************************/
localparam UNGATING = 1'b0;
localparam GATING   = 1'b1;
/*******************************************
 * INTERNAL WIRES/REGISTERS
*******************************************/
reg CS;
reg NS;
/*******************************************
 * ASSIGN/WIRE STATMENTS
*******************************************/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// added (~|i_lp_state_req) which means NOP req in the condition below 34an lw 7atena (i_pl_state_sts == RESET && i_ltsm_cs == 0) lw7do //
// kdh lma el adapter y req mnna active w nroo7 n3ml traning , initially el ltsm btb2a fi reset aslun fa el condition dh hayfdl mt722   //
// w hanfdl 3amleen gating w kdh msh han3rf nshghal el LTSM khales                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire reset_condition  = (i_pl_state_sts == RESET && i_ltsm_in_reset && ~|i_lp_state_req);
wire gating_condition = (reset_condition || i_pl_state_sts == L1 || i_pl_state_sts == L2 || i_pl_state_sts == LINKRESET || i_pl_state_sts == DISABLED);
/*******************************************
 * STATE MEMORY
*******************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        CS <= GATING;
    end else begin
        CS <= NS;
    end
end
/*******************************************
 * NEXT STATE LOGIC
*******************************************/
always @ (*) begin
    case (CS)
    UNGATING: NS = (gating_condition & ~i_lp_wake_req & ~i_sb_msg_valid)? GATING : UNGATING;
    GATING:   NS = (i_lp_wake_req || i_sb_msg_valid)? UNGATING : GATING;
    endcase
end
/*******************************************
 * OUTPUT LOGIC
*******************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        o_clk_gate_en <= 0;
        o_pl_wake_ack <= 0;
    end else begin
        o_clk_gate_en <= (CS == UNGATING);
        o_pl_wake_ack <= (i_lp_wake_req & i_ltsm_is_waked_up);
    end
end


endmodule