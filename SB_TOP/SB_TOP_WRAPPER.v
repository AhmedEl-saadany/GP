module SB_TOP_WRAPPER (
/**************************************
 * INPUTS
**************************************/
    input               i_sb_pll_clk,         // Main clock 800 MHz
    input               i_sb_mb_clk,          // 100 MHz clock for MB Sideband
    input               i_rdi_clk,            // May be 100 MHz or 200 MHz depending on the operating speed
    input               i_rdi_clk_gated,      // same freq as above but gated version for SB RDI TX
    input               i_dig_clk,
    input               i_rst_n,              // Active-low reset
    input               i_rst_n_pll,
     
    // Adapter interface
    input               i_lp_cfg_vld,
    input       [31:0]  i_lp_cfg,
    input               i_lp_cfg_crd,

    // RDI-specific Inputs
    input               i_adapter_is_waked_up,
    input               i_clk_is_ungated,
    input       [3:0]   i_msg_no_rdi,
    input               i_msg_valid_rdi,
    input               i_pl_inband_pres,

    // MB-specific Inputs
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

    // Deserializer Interface
    input               i_deser_done,
    input       [63:0]  i_deser_data,
/**************************************
 * OUTPUTS
**************************************/    
    // Adapter interface
    output              o_pl_nerror,  // added feature
    output              o_pl_cfg_vld,
    output      [31:0]  o_pl_cfg,
    output              o_pl_cfg_crd,

    // RDI-specific Outputs
    output              o_wake_adapter,
    output              o_msg_done_rdi,
    output              o_msg_valid_rdi,
    output      [3:0]   o_msg_no_rdi,

    // MB-specific Outputs
    output              o_deser_done_sampled,
    output              o_start_pattern_done,
    output              o_time_out,
    output              o_busy,
    output              o_rx_sb_start_pattern,
    output              o_mb_msg_valid,
    output              o_parity_error,
    output              o_adapter_enable,
    output              o_mb_tx_point_sweep_test_en,
    output      [1:0]   o_mb_tx_point_sweep_test,
    output      [3:0]   o_mb_msg_no,
    output      [2:0]   o_mb_msg_info,
    output      [15:0]  o_mb_data,
    output              o_mb_fifo_empty,

    // serializer Interface
    output              o_ser_done_sampled,
    output      [63:0]  o_fifo_data,
    output              o_packet_finished,
    output              o_ser_en,
    // SB CLOCK
    output              o_TXCKSB
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// INTERNAL SIGNALS //////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
wire i_sb_mb_clk;
/****************************************
* FSM MODELLING/CLOCK CONTROL SIGNALS
****************************************/
wire fsm_ser_done;
/****************************************
* TX FIFO SIGNALS
****************************************/
wire [63:0] mb_tx_fifo_data;
wire [63:0] rdi_fifo_data;
reg  [63:0] i_fifo_data;
reg write_en;
wire rdi_tx_fifo_write_en;
wire mb_tx_fifo_write_en;
wire fifo_empty;
wire fifo_full;
wire read_enable;
wire dont_send_zeros;
wire delete_data;
/****************************************
* DESER SIGNALS
****************************************/
reg deser_done_rdi;
reg deser_done_mb;
wire rdi_deser_done_sampled;
wire mb_deser_done_sampled;
/****************************************
* LTSM -> SB SYNCHRONIZER SIGNALS
****************************************/
wire sync_sb_start_pattern_req;
wire sync_sb_tx_msg_valid;
/****************************************
* RESET SYNCHRONIZER SIGNALS
****************************************/
wire sync_mb_rst_n;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// ASSIGN/WIRE STATMENTS /////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
assign o_deser_done_sampled = rdi_deser_done_sampled | mb_deser_done_sampled;
assign o_mb_fifo_empty = fifo_empty;



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// INSTANTIATIONS ////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/****************************************
* RDI TOP
****************************************/
SB_RDI_WRAPPER u_sb_rdi_wrapper (
    /*------------------------------------------------------------------------------------------------------------
     * Clock and Reset
    ------------------------------------------------------------------------------------------------------------*/
        .i_clk                  (i_rdi_clk),
        .i_clk_gated            (i_rdi_clk_gated),
        .i_rst_n                (i_rst_n),
    /*------------------------------------------------------------------------------------------------------------
     * Adapter Interface
    ------------------------------------------------------------------------------------------------------------*/
        .i_lp_cfg_vld           (i_lp_cfg_vld),
        .i_lp_cfg               (i_lp_cfg),
        .i_lp_cfg_crd           (i_lp_cfg_crd),
        .o_pl_cfg_crd           (o_pl_cfg_crd),
        .o_pl_nerror            (o_pl_nerror),
        .o_pl_cfg_vld           (o_pl_cfg_vld),
        .o_pl_cfg               (o_pl_cfg),
    /*------------------------------------------------------------------------------------------------------------
     * RDI FSM Interface
    ------------------------------------------------------------------------------------------------------------*/ 
        .i_msg_no               (i_msg_no_rdi),
        .i_msg_valid            (i_msg_valid_rdi),
        .i_adapter_is_waked_up  (i_adapter_is_waked_up),
        .i_clk_is_ungated       (i_clk_is_ungated),
        .o_wake_adapter         (o_wake_adapter),
        .o_msg_done             (o_msg_done_rdi),
        .o_msg_valid            (o_msg_valid_rdi),
        .o_msg_no               (o_msg_no_rdi),
    /*------------------------------------------------------------------------------------------------------------
     * TX FIFO Interface
    ------------------------------------------------------------------------------------------------------------*/ 
        .i_tx_fifo_full         (fifo_full),
        .i_tx_fifo_read_en      (o_ser_done_sampled),
        .i_srcid                (o_fifo_data[30:29]),
        .i_fifo_data_is_zeros   (dont_send_zeros),
        .o_tx_fifo_data         (rdi_fifo_data),
        .o_tx_fifo_write_en     (rdi_tx_fifo_write_en),
        .o_delete_data          (delete_data),
    /*------------------------------------------------------------------------------------------------------------
     * RX Deserializer Interface
    ------------------------------------------------------------------------------------------------------------*/
        .i_deser_done           (deser_done_rdi),
        .i_deser_data           (i_deser_data),
        .o_deser_done_sampled   (rdi_deser_done_sampled)     
);

/****************************************
* SB MB TOP
****************************************/
SB_MB_WRAPPER u_sb_mb_wrapper (
    /*------------------------------------------------------------------------------------------------------------
     * Clock and Reset
    ------------------------------------------------------------------------------------------------------------*/
        .i_clk                      (i_sb_mb_clk),
        .i_rst_n                    (i_rst_n),
    /*------------------------------------------------------------------------------------------------------------
     * LTSM Interface
    ------------------------------------------------------------------------------------------------------------*/
        .i_start_pattern_req        (sync_sb_start_pattern_req),
        .i_msg_valid                (sync_sb_tx_msg_valid),
        .i_data_valid               (i_data_valid),
        .i_stop_cnt                 (sync_sb_stop_cnt),
        .i_state                    (i_state),
        .i_sub_state                (i_sub_state),
        .i_msg_no                   (i_msg_no),
        .i_msg_info                 (i_msg_info),
        .i_data_bus                 (i_data_bus),
        .i_tx_point_sweep_test_en   (i_tx_point_sweep_test_en),
        .i_tx_point_sweep_test      (i_tx_point_sweep_test),
        .o_start_pattern_done       (o_start_pattern_done),
        .o_time_out                 (o_time_out),
        .o_busy                     (o_busy),
        .o_rx_sb_start_pattern      (o_rx_sb_start_pattern),
        .o_msg_valid                (o_mb_msg_valid),
        .o_parity_error             (o_parity_error),
        .o_adapter_enable           (o_adapter_enable),
        .o_tx_point_sweep_test_en   (o_mb_tx_point_sweep_test_en),
        .o_tx_point_sweep_test      (o_mb_tx_point_sweep_test),
        .o_msg_no                   (o_mb_msg_no),
        .o_msg_info                 (o_mb_msg_info),
        .o_data                     (o_mb_data),
    /*------------------------------------------------------------------------------------------------------------
     * Deserializer Interface
    ------------------------------------------------------------------------------------------------------------*/
        .i_de_ser_done              (deser_done_mb),
        .i_deser_data               (i_deser_data),
        .o_de_ser_done_sampled      (mb_deser_done_sampled),
    /*------------------------------------------------------------------------------------------------------------
     * TX FIFO Interface
    ------------------------------------------------------------------------------------------------------------*/
        .i_fifo_full                (fifo_full),
        .o_tx_data_out              (mb_tx_fifo_data),
        .o_write_enable             (mb_tx_fifo_write_en)
);
/****************************************
* CLOCK_CONTROLLER
****************************************/
SB_CLOCK_CONTROLLER clock_controller_dut (
    .i_pll_clk      (i_sb_pll_clk), 
    .i_rst_n        (i_rst_n_pll), 
    .i_enable       (o_ser_en), 
    .o_pack_finished(o_packet_finished), 
    .o_ser_done     (fsm_ser_done), 
    .TXCKSB         (o_TXCKSB) 
);
/****************************************
* FSM_Modelling
****************************************/
SB_TX_FSM_Modelling fsm_model (
	.i_clk                  (i_sb_pll_clk),
	.i_rst_n                (i_rst_n_pll),
	.i_ser_done             (fsm_ser_done),
	.i_empty                (fifo_empty),
	.i_packet_finished      (o_packet_finished),
	.i_read_enable_sampled  (o_ser_done_sampled),
	.o_read_enable          (read_enable),
    .i_dont_send_zeros      (dont_send_zeros),
	.o_clk_en               (o_ser_en)
);
/****************************************
* TX_FIFO
****************************************/
SB_TX_FIFO tx_fifo_dut (
	.i_clk              (i_sb_mb_clk),
	.i_rst_n            (i_rst_n),
	.i_data_in          (i_fifo_data), 
	.i_write_enable     (write_en), 
	.i_read_enable      (read_enable), 
    .i_delete_data      (delete_data),
	.o_data_out         (o_fifo_data), 
	.o_empty            (fifo_empty), 
	.o_ser_done_sampled (o_ser_done_sampled),
    .o_dont_send_zeros  (dont_send_zeros),
	.o_full             (fifo_full) 
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////// SYNCHRONIZERS ///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/******************************************
* LTSM --> SB SYNCHRONIZERS (FAST -> SLOW)
******************************************/
pulse_synchronizer SBINIT_start_pattern_req_sync_inst (
    .i_slow_clock       (i_sb_mb_clk),
    .i_fast_clock       (i_dig_clk),
    .i_slow_rst_n       (i_rst_n),
    .i_fast_rst_n       (sync_mb_rst_n),
    .i_fast_pulse       (i_start_pattern_req),
    .o_slow_pulse       (sync_sb_start_pattern_req)
);
bit_synchronizer sb_tx_msg_valid_sync_inst (
    .i_clk      (i_sb_mb_clk),
    .i_rst_n    (i_rst_n),
    .i_data_in  (i_msg_valid),
    .o_data_out (sync_sb_tx_msg_valid)
);
pulse_synchronizer stop_timeout_count_sync_inst (
    .i_slow_clock       (i_sb_mb_clk),
    .i_fast_clock       (i_dig_clk),
    .i_slow_rst_n       (i_rst_n),
    .i_fast_rst_n       (sync_mb_rst_n),
    .i_fast_pulse       (i_stop_cnt),
    .o_slow_pulse       (sync_sb_stop_cnt)
);
/****************************************
* RESET SYNCHRONIZERS
****************************************/
bit_synchronizer reset_synchronizer_mainband (
    .i_clk      (i_dig_clk), 
    .i_rst_n    (i_rst_n),
    .i_data_in  (1'b1),
    .o_data_out (sync_mb_rst_n)
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// MUXING ////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/****************************************
* MUXING TX FIFO DATA IN
****************************************/
always @ (*) begin
    case (i_pl_inband_pres)
        1'b0: i_fifo_data = mb_tx_fifo_data;
        1'b1: i_fifo_data = rdi_fifo_data;
        default: i_fifo_data = rdi_fifo_data;
    endcase
end
/****************************************
* MUXING TX FIFO WRITE EN
****************************************/
always @ (*) begin
    case (i_pl_inband_pres)
        1'b0: write_en = mb_tx_fifo_write_en;
        1'b1: write_en = rdi_tx_fifo_write_en;
        default: write_en = rdi_tx_fifo_write_en;
    endcase
end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// DEMUXING //////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/****************************************
* DEMUXING DESER DONE
****************************************/
always @ (*) begin
    deser_done_mb  = 0;
    deser_done_rdi = 0;
    case (i_pl_inband_pres)
        1'b0: deser_done_mb  = i_deser_done;
        1'b1: deser_done_rdi = i_deser_done;
        default: begin
            deser_done_mb  = 0;
            deser_done_rdi = 0;        
        end
    endcase
end


endmodule
