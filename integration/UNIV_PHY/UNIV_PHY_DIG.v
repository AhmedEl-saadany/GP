module UNIV_PHY_DIG #(parameter SER_WIDTH = 32) (
/*************************************************************************
* INPUTS
*************************************************************************/
    // clocks and resets 
    input                       i_pll_mb_clk, // main pll clock (4GHz, 8GHz, 12GHz)
    input                       i_pll_sb_clk, // SB pll clock 800MHz
    input                       i_rst_n, 
    
    // Clock lanes input
    input                       i_RCKP,      // Received CKP
    input                       i_RCKN,      // Received CKN
    input                       i_RTRACK,    // Received TRACK

    // valid lane (connected to HM de-serializer)
    input       [SER_WIDTH-1:0] i_RVLD_L, 
    
    // Main band data lanes (connected to HM de-serializers)
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
    
    // Hard-Macro related signals (MB)
    input                       i_deser_valid_data, // a valid signal from data  lane deserializer
    input                       i_deser_valid_val,  // a valid signal from valid lane deserilaizer

    // Hard-Macro related signals (SB)
    input                       i_sb_deser_done,
    input                       i_sb_deser_data,

    // Adapter RDI Interface
    input                       i_lp_irdy,
    input                       i_lp_valid,
    input     [511:0]           i_lp_data, // 64 bytes  lesa hat2kd mn el width               
    input     [3:0]             i_lp_state_req,
    input                       i_lp_linkerror,
    input                       i_lp_stallack,
    input                       i_lp_clk_ack,
    input                       i_lp_wake_req,
    input     [31:0]            i_lp_cfg,
    input                       i_lp_cfg_vld,
    input                       i_lp_cfg_crd,
    /*---------------------------------------------------------------*/
    input                       i_lp_retimer_crd, // NOT USED, IGNORE
    /*---------------------------------------------------------------*/
