module tb_reset_counter;
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
logic   i_count_en;
logic   o_reset_count_done;
bit [3:0] clk_div_8;
///////////////////////////////////
///////////// DUT INST ////////////
///////////////////////////////////
reset_counter DUT(
    .i_clk                  (clk_div_8),
    .i_rst_n                (i_rst_n),
    .i_count_en             (i_count_en),
    .i_clk_div_ratio        (1'b1),
    .o_reset_count_done     (o_reset_count_done)
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
    i_count_en = 0;
    DELAY (4);
    i_count_en = 1;
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
always @ (posedge o_reset_count_done) begin
    DELAY (3);
    i_count_en = 0;
end
endmodule