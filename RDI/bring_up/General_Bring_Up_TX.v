module General_Bring_Up_TX (
    input               lclk,
    input               sys_rst,
    input   [2:0]       i_rdi_controller_choosen_bring_up, // This are 3 bits (level signal) used to choose which bring will use in the bring up block (1 ACTIVE ,2 RETRAIN, 3 LINKERROR ,4 LINKRESET, 5 DISABLE)
    input   [3:0]       i_rx_sb_message,
    input               i_rx_busy_from_RX, // Indicates if the RX side is busy
    input               i_rx_msg_valid, // sb_message_valid from rx _sb
    input               i_rx_done_send_message, // indicate that the sb already send the message
    output reg  [3:0]   o_tx_sb_message,
    output reg          o_tx_msg_valid, // sb_message_valid to tx_sb
    output reg          o_General_Bring_Up_done_TX // General bring up done signal to the rdi controller
);
    // Message encodings as local parameters
    localparam [3:0] 
        ACTIVE_REQ      = 4'd1,
        ACTIVE_RSP      = 4'd2,
        LINKRESET_REQ   = 4'd7,
        LINKRESET_RSP   = 4'd8,
        LINKERROR_REQ   = 4'd9,
        LINKERROR_RSP   = 4'd10,
        RETRAIN_REQ     = 4'd11,
        RETRAIN_RSP     = 4'd12,
        DISABLE_REQ     = 4'd13,
        DISABLE_RSP     = 4'd14;
    reg [1:0] CS, NS;
    parameter [1:0] IDLE                = 4'b0000,
                    REQ_SEND            = 4'b0001,
                    HANDLE              = 4'b0010,
                    DONE                = 4'b0011;

    wire transition_to_DONE;
    assign transition_to_DONE = (i_rx_sb_message == ACTIVE_RSP || i_rx_sb_message == RETRAIN_RSP || i_rx_sb_message == LINKERROR_RSP || i_rx_sb_message == LINKRESET_RSP || i_rx_sb_message == DISABLE_RSP) && i_rx_msg_valid;

    // State register
    always @(posedge lclk or negedge sys_rst) begin
        if (!sys_rst)
            CS <= IDLE;
        else
            CS <= NS;
    end
    // Next state logic
    always @(*) begin
        NS = CS; // Default to current state
        case (CS)
            IDLE: begin
                if ( i_rdi_controller_choosen_bring_up!=3'b000 && ~i_rx_busy_from_RX ) begin
                    NS = REQ_SEND; // If a message is valid, go to REQ_SEND state
                end
            end
            REQ_SEND: begin
                if (i_rdi_controller_choosen_bring_up==0) NS= IDLE;
                else if (i_rx_done_send_message) begin
                    NS = HANDLE;
                end
            end
            HANDLE: begin
                if (i_rdi_controller_choosen_bring_up==0) NS= IDLE;
                else if (transition_to_DONE) begin
                    NS = DONE;
                end 
            end
            DONE: begin
                if (i_rdi_controller_choosen_bring_up==0) NS= IDLE; 
            end 
            default: NS = IDLE; // Default state to avoid latches
        endcase
    end
    // Output logic
    always
@(posedge lclk or negedge sys_rst) begin
        if (!sys_rst) begin
            o_tx_sb_message <= 4'b0000;
            o_tx_msg_valid <= 1'b0;
            o_General_Bring_Up_done_TX <= 1'b0;
        end else begin
            case (NS)
                IDLE: begin
                    o_tx_sb_message <= 4'b0000;
                    o_tx_msg_valid <= 1'b0;
                    o_General_Bring_Up_done_TX <= 1'b0;
                end
                REQ_SEND: begin
                    case (i_rdi_controller_choosen_bring_up)
                        3'b001: o_tx_sb_message <= ACTIVE_REQ; // ACTIVE
                        3'b010: o_tx_sb_message <= RETRAIN_REQ; // RETRAIN
                        3'b011: o_tx_sb_message <= LINKERROR_REQ; // LINKERROR
                        3'b100: o_tx_sb_message <= LINKRESET_REQ; // LINKRESET
                        3'b101: o_tx_sb_message <= DISABLE_REQ; // DISABLE
                        default: o_tx_sb_message <= 4'b0000;
                    endcase
                    o_tx_msg_valid <= 1'b1;
                end
                HANDLE: begin
                    o_tx_msg_valid <= 1'b0;
                end
                DONE: begin 
                    o_General_Bring_Up_done_TX <= 1'b1; 
                end 
            endcase
        end
    end

endmodule


