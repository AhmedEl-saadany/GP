module PM_entry_wrapper (
/**************************************
 * INPUTS
**************************************/
    input               i_clk,
    input               i_rst_n,
    // RDI FSM related signals
    input               i_en,
    input               i_req_L1_or_L2,
    input               i_clk_div_ratio,
    // RDI Sideband related signals
    input               i_msg_done,
    input               i_msg_valid,
    input   [3:0]       i_msg_no,
/**************************************
 * OUTPUTS
**************************************/
    // RDI Sideband related signals
    output              o_msg_valid, 
    output  reg [3:0]   o_msg_no,
    // RDI FSM related signals
    output              o_test_done,
    output              o_pm_nak
);
/********************************************************************************
* INTERNAL WIRES AND REGISTERS
********************************************************************************/
wire pm_tx_msg_valid;
wire pm_rx_msg_valid;
wire pm_tx_test_done;
wire pm_rx_test_done;
wire pm_tx_force_exit;
wire [3:0] pm_tx_msg_no;
wire [3:0] pm_rx_msg_no;
/********************************************************************************
* ASSIGN/WIRE STATMENTS
********************************************************************************/
assign o_msg_valid = pm_tx_msg_valid | pm_rx_msg_valid;
assign o_test_done = pm_tx_test_done & pm_rx_test_done;
/********************************************************************************
* INSTANSIATION
********************************************************************************/
// PM_entry_tx instance
PM_entry_tx pm_entry_tx_inst (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_en               (i_en),
    .i_rx_msg_valid     (pm_rx_msg_valid),
    .i_req_L1_or_L2     (i_req_L1_or_L2),
    .i_clk_div_ratio    (i_clk_div_ratio),
    .i_msg_done         (i_msg_done),
    .i_msg_valid        (i_msg_valid),
    .i_msg_no           (i_msg_no),
    .o_force_exit       (pm_tx_force_exit),
    .o_msg_valid        (pm_tx_msg_valid),
    .o_msg_no           (pm_tx_msg_no),
    .o_test_done        (pm_tx_test_done),
    .o_pm_nak           (o_pm_nak)
);
// PM_entry_rx instance
PM_entry_rx pm_entry_rx_inst (
    .i_clk              (i_clk),
    .i_rst_n            (i_rst_n),
    .i_en               (i_en),
    .i_req_L1_or_L2     (i_req_L1_or_L2),
    .i_clk_div_ratio    (i_clk_div_ratio),
    .i_force_exit       (pm_tx_force_exit),
    .i_msg_done         (i_msg_done),
    .i_msg_valid        (i_msg_valid),
    .i_msg_no           (i_msg_no),
    .o_msg_valid        (pm_rx_msg_valid),
    .o_msg_no           (pm_rx_msg_no),
    .o_test_done        (pm_rx_test_done)
);

/////////////////////////////////////////
//// Handling SB encoded priorities /////
///////////////////////////////////////// 

always @ (*) begin
    case ({pm_tx_msg_valid, pm_rx_msg_valid})
        2'b00: o_msg_no = 4'b0000;
        2'b01: o_msg_no = pm_rx_msg_no;
        2'b10: o_msg_no = pm_tx_msg_no;
        2'b11: o_msg_no = pm_rx_msg_no;
        default: o_msg_no = 4'b0000;
    endcase
end

endmodule