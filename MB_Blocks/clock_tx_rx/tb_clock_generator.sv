`timescale 1ps/100fs
module tb_clock_generator;

logic                          i_local_ckp;    // pll clock / 2
logic                          i_sys_clk;      // pll clock /32 --> local ckp/16
logic                          i_rst_n;        // should be synchronous to dig_clk
logic                          i_rst_ckp_n;    // should be synchronous to local_ckp
logic                          i_start_clk_training;
logic                          o_CKP;
logic                          o_CKN;
logic                          o_TRACK;
logic                          o_done;
logic                          i_ser_clk_2G;
logic                          i_ser_clk_4G;
logic                          dig_clk;
logic                          i_clear_results;
logic [2:0]                    o_Clock_track_result_logged;



clock_generator clock_generator_inst (
    .i_local_ckp            (i_ser_clk_2G),
    .i_local_ckn            (~i_ser_clk_2G),
    .i_sys_clk              (dig_clk),
    .i_rst_n                (i_rst_n),
    .i_rst_ckp_n            (i_rst_n),
    .i_start_clk_training   (i_start_clk_training),
    .o_CKP                  (o_CKP),
    .o_CKN                  (o_CKN),
    .o_TRACK                (o_TRACK),
    .o_done                 (o_done)
);

clock_detector clock_detector_inst (
    .i_dig_clk              (dig_clk),
    .i_local_ckp            (i_ser_clk_4G),
    .i_local_ckn            (~i_ser_clk_4G),   
    .i_rst_n                (i_rst_n),
    .i_rst_ckp_n            (i_rst_n),   
    .i_rst_ckn_n            (i_rst_n), 
    .i_RCKP                 (o_CKP),  
    .i_RCKN                 (o_CKN),
    .i_RTRK                 (o_TRACK),
    .i_clear_results        (i_clear_results),
    .o_Clock_track_result_logged (o_Clock_track_result_logged)
);


initial begin
    i_ser_clk_2G = 0;
    forever #25 i_ser_clk_2G = ~i_ser_clk_2G; // 0.5ns period = 2GHz
end

initial begin
    i_ser_clk_4G = 0;
    forever #12.5 i_ser_clk_4G = ~i_ser_clk_4G; // 0.25ns period = 4GHz
end


// just for modelling
clock_div_32 clock_div_32_inst_1 (
    .i_clk             (i_ser_clk_4G),
    .i_rst_n           (i_rst_n),
    .o_div_clk         (dig_clk)
);   

initial begin
    i_rst_n = 0;
    i_start_clk_training = 0;
    i_clear_results = 0;
    DELAY (50);
    i_rst_n = 1;
    DELAY (500);
    @(posedge dig_clk);
    i_start_clk_training = 1;
    repeat (1) @(posedge dig_clk)
    i_clear_results = 1;
    @(posedge dig_clk);
    i_clear_results = 0;
    DELAY (1000000);
    $stop;
end

/**********************************
* delay task 
**********************************/
task DELAY (input integer delay);
    repeat (delay) @(posedge i_ser_clk_4G);
endtask

endmodule 