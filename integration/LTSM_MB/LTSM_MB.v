module LTSM_MB #(
    parameter SER_WIDTH = 32
) (
    /*************************************************************************
    * INPUTS
    *************************************************************************/
    // clocks and resets 
    input                       i_pll_mb_clk,      // main pll clock
    input                       i_rst_n, 
    
    // Clock lanes input
    input                       i_RCKP,      // Received CKP
    input                       i_RCKN,      // Received CKN
    input                       i_RTRACK,    // Received TRACK

    // valid lane
    input       [SER_WIDTH-1:0] i_RVLD_L, 
    
    // Main band data lanes
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_0,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_1,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_2,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_3,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_4,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_5,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_6,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_7,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_8,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_9,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_10,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_11,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_12,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_13,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_14,
    input       [SER_WIDTH-1:0] i_lfsr_rx_lane_15,
    
    // RDI (this signals will come already synchronized in rdi domain so we must pass for them our dig_clk) 
    input       [8*63:0]        i_lp_data, // input to mapper
    input                       i_start_training_RDI,
    input                       i_go_to_phyretrain_RDI,  
    input                       i_lp_linkerror, 
    input                       i_go_to_active_RDI, 
    input                       i_go_to_L1_RDI,   
    input                       i_go_to_L2_RDI,
    input                       i_exit_from_L1, // connected to o_go_to_speedidle_RDI
    input                       i_exit_from_L2, // connected to o_reset_count_done
    input                       i_enable_scrambler, // this signal is from rdi to indicate that there is an adapter valid data
    input                       i_clk_gating_en,

    // Sideband related signals
    input                       i_SB_fifo_empty,      // from sideband to let us know that there is no more data to be transmitted
    input                       i_start_pattern_done, // from SB means that the SBINIT pattern has sent and received successfully without timeout
    input                       i_start_training_SB,  // from SB means that the remote partner starts sending SBINIT pattern to start communication
    input                       i_time_out,           //  from SB means that timeout occur and we must go to TRAINERROR
    input                       i_busy,               // from SB means that it is processing on the data on the bus and this data should not be changed 
    input                       i_rx_msg_valid,
    input       [3:0]           i_decoded_SB_msg,     // gyaly mn el SB b3d my3ml decode ll msg eli gyalo mn el partner w yb3tli el crossponding format liha 
    input       [2:0]           i_rx_msg_info,        // from SB containing SB message info
    input       [15:0]          i_rx_data_bus,        // from SB containing SB message data

    // Hard-Macro related signals
    input                       i_deser_valid_data, // a valid signal from data  lane deserializer
    input                       i_deser_valid_val,  // a valid signal from valid lane deserilaizer
    /*************************************************************************
    * OUTPUTS
    *************************************************************************/
    // Clock lanes : CKP, CKN, TRACK
    output                      o_CKP,
    output                      o_CKN,
    output                      o_TRACK,

    // valid lane
    output      [SER_WIDTH-1:0] o_TVLD_L, 

    // Main band data lanes
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_0,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_1,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_2,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_3,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_4,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_5,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_6,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_7,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_8,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_9,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_10,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_11,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_12,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_13,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_14,
    output      [SER_WIDTH-1:0] o_lfsr_tx_lane_15,

    // RDI (this signals will be synchronized in rdi domain)
    output       [511:0]        o_pl_data,          // output from demapper 64B
    output                      o_ltsm_in_reset,
    output                      o_pl_trainerror,    // trainerror
    output                      o_pl_inband_pres,  
    output                      o_pl_error,         // framing error
    output                      o_dig_clk,

    // Sideband related signals
    output                      o_start_pattern_req, // to SB to start SBINIT pattern generation
    output         [3:0]        o_tx_state,          // LTSM state indication
    output         [3:0]        o_tx_sub_state,      // LTSM substates indication (muxed between MBINIT & MBTRAIN)
    output         [3:0]        o_tx_msg_no,         // (to be muxed)
    output         [2:0]        o_tx_msg_info,       // (to be muxed) 
    output         [15:0]       o_tx_data_bus,       // (to be muxed)
    output                      o_tx_msg_valid,      // (to be muxed)
    output                      o_tx_data_valid,     // (to be muxed)
    output                      o_MBTRAIN_timeout_disable,
    output                      o_MBTRAIN_tx_eye_width_sweep_en,
    output                      o_MBTRAIN_rx_eye_width_sweep_en,
    output                      o_tx_point_sweep_test_en,
    output          [1:0]       o_tx_point_sweep_test_type,

    // Hard-Macro related signals
    output                      o_serliazer_valid_en, // valid lane serializer enable
    output                      o_serliazer_data_en,  // data  lane serializer enable
    output                      o_diff_or_quad_clk,
    output     [3:0]            o_reciever_ref_volatge,
    output     [3:0]            o_pi_step,
    output     [2:0]            o_curret_operating_speed 
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// INTERNAL SIGNALS //////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/****************************************
* MAPPER related signals
****************************************/
wire [SER_WIDTH-1:0] o_mapper_lane_0;
wire [SER_WIDTH-1:0] o_mapper_lane_1;
wire [SER_WIDTH-1:0] o_mapper_lane_2;
wire [SER_WIDTH-1:0] o_mapper_lane_3;
wire [SER_WIDTH-1:0] o_mapper_lane_4;
wire [SER_WIDTH-1:0] o_mapper_lane_5;
wire [SER_WIDTH-1:0] o_mapper_lane_6;
wire [SER_WIDTH-1:0] o_mapper_lane_7;
wire [SER_WIDTH-1:0] o_mapper_lane_8;
wire [SER_WIDTH-1:0] o_mapper_lane_9;
wire [SER_WIDTH-1:0] o_mapper_lane_10;
wire [SER_WIDTH-1:0] o_mapper_lane_11;
wire [SER_WIDTH-1:0] o_mapper_lane_12;
wire [SER_WIDTH-1:0] o_mapper_lane_13;
wire [SER_WIDTH-1:0] o_mapper_lane_14;
wire [SER_WIDTH-1:0] o_mapper_lane_15;
/****************************************
* LFSR TX related signals
****************************************/
wire lfsr_tx_pattern_done;
wire [1:0] mainband_pattern_generator_cw;
/****************************************
* LFSR RX related signals
****************************************/
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_0;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_1;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_2;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_3;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_4;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_5;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_6;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_7;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_8;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_9;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_10;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_11;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_12;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_13;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_14;
wire [SER_WIDTH-1:0] o_lfsr_rx_bypass_15;

wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_0;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_1;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_2;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_3;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_4;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_5;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_6;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_7;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_8;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_9;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_10;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_11;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_12;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_13;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_14;
wire [SER_WIDTH-1:0] o_lfsr_rx_final_gen_15;

wire [1:0]  mainband_pattern_comparator_cw;
wire [15:0] lfsr_rx_comparison_results;
wire aggregate_error_found;
wire enable_pattern_comparitor;
/****************************************
* TX D2C POINT TEST related signals
****************************************/
wire tx_d2c_pt_en;
wire tx_d2c_pt_done;
wire tx_datatrain_or_valtrain;
wire tx_d2c_pt_valid_result;
wire tx_perlaneid_or_lfsr;
wire val_pattern_en_tx_d2c_pt;
wire val_comparison_en_tx_d2c_pt;
wire [15:0] tx_d2c_pt_data_results;
wire [1:0] mainband_pattern_generator_cw_tx_d2c_pt;
wire [1:0] mainband_pattern_comparator_cw_tx_d2c_pt;
/****************************************
* RX D2C POINT TEST related signals
****************************************/
wire rx_d2c_pt_en;
wire rx_d2c_pt_done;
wire rx_datavref_or_valvref;
wire val_pattern_en_rx_d2c_pt;
wire val_comparison_en_rx_d2c_pt;
wire [15:0] rx_d2c_pt_results;
wire [1:0] mainband_pattern_generator_cw_rx_d2c_pt;
wire [1:0] mainband_pattern_comparator_cw_rx_d2c_pt;
/****************************************
* SIDEBAND related signals
****************************************/
// ORed
wire [3:0]  sb_tx_msg_no_ltsm;
wire [3:0]  sb_tx_msg_no_rx_d2c_pt;
wire [3:0]  sb_tx_msg_no_tx_d2c_pt;
// ORed
wire [15:0] sb_tx_data_bus_ltsm;
wire [15:0] sb_tx_data_bus_rx_d2c_pt;
wire [15:0] sb_tx_data_bus_tx_d2c_pt;
// ORed 
wire sb_tx_msg_valid_ltsm;
wire sb_tx_msg_valid_rx_d2c_pt;
wire sb_tx_msg_valid_tx_d2c_pt;
// ORed
wire sb_tx_data_valid_ltsm;
wire sb_tx_data_valid_rx_d2c_pt;
wire sb_tx_data_valid_tx_d2c_pt;
//ORed
wire [2:0] sb_tx_msg_info_ltsm;
wire sb_tx_msg_info_tx_d2c_pt;
/****************************************
* LTSM related signals
****************************************/
wire ltsm_apply_reversal_en;
wire ltsm_val_pattern_en;
wire [1:0] ltsm_mainband_pattern_generator_cw;
wire [1:0] ltsm_mainband_pattern_comparator_cw;
wire [1:0] ltsm_functional_tx_lanes;
wire [1:0] ltsm_functional_rx_lanes;
wire ltsm_final_clk_mode;
wire ltsm_valid_consec_detect;
wire ltsm_clear_clk_results;
wire ltsm_clk_tx_pattern_en;
wire mapper_demapper_en;
wire falling_edge_busy;
assign o_tx_point_sweep_test_en   = tx_d2c_pt_en | rx_d2c_pt_en;
assign o_tx_point_sweep_test_type = (tx_d2c_pt_en)? 2'b00 : (rx_d2c_pt_en)? 2'b10 : 2'b00;
/****************************************
* VALID related signals
****************************************/
wire val_tx_pattern_done;
wire val_rx_comparison_result;
wire valid_frame_detect;
/****************************************
* CLOCK CONTROL related signals
****************************************/
wire clk_tx_pattern_done;
wire clk_result_ckp;
wire clk_result_ckn;
wire clk_result_trk;
wire [2:0] clk_logged_results = {clk_result_ckp, clk_result_ckn, clk_result_trk};
/****************************************
* SB SYNCHRONIZERS related signals
****************************************/
// these signals are the synchronized version of the sideband inputs for us, our outputs to sideband will be synchronized @ thier domain
wire sync_sb_start_pattern_done;
wire sync_sb_rx_start_training;
wire sync_sb_rx_msg_valid;
wire sync_sb_fifo_empty;
wire sync_sb_time_out;
wire sync_sb_busy;
/****************************************
* RESET SYNCHRONIZERS related signals
****************************************/
wire sync_mb_rst_n;
wire sync_mb_pll_rst_n;
/****************************************
* CLOCK DIVIDERS related signals
****************************************/
wire dig_clk ;
wire clock_local_ckp;
wire dig_clk_gated;
/****************************************
* RDI related signals
****************************************/
assign o_dig_clk = dig_clk; // goes to rdi to synchronize our inputs for us
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// INSTANTIATIONS ////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/****************************************
* LTSM TOP
****************************************/
LTSM_TOP LTSM_TOP_inst (
    .i_clk                                                          (dig_clk_gated),
    .i_rst_n                                                        (sync_mb_rst_n),
    /*------------------------------------------------------------------------------------------------------------
     * RDI signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_start_training_RDI                                           (i_start_training_RDI),
    .i_go_to_phyretrain_RDI                                         (i_go_to_phyretrain_RDI), 
    .i_lp_linkerror                                                 (i_lp_linkerror), 
    .i_go_to_active_RDI                                             (i_go_to_active_RDI), 
    .i_go_to_L1_RDI                                                 (i_go_to_L1_RDI),
    .i_go_to_L2_RDI                                                 (i_go_to_L2_RDI),
    .i_exit_from_L1                                                 (i_exit_from_L1),
    .i_exit_from_L2                                                 (i_exit_from_L2),
    .o_ltsm_in_reset                                                (o_ltsm_in_reset),
    .o_pl_trainerror                                                (o_pl_trainerror),
    .o_pl_inband_pres                                               (o_pl_inband_pres),
    .o_pl_error                                                     (o_pl_error),
    /*------------------------------------------------------------------------------------------------------------
     * SB signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_SB_fifo_empty                                                (sync_sb_fifo_empty),
    .i_start_pattern_done                                           (sync_sb_start_pattern_done),
    .i_start_training_SB                                            (sync_sb_rx_start_training),
    .i_time_out                                                     (sync_sb_time_out),
    .i_busy                                                         (sync_sb_busy),
    .i_rx_msg_valid                                                 (sync_sb_rx_msg_valid),
    .i_decoded_SB_msg                                               (i_rx_msg_no),
    .i_rx_msg_info                                                  (i_rx_msg_info),
    .i_rx_data_bus                                                  (i_rx_data_bus),
    .o_start_pattern_req                                            (o_start_pattern_req),
    .o_tx_state                                                     (o_tx_state),
    .o_tx_sub_state                                                 (o_tx_sub_state),
    .o_encoded_SB_msg                                               (sb_tx_msg_no_ltsm),
    .o_tx_msg_info                                                  (sb_tx_msg_info_ltsm),
    .o_tx_data_bus                                                  (sb_tx_data_bus_ltsm),
    .o_tx_msg_valid                                                 (sb_tx_msg_valid_ltsm),
    .o_tx_data_valid                                                (sb_tx_data_valid_ltsm),
    .o_MBTRAIN_timeout_disable                                      (o_MBTRAIN_timeout_disable),
    /*------------------------------------------------------------------------------------------------------------
     * TX INITIATED D2C POINT TEST signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_Transmitter_initiated_Data_to_CLK_done                       (tx_d2c_pt_done),
    .i_Transmitter_initiated_Data_to_CLK_Result                     (tx_d2c_pt_data_results),
    .i_Transmitter_initiated_Data_to_CLK_valid_result               (tx_d2c_pt_valid_result),
    .o_mainband_or_valtrain_Transmitter_initiated_Data_to_CLK       (tx_datatrain_or_valtrain),
    .o_lfsr_or_perlane_Transmitter_initiated_Data_to_CLK            (tx_perlaneid_or_lfsr),
    .o_Transmitter_initiated_Data_to_CLK_en                         (tx_d2c_pt_en),
    /*------------------------------------------------------------------------------------------------------------
     * RX INITIATED D2C POINT TEST signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_Receiver_initiated_Data_to_CLK_done                          (rx_d2c_pt_done),
    .i_Receiver_initiated_Data_to_CLK_Result                        (rx_d2c_pt_results),
    .o_MBTRAIN_mainband_or_valtrain_Receiver_initiated_Data_to_CLK  (rx_datavref_or_valvref),
    .o_MBTRAIN_Receiver_initiated_Data_to_CLK_en                    (rx_d2c_pt_en),
    /*------------------------------------------------------------------------------------------------------------
     * LFSR TX signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_pattern_generation_done                                      (lfsr_tx_pattern_done),
    .i_REVERSAL_done                                                (lfsr_tx_pattern_done),
    .o_MBINIT_mainband_pattern_generator_cw                         (ltsm_mainband_pattern_generator_cw),
    .o_MBINIT_REVERSALMB_ApplyReversal_En                           (ltsm_apply_reversal_en),
    /*------------------------------------------------------------------------------------------------------------
     * LFSR RX signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_comparsion_results                                           (lfsr_rx_comparison_results),
    .i_aggregate_error_found                                        (aggregate_error_found),
    .o_MBINIT_mainband_pattern_comparator_cw                        (ltsm_mainband_pattern_comparator_cw),
    /*------------------------------------------------------------------------------------------------------------
     * CLOCK CONTROLLER signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_CLK_Track_done                                               (clk_tx_pattern_done),
    .o_MBINIT_REPAIRCLK_Pattern_En                                  (ltsm_clk_tx_pattern_en),
    .o_MBINIT_Final_ClockMode                                       (ltsm_final_clk_mode),
    .o_MBINIT_Final_ClockPhase                                      (o_diff_or_quad_clk),
    /*------------------------------------------------------------------------------------------------------------
     * CLOCK PATTERN DETECTOR signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_logged_clk_result                                            (clk_logged_results),
    .o_MBINIT_clear_clk_detection                                   (ltsm_clear_clk_results),
    /*------------------------------------------------------------------------------------------------------------
     * VALID CONTROLLER signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_VAL_Pattern_done                                             (val_tx_pattern_done),
    .o_MBINIT_REPAIRVAL_Pattern_En                                  (ltsm_val_pattern_en),
    /*------------------------------------------------------------------------------------------------------------
     * VALID PATTERN DETECTOR signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_logged_val_result                                            (val_rx_comparison_result),
    .i_valid_framing_error                                          (valid_frame_detect),
    .o_MBINIT_enable_cons                                           (ltsm_valid_consec_detect),
    /*------------------------------------------------------------------------------------------------------------
     * MAPPER/DEMAPPER signals
    ------------------------------------------------------------------------------------------------------------*/ 
    .o_mapper_demapper_en                                           (mapper_demapper_en), 
    /*------------------------------------------------------------------------------------------------------------
     * OTHERS 
    ------------------------------------------------------------------------------------------------------------*/
    .i_start_training_DVSEC                                         (1'b0), // to be edited
    .o_reciever_ref_volatge                                         (o_reciever_ref_volatge),
    .o_functional_tx_lanes                                          (ltsm_functional_tx_lanes),
    .o_functional_rx_lanes                                          (ltsm_functional_rx_lanes),
    .o_MBTRAIN_tx_eye_width_sweep_en                                (o_MBTRAIN_tx_eye_width_sweep_en),
    .o_MBTRAIN_rx_eye_width_sweep_en                                (o_MBTRAIN_rx_eye_width_sweep_en),
    .o_curret_operating_speed                                       (o_curret_operating_speed),
    .o_falling_edge_busy                                            (falling_edge_busy)
); 
/****************************************
* TX INITIATED D2C POINT TEST
****************************************/
tx_initiated_point_test_wrapper tx_d2c_pt_inst (
    .clk                                (dig_clk_gated),    
    .rst_n                              (sync_mb_rst_n),  
    /*------------------------------------------------------------------------------------------------------------
     * LTSM signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_en                               (tx_d2c_pt_en), 
    .i_mainband_or_valtrain_test        (tx_datatrain_or_valtrain), 
    .i_lfsr_or_perlane                  (tx_perlaneid_or_lfsr), 
    .i_falling_edge_busy                (falling_edge_busy),
    .o_valid_result                     (tx_d2c_pt_valid_result),    
    .o_mainband_lanes_result            (tx_d2c_pt_data_results),   
    .o_test_ack                         (tx_d2c_pt_done),
    /*------------------------------------------------------------------------------------------------------------
     * SB signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_sideband_message                 (i_rx_msg_no),
    .i_sideband_data                    (i_rx_data_bus),
    .i_sideband_message_valid           (sync_sb_rx_msg_valid),
    .i_busy                             (sync_sb_busy),
    .i_msg_info                         (i_rx_msg_info[1]),
    .o_msg_info                         (sb_tx_msg_info_tx_d2c_pt),
    .o_sideband_message                 (sb_tx_msg_no_tx_d2c_pt),
    .o_valid                            (sb_tx_msg_valid_tx_d2c_pt),
    .o_sideband_data                    (sb_tx_data_bus_tx_d2c_pt),
    .o_data_valid                       (sb_tx_data_valid_tx_d2c_pt),
    /*------------------------------------------------------------------------------------------------------------
     * LFSR TX signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_pattern_finished                 (lfsr_tx_pattern_done | val_tx_pattern_done), 
    .o_mainband_pattern_generator_cw    (mainband_pattern_generator_cw_tx_d2c_pt),
    /*------------------------------------------------------------------------------------------------------------
     * LFSR RX signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_comparison_results               (lfsr_rx_comparison_results),
    .o_mainband_pattern_compartor_cw    (mainband_pattern_comparator_cw_tx_d2c_pt),
    /*------------------------------------------------------------------------------------------------------------
     * VALID CONTROLLER signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_valid_result                     (val_rx_comparison_result),
    .o_val_pattern_en                   (val_pattern_en_tx_d2c_pt),
    .o_comparison_valid_en              (val_comparison_en_tx_d2c_pt)
);
/****************************************
* RX INITIATED D2C POINT TEST
****************************************/
rx_initiated_point_test_wrapper rx_d2c_pt_inst (
    .i_clk                              (dig_clk_gated),
    .i_rst_n                            (sync_mb_rst_n),
    /*------------------------------------------------------------------------------------------------------------
     * LTSM signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_rx_d2c_pt_en                     (rx_d2c_pt_en),
    .i_datavref_or_valvref              (rx_datavref_or_valvref),
    .i_falling_edge_busy                (falling_edge_busy),
    .o_comparison_result                (rx_d2c_pt_results),
    .o_rx_d2c_pt_done                   (rx_d2c_pt_done),
    /*------------------------------------------------------------------------------------------------------------
     * SB signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_SB_Busy                          (sync_sb_busy),
    .i_rx_msg_valid                     (sync_sb_rx_msg_valid),
    .i_decoded_SB_msg                   (i_rx_msg_no),
    .o_encoded_SB_msg                   (sb_tx_msg_no_rx_d2c_pt),
    .o_tx_data_bus                      (sb_tx_data_bus_rx_d2c_pt),
    .o_tx_data_valid                    (sb_tx_data_valid_rx_d2c_pt),
    .o_tx_msg_valid                     (sb_tx_msg_valid_rx_d2c_pt),
    /*------------------------------------------------------------------------------------------------------------
     * LFSR TX signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_pattern_finished                 (lfsr_tx_pattern_done | val_tx_pattern_done),
    .o_mainband_pattern_generator_cw    (mainband_pattern_generator_cw_rx_d2c_pt),
    /*------------------------------------------------------------------------------------------------------------
     * LFSR RX signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_comparison_results               (lfsr_rx_comparison_results),
    .o_mainband_pattern_comparator_cw   (mainband_pattern_comparator_cw_rx_d2c_pt),
    /*------------------------------------------------------------------------------------------------------------
     * VALID CONTROLLER signals
    ------------------------------------------------------------------------------------------------------------*/
    .o_val_pattern_en                   (val_pattern_en_rx_d2c_pt),
    .o_comparison_valid_en              (val_comparison_en_rx_d2c_pt)
);
/****************************************
* LFSR TRANSMITTER
****************************************/
LFSR_Transmitter #(
    .WIDTH (SER_WIDTH) 
) LFSR_TX_inst (
    .i_clk                            (dig_clk_gated),                      
    .i_rst_n                          (sync_mb_rst_n),                   
    .i_state                          (mainband_pattern_generator_cw),                    
    .i_enable_scrambeling_pattern     (i_enable_scrambler), // this signal is from rdi to indicate that there is an adapter valid data
    .i_functional_tx_lanes            (ltsm_functional_tx_lanes),      
    .i_enable_reversal                (ltsm_apply_reversal_en),          
    .i_lane_0                         (o_mapper_lane_0),
    .i_lane_1                         (o_mapper_lane_1),
    .i_lane_2                         (o_mapper_lane_2),
    .i_lane_3                         (o_mapper_lane_3),
    .i_lane_4                         (o_mapper_lane_4),
    .i_lane_5                         (o_mapper_lane_5),
    .i_lane_6                         (o_mapper_lane_6),
    .i_lane_7                         (o_mapper_lane_7),
    .i_lane_8                         (o_mapper_lane_8),
    .i_lane_9                         (o_mapper_lane_9),
    .i_lane_10                        (o_mapper_lane_10),
    .i_lane_11                        (o_mapper_lane_11),
    .i_lane_12                        (o_mapper_lane_12),
    .i_lane_13                        (o_mapper_lane_13),
    .i_lane_14                        (o_mapper_lane_14),
    .i_lane_15                        (o_mapper_lane_15),
    .o_lane_0                         (o_lfsr_tx_lane_0),
    .o_lane_1                         (o_lfsr_tx_lane_1),
    .o_lane_2                         (o_lfsr_tx_lane_2),
    .o_lane_3                         (o_lfsr_tx_lane_3),
    .o_lane_4                         (o_lfsr_tx_lane_4),
    .o_lane_5                         (o_lfsr_tx_lane_5),
    .o_lane_6                         (o_lfsr_tx_lane_6),
    .o_lane_7                         (o_lfsr_tx_lane_7),
    .o_lane_8                         (o_lfsr_tx_lane_8),
    .o_lane_9                         (o_lfsr_tx_lane_9),
    .o_lane_10                        (o_lfsr_tx_lane_10),
    .o_lane_11                        (o_lfsr_tx_lane_11),
    .o_lane_12                        (o_lfsr_tx_lane_12),
    .o_lane_13                        (o_lfsr_tx_lane_13),
    .o_lane_14                        (o_lfsr_tx_lane_14),
    .o_lane_15                        (o_lfsr_tx_lane_15),
    .o_Lfsr_tx_done                   (lfsr_tx_pattern_done),
    .o_enable_frame                   (o_serliazer_data_en) // this bit should be delayed one clock cycle to be aligned with o_serliazer_valid_en?
);
/****************************************
* LFSR RECEIVER
****************************************/
LFSR_Receiver #(
    .WIDTH (SER_WIDTH) 
) LFSR_RX_inst (
    .i_clk                            (dig_clk_gated),
    .i_rst_n                          (sync_mb_rst_n),
    .i_state                          (mainband_pattern_comparator_cw),
    .i_functional_rx_lanes            (ltsm_functional_rx_lanes),
    .i_enable_Descrambeling_pattern   (i_deser_valid_data & mapper_demapper_en), // use the deser_valid_data as an enable to de-scrambler but only in active state which is (mapper_demapper_en) signal
    .i_enable_buffer                  (i_deser_valid_data),
    .i_data_in_0                      (i_lfsr_rx_lane_0),
    .i_data_in_1                      (i_lfsr_rx_lane_1),
    .i_data_in_2                      (i_lfsr_rx_lane_2),
    .i_data_in_3                      (i_lfsr_rx_lane_3),
    .i_data_in_4                      (i_lfsr_rx_lane_4),
    .i_data_in_5                      (i_lfsr_rx_lane_5),
    .i_data_in_6                      (i_lfsr_rx_lane_6),
    .i_data_in_7                      (i_lfsr_rx_lane_7),
    .i_data_in_8                      (i_lfsr_rx_lane_8),
    .i_data_in_9                      (i_lfsr_rx_lane_9),
    .i_data_in_10                     (i_lfsr_rx_lane_10),
    .i_data_in_11                     (i_lfsr_rx_lane_11),
    .i_data_in_12                     (i_lfsr_rx_lane_12),
    .i_data_in_13                     (i_lfsr_rx_lane_13),
    .i_data_in_14                     (i_lfsr_rx_lane_14),
    .i_data_in_15                     (i_lfsr_rx_lane_15),
    .o_Data_by_0                      (o_lfsr_rx_bypass_0),
    .o_Data_by_1                      (o_lfsr_rx_bypass_1),
    .o_Data_by_2                      (o_lfsr_rx_bypass_2),
    .o_Data_by_3                      (o_lfsr_rx_bypass_3),
    .o_Data_by_4                      (o_lfsr_rx_bypass_4),
    .o_Data_by_5                      (o_lfsr_rx_bypass_5),
    .o_Data_by_6                      (o_lfsr_rx_bypass_6),
    .o_Data_by_7                      (o_lfsr_rx_bypass_7),
    .o_Data_by_8                      (o_lfsr_rx_bypass_8),
    .o_Data_by_9                      (o_lfsr_rx_bypass_9),
    .o_Data_by_10                     (o_lfsr_rx_bypass_10),
    .o_Data_by_11                     (o_lfsr_rx_bypass_11),
    .o_Data_by_12                     (o_lfsr_rx_bypass_12),
    .o_Data_by_13                     (o_lfsr_rx_bypass_13),
    .o_Data_by_14                     (o_lfsr_rx_bypass_14),
    .o_Data_by_15                     (o_lfsr_rx_bypass_15),
    .o_final_gene_0                   (o_lfsr_rx_final_gen_0),
    .o_final_gene_1                   (o_lfsr_rx_final_gen_1),
    .o_final_gene_2                   (o_lfsr_rx_final_gen_2),
    .o_final_gene_3                   (o_lfsr_rx_final_gen_3),
    .o_final_gene_4                   (o_lfsr_rx_final_gen_4),
    .o_final_gene_5                   (o_lfsr_rx_final_gen_5),
    .o_final_gene_6                   (o_lfsr_rx_final_gen_6),
    .o_final_gene_7                   (o_lfsr_rx_final_gen_7),
    .o_final_gene_8                   (o_lfsr_rx_final_gen_8),
    .o_final_gene_9                   (o_lfsr_rx_final_gen_9),
    .o_final_gene_10                  (o_lfsr_rx_final_gen_10),
    .o_final_gene_11                  (o_lfsr_rx_final_gen_11),
    .o_final_gene_12                  (o_lfsr_rx_final_gen_12),
    .o_final_gene_13                  (o_lfsr_rx_final_gen_13),
    .o_final_gene_14                  (o_lfsr_rx_final_gen_14),
    .o_final_gene_15                  (o_lfsr_rx_final_gen_15),
    .enable_pattern_comparitor        (enable_pattern_comparitor)
);
/****************************************
* LFSR COMPARATOR
****************************************/
pattern_comparator #(
    .WIDTH (SER_WIDTH)
) PATTERN_COMP_inst (
    .i_clk                            (dig_clk_gated),
    .i_rst_n                          (sync_mb_rst_n),
    .i_Type_comp                      (1'b1), // 0h: aggregate comparison , 1h: per lane comparison
    .i_enable_buffer                  (i_deser_valid_data), // a valid signal from data deserializer
    .i_state                          (mainband_pattern_comparator_cw),
    .enable_pattern_comparitor        (enable_pattern_comparitor),
    .i_local_gen_0                    (o_lfsr_rx_final_gen_0),
    .i_local_gen_1                    (o_lfsr_rx_final_gen_1),
    .i_local_gen_2                    (o_lfsr_rx_final_gen_2),
    .i_local_gen_3                    (o_lfsr_rx_final_gen_3),
    .i_local_gen_4                    (o_lfsr_rx_final_gen_4),
    .i_local_gen_5                    (o_lfsr_rx_final_gen_5),
    .i_local_gen_6                    (o_lfsr_rx_final_gen_6),
    .i_local_gen_7                    (o_lfsr_rx_final_gen_7),
    .i_local_gen_8                    (o_lfsr_rx_final_gen_8),
    .i_local_gen_9                    (o_lfsr_rx_final_gen_9),
    .i_local_gen_10                   (o_lfsr_rx_final_gen_10),
    .i_local_gen_11                   (o_lfsr_rx_final_gen_11),
    .i_local_gen_12                   (o_lfsr_rx_final_gen_12),
    .i_local_gen_13                   (o_lfsr_rx_final_gen_13),
    .i_local_gen_14                   (o_lfsr_rx_final_gen_14),
    .i_local_gen_15                   (o_lfsr_rx_final_gen_15),
    .i_Data_by_0                      (o_lfsr_rx_bypass_0),
    .i_Data_by_1                      (o_lfsr_rx_bypass_1),
    .i_Data_by_2                      (o_lfsr_rx_bypass_2),
    .i_Data_by_3                      (o_lfsr_rx_bypass_3),
    .i_Data_by_4                      (o_lfsr_rx_bypass_4),
    .i_Data_by_5                      (o_lfsr_rx_bypass_5),
    .i_Data_by_6                      (o_lfsr_rx_bypass_6),
    .i_Data_by_7                      (o_lfsr_rx_bypass_7),
    .i_Data_by_8                      (o_lfsr_rx_bypass_8),
    .i_Data_by_9                      (o_lfsr_rx_bypass_9),
    .i_Data_by_10                     (o_lfsr_rx_bypass_10),
    .i_Data_by_11                     (o_lfsr_rx_bypass_11),
    .i_Data_by_12                     (o_lfsr_rx_bypass_12),
    .i_Data_by_13                     (o_lfsr_rx_bypass_13),
    .i_Data_by_14                     (o_lfsr_rx_bypass_14),
    .i_Data_by_15                     (o_lfsr_rx_bypass_15),
    .i_Max_error_Threshold_per_lane   (12'h001),  // to be edited
    .i_Max_error_Threshold_aggregate  (16'h0001), // to be edited
    .o_per_lane_error                 (lfsr_rx_comparison_results),
    .o_error_done                     (aggregate_error_found)
);
/****************************************
* VALID CONTROLLER
****************************************/
Valtrain_Controller VALTRAIN_CTRL_inst (
    .i_clk                 (dig_clk_gated),
    .i_rst_n               (sync_mb_rst_n),
    .Valid_pattern_enable  (val_pattern_en_rx_d2c_pt | val_pattern_en_tx_d2c_pt | ltsm_val_pattern_en),
    .valid_frame_enable    (o_serliazer_data_en), 
    .o_TVLD_L              (o_TVLD_L), 
    .o_done                (val_tx_pattern_done),
    .enable_detector       (o_serliazer_valid_en) 
);
/****************************************
* VALID PATTERN DETECTOR
****************************************/
Pattern_valid_detector PATTERN_VALID_DET_inst (
    .i_clk               (dig_clk_gated),
    .i_rst_n             (sync_mb_rst_n),
    .RVLD_L              (i_RVLD_L),
    .error_threshold     (12'h001),
    .i_enable_cons       (ltsm_valid_consec_detect & ~(val_comparison_en_rx_d2c_pt | val_comparison_en_tx_d2c_pt)), // ltsm_valid_consec_detect: ayman mkhliha dayman b 1'b1 so i made & ~(val_comparison_en_rx_d2c_pt | val_comparison_en_tx_d2c_pt)
    .i_enable_128        (val_comparison_en_rx_d2c_pt | val_comparison_en_tx_d2c_pt), 
    .i_enable_detector   (i_deser_valid_val),
    .detection_result    (val_rx_comparison_result),
    .o_valid_frame_detect(valid_frame_detect) // this signal detects if there is a valid framing error (should be connected to LTSM TOP)
);
/****************************************
* MAPPER
****************************************/
Byte_To_lane_mapping #(
    .WIDTH       (SER_WIDTH),         
    .N_BYTES     (1024),     
    .NUM_LANES   (16)          
) MAPPER_inst (
    .i_clk                  (dig_clk_gated),
    .i_rst_n                (sync_mb_rst_n),
    .i_in_data              (i_lp_data),
    .enable_mapper          (mapper_demapper_en),
    .i_functional_tx_lanes  (ltsm_functional_tx_lanes),
    .o_lane_0               (o_mapper_lane_0),
    .o_lane_1               (o_mapper_lane_1),
    .o_lane_2               (o_mapper_lane_2),
    .o_lane_3               (o_mapper_lane_3),
    .o_lane_4               (o_mapper_lane_4),
    .o_lane_5               (o_mapper_lane_5),
    .o_lane_6               (o_mapper_lane_6),
    .o_lane_7               (o_mapper_lane_7),
    .o_lane_8               (o_mapper_lane_8),
    .o_lane_9               (o_mapper_lane_9),
    .o_lane_10              (o_mapper_lane_10),
    .o_lane_11              (o_mapper_lane_11),
    .o_lane_12              (o_mapper_lane_12),
    .o_lane_13              (o_mapper_lane_13),
    .o_lane_14              (o_mapper_lane_14),
    .o_lane_15              (o_mapper_lane_15)
);
/****************************************
* DEMAPPER
****************************************/
Lane_To_Byte_Demapping #(
    .WIDTH       (SER_WIDTH),        
    .N_BYTES     (64),         
    .NUM_LANES   (16)          
) DEMAPPER_inst (
    .i_clk                  (dig_clk_gated),
    .i_rst_n                (sync_mb_rst_n),
    .i_lane_0               (o_lfsr_rx_bypass_0),
    .i_lane_1               (o_lfsr_rx_bypass_1),
    .i_lane_2               (o_lfsr_rx_bypass_2),
    .i_lane_3               (o_lfsr_rx_bypass_3),
    .i_lane_4               (o_lfsr_rx_bypass_4),
    .i_lane_5               (o_lfsr_rx_bypass_5),
    .i_lane_6               (o_lfsr_rx_bypass_6),
    .i_lane_7               (o_lfsr_rx_bypass_7),
    .i_lane_8               (o_lfsr_rx_bypass_8),
    .i_lane_9               (o_lfsr_rx_bypass_9),
    .i_lane_10              (o_lfsr_rx_bypass_10),
    .i_lane_11              (o_lfsr_rx_bypass_11),
    .i_lane_12              (o_lfsr_rx_bypass_12),
    .i_lane_13              (o_lfsr_rx_bypass_13),
    .i_lane_14              (o_lfsr_rx_bypass_14),
    .i_lane_15              (o_lfsr_rx_bypass_15),
    .enable_demapper        (~enable_pattern_comparitor),
    .i_functional_rx_lanes  (ltsm_functional_rx_lanes),
    .o_out_data             (o_pl_data)
);
/****************************************
* CLOCK GEN/COMP WRAPPER
****************************************/
clock_generator clock_generator_inst (
    .i_dig_clk              (dig_clk_gated),
    .i_rst_n                (sync_mb_rst_n),
    .i_local_ckp            (clock_local_ckp), // half rate clock
    .i_local_ckn            (~clock_local_ckp),
    .i_pll_clk              (i_pll_mb_clk),
    .i_start_clk_training   (ltsm_clk_tx_pattern_en),
    .i_ltsm_in_reset        (~|o_tx_state),
    .o_CKP                  (o_CKP),
    .o_CKN                  (o_CKN),
    .o_TRACK                (o_TRACK),
    .o_done                 (clk_tx_pattern_done)
);
clock_detector clock_detector_ckp_inst (
    .i_dig_clk                      (dig_clk_gated),
    .i_half_pll_clk                 (clock_local_ckp),
    .i_rst_n                        (sync_mb_rst_n),
    .i_RCLK                         (i_RCKP),
    .i_start_clk_training           (ltsm_clk_tx_pattern_en),
    .i_clear_results                (ltsm_clear_clk_results),
    .o_result                       (clk_result_ckp)
);
clock_detector clock_detector_ckn_inst (
    .i_dig_clk                      (dig_clk_gated),
    .i_half_pll_clk                 (~clock_local_ckp),
    .i_rst_n                        (sync_mb_rst_n),
    .i_RCLK                         (i_RCKN),
    .i_start_clk_training           (ltsm_clk_tx_pattern_en),
    .i_clear_results                (ltsm_clear_clk_results),
    .o_result                       (clk_result_ckn)
);
clock_detector clock_detector_trk_inst (
    .i_dig_clk                      (dig_clk_gated),
    .i_half_pll_clk                 (clock_local_ckp),
    .i_rst_n                        (sync_mb_rst_n),
    .i_RCLK                         (i_RTRACK),
    .i_start_clk_training           (ltsm_clk_tx_pattern_en),
    .i_clear_results                (ltsm_clear_clk_results),
    .o_result                       (clk_result_trk)
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////// CLOCK DIVIDERS ///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/****************************************
* MAINBAND CLOCK DIVIDER
****************************************/
clock_div_32 clock_div_32_inst_1 (
    .i_clk             (i_pll_mb_clk),
    .i_rst_n           (sync_mb_pll_rst_n),
    .o_div_clk         (dig_clk)
);  
/****************************************
* LOCAL CKP/CKN CLOCK DIVIDER
****************************************/
clock_div_2 clock_div_2_inst (
    .i_clk             (i_pll_mb_clk),
    .i_rst_n           (sync_mb_rst_n),
    .o_div_clk         (clock_local_ckp)
);
/****************************************
* MAINBAND CLOCK GATER 
****************************************/
CLK_GATING clock_gating_inst (
    .CLK        (dig_clk),
    .EN         (i_clk_gating_en),
    .GATED_CLK  (dig_clk_gated)
)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////// SYNCHRONIZERS ///////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/******************************************
* SB --> LTSM SYNCHRONIZERS (SLOW -> FAST)
******************************************/
bit_synchronizer SBINIT_start_pattern_done_sync_inst (
    .i_clk      (dig_clk),
    .i_rst_n    (sync_mb_rst_n),
    .i_data_in  (i_start_pattern_done),
    .o_data_out (sync_sb_start_pattern_done)
);
bit_synchronizer SB_start_training_sync_inst (
    .i_clk      (dig_clk),
    .i_rst_n    (sync_mb_rst_n),
    .i_data_in  (i_start_training_SB),
    .o_data_out (sync_sb_rx_start_training)
);
bit_synchronizer SB_fifo_empty_sync_inst (
    .i_clk      (dig_clk),
    .i_rst_n    (sync_mb_rst_n),
    .i_data_in  (i_SB_fifo_empty),
    .o_data_out (sync_sb_fifo_empty)
);
bit_synchronizer SB_timeout_sync_inst (
    .i_clk      (dig_clk),
    .i_rst_n    (sync_mb_rst_n),
    .i_data_in  (i_time_out),
    .o_data_out (sync_sb_time_out)
);
bit_synchronizer SB_busy_sync_inst (
    .i_clk      (dig_clk),
    .i_rst_n    (sync_mb_rst_n),
    .i_data_in  (i_busy),
    .o_data_out (sync_sb_busy)
);
bit_synchronizer SB_rx_msg_valid_sync_inst (
    .i_clk      (dig_clk),
    .i_rst_n    (sync_mb_rst_n),
    .i_data_in  (i_rx_msg_valid),
    .o_data_out (sync_sb_rx_msg_valid)
);
/****************************************
* RESET SYNCHRONIZERS
****************************************/
// Mainband (dig clock)
bit_synchronizer bit_synchronizer_mainband_digclk (
    .i_clk      (dig_clk), // all mainband resets synchronized with the slowest clock (pll_clk/32)
    .i_rst_n    (i_rst_n),
    .i_data_in  (1'b1),
    .o_data_out (sync_mb_rst_n)
);
//////////////////////////////////////////////////////////////////////////////////////////////////////
 /* the synchronizer below used to just synchronize the reset for the dig_clk generator block which //
   is the clock_div_32 since all other blocks resets is synchronized with this dig_clk so how can   //
   we synchronize the reset with dig_clk if the dig_clk generator is not working yet ? .. so the    //
   generator of the dig clock should be reseted synchronosly with the pll_clk                       //
   -----------------------------------------------------------------------------------------------  //
 * after generating the dig clock while the reset is already deasserted many clock cycles earlier,  //
   the 1'b1 in the reset synchronizer can now propagate and de-asserts reset in all other blocks    //
   working with dig_clk */                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////
// Mainband (pll clock)
bit_synchronizer bit_synchronizer_mainband_pllclk (
    .i_clk      (i_pll_mb_clk), // all mainband resets synchronized with the slowest clock (pll_clk/32)
    .i_rst_n    (i_rst_n),
    .i_data_in  (1'b1),
    .o_data_out (sync_mb_pll_rst_n)
);
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////// ORing ///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*---------------------------------------
 * sideband tx message number Oring
---------------------------------------*/
assign o_tx_msg_no = sb_tx_msg_no_ltsm | sb_tx_msg_no_tx_d2c_pt | sb_tx_msg_no_rx_d2c_pt;
/*---------------------------------------
 * sideband tx message info Oring
---------------------------------------*/
assign o_tx_msg_info = {sb_tx_msg_info_ltsm[2], (sb_tx_msg_info_ltsm[1]  | sb_tx_msg_info_tx_d2c_pt), sb_tx_msg_info_ltsm[0]}; // 34an el tx d2c pt haytl3 1 bit msg info w 3ayzeen el bus sa3tha ykun kdh 3'b010 or 3'b000
/*---------------------------------------
 * sideband tx data bus Oring
---------------------------------------*/
assign o_tx_data_bus = sb_tx_data_bus_ltsm | sb_tx_data_bus_rx_d2c_pt | sb_tx_data_bus_tx_d2c_pt;
/*---------------------------------------
 * sideband tx message valid Oring
---------------------------------------*/
assign o_tx_msg_valid = sb_tx_msg_valid_ltsm | sb_tx_msg_valid_rx_d2c_pt | sb_tx_msg_valid_tx_d2c_pt;
/*---------------------------------------
 * sideband tx data valid Oring
---------------------------------------*/
assign o_tx_data_valid = sb_tx_data_valid_ltsm | sb_tx_data_valid_rx_d2c_pt | sb_tx_data_valid_tx_d2c_pt;
/*---------------------------------------
 * mainband_pattern_generator_cw ORing
---------------------------------------*/
assign mainband_pattern_generator_cw = ltsm_mainband_pattern_generator_cw | mainband_pattern_generator_cw_tx_d2c_pt | mainband_pattern_generator_cw_rx_d2c_pt;
/*---------------------------------------
 * mainband_pattern_comparator_cw ORing
---------------------------------------*/
assign mainband_pattern_comparator_cw = ltsm_mainband_pattern_comparator_cw | mainband_pattern_comparator_cw_tx_d2c_pt | mainband_pattern_comparator_cw_rx_d2c_pt;

endmodule