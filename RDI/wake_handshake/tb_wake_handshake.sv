module tb_wake_handshake;
///////////////////////////////////
//////////// PARAMETERS ///////////
///////////////////////////////////
localparam MB_PLL_CLK_PER = 0.25;  // in ns
localparam SB_PLL_CLK_PER = 1.25;  // in ns
///////////////////////////////////
///////////// SIGNALS /////////////
///////////////////////////////////
logic          rdi_clk;
logic          i_rst_n;
logic    [3:0] i_pl_state_sts;
logic    [3:0] i_lp_state_req;
logic          i_ltsm_in_reset;
logic          i_lp_wake_req;
logic          i_ltsm_is_waked_up;
logic          o_clk_gate_en;
logic          o_pl_wake_ack;
logic          dig_clk;
logic          i_ser_clk_4G;
logic          i_clk_sb;
///////////////////////////////////
///////////// DUT INST ////////////
///////////////////////////////////
wake_handshake DUT (
    .i_clk                  (rdi_clk),
    .i_rst_n                (i_rst_n),
    .i_pl_state_sts         (i_pl_state_sts),
    .i_lp_state_req         (i_lp_state_req),
    .i_ltsm_in_reset        (i_ltsm_in_reset),
    .i_lp_wake_req          (i_lp_wake_req),
    .i_ltsm_is_waked_up     (i_ltsm_is_waked_up),
    .o_clk_gate_en          (o_clk_gate_en),
    .o_pl_wake_ack          (o_pl_wake_ack)
);
/**************************************************************************************************************************************************
*************************************************************** STIMILUS GENERATION ***************************************************************
**************************************************************************************************************************************************/
///////////////////////////////////
//////// CLOCK GENERATION /////////
///////////////////////////////////
// // just for modelling
// clock_div_32 clock_div_32_inst_1 (
//     .i_clk             (i_ser_clk_4G),
//     .i_rst_n           (i_rst_n),
//     .o_div_clk         (dig_clk)
// );  

generic_clk_divider #(.DIV_WIDTH (4)) generic_clk_divider_inst_1  (
    .i_ref_clk          (i_clk_sb),
    .i_rst_n            (i_rst_n),
    .i_clk_en           (1'b1),
    .i_div_ratio        (8),
    .o_div_clk          (rdi_clk)
);

generic_clk_divider #(.DIV_WIDTH (6)) generic_clk_divider_inst_2  (
    .i_ref_clk          (i_ser_clk_4G),
    .i_rst_n            (i_rst_n),
    .i_clk_en           (1'b1),
    .i_div_ratio        (32),
    .o_div_clk          (dig_clk)
);

initial begin
    i_ser_clk_4G = 0;
    forever #((MB_PLL_CLK_PER*1000)/2) i_ser_clk_4G = ~i_ser_clk_4G; // 0.25ns period = 4GHz
end

initial begin
    i_clk_sb =  0;
    forever #((SB_PLL_CLK_PER*1000)/2) i_clk_sb = ~ i_clk_sb; // 1.25ns period = 800MHz
end

///////////////////////////////////
///////// INITIAL BLOCK ///////////
///////////////////////////////////
// Reset generation
initial begin
    i_rst_n = 0;
    #20;
    i_rst_n = 1;
end

// initialzing inputs 
initial begin
    i_pl_state_sts  = 0;
    i_lp_state_req  = 0;
    i_ltsm_in_reset = 1;
    i_lp_wake_req   = 0;
end

initial begin
    DELAY (3);
    i_pl_state_sts  = 0;
    i_lp_state_req  = 0;
    i_ltsm_in_reset = 1;
    i_lp_wake_req   = 1;
    DELAY (10);
    i_lp_state_req  = 1;
    DELAY (10);
    $stop;
end

///////////////////////////////////
////////////// TASKS //////////////
///////////////////////////////////  
/**********************************
* delay task 
**********************************/
task DELAY (input integer delay);
    repeat (delay) @(posedge rdi_clk);
endtask

/**********************************
* modelling i_ltsm_is_waked_up 
**********************************/
logic o_clk_gate_en_sync;

bit_synchronizer rdi_2_ltsm_gate_en (
    .i_clk      (dig_clk),
    .i_rst_n    (i_rst_n),
    .i_data_in  (o_clk_gate_en),
    .o_data_out (o_clk_gate_en_sync)
);

bit_synchronizer ltsm_2_rdi_waked_up (
    .i_clk      (rdi_clk),
    .i_rst_n    (i_rst_n),
    .i_data_in  (o_clk_gate_en_sync),
    .o_data_out (i_ltsm_is_waked_up)
);

// pulse_synchronizer ltsm_2_rdi_waked_up (
//     .i_slow_clock       (sb_divided_clk),
//     .i_fast_clock       (dig_clk),
//     .i_slow_rst_n       (sync_sb_rst_n),
//     .i_fast_rst_n       (sync_mb_rst_n),
//     .i_fast_pulse       (sb_start_pattern_req),
//     .o_slow_pulse       (sync_sb_start_pattern_req)
// );

/**********************************
* modelling i_ltsm_is_waked_up 
**********************************/
always @ (o_pl_wake_ack) begin
    if (o_pl_wake_ack) begin
        DELAY (2);
        i_lp_wake_req = 0;  
        i_lp_state_req = 1;
    end
end

endmodule 