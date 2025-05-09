module General_Bring_Up_RX (
    input wire              lclk,           // Local clock
    input wire              sys_rst,        // System reset (active low)
    
    input [2:0]             i_rdi_controller_choosen_bring_up, // Chosen bring up signal from RDI controller
    // Sideband message interface
    input wire              i_rx_busy_from_TX, // Indicates if the RX side is busy
    input wire [3:0]        i_rx_sb_message, // Received sideband message
    input wire              i_rx_msg_valid,        // Indicates if the received message is valid 
    input wire              i_rx_done_send_message,
    output reg [3:0]        o_tx_sb_message,
    output reg              o_tx_msg_valid, // sb_message_valid to tx_sb   
    // General Bring Up signals
    // input wire [3:0]        i_pl_state_sts, // Chosen bring up signal from RDI controller
    input wire [3:0]        i_lp_state_req, // Chosen bring up signal from RDI controller
    // input                   i_lp_linkerror,

    output reg              o_General_Bring_Up_done_RX  // Indicates if the general bring up process is done
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

    // State definitions as local parameters
    localparam [3:0] 
        Active      = 4'b0001,
        LinkReset   = 4'b1001,
        LinkError   = 4'b1010,
        Retrain     = 4'b1011,
        Disable     = 4'b1100;
    // State machine states
    reg [1:0] CS, NS;

    parameter [1:0] IDLE                = 2'b00,
                    CHECK_REQ_MESSG     = 2'b01,
                    RESP_SEND           = 2'b10,
                    DONE                = 2'b11;
                

    reg transition_to_RESP_SEND;
    wire transition_to_CHECK_REQ_MESSG;
    reg repeat_to_check_Req;
    always @(posedge lclk ,negedge sys_rst) begin
        if (!sys_rst) begin
            CS <= IDLE;
        end else begin
            CS <= NS;
        end
    end

    // State transition conditions    
    // assign transition_to_CHECK_REQ_MESSG = (i_lp_state_req == Active || i_lp_state_req == LinkReset || i_lp_linkerror || i_lp_state_req == Retrain || i_lp_state_req == Disable || i_pl_train_error_from_ltsm);
    assign transition_to_CHECK_REQ_MESSG = (i_rdi_controller_choosen_bring_up!=0 && i_rdi_controller_choosen_bring_up!=6 && i_rdi_controller_choosen_bring_up != 7 );
    always @(posedge lclk ,negedge sys_rst) begin
        if (!sys_rst) begin
            transition_to_RESP_SEND <= 0;
            repeat_to_check_Req <= 0;
        end else begin
            transition_to_RESP_SEND = (i_rx_sb_message == ACTIVE_REQ || i_rx_sb_message == LINKRESET_REQ || i_rx_sb_message == LINKERROR_REQ || i_rx_sb_message == RETRAIN_REQ || i_rx_sb_message == DISABLE_REQ) && i_rx_msg_valid;
            if (CS == IDLE && NS == RESP_SEND) begin
                repeat_to_check_Req<= 1'b1; // Set the flag to check for a valid message
            end else if (CS== DONE && NS == CHECK_REQ_MESSG) begin
                repeat_to_check_Req <= 1'b0; // Reset the flag to check for a valid message
            end
        end
    end

    // Next state logic
    always @(*) begin
        NS = CS; // Default to current state
        case (CS)
            IDLE: begin
                if (transition_to_CHECK_REQ_MESSG) begin
                    NS = CHECK_REQ_MESSG; // If a message is valid, go to REQ_SEND state
                end else if (transition_to_RESP_SEND) begin
                    NS = RESP_SEND; // If a message is valid, go to REQ_SEND state
                end
            end
            CHECK_REQ_MESSG: begin
                if (transition_to_RESP_SEND && ~ i_rx_busy_from_TX) begin
                    NS = RESP_SEND;
                end 
            end
            RESP_SEND: begin
                if (i_rx_done_send_message) begin
                    NS = DONE;
                end
            end
            DONE: begin 
                if (repeat_to_check_Req) begin
                    NS = CHECK_REQ_MESSG; // If a message is valid, go to REQ_SEND state
                end else if (i_rdi_controller_choosen_bring_up==0) NS= IDLE;
            end 
        default: NS = IDLE; // Default state to avoid latches
        endcase
    end
    // Output logic
    always @(posedge lclk or negedge sys_rst) begin
        if (!sys_rst) begin
            o_tx_sb_message <= 4'b0000;
            o_tx_msg_valid <= 1'b0;
            o_General_Bring_Up_done_RX <= 1'b0;
        end else begin
            o_tx_sb_message <= 4'b0000;
            o_tx_msg_valid <= 1'b0;
            o_General_Bring_Up_done_RX <= 1'b0;
            case (NS)
                IDLE: begin
                    o_tx_sb_message <= 4'b0000;
                    o_tx_msg_valid <= 1'b0;
                    o_General_Bring_Up_done_RX <= 1'b0;
                end
                RESP_SEND: begin 
                    case (i_rdi_controller_choosen_bring_up)
                        3'b001: o_tx_sb_message <= ACTIVE_RSP; // ACTIVE
                        3'b010: o_tx_sb_message <= RETRAIN_RSP; // RETRAIN
                        3'b011: o_tx_sb_message <= LINKERROR_RSP; // LINKERROR
                        3'b100: o_tx_sb_message <= LINKRESET_RSP; // LINKRESET
                        3'b101: o_tx_sb_message <= DISABLE_RSP; // DISABLE
                        default: o_tx_sb_message <= 4'b0000;
                    endcase
                    o_tx_msg_valid <= 1'b1;
                    // if (i_lp_linkerror || i_) begin
                    //         o_tx_sb_message <= LINKERROR_RSP;
                    //         o_tx_msg_valid <= 1'b1;
                    // end else begin
                    //     case (i_lp_state_req)
                    //         Active: begin
                    //             o_tx_sb_message <= ACTIVE_RSP;
                    //             o_tx_msg_valid <= 1'b1;
                    //         end
                    //         LinkReset: begin
                    //             o_tx_sb_message <= LINKRESET_RSP;
                    //             o_tx_msg_valid <= 1'b1;
                    //         end
                    //         Retrain: begin
                    //             o_tx_sb_message <= RETRAIN_RSP;
                    //             o_tx_msg_valid <= 1'b1;
                    //         end
                    //         Disable: begin
                    //             o_tx_sb_message <= DISABLE_RSP;
                    //             o_tx_msg_valid <= 1'b1;
                    //         end
                    //         default: begin // Default case to avoid latches
                    //             o_tx_sb_message <= 4'b0000; // No valid message, set to zero
                    //             o_tx_msg_valid <= 1'b0; // Message not valid in IDLE state
                    //         end
                    //     endcase 
                    // end
                end 
                DONE: begin 
                    o_General_Bring_Up_done_RX <= 1'b1; 
                end 

            default: begin 
                o_tx_sb_message <= 4'b0000;
                o_tx_msg_valid <= 1'b0;
                o_General_Bring_Up_done_RX <= 1'b0;
            end
            endcase
        end
    end      
        


    // State transition conditions
    
endmodule