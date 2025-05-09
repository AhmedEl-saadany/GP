module credit_loop_controller (
/**************************************
 * INPUTS
**************************************/
    input           i_clk,
    input           i_rst_n,
    // TX fifo related signals
    input           i_tx_fifo_read_en,  // should be connected to o_ser_done_sampled 
    input [1:0]     i_srcid,            // should be connected to o_fifo_data [30:29]
    input           i_fifo_data_is_zeros,
    // Adapter related signals
    input           i_lp_cfg_crd,  
    // Sideband RDI RX    
    input           i_rising_edge_pl_cfg_vld,
/**************************************
 * OUTPUTS
**************************************/    
    // Adapter related signals
    output          o_pl_cfg_crd,         
    // Sideband RDI RX
    output          o_adapter_is_full     
);

/**************************************
 * Module Instantiations
**************************************/
// credit_notifier instance
credit_notifier credit_notifier_inst (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_srcid                (i_srcid),
    .i_fifo_data_is_zeros   (i_fifo_data_is_zeros),
    .i_tx_fifo_read_en      (i_tx_fifo_read_en),
    .o_pl_cfg_crd           (o_pl_cfg_crd)
);

// credit_counter instance
credit_counter credit_counter_inst (
    .i_clk                      (i_clk),
    .i_rst_n                    (i_rst_n),
    .i_lp_cfg_crd               (i_lp_cfg_crd),
    .i_rising_edge_pl_cfg_vld   (i_rising_edge_pl_cfg_vld),
    .o_adapter_is_full          (o_adapter_is_full)
);

endmodule