`timescale 1ns/1ps
module tb_PM_entry_wrapper;
/**************************************
 * PARAMETERS
**************************************/
localparam CLK_PERIOD = 10;  // 100MHz
localparam SIM_TIME = 5000;  // 5us simulation
/**************************************
 * SIGNALS
**************************************/
reg clk;
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

/**********************************************************************************************************************
************************************************ INSTANIATING DUT *****************************************************
***********************************************************************************************************************/
///////////////////// Device Under Test - Instance 1 ///////////////////////////
PM_entry_wrapper dut1 (
    .i_clk              (clk),                  // done
    .i_rst_n            (rst_n),                // done
    .i_en               (en_1),                 // done
    .i_req_L1_or_L2     (req_L1_or_L2_1),       // done
    .i_clk_div_ratio    (clk_div_ratio),        // done
    .i_msg_done         (msg_done_1),           // done
    .i_msg_valid        (msg_valid_2_delayed),  // done
    .i_msg_no           (msg_no_2_delayed),     // done
    .o_msg_valid        (msg_valid_1),          // done
    .o_msg_no           (msg_no_1),             // done
    .o_test_done        (test_done_1),
    .o_pm_nak           (pm_nak_1)
);
/**********************************************
 * DELAYING OUTPUTS FROM 1 -> 2
**********************************************/
delay_cell #(.DELAY_CYCLES(4),.DATA_WIDTH(4)) msg_no_1_delay_cell (
    .i_clk                  (clk),
    .i_rst_n                (rst_n),
    .i_data                 (msg_no_1),
    .o_data                 (msg_no_1_delayed)
);

delay_cell #(.DELAY_CYCLES(4),.DATA_WIDTH(1)) msg_valid_1_delay_cell (
    .i_clk                  (clk),
    .i_rst_n                (rst_n),
    .i_data                 (msg_valid_1),
    .o_data                 (msg_valid_1_delayed)
);
///////////////////// Device Under Test - Instance 2 ///////////////////////////
PM_entry_wrapper dut2 (
    .i_clk              (clk),
    .i_rst_n            (rst_n),
    .i_en               (en_2),
    .i_req_L1_or_L2     (req_L1_or_L2_2), 
    .i_clk_div_ratio    (clk_div_ratio),
    .i_msg_done         (msg_done_2),
    .i_msg_valid        (msg_valid_1_delayed),
    .i_msg_no           (msg_no_1_delayed),
    .o_msg_valid        (msg_valid_2),
    .o_msg_no           (msg_no_2),
    .o_test_done        (test_done_2),
    .o_pm_nak           (pm_nak_2)
);
/**********************************************
 * DELAYING OUTPUTS FROM 1 -> 2
**********************************************/
delay_cell #(.DELAY_CYCLES(4),.DATA_WIDTH(4)) msg_no_2_delay_cell (
    .i_clk                  (clk),
    .i_rst_n                (rst_n),
    .i_data                 (msg_no_2),
    .o_data                 (msg_no_2_delayed)
);

delay_cell #(.DELAY_CYCLES(4),.DATA_WIDTH(1)) msg_valid_2_delay_cell (
    .i_clk                  (clk),
    .i_rst_n                (rst_n),
    .i_data                 (msg_valid_2),
    .o_data                 (msg_valid_2_delayed)
);
/**********************************************************************************************************************
************************************************* CLOCK GENERATION ****************************************************
***********************************************************************************************************************/
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
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
    repeat (30) @(posedge clk);
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
    force msg_valid_1_delayed = 0;
    req_L1_or_L2_1 = 1; // req L1;
    wait(test_done_1);
    release msg_valid_1_delayed;
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
    msg_done_1 = 0;
    msg_done_2 = 0;
    req_L1_or_L2_1 = 0;
    req_L1_or_L2_2 = 0;

    // Wait for reset
    wait(rst_n);
    
    // Scenario 1: Normal L1 entry
    $display("\n=== Scenario 1: Normal L1 Entry ===");
    start_pm_entry(1,"L1");
    #1000;
    
    rst_n = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);
    
    // Scenario 2: Normal L2 entry
    $display("\n=== Scenario 2: Normal L2 Entry ===");
    start_pm_entry(1,"L2");
    #1000;
    
    rst_n = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);
    
    // Scenario 3: PMNAK case
    $display("\n=== Scenario 3: PM.NAK Case ===");
    start_pm_entry(2,"NONE");
    #1000;
    
    rst_n = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

    // Scenario 4: Conflicting requests
    $display("\n=== Scenario 4: Conflicting Requests ===");
    start_pm_entry(3,"NONE");
    #1000;
    rst_n = 0;
    repeat (2) @(posedge clk);
    rst_n = 1;
    repeat (2) @(posedge clk);

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
// die 0
always @(msg_valid_1 or msg_done_1) begin
   if (msg_valid_1) begin
        @(posedge clk);
        msg_done_1 = 1;
        repeat (2) @(posedge clk);
        msg_done_1 = 0;
   end
end
// die 1
always @(msg_valid_2 or msg_done_2) begin
   if (msg_valid_2) begin
        @(posedge clk);
        msg_done_2 = 1;
        repeat (2) @(posedge clk);
        msg_done_2 = 0;
   end
end
/**********************************************************************************************************************
************************************************ FOR DEBUGGING ONLY ***************************************************
***********************************************************************************************************************/
always @(*) begin
    case (msg_no_2_delayed) // input to dut 1
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
    endcase
end

always @(*) begin
    case (msg_no_1_delayed) // input to dut 2
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
    endcase
end
endmodule