/*************************************************************************
* OUTPUTS
*************************************************************************/
    // Clock lanes output
    output                      o_CKP,
    output                      o_CKN,
    output                      o_TRACK,

    // valid lane (connected to HM serializer)
    output      [SER_WIDTH-1:0] o_TVLD_L, 

    // Main band data lanes (connected to HM serializers)
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

    // Hard-Macro related signals (MB)
    output                      o_serliazer_valid_en, // valid lane serializer enable
    output                      o_serliazer_data_en,  // data  lane serializer enable
    output                      o_diff_or_quad_clk,
    output     [3:0]            o_reciever_ref_volatge,
    output     [3:0]            o_pi_step,
    output     [2:0]            o_curret_operating_speed,

    // Hard-Macro related signals (SB)
    output                      o_sb_ser_done_sampled,
    output                      o_sb_deser_done_sampled,
    output     [63:0]           o_sb_fifo_data,
    output                      o_sb_packet_finished,
    output                      o_sb_ser_en,
    output                      o_sb_TXCKSB,

    // Adapter RDI Interface
    output                      o_pl_trdy, 
    output                      o_pl_valid,
    output     [511:0]          o_pl_data, // 64B lesa hat2kd mn el WIDTH
    output     [3:0]            o_pl_state_sts,
    output                      o_pl_inband_pres,
    output                      o_pl_error,
    output                      o_pl_nferror,
    output                      o_pl_trainerror,
    output                      o_pl_stallreq,
    output     [2:0]            o_pl_speedmode,
    output     [2:0]            o_pl_lnk_cfg,
    output                      o_pl_clk_req,
    output                      o_pl_wake_ack,
    output     [31:0]           o_pl_cfg,
    output                      o_pl_cfg_vld,
    output                      o_pl_cfg_crd,
    /*------------------------------------------------------------------*/
    output                      o_pl_retimer_crd,   // NOT USED, IGNORE
    output                      o_pl_cerror,        // NOT USED, IGNORE
    output                      o_pl_phyinrecenter  // NOT USED, IGNORE
    /*------------------------------------------------------------------*/
);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// INTERNAL SIGNALS //////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/****************************************
* SB/RDI SHARED SIGNALS
****************************************/
wire rdi_clk;
wire rdi_gated_clk;
wire divided_clk_100mhz;
wire divided_clk_200mhz;
wire sync_sb_rst_n_pll;
wire sync_rdi_rst_n;
/****************************************
* MAINBAND O/Ps SIGNALS
****************************************/
// outputs to sideband
wire mb_start_pattern_req;
wire mb_tx_data_valid;
wire mb_tx_msg_valid;
wire mb_timeout_disable;
wire mb_tx_point_sweep_test_en;
wire [1:0] mb_tx_point_sweep_test_type;
wire [3:0] mb_tx_state;
wire [3:0] mb_tx_sub_state;
wire [3:0] mb_tx_msg_no;
wire [2:0] mb_tx_msg_info;
wire [15:0] mb_tx_data_bus;
// outputs to rdi
wire ltsm_in_reset;
wire ltsm_pl_trainerror;
wire ltsm_pl_inband_pres;
wire ltsm_pl_error;
wire ltsm_dig_clk;
wire [511:0] ltsm_pl_data; // lesa msh mot2kd mn el width
/****************************************
* SIDEBAND O/Ps SIGNALS
****************************************/
// outputs to ltsm
wire sb_fifo_empty;
wire sb_start_pattern_done;
wire sb_start_training;
wire sb_timeout;
wire sb_busy;
wire sb_rx_msg_valid;
wire [3:0] sb_rx_msg_no;
wire [2:0] sb_rx_msg_info;
wire [15:0] sb_rx_data_bus;
// outputs to rdi
wire sb_wake_adapter;
wire sb_msg_done;
wire sb_msg_valid;
wire [3:0] sb_msg_no;
/****************************************
* RDI O/Ps SIGNALS
****************************************/
// outputs to ltsm
wire rdi_start_training;
wire rdi_go_to_phyretrain;
wire rdi_go_to_linkerror;
wire rdi_go_to_active;
wire rdi_go_to_l1;
wire rdi_go_to_l2;
wire rdi_exit_from_l1;
wire rdi_exit_from_l2;
wire rdi_enable_scrambler;
wire rdi_clk_gate_en_sync;  // should be connected to o_clk_gate_en_sync from rdi
// outputs to sideband
wire rdi_adapter_is_waked_up;
wire rdi_msg_valid;
wire rdi_clk_gate_en;
wire [3:0] rdi_msg_no;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// ASSIGN STATMENTS //////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*********************************************
* RDI/SIDEBAND RELATED
*********************************************/
assign rdi_clk = (~|o_curret_operating_speed)? divided_clk_100mhz : divided_clk_200mhz; // this is the rdi clock mux to choose to operate rdi on wether
// 100 MHz clock in case that mainband pll is working on 4G or 200 MHz in case that mainband pll is working at any higher speed, (Hint: ~|X is same as X == 3'b000)
assign o_pl_lnk_cfg = 3'b010; // x16 lanes
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////// INSTANTIATIONS ////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*********************************************
* MAINBAND (LTSM + (DATA,VALID,CLOCK) BLOCKS)
*********************************************/
LTSM_MB #(.SER_WIDTH(32)) LTSM_MB_inst (
    .i_pll_mb_clk               (i_pll_mb_clk),
    .i_rst_n                    (i_rst_n),
    /*------------------------------------------------------------------------------------------------------------
     * Clock lanes 
    ------------------------------------------------------------------------------------------------------------*/
    .i_RCKP                     (i_RCKP),
    .i_RCKN                     (i_RCKN),
    .i_RTRACK                   (i_RTRACK),
    .o_CKP                      (o_CKP),
    .o_CKN                      (o_CKN),
    .o_TRACK                    (o_TRACK),
    /*------------------------------------------------------------------------------------------------------------
     * valid lane
    ------------------------------------------------------------------------------------------------------------*/
    .i_RVLD_L                   (i_RVLD_L),
    .o_TVLD_L                   (o_TVLD_L),
    /*------------------------------------------------------------------------------------------------------------
     * Main band data lanes
    ------------------------------------------------------------------------------------------------------------*/
    .i_lfsr_rx_lane_0           (i_lfsr_rx_lane_0),
    .i_lfsr_rx_lane_1           (i_lfsr_rx_lane_1),
    .i_lfsr_rx_lane_2           (i_lfsr_rx_lane_2),
    .i_lfsr_rx_lane_3           (i_lfsr_rx_lane_3),
    .i_lfsr_rx_lane_4           (i_lfsr_rx_lane_4),
    .i_lfsr_rx_lane_5           (i_lfsr_rx_lane_5),
    .i_lfsr_rx_lane_6           (i_lfsr_rx_lane_6),
    .i_lfsr_rx_lane_7           (i_lfsr_rx_lane_7),
    .i_lfsr_rx_lane_8           (i_lfsr_rx_lane_8),
    .i_lfsr_rx_lane_9           (i_lfsr_rx_lane_9),
    .i_lfsr_rx_lane_10          (i_lfsr_rx_lane_10),
    .i_lfsr_rx_lane_11          (i_lfsr_rx_lane_11),
    .i_lfsr_rx_lane_12          (i_lfsr_rx_lane_12),
    .i_lfsr_rx_lane_13          (i_lfsr_rx_lane_13),
    .i_lfsr_rx_lane_14          (i_lfsr_rx_lane_14),
    .i_lfsr_rx_lane_15          (i_lfsr_rx_lane_15),
    .o_lfsr_tx_lane_0           (o_lfsr_tx_lane_0),
    .o_lfsr_tx_lane_1           (o_lfsr_tx_lane_1),
    .o_lfsr_tx_lane_2           (o_lfsr_tx_lane_2),
    .o_lfsr_tx_lane_3           (o_lfsr_tx_lane_3),
    .o_lfsr_tx_lane_4           (o_lfsr_tx_lane_4),
    .o_lfsr_tx_lane_5           (o_lfsr_tx_lane_5),
    .o_lfsr_tx_lane_6           (o_lfsr_tx_lane_6),
    .o_lfsr_tx_lane_7           (o_lfsr_tx_lane_7),
    .o_lfsr_tx_lane_8           (o_lfsr_tx_lane_8),
    .o_lfsr_tx_lane_9           (o_lfsr_tx_lane_9),
    .o_lfsr_tx_lane_10          (o_lfsr_tx_lane_10),
    .o_lfsr_tx_lane_11          (o_lfsr_tx_lane_11),
    .o_lfsr_tx_lane_12          (o_lfsr_tx_lane_12),
    .o_lfsr_tx_lane_13          (o_lfsr_tx_lane_13),
    .o_lfsr_tx_lane_14          (o_lfsr_tx_lane_14),
    .o_lfsr_tx_lane_15          (o_lfsr_tx_lane_15),
    /*------------------------------------------------------------------------------------------------------------
     * RDI signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_start_training_RDI       (rdi_start_training),
    .i_go_to_phyretrain_RDI     (rdi_go_to_phyretrain),
    .i_go_to_active_RDI         (rdi_go_to_active),
    .i_go_to_L1_RDI             (rdi_go_to_l1),
    .i_go_to_L2_RDI             (rdi_go_to_l2),
    .i_exit_from_L1             (rdi_exit_from_l1),
    .i_exit_from_L2             (rdi_exit_from_l2),
    .i_enable_scrambler         (rdi_enable_scrambler),
    .i_clk_gating_en            (rdi_clk_gate_en_sync), 
    .i_lp_linkerror             (rdi_go_to_linkerror),  
    .i_lp_data                  (i_lp_data),
    .o_pl_data                  (ltsm_pl_data), 
    .o_ltsm_in_reset            (ltsm_in_reset),
    .o_pl_trainerror            (ltsm_pl_trainerror),
    .o_pl_inband_pres           (ltsm_pl_inband_pres),
    .o_pl_error                 (ltsm_pl_error),
    .o_dig_clk                  (ltsm_dig_clk),
    /*------------------------------------------------------------------------------------------------------------
     * Sideband Signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_SB_fifo_empty            (sb_fifo_empty),
    .i_start_pattern_done       (sb_start_pattern_done), 
    .i_start_training_SB        (sb_start_training), 
    .i_time_out                 (sb_timeout), 
    .i_busy                     (sb_busy), 
    .i_rx_msg_valid             (sb_rx_msg_valid), 
    .i_decoded_SB_msg           (sb_rx_msg_no), 
    .i_rx_msg_info              (sb_rx_msg_info), 
    .i_rx_data_bus              (sb_rx_data_bus),
    .o_start_pattern_req        (mb_start_pattern_req),
    .o_tx_state                 (mb_tx_state),
    .o_tx_sub_state             (mb_tx_sub_state),
    .o_tx_msg_no                (mb_tx_msg_no),
    .o_tx_msg_info              (mb_tx_msg_info),
    .o_tx_data_bus              (mb_tx_data_bus),
    .o_tx_msg_valid             (mb_tx_msg_valid),
    .o_tx_data_valid            (mb_tx_data_valid),
    .o_MBTRAIN_timeout_disable  (mb_timeout_disable),
    .o_tx_point_sweep_test_en   (mb_tx_point_sweep_test_en),
    .o_tx_point_sweep_test_type (mb_tx_point_sweep_test_type),
    /*------------------------------------------------------------------------------*/
    .o_MBTRAIN_tx_eye_width_sweep_en (mb_tx_eye_width_sweep_en), // NOT USED, IGNORE
    .o_MBTRAIN_rx_eye_width_sweep_en (mb_rx_eye_width_sweep_en), // NOT USED, IGNORE
    /*------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------------------------------------
     * Hard-macro Signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_deser_valid_data         (i_deser_valid_data),
    .i_deser_valid_val          (i_deser_valid_val),
    .o_serliazer_valid_en       (o_serliazer_valid_en),
    .o_serliazer_data_en        (o_serliazer_data_en),
    .o_diff_or_quad_clk         (o_diff_or_quad_clk),
    .o_reciever_ref_volatge     (o_reciever_ref_volatge),
    .o_pi_step                  (o_pi_step),
    .o_curret_operating_speed   (o_curret_operating_speed)
);
/*********************************************
* SIDEBAND (MB SIDEBAND + RDI SIDEBAND)
*********************************************/
SB_TOP_WRAPPER SB_TOP_WRAPPER_inst (
    .i_sb_pll_clk                  (i_pll_sb_clk),
    .i_sb_mb_clk                   (divided_clk_100mhz), // 100 MHz clock for MB Sideband 
    .i_rdi_clk                     (rdi_clk),            // 100/200 MHz clock for RDI Sideband
    .i_rdi_clk_gated               (rdi_gated_clk),      // same as above but gated for RDI Sideband encoder
    .i_dig_clk                     (ltsm_dig_clk),       // used for synchronizing ltsm inputs from the pov of sideband
    .i_rst_n                       (sync_rdi_rst_n),
    .i_rst_n_pll                   (sync_sb_rst_n_pll),
    /*------------------------------------------------------------------------------------------------------------
     * Adapter Interface
    ------------------------------------------------------------------------------------------------------------*/
    .i_lp_cfg_vld                  (i_lp_cfg_vld),
    .i_lp_cfg                      (i_lp_cfg),
    .i_lp_cfg_crd                  (i_lp_cfg_crd),
    .o_pl_nerror                   (o_pl_nerror),
    .o_pl_cfg_vld                  (o_pl_cfg_vld),
    .o_pl_cfg                      (o_pl_cfg),
    .o_pl_cfg_crd                  (o_pl_cfg_crd),
    /*------------------------------------------------------------------------------------------------------------
     * RDI Signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_adapter_is_waked_up         (rdi_adapter_is_waked_up),
    .i_clk_is_ungated              (rdi_clk_gate_en), // should be connected to o_clk_gate_en from rdi
    .i_msg_no_rdi                  (rdi_msg_no),
    .i_msg_valid_rdi               (rdi_msg_valid),
    .i_pl_inband_pres              (o_pl_inband_pres),
    .o_wake_adapter                (sb_wake_adapter),
    .o_msg_done_rdi                (sb_msg_done),
    .o_msg_valid_rdi               (sb_msg_valid),
    .o_msg_no_rdi                  (sb_msg_no),
    /*------------------------------------------------------------------------------------------------------------
     * MAINBAND Signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_start_pattern_req           (mb_start_pattern_req),
    .i_data_valid                  (mb_tx_data_valid),
    .i_msg_valid                   (mb_tx_msg_valid),
    .i_state                       (mb_tx_state), 
    .i_sub_state                   (mb_tx_sub_state), 
    .i_msg_no                      (mb_tx_msg_no),
    .i_msg_info                    (mb_tx_msg_info),
    .i_data_bus                    (mb_tx_data_bus),
    .i_stop_cnt                    (mb_timeout_disable),
    .i_tx_point_sweep_test_en      (mb_tx_point_sweep_test_en),
    .i_tx_point_sweep_test         (mb_tx_point_sweep_test_type),
    .o_start_pattern_done          (sb_start_pattern_done),
    .o_time_out                    (sb_timeout),
    .o_busy                        (sb_busy),
    .o_rx_sb_start_pattern         (sb_start_training),
    .o_mb_msg_valid                (sb_rx_msg_valid),
    .o_mb_msg_no                   (sb_rx_msg_no),
    .o_mb_msg_info                 (sb_rx_msg_info),
    .o_mb_data                     (sb_rx_data_bus),
    .o_mb_fifo_empty               (sb_fifo_empty),
    /*-------------------------------------------------------------------------------*/
    .o_adapter_enable              (adapter_enable),            // NOT USED, IGNORE
    .o_mb_tx_point_sweep_test_en   (sb_tx_point_sweep_test_en), // NOT USED, IGNORE
    .o_parity_error                (parity_error),              // NOT USED, IGNORE
    .o_mb_tx_point_sweep_test      (sb_tx_point_sweep_test),    // NOT USED, IGNORE
    /*-------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------------------------------------
     * Hard-macro Signals
    ------------------------------------------------------------------------------------------------------------*/
    .i_deser_done                  (i_sb_deser_done),
    .i_deser_data                  (i_sb_deser_data),
    .o_ser_done_sampled            (o_sb_ser_done_sampled),
    .o_deser_done_sampled          (o_sb_deser_done_sampled),
    .o_fifo_data                   (o_sb_fifo_data),
    .o_packet_finished             (o_sb_packet_finished),
    .o_ser_en                      (o_sb_ser_en),
    .o_TXCKSB                      (o_sb_TXCKSB)
);
/*********************************************
* RDI TOP
*********************************************/
RDI_TOP  #(.NBYTES(64*8)) RDI_TOP_inst (
    .lclk                                   (rdi_clk),                              
    .sys_rst                                (sync_rdi_rst_n),                       
    .clk_ltsm                               (ltsm_dig_clk),                         
    .o_clk_for_rdi_controller               (rdi_gated_clk),    
    /*------------------------------------------------------------------------------------------------------------
     * LTSM Interface
    ------------------------------------------------------------------------------------------------------------*/
    .i_reset_only_from_ltsm                 (ltsm_in_reset),                        
    .i_pl_error_from_ltsm                   (ltsm_pl_error),                        
    .i_pl_inband_pres_from_ltsm             (ltsm_pl_inband_pres),                  
    .i_pl_train_error_from_ltsm             (ltsm_pl_trainerror),                   
    .i_pl_link_speed_from_ltsm              (o_curret_operating_speed),             
    .o_go_to_l1_from_rdi_to_ltsm_sync       (rdi_go_to_l1),                         
    .o_go_to_l2_from_rdi_to_ltsm_sync       (rdi_go_to_l2),                         
    .o_go_to_active_from_rdi_to_ltsm_sync   (rdi_go_to_active),                     
    .o_go_to_training_from_rdi_to_ltsm_sync (rdi_start_training),                   
    .o_go_to_linkerror_from_rdi_to_ltsm_sync(rdi_go_to_linkerror),                 
    .o_go_to_retrain_from_rdi_to_ltsm_sync  (rdi_go_to_phyretrain),                 
    .o_exit_from_l1_sync                    (rdi_exit_from_l1),                     
    .o_reset_counter_signal                 (rdi_exit_from_l2),                     
    .o_clk_gate_en_sync                     (rdi_clk_gate_en_sync),                 
    /*------------------------------------------------------------------------------------------------------------
     * Adapter Interface ///////////////////// AYMAN: zabt el data flow signals lp_data/pl_data interconnections between rdi and ltsm and adapter  ////////////
    ------------------------------------------------------------------------------------------------------------*/
    .i_lp_state_req                         (i_lp_state_req),
    .i_lp_wake_req                          (i_lp_wake_req),
    .i_lp_stallack                          (i_lp_stallack),
    .i_lp_linkerror                         (i_lp_linkerror),
    .i_lp_clk_ack                           (i_lp_clk_ack),
    .i_lp_irdy                              (i_lp_irdy),
    .i_lp_valid                             (i_lp_valid),
    .i_lp_data                              (i_lp_data),
    .o_pl_wake_ack                          (o_pl_wake_ack),
    .o_pl_clk_req                           (o_pl_clk_req),
    .o_pl_stallreq                          (o_pl_stallreq),
    .o_pl_trdy                              (o_pl_trdy),
    .o_pl_valid                             (o_pl_valid),
    .o_pl_data                              (o_pl_data),
    .o_pl_error                             (o_pl_error),
    .o_pl_train_error                       (o_pl_trainerror),
    .o_pl_speed_mode                        (o_pl_speedmode),
    .o_pl_state_sts                         (o_pl_state_sts),
    .o_pl_inband_pres                       (o_pl_inband_pres),
    /*------------------------------------------------------------------------------------------------------------
     * Sideband Interface
    ------------------------------------------------------------------------------------------------------------*/
    .i_rx_sb_message                        (sb_msg_no),
    .i_rx_msg_valid                         (sb_msg_valid),
    .i_rx_done_send_message                 (sb_msg_done),
    .i_wake_adapter                         (sb_wake_adapter),
    .o_tx_sb_message                        (rdi_msg_no),
    .o_tx_msg_valid                         (rdi_msg_valid),
    .o_clk_done_hand_shake                  (rdi_adapter_is_waked_up),
    .o_clk_gate_en                          (rdi_clk_gate_en), ///////////////////// AYMAN: Tal3 el signal di zy mhya b esmha kdh o_clk_gate_en ////////////
    /*------------------------------------------------------------------------------------------------------------
     * Others
    ------------------------------------------------------------------------------------------------------------*/
    .i_reset_pin_or_soft_ware_clear_error (reset_pin_or_clear_error)
);


