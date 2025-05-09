`timescale 1ns/1ps
module tb_PM_entry_wrapper;
/**************************************
 * SIGNALS
**************************************/
reg clk;
reg i_clk_pll;
bit i_clk_fifo;
reg rst_n;

// Wrapper 1 signals
logic [3:0] msg_no_1;
logic msg_valid_1;
logic test_done_1;
logic req_L1_or_L2_1;
logic pm_nak_1;
logic msg_done_1;
logic en_1;

// Wrapper 2 signals
logic [3:0] msg_no_2;
logic msg_valid_2;
logic test_done_2;
logic req_L1_or_L2_2;
logic pm_nak_2;
logic msg_done_2;
logic en_2;

// Common control signals
logic clk_div_ratio = 0;

// delayed signals
logic [3:0] msg_no_1_delayed;
logic [3:0] msg_no_2_delayed;
logic msg_valid_1_delayed;
logic msg_valid_2_delayed;

// debugging signals
string i_msg_no_1_string;
string i_msg_no_2_string;
string o_msg_no_1_string;
string o_msg_no_2_string;

///////////////////////////////////////////////////////////////////////
// DON'T TOUCH THESE SIGNALS 
///////////////////////////////////////////////////////////////////////
logic i_msg_valid_1;
logic i_msg_valid_2;

logic [3:0] i_msg_no_1;
logic [3:0] i_msg_no_2;

// TX FIFO signals
wire [63:0] o_fifo_data_encoder;
wire [63:0] o_real_fifo_data;
wire fifo_write_en;
wire fifo_read_en;
wire fifo_full;
wire fifo_empty;
wire o_ser_done_sampled;
wire o_dont_send_zeros;
// FSM MODELLING signals
wire o_clk_ser_en;
// CLOCK CONTROLLER signals
wire o_pack_finished;
wire TXCKSB;
// TX SERIALIZER signals
wire ser_done;
wire TXDATA_SB;
// RX DESERIALIZER signals
wire o_deser_done_sampled;
// RX DECODER signals
wire [31:0] o_pl_cfg;
wire o_pl_cfg_vld;
wire [63:0] deser_data;
wire deser_done;
wire o_wake_adapter;
// TX ENCODER signals
wire o_delete_data;


// TX FIFO signals
wire [63:0] o_fifo_data_encoder_2;
wire [63:0] o_real_fifo_data_2;
wire fifo_write_en_2;
wire fifo_read_en_2;
wire fifo_full_2;
wire fifo_empty_2;
wire o_ser_done_sampled_2;
wire o_dont_send_zeros_2;
// FSM MODELLING signals
wire o_clk_ser_en_2;
// CLOCK CONTROLLER signals
wire o_pack_finished_2;
wire TXCKSB_2;
// TX SERIALIZER signals
wire ser_done_2;
wire TXDATA_SB_2;
// RX DESERIALIZER signals
wire o_deser_done_sampled_2;
// RX DECODER signals
wire [31:0] o_pl_cfg_2;
wire o_pl_cfg_vld_2;
wire [63:0] deser_data_2;
wire deser_done_2;
wire o_wake_adapter_2;
// TX ENCODER signals
wire o_delete_data_2;

/**********************************************************************************************************************
************************************************ INSTANIATING DUT *****************************************************
***********************************************************************************************************************/
SB_RDI_WRAPPER sb_rdi_wrapper_1 (
    // Clock and reset
    .i_clk                  (clk),
    .i_clk_gated            (clk),
    .i_rst_n                (rst_n),

    // Adapter interface
    .i_lp_cfg_vld           ('b0),
    .i_lp_cfg               ('b0),
    .i_lp_cfg_crd           ('b0),
    .o_pl_nerror            (o_pl_nerror),  // ignored
    .o_pl_cfg_vld           (o_pl_cfg_vld), // ignored
    .o_pl_cfg               (o_pl_cfg),     // ignored
    .o_pl_cfg_crd           (o_pl_cfg_crd), // ignored

    // RDI FSM interface
    .i_msg_no               (msg_no_1),
    .i_msg_valid            (msg_valid_1),
    .i_adapter_is_waked_up  (1'b1),
    .i_clk_is_ungated       (1'b1),
    .o_wake_adapter         (o_wake_adapter), // ignored
    .o_msg_done             (msg_done_1),     
    .o_msg_valid            (i_msg_valid_1),
    .o_msg_no               (i_msg_no_1), 

    // TX FIFO interface
    .i_tx_fifo_full         (fifo_full),
    .i_tx_fifo_read_en      (o_ser_done_sampled),
    .i_srcid                (o_real_fifo_data[30:29]),
    .i_fifo_data_is_zeros   (o_dont_send_zeros),
    .o_tx_fifo_data         (o_fifo_data_encoder),
    .o_tx_fifo_write_en     (fifo_write_en),
    .o_delete_data          (o_delete_data),

    // RX Deserializer interface
    .i_deser_done           (deser_done),
    .i_deser_data           (deser_data),
    .o_deser_done_sampled   (o_deser_done_sampled)
);

SB_TX_FIFO tx_fifo_1 (
	.i_clk         (clk),
	.i_rst_n       (rst_n),
	.i_data_in     (o_fifo_data_encoder), //
	.i_write_enable(fifo_write_en), //
	.i_read_enable (fifo_read_en), //
    .i_delete_data (o_delete_data),
	.o_data_out    (o_real_fifo_data), //
	.o_empty       (fifo_empty), //
	.o_ser_done_sampled(o_ser_done_sampled),
    .o_dont_send_zeros  (o_dont_send_zeros),
	.o_full        (fifo_full) //
);

SB_CLOCK_CONTROLLER clock_controller_1 (
    .i_pll_clk      (i_clk_pll), //
    .i_rst_n        (rst_n), //
    .i_enable       (o_clk_ser_en), // 
    .o_pack_finished(o_pack_finished), //
    .o_ser_done     (ser_done), //
    .TXCKSB         (TXCKSB) //
);

SB_TX_FSM_Modelling fsm_model_1 (
	.i_rst_n          (rst_n),
	.i_clk            (i_clk_pll),
	.i_ser_done       (ser_done),
	.i_empty          (fifo_empty),
	.i_packet_finished(o_pack_finished),
	.i_read_enable_sampled(o_ser_done_sampled),
	.o_read_enable    (fifo_read_en),
    .i_dont_send_zeros  (o_dont_send_zeros),
	.o_clk_en         (o_clk_ser_en)
);

SB_TX_SERIALIZER SB_TX_SERIALIZER_1 (
    .i_pll_clk          (i_clk_pll),
    .i_rst_n            (rst_n),
    .i_data_in          (o_real_fifo_data),
    .i_enable           (o_clk_ser_en),
    .i_pack_finished    (o_pack_finished),
    .TXDATASB           (TXDATA_SB)
);

SB_RX_DESER SB_RX_DESER_1(
    .i_clk                  (TXCKSB_2),
    .i_clk_pll              (i_clk_pll),
    .i_rst_n                (rst_n),
    .ser_data_in            (TXDATA_SB_2),
    .i_de_ser_done_sampled  (o_deser_done_sampled),
    .par_data_out           (deser_data),
    .de_ser_done            (deser_done)
);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

SB_RDI_WRAPPER sb_rdi_wrapper_2 (
    // Clock and reset
    .i_clk                  (clk),
    .i_clk_gated            (clk),
    .i_rst_n                (rst_n),

    // Adapter interface
    .i_lp_cfg_vld           ('b0),
    .i_lp_cfg               ('b0),
    .i_lp_cfg_crd           ('b0),
    .o_pl_nerror            (o_pl_nerror_2),  // ignored
    .o_pl_cfg_vld           (o_pl_cfg_vld_2), // ignored
    .o_pl_cfg               (o_pl_cfg_2),     // ignored
    .o_pl_cfg_crd           (o_pl_cfg_crd_2), // ignored

    // RDI FSM interface
    .i_msg_no               (msg_no_2),
    .i_msg_valid            (msg_valid_2),
    .i_adapter_is_waked_up  (1'b1),
    .i_clk_is_ungated       (1'b1),
    .o_wake_adapter         (o_wake_adapter_2), // ignored
    .o_msg_done             (msg_done_2),     
    .o_msg_valid            (i_msg_valid_2),
    .o_msg_no               (i_msg_no_2), 

    // TX FIFO interface
    .i_tx_fifo_full         (fifo_full_2),
    .i_tx_fifo_read_en      (o_ser_done_sampled_2),
    .i_srcid                (o_real_fifo_data_2[30:29]),
    .i_fifo_data_is_zeros   (o_dont_send_zeros_2),
    .o_tx_fifo_data         (o_fifo_data_encoder_2),
    .o_tx_fifo_write_en     (fifo_write_en_2),
    .o_delete_data          (o_delete_data_2),

    // RX Deserializer interface
    .i_deser_done           (deser_done_2),
    .i_deser_data           (deser_data_2),
    .o_deser_done_sampled   (o_deser_done_sampled_2)
);

SB_TX_FIFO tx_fifo_2 (
	.i_clk         (clk),
	.i_rst_n       (rst_n),
	.i_data_in     (o_fifo_data_encoder_2), 
	.i_write_enable(fifo_write_en_2), 
	.i_read_enable (fifo_read_en_2), 
    .i_delete_data (o_delete_data_2),
	.o_data_out    (o_real_fifo_data_2), 
	.o_empty       (fifo_empty_2), 
	.o_ser_done_sampled(o_ser_done_sampled_2),
    .o_dont_send_zeros  (o_dont_send_zeros_2),
	.o_full        (fifo_full_2) 
);

SB_CLOCK_CONTROLLER clock_controller_2 (
    .i_pll_clk      (i_clk_pll), //
    .i_rst_n        (rst_n), //
    .i_enable       (o_clk_ser_en_2), // 
    .o_pack_finished(o_pack_finished_2), //
    .o_ser_done     (ser_done_2), //
    .TXCKSB         (TXCKSB_2) //
);

SB_TX_FSM_Modelling fsm_model_2 (
	.i_rst_n          (rst_n),
	.i_clk            (i_clk_pll),
	.i_ser_done       (ser_done_2),
	.i_empty          (fifo_empty_2),
	.i_packet_finished(o_pack_finished_2),
	.i_read_enable_sampled(o_ser_done_sampled_2),
	.o_read_enable    (fifo_read_en_2),
    .i_dont_send_zeros  (o_dont_send_zeros_2),
	.o_clk_en         (o_clk_ser_en_2)
);

SB_TX_SERIALIZER SB_TX_SERIALIZER_2 (
    .i_pll_clk          (i_clk_pll),
    .i_rst_n            (rst_n),
    .i_data_in          (o_real_fifo_data_2),
    .i_enable           (o_clk_ser_en_2),
    .i_pack_finished    (o_pack_finished_2),
    .TXDATASB           (TXDATA_SB_2)
);

SB_RX_DESER SB_RX_DESER_2(
    .i_clk                  (TXCKSB),
    .i_clk_pll              (i_clk_pll),
    .i_rst_n                (rst_n),
    .ser_data_in            (TXDATA_SB),
    .i_de_ser_done_sampled  (o_deser_done_sampled_2),
    .par_data_out           (deser_data_2),
    .de_ser_done            (deser_done_2)
);

///////////////////// Device Under Test - Instance 1 ///////////////////////////
PM_entry_wrapper dut1 (
    .i_clk              (clk),                  // done
    .i_rst_n            (rst_n),                // done
    .i_en               (en_1),                 // done
    .i_req_L1_or_L2     (req_L1_or_L2_1),       // done
    .i_clk_div_ratio    (clk_div_ratio),        // done
    .i_msg_done         (msg_done_1),           // done
    .i_msg_valid        (i_msg_valid_1),        // done
    .i_msg_no           (i_msg_no_1),           // done
    .o_msg_valid        (msg_valid_1),          // done
    .o_msg_no           (msg_no_1),             // done
    .o_test_done        (test_done_1),
    .o_pm_nak           (pm_nak_1)
);

///////////////////// Device Under Test - Instance 2 ///////////////////////////
PM_entry_wrapper dut2 (
    .i_clk              (clk),
    .i_rst_n            (rst_n),
    .i_en               (en_2),
    .i_req_L1_or_L2     (req_L1_or_L2_2), 
    .i_clk_div_ratio    (clk_div_ratio),
    .i_msg_done         (msg_done_2),
    .i_msg_valid        (i_msg_valid_2),
    .i_msg_no           (i_msg_no_2),
    .o_msg_valid        (msg_valid_2),
    .o_msg_no           (msg_no_2),
    .o_test_done        (test_done_2),
    .o_pm_nak           (pm_nak_2)
);

/**********************************************************************************************************************
************************************************* CLOCK GENERATION ****************************************************
***********************************************************************************************************************/
initial begin
    i_clk_pll = 0;
    forever #1 i_clk_pll = ~i_clk_pll; // 100MHz clock
end

initial begin
    i_clk_fifo = 0;
    forever #4 i_clk_fifo = ~i_clk_fifo; // 100MHz clock
end

initial begin
    clk = 0;
    forever #2 clk = ~clk; // 100MHz clock
end
/**********************************************************************************************************************
******************************************************* TASKS *********************************************************
***********************************************************************************************************************/
task start_pm_entry (
    input [2:0] scenario,
    input string req_type
);
logic pm_req_type; 
pm_req_type = (req_type == "L1")? 0 : (req_type == "L2")? 1 : 0;
if (scenario == 1) begin // basic scenario (die 0 req pm entry and die 1 req same pm entry)
    en_1 = 1;
    req_L1_or_L2_1 = pm_req_type; // req L1;
    repeat (100) @(posedge clk);
    en_2 = 1;
    req_L1_or_L2_2 = pm_req_type; // req L1;
    wait (test_done_2);
end else if (scenario == 2) begin // die 0 req pm entry and die 1 don't but respond with pmnak
    en_1 = 1;
    req_L1_or_L2_1 = 0; // req L1;
    wait (test_done_1);    
end else if (scenario == 3) begin // die 0 req L1 entry and fie 2 resp with L2
    en_1 = 1;
    req_L1_or_L2_1 = 0; // req L1;
    repeat (30) @(posedge clk);
    en_2 = 1;
    req_L1_or_L2_2 = 1; // req L2;
    wait (test_done_2);
end else if (scenario == 4) begin // die 0 req pm entry and die 1 don't responce with any thing (Timeout case)
    en_1 = 1;
    force i_msg_valid_2 = 0;
    req_L1_or_L2_1 = 1; // req L1;
    wait(test_done_1);
    release i_msg_valid_2;
end
endtask
/**********************************************************************************************************************
********************************************* STIMILUS GENERATION *****************************************************
***********************************************************************************************************************/
// Reset generation
initial begin
    rst_n = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;
end

// Test scenarios
initial begin
    // Inialize inputs 
    en_1 = 0;
    en_2 = 0;
    req_L1_or_L2_1 = 0;
    req_L1_or_L2_2 = 0;

    // Wait for reset
    wait(rst_n);
    
    // Scenario 1: Normal L1 entry
    $display("\n=== Scenario 1: Normal L1 Entry ===");
    start_pm_entry(1,"L1");
    #1000;
    
    // rst_n = 0;
    // repeat (2) @(posedge clk);
    // rst_n = 1;
    // repeat (2) @(posedge clk);
    
    // Scenario 2: Normal L2 entry
    $display("\n=== Scenario 2: Normal L2 Entry ===");
    start_pm_entry(1,"L2");
    #1000;
    
    // rst_n = 0;
    // repeat (2) @(posedge clk);
    // rst_n = 1;
    // repeat (2) @(posedge clk);

    // Scenario 3: PMNAK case
    $display("\n=== Scenario 3: PM.NAK Case ===");
    start_pm_entry(2,"NONE");
    #1000;
    
    // rst_n = 0;
    // repeat (2) @(posedge clk);
    // rst_n = 1;
    // repeat (2) @(posedge clk);

    // Scenario 4: Conflicting requests
    $display("\n=== Scenario 4: Conflicting Requests ===");
    start_pm_entry(3,"NONE");
    #1000;
    // rst_n = 0;
    // repeat (2) @(posedge clk);
    // rst_n = 1;
    // repeat (2) @(posedge clk);

    // Scenario 5: Timeout case
    $display("\n=== Scenario 4: Timeout Case ===");
    start_pm_entry(4,"NONE");

    // End simulation
    #1000;
    $display("\n=== Simulation Complete ===");
    $finish;
end
/**********************************************************************************************************************
********************************************* MODELLING INPUT SIGNALS *************************************************
***********************************************************************************************************************/
/****************************************
 * modelling de-assertion of i_en
****************************************/
// die 0
always @(posedge test_done_1) begin
    @(posedge clk);
    en_1 = 0;
end
// die 1
always @(posedge test_done_2) begin
    @(posedge clk);
    en_2 = 0;
end
/****************************************
 * modelling assertion of i_msg_done
****************************************/
// // die 0
// always @(msg_valid_1 or msg_done_1) begin
//    if (msg_valid_1) begin
//         @(posedge clk);
//         msg_done_1 = 1;
//         repeat (2) @(posedge clk);
//         msg_done_1 = 0;
//    end
// end
// // die 1
// always @(msg_valid_2 or msg_done_2) begin
//    if (msg_valid_2) begin
//         @(posedge clk);
//         msg_done_2 = 1;
//         repeat (2) @(posedge clk);
//         msg_done_2 = 0;
//    end
// end
/**********************************************************************************************************************
************************************************ FOR DEBUGGING ONLY ***************************************************
***********************************************************************************************************************/
always @(*) begin
    case (i_msg_no_1) // input to dut 1
        4'd1:    i_msg_no_1_string = "LinkMgmt.RDI.Req.Active";                          
        4'd2:    i_msg_no_1_string = "LinkMgmt.RDI.Req.L1";                           
        4'd3:    i_msg_no_1_string = "LinkMgmt.RDI.Req.L2";                            
        4'd4:    i_msg_no_1_string = "LinkMgmt.RDI.Req.LinkReset";                            
        4'd5:    i_msg_no_1_string = "LinkMgmt.RDI.Req.LinkError";                          
        4'd6:    i_msg_no_1_string = "LinkMgmt.RDI.Req.Retrain";                            
        4'd7:    i_msg_no_1_string = "LinkMgmt.RDI.Req.Disable";                            
        4'd8:    i_msg_no_1_string = "LinkMgmt.RDI.Rsp.Active";                            
        4'd9:    i_msg_no_1_string = "LinkMgmt.RDI.Rsp.PMNAK";                           
        4'd10:   i_msg_no_1_string = "LinkMgmt.RDI.Rsp.L1";             
        4'd11:   i_msg_no_1_string = "LinkMgmt.RDI.Rsp.L2";             
        4'd12:   i_msg_no_1_string = "LinkMgmt.RDI.Rsp.LinkReset";              
        4'd13:   i_msg_no_1_string = "LinkMgmt.RDI.Rsp.LinkError";             
        4'd14:   i_msg_no_1_string = "LinkMgmt.RDI.Rsp.Retrain";             
        4'd15:   i_msg_no_1_string = "LinkMgmt.RDI.Rsp.Disable";    
        default: i_msg_no_1_string = "----------";         
    endcase
end

always @(*) begin
    case (i_msg_no_2) // input to dut 2
        4'd1:    i_msg_no_2_string = "LinkMgmt.RDI.Req.Active";                          
        4'd2:    i_msg_no_2_string = "LinkMgmt.RDI.Req.L1";                           
        4'd3:    i_msg_no_2_string = "LinkMgmt.RDI.Req.L2";                            
        4'd4:    i_msg_no_2_string = "LinkMgmt.RDI.Req.LinkReset";                            
        4'd5:    i_msg_no_2_string = "LinkMgmt.RDI.Req.LinkError";                          
        4'd6:    i_msg_no_2_string = "LinkMgmt.RDI.Req.Retrain";                            
        4'd7:    i_msg_no_2_string = "LinkMgmt.RDI.Req.Disable";                            
        4'd8:    i_msg_no_2_string = "LinkMgmt.RDI.Rsp.Active";                            
        4'd9:    i_msg_no_2_string = "LinkMgmt.RDI.Rsp.PMNAK";                           
        4'd10:   i_msg_no_2_string = "LinkMgmt.RDI.Rsp.L1";             
        4'd11:   i_msg_no_2_string = "LinkMgmt.RDI.Rsp.L2";             
        4'd12:   i_msg_no_2_string = "LinkMgmt.RDI.Rsp.LinkReset";              
        4'd13:   i_msg_no_2_string = "LinkMgmt.RDI.Rsp.LinkError";             
        4'd14:   i_msg_no_2_string = "LinkMgmt.RDI.Rsp.Retrain";             
        4'd15:   i_msg_no_2_string = "LinkMgmt.RDI.Rsp.Disable";    
        default: i_msg_no_2_string = "----------";       
    endcase
end

always @(*) begin
    case (msg_no_1) // output from dut 1
        4'd1:    o_msg_no_1_string = "LinkMgmt.RDI.Req.Active";                          
        4'd2:    o_msg_no_1_string = "LinkMgmt.RDI.Req.L1";                           
        4'd3:    o_msg_no_1_string = "LinkMgmt.RDI.Req.L2";                            
        4'd4:    o_msg_no_1_string = "LinkMgmt.RDI.Req.LinkReset";                            
        4'd5:    o_msg_no_1_string = "LinkMgmt.RDI.Req.LinkError";                          
        4'd6:    o_msg_no_1_string = "LinkMgmt.RDI.Req.Retrain";                            
        4'd7:    o_msg_no_1_string = "LinkMgmt.RDI.Req.Disable";                            
        4'd8:    o_msg_no_1_string = "LinkMgmt.RDI.Rsp.Active";                            
        4'd9:    o_msg_no_1_string = "LinkMgmt.RDI.Rsp.PMNAK";                           
        4'd10:   o_msg_no_1_string = "LinkMgmt.RDI.Rsp.L1";             
        4'd11:   o_msg_no_1_string = "LinkMgmt.RDI.Rsp.L2";             
        4'd12:   o_msg_no_1_string = "LinkMgmt.RDI.Rsp.LinkReset";              
        4'd13:   o_msg_no_1_string = "LinkMgmt.RDI.Rsp.LinkError";             
        4'd14:   o_msg_no_1_string = "LinkMgmt.RDI.Rsp.Retrain";             
        4'd15:   o_msg_no_1_string = "LinkMgmt.RDI.Rsp.Disable";    
        default: o_msg_no_1_string = "----------";         
    endcase
end

always @(*) begin
    case (msg_no_2) // output from dut 2
        4'd1:    o_msg_no_2_string = "LinkMgmt.RDI.Req.Active";                          
        4'd2:    o_msg_no_2_string = "LinkMgmt.RDI.Req.L1";                           
        4'd3:    o_msg_no_2_string = "LinkMgmt.RDI.Req.L2";                            
        4'd4:    o_msg_no_2_string = "LinkMgmt.RDI.Req.LinkReset";                            
        4'd5:    o_msg_no_2_string = "LinkMgmt.RDI.Req.LinkError";                          
        4'd6:    o_msg_no_2_string = "LinkMgmt.RDI.Req.Retrain";                            
        4'd7:    o_msg_no_2_string = "LinkMgmt.RDI.Req.Disable";                            
        4'd8:    o_msg_no_2_string = "LinkMgmt.RDI.Rsp.Active";                            
        4'd9:    o_msg_no_2_string = "LinkMgmt.RDI.Rsp.PMNAK";                           
        4'd10:   o_msg_no_2_string = "LinkMgmt.RDI.Rsp.L1";             
        4'd11:   o_msg_no_2_string = "LinkMgmt.RDI.Rsp.L2";             
        4'd12:   o_msg_no_2_string = "LinkMgmt.RDI.Rsp.LinkReset";              
        4'd13:   o_msg_no_2_string = "LinkMgmt.RDI.Rsp.LinkError";             
        4'd14:   o_msg_no_2_string = "LinkMgmt.RDI.Rsp.Retrain";             
        4'd15:   o_msg_no_2_string = "LinkMgmt.RDI.Rsp.Disable"; 
        default: o_msg_no_2_string = "----------";              
    endcase
end
endmodule