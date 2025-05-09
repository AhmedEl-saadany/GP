module tb_clk_handshake;
///////////////////////////////////
//////////// PARAMETERS ///////////
///////////////////////////////////
localparam MB_PLL_CLK_PER = 0.25;  // in ns
localparam SB_PLL_CLK_PER = 1.25;  // in ns
///////////////////////////////////
///////////// SIGNALS /////////////
///////////////////////////////////
bit     i_clk_sb;
logic   i_rst_n;
logic   i_en;
logic   i_lp_clk_ack;
logic   o_pl_clk_req;
logic   o_adapter_is_waked_up;
bit [3:0] clk_div_8;
///////////////////////////////////
///////////// DUT INST ////////////
///////////////////////////////////
clk_handshake DUT(
    .i_clk                  (clk_div_8),
    .i_rst_n                (i_rst_n),
    .i_lp_clk_ack           (i_lp_clk_ack),
    .i_en                   (i_en),
    .o_pl_clk_req           (o_pl_clk_req),
    .o_adapter_is_waked_up  (o_adapter_is_waked_up)
);

/**************************************************************************************************************************************************
*************************************************************** STIMILUS GENERATION ***************************************************************
**************************************************************************************************************************************************/
///////////////////////////////////
//////// CLOCK GENERATION /////////
///////////////////////////////////
initial begin
    i_clk_sb =  0;
    forever #((SB_PLL_CLK_PER*1000)/2) i_clk_sb = ~ i_clk_sb; // 1.25ns period = 800MHz
end

always @ (posedge i_clk_sb or negedge i_rst_n) begin
    if (~i_rst_n) begin
        clk_div_8 <= {4{1'b0}};
    end else begin
        clk_div_8 <= {clk_div_8[2:0],~clk_div_8[3]};
    end
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
    i_en = 0;
    i_lp_clk_ack = 0;
    DELAY (4);
    i_en = 1;
    DELAY (1000);
    $stop;
end

///////////////////////////////////
////////////// TASKS //////////////
///////////////////////////////////  
/**********************************
* delay task 
**********************************/
task DELAY (input integer delay);
    repeat (delay) @(posedge clk_div_8);
endtask
/**********************************
* Modelling RDI FSM 
**********************************/
always @ (posedge o_adapter_is_waked_up) begin
    DELAY (3);
    i_en = 0;
end

always @ (posedge o_pl_clk_req) begin
    DELAY (2);
    i_lp_clk_ack = 1;
    DELAY (9);
    i_lp_clk_ack = 0;
end
endmodule