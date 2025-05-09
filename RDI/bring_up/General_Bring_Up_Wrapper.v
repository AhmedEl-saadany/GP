module General_Bring_Up_Wrapper (
    input               lclk,
    input               sys_rst,
    input   [2:0]       i_rdi_controller_choosen_bring_up, // Chosen bring up signal for TX
    input   [3:0]       i_rx_sb_message,                  // Sideband message from RX
    // input               i_rx_busy_from_RX,                // RX busy signal
    input               i_rx_msg_valid,                   // RX message valid signal
    input               i_rx_done_send_message,           // RX done sending message
    // input   [3:0]       i_pl_state_sts,                   // Chosen bring up signal for RX
    input   [3:0]       i_lp_state_req,                    // Link state request signal
    // input               i_lp_linkerror,
    // input               i_rx_busy_from_TX,                // TX busy signal
    output  [3:0]       o_tx_sb_message,                  // Sideband message from TX
    output              o_tx_msg_valid,                   // TX message valid signal
    output              o_General_Bring_Up_done       // General bring up done signal from TX
);
    // Internal signals for interconnection
    wire            General_Bring_Up_done_RX,General_Bring_Up_done_TX;
    wire            o_tx_msg_valid_TX, o_tx_msg_valid_RX;
    wire [3:0]      tx_sb_message_output_from_RX, tx_sb_message_output_from_TX;

    // Instantiate General_Bring_Up_RX
    General_Bring_Up_RX rx_inst (
        .lclk(lclk),
        .sys_rst(sys_rst),
        .i_rx_busy_from_TX(o_tx_msg_valid_TX),
        .i_rdi_controller_choosen_bring_up(i_rdi_controller_choosen_bring_up),
        .i_rx_sb_message(i_rx_sb_message),
        .i_rx_done_send_message(i_rx_done_send_message),
        .i_rx_msg_valid(i_rx_msg_valid),
        .i_lp_state_req(i_lp_state_req),
        // .i_lp_linkerror(i_lp_linkerror),
        .o_tx_sb_message(tx_sb_message_output_from_RX),
        .o_tx_msg_valid(o_tx_msg_valid_RX),
        .o_General_Bring_Up_done_RX(General_Bring_Up_done_RX)
    );

    // Instantiate General_Bring_Up_TX
    General_Bring_Up_TX tx_inst (
        .lclk(lclk),
        .sys_rst(sys_rst),
        .i_rdi_controller_choosen_bring_up(i_rdi_controller_choosen_bring_up),
        .i_rx_sb_message(i_rx_sb_message),
        .i_rx_busy_from_RX(o_tx_msg_valid_RX),
        .i_rx_msg_valid(i_rx_msg_valid),
        .i_rx_done_send_message(i_rx_done_send_message),
        .o_tx_sb_message(tx_sb_message_output_from_TX),
        .o_tx_msg_valid(o_tx_msg_valid_TX),
        .o_General_Bring_Up_done_TX(General_Bring_Up_done_TX)
    );
    assign o_General_Bring_Up_done = General_Bring_Up_done_RX & General_Bring_Up_done_TX; // Combine the done signals from RX and TX
    assign o_tx_sb_message = (o_tx_msg_valid_RX)? tx_sb_message_output_from_RX :(o_tx_msg_valid_TX)? tx_sb_message_output_from_TX:0; // Choose the sideband message based on the valid signal from RX or TX
    assign o_tx_msg_valid = o_tx_msg_valid_RX | o_tx_msg_valid_TX; // Combine the message valid signals from RX and TX
endmodule