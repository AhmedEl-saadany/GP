module PM_entry_rx (
/**************************************
 * INPUTS
**************************************/
    input               i_clk,
    input               i_rst_n,
    // Wrapper signals
    input               i_force_exit, // from pm_entry_tx when it doesn't receive any responces it should return back to fsm with o_test_done & o_pm_nak
                                      // but since o_test_done that reaches to rdi fsm is depending on the two blocks (pm_tx/pm_rx) so in this case tx forces rx to raise o_test_done
    // RDI FSM related signals
    input               i_en,
    input               i_req_L1_or_L2,  // 0h: for requsting L1, 1h: for requsting L2
    input               i_clk_div_ratio, // 0h: 800M/(8) = 100MHz, 1h: 800MHz/(4) = 200MHz 
    // RDI Sdeband related signals
    input               i_msg_done,
    input               i_msg_valid,
    input   [3:0]       i_msg_no,
/**************************************
 * OUTPUTS
**************************************/
    // RDI Sdeband related signals
    output  reg         o_msg_valid,
    output  reg [3:0]   o_msg_no,
    // RDI FSM related signals
    output  reg         o_test_done    // 1h: upon finishing the flow (when receiving either pm.resp or pm.nak), 0h: the flow did not finished yet
);
/********************************************************************************
 * PARAMETERS
********************************************************************************/
localparam [3:0] LinkMgmt_RDI_Req_L1         = 4'd2,
                 LinkMgmt_RDI_Req_L2         = 4'd3,
                 LinkMgmt_RDI_Rsp_PMNAK      = 4'd9,
                 LinkMgmt_RDI_Rsp_L1         = 4'd10,
                 LinkMgmt_RDI_Rsp_L2         = 4'd11;

localparam COUNTING_1microsec_USING_100mhz = 100;// 100: number of clock cycles representing 1micros using 100 MHz clock
localparam COUNTING_1microsec_USING_200mhz = 200;// 200: number of clock cycles representing 1micros using 200 MHz clock
/********************************************************************************
* FSM STATES
********************************************************************************/
localparam [1:0]    IDLE                = 2'b00,
                    WAIT_FOR_PM_REQ     = 2'b01,
                    SEND_PM_RESP        = 2'b11,
                    TEST_FINISHED       = 2'b10;
/********************************************************************************
* INTERNAL WIRES AND REGISTERS
********************************************************************************/
reg [1:0]  CS,NS;
reg [7:0]  counter_1microsec;
reg start_count;
/********************************************************************************
* ASSIGN/WIRE STATMENTS
********************************************************************************/
// counter related signals
wire count_done = ((~i_clk_div_ratio && counter_1microsec == COUNTING_1microsec_USING_100mhz) || (i_clk_div_ratio && counter_1microsec == COUNTING_1microsec_USING_200mhz))? 1 : 0;
wire continue_counting  = (~i_clk_div_ratio && counter_1microsec < COUNTING_1microsec_USING_100mhz)? 1 : (i_clk_div_ratio && counter_1microsec < COUNTING_1microsec_USING_200mhz)? 1 : 0;
/////////////////////////////////////////////////////////////////////////////////
wire send_pm_resp = (CS == WAIT_FOR_PM_REQ && NS == SEND_PM_RESP);
wire send_pm_nak  = (CS == WAIT_FOR_PM_REQ && count_done);
wire receivied_L1_req  = ((i_msg_no == LinkMgmt_RDI_Req_L1) && i_msg_valid);
wire receivied_L2_req  = ((i_msg_no == LinkMgmt_RDI_Req_L2) && i_msg_valid);
wire receivied_pm_nak  = ((i_msg_no == LinkMgmt_RDI_Rsp_PMNAK) && i_msg_valid);
wire send_rdi_outputs  = ((CS == SEND_PM_RESP && NS == TEST_FINISHED));
/********************************************************************************
* STATE MEMORY
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        CS <= IDLE;
    end
    else begin
        CS <= NS;
    end
end
/********************************************************************************
* NEXT STATE LOGIC
********************************************************************************/
always @ (*) begin
    case (CS)
/*-------------------------------------------------------------------------------
 * IDLE state
-------------------------------------------------------------------------------*/
        IDLE: begin
            if (((i_msg_no == LinkMgmt_RDI_Req_L1) || (i_msg_no == LinkMgmt_RDI_Req_L2)) && i_msg_valid) begin
                NS = WAIT_FOR_PM_REQ;
            end else begin
                NS = IDLE;
            end
        end              
/*-------------------------------------------------------------------------------
 * WAIT_FOR_PM_REQ state
-------------------------------------------------------------------------------*/
        WAIT_FOR_PM_REQ: begin
            if (count_done) begin
                NS = IDLE;
            end else if (i_en) begin
                NS = SEND_PM_RESP;
            end else begin
                NS = WAIT_FOR_PM_REQ;
            end
        end
/*-------------------------------------------------------------------------------
 * SEND_PM_RESP state
-------------------------------------------------------------------------------*/
        SEND_PM_RESP: begin
            if (~i_en) begin
                NS = IDLE;
            end else if (~o_msg_valid) begin
                NS = TEST_FINISHED;
            end else begin
                NS = SEND_PM_RESP;
            end
        end
/*-------------------------------------------------------------------------------
 * TEST_FINISHED state
-------------------------------------------------------------------------------*/
        TEST_FINISHED: begin
            if (~i_en || o_msg_no == LinkMgmt_RDI_Rsp_PMNAK) begin
                NS = IDLE;
            end else begin
                NS = TEST_FINISHED;
            end
        end
        default: NS = IDLE;
    endcase
end
/********************************************************************************
* OUTPUT LOGIC
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        o_msg_no    <= 1'b0;
        o_test_done <= 1'b0;
    end else begin
        if (CS == IDLE) begin
            o_msg_no    <= 1'b0;
            o_test_done <= 1'b0;
        end
        /****************************************************
         * sideband responce
        ****************************************************/
        if (send_pm_nak) begin
            o_msg_no <= LinkMgmt_RDI_Rsp_PMNAK;
        end else if (send_pm_resp && ~i_req_L1_or_L2) begin
            o_msg_no <= LinkMgmt_RDI_Rsp_L1;
        end else if (send_pm_resp && i_req_L1_or_L2) begin
            o_msg_no <= LinkMgmt_RDI_Rsp_L2;
        end
        /****************************************************
         * RDI FSM outputs
        ****************************************************/
        if (send_rdi_outputs || receivied_pm_nak || i_force_exit) begin 
            o_test_done <= 1;
        end 
    end
end
/********************************************************************************
* VALID LOGIC
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        o_msg_valid <= 1'b0;
    end else begin
        if (send_pm_resp || send_pm_nak) begin
            o_msg_valid <= 1'b1;
        end else if (i_msg_done) begin 
            o_msg_valid <= 1'b0;
        end
    end
end
/********************************************************************************
* 1 MICROSECONDS COUNTER
********************************************************************************/
always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        counter_1microsec <= {9{1'b0}};
        start_count       <= 1'b0;
    end else if (~i_en && (receivied_L1_req || receivied_L2_req)) begin 
        counter_1microsec <= {9{1'b0}};
        start_count       <= 1'b1;
    end else if (continue_counting && start_count) begin
        counter_1microsec <= counter_1microsec + 1;
    end else begin
        start_count <= 1'b0;
    end

    if (i_en || count_done) begin
        start_count <= 1'b0;
        counter_1microsec <= {9{1'b0}};
    end
end

endmodule 