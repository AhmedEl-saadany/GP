module stall_hand_chak (
    input wire              lclk,           // Local clock
    input wire              sys_rst,        // System reset (active low)
    input [3:0]             i_pl_State_sts, // i_rdi_cs
    input [3:0]             i_lp_state_req , // i_adapter_req
    input [3:0]             i_rx_sb_message,
    input wire              i_rx_sb_message_valid, // Message valid signal
    input                   i_pl_error, // Message type (Request/Response)
    input                   i_stall_start,
    // Stall Request Interface
    input wire              i_lp_stallack,    // Stall acknowledge from power logic
    output reg              o_pl_stallreq,    // Stall request output
    output reg              o_stall_done,     // Stall handshake completion
    output reg              o_pl_trdy
);
    /////////////////////////////////////////
    ////////// Machine RDI STATES //////////
    /////////////////////////////////////////
    localparam [3:0] 
        Nop         = 4'b0000,
        Active      = 4'b0001,
        L1          = 4'b0100,
        L2          = 4'b1000,
        LinkReset   = 4'b1001,
        LinkError   = 4'b1010,
        Retrain     = 4'b1011,
        Disable     = 4'b1100,
        ActivePMNAK = 4'b0010,
        exite_pm    = 4'b1111; // to indicate the exit from pm state
    // Message encodings as local parameters
    localparam [3:0] 
        ACTIVE_REQ      = 4'd0001,
        ACTIVE_RSP      = 4'd2,
        L1_REQ          = 4'd3,
        L1_RSP          = 4'd4,
        L2_REQ          = 4'd5,
        L2_RSP          = 4'd6,
        LINKRESET_REQ   = 4'd7,
        LINKRESET_RSP   = 4'd8,
        LINKERROR_REQ   = 4'd9,
        LINKERROR_RSP   = 4'd10,
        RETRAIN_REQ     = 4'd11,
        RETRAIN_RSP     = 4'd12,
        DISABLE_REQ     = 4'd13,
        DISABLE_RSP     = 4'd14,
        PM_NAK_MSG      = 4'd15;
    /////////////////////////////////////////
    ////////// Machine RDI STATES //////////
    /////////////////////////////////////////
    localparam [1:0]
        IDLE       = 2'b00,
        STALL_REQ  = 2'b01,
        STALL_ACK  = 2'b10,
        STALL_DONE = 2'b11;
    
    reg [1:0] stall_phase;
    // Stall Request Handshake Logic
    always @(posedge lclk or negedge sys_rst) begin
        if (~sys_rst) begin
            o_pl_stallreq <= 1'b0;
            o_stall_done  <= 1'b0;
            stall_phase <= IDLE;
        end else begin
            case (stall_phase)
                IDLE: begin
                    o_pl_stallreq <= 1'b0;
                    o_stall_done  <= 1'b0;
                    if (i_stall_start && ~i_lp_stallack) begin
                        stall_phase <= STALL_REQ;
                    end
                end
                STALL_REQ: begin
                    o_pl_stallreq <= 1'b1;
                    if (i_lp_stallack) begin
                        stall_phase <= STALL_ACK;
                    end
                end
                STALL_ACK: begin
                    o_pl_stallreq <= 1'b0;
                    o_pl_trdy <= 1'b0; // Deassert o_pl_trdy when stall is acknowledged
                    stall_phase <= STALL_DONE;
                end
                STALL_DONE: begin
                    if (~i_lp_stallack) begin
                        o_stall_done <= 1'b1;
                        stall_phase <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule