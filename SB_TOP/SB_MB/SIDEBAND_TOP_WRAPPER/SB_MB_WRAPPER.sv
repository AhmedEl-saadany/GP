module SB_MB_WRAPPER (
    input               i_clk,
    input               i_rst_n,
    input               i_start_pattern_req,
    input               i_data_valid,
    input               i_msg_valid,
    input       [3:0]   i_state,
    input       [3:0]   i_sub_state,
    input       [3:0]   i_msg_no,
    input       [2:0]   i_msg_info,
    input       [15:0]  i_data_bus,
    input               i_stop_cnt,
    input               i_tx_point_sweep_test_en,
    input       [1:0]   i_tx_point_sweep_test,
    input               i_de_ser_done,
    input       [63:0]  i_deser_data,
    input               i_fifo_full,
    output              o_de_ser_done_sampled,
    output              o_start_pattern_done,
    output              o_time_out,
    output              o_busy,
    output              o_rx_sb_start_pattern,
    output              o_msg_valid,
    output              o_parity_error,
    output              o_adapter_enable,
    output              o_tx_point_sweep_test_en,
    output      [1:0]   o_tx_point_sweep_test,
    output      [3:0]   o_msg_no,
    output      [2:0]   o_msg_info,
    output      [15:0]  o_data,    
    output      [63:0]  o_tx_data_out,
    output              o_write_enable
);

/*------------------------------------------------------------------------------
-- INTERNAL WIRES & REGS   
------------------------------------------------------------------------------*/
wire rx_sb_rsp_delivered;
wire rx_sb_pattern_samp_done;
wire divided_clk;

/*------------------------------------------------------------------------------
-- Blocks Instantiation
------------------------------------------------------------------------------*/
SB_TX_WRAPPER tx_wrapper (
    .i_divided_clk            (i_clk),
    .i_rst_n                  (i_rst_n),
    .i_start_pattern_req      (i_start_pattern_req),
    .i_data_valid             (i_data_valid),
    .i_msg_valid              (i_msg_valid),
    .i_state                  (i_state),
    .i_sub_state              (i_sub_state),
    .i_msg_no                 (i_msg_no),
    .i_msg_info               (i_msg_info),
    .i_data_bus               (i_data_bus),
    .i_fifo_full              (i_fifo_full),
    .i_rx_sb_pattern_samp_done(rx_sb_pattern_samp_done),
    .i_rx_sb_rsp_delivered    (rx_sb_rsp_delivered),
    .i_stop_cnt               (i_stop_cnt),
    .i_tx_point_sweep_test_en (i_tx_point_sweep_test_en),
    .i_tx_point_sweep_test    (i_tx_point_sweep_test),
    .o_start_pattern_done     (o_start_pattern_done),
    .o_time_out               (o_time_out),
    .o_busy                   (o_busy),
    .o_tx_data_out            (o_tx_data_out),
    .o_write_enable           (o_write_enable)
);

SB_RX_WRAPPER rx_wrapper (
    .i_clk                    (i_clk),
    .i_rst_n                  (i_rst_n),
    .i_state                  (i_state),
    .o_rx_sb_start_pattern    (o_rx_sb_start_pattern),
    .o_rx_sb_pattern_samp_done(rx_sb_pattern_samp_done),
    .o_msg_valid              (o_msg_valid),
    .o_parity_error           (o_parity_error),
    .o_rx_rsp_delivered       (rx_sb_rsp_delivered),
    .o_adapter_enable         (o_adapter_enable),
    .o_tx_point_sweep_test_en (o_tx_point_sweep_test_en),
    .o_tx_point_sweep_test    (o_tx_point_sweep_test),
    .o_msg_no                 (o_msg_no),
    .o_msg_info               (o_msg_info),
    .o_data                   (o_data),
    .o_de_ser_done_sampled      (o_de_ser_done_sampled),
    .i_deser_data               (i_deser_data),
    .i_de_ser_done              (i_de_ser_done)
);

endmodule 