///////////////////////////////////////////////////////////////////////////////////////
// this blocks outputs are shared between sideband and RDI
///////////////////////////////////////////////////////////////////////////////////////
/****************************************
* CLOCK DIVIDER 
****************************************/
Clock_Divider_by_8 sb_clk_div_inst (
    .i_pll_clk      (i_pll_sb_clk),
    .i_rst_n        (sync_sb_rst_n_pll),
    .o_divided_clk  (divided_clk_100mhz)
);
Clock_Divider_by_4 rdi_clk_div_inst (
    .i_pll_clk      (i_pll_sb_clk),
    .i_rst_n        (sync_sb_rst_n_pll),
    .o_divided_clk  (divided_clk_200mhz)
);
/****************************************
* RESET SYNCHRONIZERS
****************************************/
bit_synchronizer reset_synchronizer_sideband_pll (
    .i_clk      (i_pll_sb_clk), 
    .i_rst_n    (i_rst_n),
    .i_data_in  (1'b1),
    .o_data_out (sync_sb_rst_n_pll)
);
bit_synchronizer reset_synchronizer_rdi (
    .i_clk      (divided_clk_100mhz), 
    .i_rst_n    (i_rst_n),
    .i_data_in  (1'b1),
    .o_data_out (sync_rdi_rst_n)
);


endmodule