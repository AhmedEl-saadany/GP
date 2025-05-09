module SB_RDI_WRAPPER (
/**************************************
 * INPUTS
**************************************/
    input                   i_clk,
    input                   i_clk_gated,
    input                   i_rst_n,
    // Adapter related signals
    input                   i_lp_cfg_vld,
    input       [31:0]      i_lp_cfg,
    input                   i_lp_cfg_crd,
    // RDI FSM related signals
    input       [3:0]       i_msg_no,
    input                   i_msg_valid,
    input                   i_adapter_is_waked_up,
    input                   i_clk_is_ungated,
    // TX FIFO Interface
    input                   i_tx_fifo_full,
    input                   i_tx_fifo_read_en,    // should be connected to o_ser_done_sampled of tx fifo (Credit-loop related)
    input       [1:0]       i_srcid,              // should be connected to o_fifo_data [30:29] (Credit-loop related)
    input                   i_fifo_data_is_zeros, // should be connected to o_dont_send_zeros in tx fifo (Credit-loop related)
    // RX Deserializer Interface
    input                   i_deser_done,
    input       [63:0]      i_deser_data,
/**************************************
 * OUTPUTS
**************************************/
    // Adapter related signals
    output                  o_pl_nerror,    
    output                  o_pl_cfg_vld,
    output      [31:0]      o_pl_cfg,      
    output                  o_pl_cfg_crd,
    // RDI FSM related signals
    output                  o_wake_adapter,
    output                  o_msg_done,
    output                  o_msg_valid,
    output      [3:0]       o_msg_no,
    // TX FIFO Interface
    output      [63:0]      o_tx_fifo_data,
    output                  o_tx_fifo_write_en,
    output                  o_delete_data,      // goes to fifo to delete data written by mistake when error found late (Encoder related)
    // RX Deserializer Interface
    output                  o_deser_done_sampled
);
/*******************************************
 * WIRES/REGISTERS
*******************************************/
wire pl_nerror_rx;
wire pl_nerror_tx;
wire wake_adapter_tx; 
wire wake_adapter_rx;
wire adapter_is_full; 
wire decoder_rising_edge_pl_cfg_vld;
/*******************************************
 * ASSIGN/WIRE STATMENTS
*******************************************/
assign o_pl_nerror = pl_nerror_tx | pl_nerror_rx;
assign o_wake_adapter = wake_adapter_tx | wake_adapter_rx;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////// INSTANSIATIONS ///////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*************************************************************************************************************
 * TX
/************************************************************************************************************/ 
SB_RDI_ENCODER SB_RDI_ENCODER_inst (
    .i_clk                  (i_clk_gated),              // Gated clock input
    .i_rst_n                (i_rst_n),                  // Active-low system reset
    /*------------------------------------------------------------------------------------------------------------
     * Adapter Interface Signals
    ------------------------------------------------------------------------------------------------------------*/   
    .i_lp_cfg_vld           (i_lp_cfg_vld),             // LP configuration valid
    .i_lp_cfg               (i_lp_cfg),                 // 32-bit LP configuration data
    .o_pl_nerror            (pl_nerror_tx),             // PHY link error indicator (active-low)
    /*------------------------------------------------------------------------------------------------------------
     * RDI FSM Interface
    ------------------------------------------------------------------------------------------------------------*/    
    .i_msg_no               (i_msg_no),                 // 4-bit RDI message number (1-15)
    .i_msg_valid            (i_msg_valid),              // RDI message valid pulse
    .i_adapter_is_waked_up  (i_adapter_is_waked_up),    // Adapter wake-up status
    .o_msg_done             (o_msg_done),               // Message encoding complete
    .o_wake_adapter         (wake_adapter_tx),          // Wake adapter request
    /*------------------------------------------------------------------------------------------------------------
     * TX FIFO Interface
    ------------------------------------------------------------------------------------------------------------*/    
    .i_fifo_full            (i_tx_fifo_full),           // TX FIFO full status
    .o_fifo_data            (o_tx_fifo_data),           // 64-bit encoded output data
    .o_fifo_write_en        (o_tx_fifo_write_en),       // FIFO write enable pulse
    .o_delete_data          (o_delete_data)             // goes to fifo to delete data written by mistake when error found late
);
/*************************************************************************************************************
 * RX
/************************************************************************************************************/ 
SB_RDI_DECODER SB_RDI_DECODER_inst (
    .i_clk                      (i_clk),                    // Main system clock 
    .i_rst_n                    (i_rst_n),                  // Active-low system reset
    /*------------------------------------------------------------------------------------------------------------
     * Credit Loop Control Signals
    ------------------------------------------------------------------------------------------------------------*/     
    .i_adapter_is_full          (adapter_is_full),                // Signal from adapter indicating it's full
    .o_rising_edge_pl_cfg_vld   (decoder_rising_edge_pl_cfg_vld), // should be used to increment credit counter upon each rising pl_cfg_vld
    /*------------------------------------------------------------------------------------------------------------
     * RDI FSM signals
    ------------------------------------------------------------------------------------------------------------*/     
    .i_clk_is_ungated           (i_clk_is_ungated),         // Status indicating if RDI clock is ungated since if not it will keep o_msg_valid till clock is ungated
    .i_adapter_is_waked_up      (i_adapter_is_waked_up),    // Signal from rdi fsm indicating that adapter wake-up complete
    .o_wake_adapter             (wake_adapter_rx),          // Signal to wake up adapter
    .o_msg_valid                (o_msg_valid),              // Valid pulse for RDI messages
    .o_msg_no                   (o_msg_no),                 // 4-bit RDI message number
    /*------------------------------------------------------------------------------------------------------------
     * RX Deserializer Interface
    ------------------------------------------------------------------------------------------------------------*/     
    .i_deser_done               (i_deser_done),             // Pulse indicating deserialization complete
    .i_deser_data               (i_deser_data),             // 64-bit deserialized data input
    .o_deser_done_sampled       (o_deser_done_sampled),     // Sampled deserializer done signal
    /*------------------------------------------------------------------------------------------------------------
     * Adapter Interface
    ------------------------------------------------------------------------------------------------------------*/ 
    .o_pl_cfg                   (o_pl_cfg),                 // 32-bit PHY link configuration
    .o_pl_cfg_vld               (o_pl_cfg_vld),             // PHY link config valid pulse
    .o_pl_nerror                (pl_nerror_rx)              // Active-high PHY link error indicator
);
/*************************************************************************************************************
 * CREDIT LOOP CONTROLLER
/************************************************************************************************************/ 
credit_loop_controller credit_loop_controller_inst (
    .i_clk                      (i_clk),
    .i_rst_n                    (i_rst_n),
    .i_srcid                    (i_srcid),              // should be connected to o_fifo_data [30:29]
    .i_fifo_data_is_zeros       (i_fifo_data_is_zeros), // should be connected to o_dont_send_zeros in tx fifo
    .i_tx_fifo_read_en          (i_tx_fifo_read_en),    // should be connected to o_ser_done_sampled 
    .i_lp_cfg_crd               (i_lp_cfg_crd),
    .i_rising_edge_pl_cfg_vld   (decoder_rising_edge_pl_cfg_vld),
    .o_pl_cfg_crd               (o_pl_cfg_crd),
    .o_adapter_is_full          (adapter_is_full)
);

endmodule