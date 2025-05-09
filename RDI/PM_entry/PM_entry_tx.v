module PM_entry_tx (
/**************************************
 * INPUTS
**************************************/
    input               i_clk,
    input               i_rst_n,
    // Wrapper signals
    input               i_rx_msg_valid, // from PM_entry_rx
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
    // Wrapper signals
    output  reg         o_force_exit,
    // RDI Sdeband related signals
    output  reg         o_msg_valid,
    output  reg [3:0]   o_msg_no,
    // RDI FSM related signals
    output  reg         o_test_done,    // 1h: upon finishing the flow (when receiving either pm.resp or pm.nak), 0h: the flow did not finished yet
    output  reg         o_pm_nak        // 1h: if receivied pm.nak (failed entry), 0h: if receivied pm.resp (successfull entry)
);
/********************************************************************************
 * PARAMETERS
********************************************************************************/
localparam [3:0] LinkMgmt_RDI_Req_L1         = 4'd2,
                 LinkMgmt_RDI_Req_L2         = 4'd3,
                 LinkMgmt_RDI_Rsp_PMNAK      = 4'd9,
                 LinkMgmt_RDI_Rsp_L1         = 4'd10,
                 LinkMgmt_RDI_Rsp_L2         = 4'd11;
                 
localparam COUNTING_2microsec_USING_100mhz = 200;// 200: number of clock cycles representing 2micros using 100 MHz clock
localparam COUNTING_2microsec_USING_200mhz = 400;// 400: number of clock cycles representing 2micros using 200 MHz clock
/********************************************************************************
* FSM STATES
********************************************************************************/
localparam [1:0]    IDLE                = 2'b00,
                    WAIT_FOR_RX_TO_RESP = 2'b01,
                    SEND_PM_REQ         = 2'b11,
                    TEST_FINISHED       = 2'b10;
/********************************************************************************
* INTERNAL WIRES AND REGISTERS
********************************************************************************/
reg [1:0]  CS,NS;
reg [8:0]  counter_2microsec;
/********************************************************************************
* ASSIGN/WIRE STATMENTS
********************************************************************************/
wire send_pm_req = ((CS == IDLE || CS == WAIT_FOR_RX_TO_RESP) && NS == SEND_PM_REQ);
wire receivied_L1_resp  = ((i_msg_no == LinkMgmt_RDI_Rsp_L1) && i_msg_valid);
wire receivied_L2_resp  = ((i_msg_no == LinkMgmt_RDI_Rsp_L2) && i_msg_valid);
wire receivied_pm_nak   = ((i_msg_no == LinkMgmt_RDI_Rsp_PMNAK) && i_msg_valid);
wire go_to_test_finish  = (receivied_L1_resp || receivied_L2_resp || receivied_pm_nak);
wire send_rdi_outputs   = ((CS == SEND_PM_REQ && NS == TEST_FINISHED));
// counter related signals
wire continue_counting  = (~i_clk_div_ratio && counter_2microsec < COUNTING_2microsec_USING_100mhz)? 1 : (i_clk_div_ratio && counter_2microsec < COUNTING_2microsec_USING_200mhz)? 1 : 0;
wire count_done = ((~i_clk_div_ratio && counter_2microsec == COUNTING_2microsec_USING_100mhz) || (i_clk_div_ratio && counter_2microsec == COUNTING_2microsec_USING_200mhz))? 1 : 0;
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
            if (~i_en) begin
                NS = IDLE;
            end else if (i_en && (i_msg_no != LinkMgmt_RDI_Req_L1) && (i_msg_no != LinkMgmt_RDI_Req_L2)) begin
                NS = SEND_PM_REQ;
            end else begin
                NS = WAIT_FOR_RX_TO_RESP;
            end
        end              
/*-------------------------------------------------------------------------------
 * WAIT_FOR_RX_TO_RESP state (prioritizing resp)
-------------------------------------------------------------------------------*/
        WAIT_FOR_RX_TO_RESP: begin
            if (~i_en) begin
                NS = IDLE;
            end else if (~i_rx_msg_valid) begin
                NS = SEND_PM_REQ;
            end else begin
                NS = WAIT_FOR_RX_TO_RESP;
            end
        end
/*-------------------------------------------------------------------------------
 * SEND_PM_REQ state
-------------------------------------------------------------------------------*/
        SEND_PM_REQ: begin
            if (~i_en) begin
                NS = IDLE;
            end else if (go_to_test_finish || count_done) begin
                NS = TEST_FINISHED;
            end else begin
                NS = SEND_PM_REQ;
            end
        end
/*-------------------------------------------------------------------------------
 * TEST_FINISHED state
-------------------------------------------------------------------------------*/
        TEST_FINISHED: begin
            if (~i_en) begin
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
        o_pm_nak    <= 1'b0;
    end else begin
        if (CS == IDLE) begin
            o_msg_no    <= 1'b0;
            o_test_done <= 1'b0;
            o_pm_nak    <= 1'b0;
            o_force_exit <= 0;
        end else if (count_done) begin
            o_force_exit <= 1;
        end
        /****************************************************
         * sideband request
        ****************************************************/
        if (send_pm_req && ~i_req_L1_or_L2) begin
            o_msg_no <= LinkMgmt_RDI_Req_L1;
        end else if (send_pm_req && i_req_L1_or_L2) begin
            o_msg_no <= LinkMgmt_RDI_Req_L2;
        end
        /****************************************************
         * RDI FSM outputs
        ****************************************************/
        if (send_rdi_outputs && count_done) begin // (Abort flow)
            // mdam dakhlt el condition dh fa dh m3nah en el 2 microseconds 3adoo mn gher mygeelk ay responces khales
            o_test_done <= 1;
            o_pm_nak    <= 1;
        end else if (send_rdi_outputs && ~i_req_L1_or_L2 && (receivied_L2_resp || receivied_pm_nak)) begin  // (Abort flow)
            // mdam dakhlt el condition dh fa dh m3nah en galk responce L2 aw galk pmnak wenta aslun kunt ba3t req L1 fa kdh lazm t resolve l pmnak
            o_test_done <= 1;
            o_pm_nak    <= 1;
        end else if (send_rdi_outputs && i_req_L1_or_L2 && (receivied_L1_resp || receivied_pm_nak)) begin // (Abort flow)
            // mdam dakhlt el condition dh fa dh m3nah en galk responce L1 aw galk pmnak wenta aslun kunt ba3t req L2 fa kdh lazm t resolve l pmnak
            o_test_done <= 1;
            o_pm_nak    <= 1;           
        end else if (send_rdi_outputs) begin // (Successfull entry flow)
            o_test_done <= 1;
            o_pm_nak    <= 0;
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
        if (send_pm_req) begin
            o_msg_valid <= 1'b1;
        end else if (i_msg_done && ~i_rx_msg_valid) begin // 34an lw el rx byb3t fa el i_msg_done di htb2a bta3to hwa falazm at2kd enha bta3ty
            o_msg_valid <= 1'b0;
        end
    end
end
/********************************************************************************
* 2 MICROSECONDS COUNTER
********************************************************************************/
// this counter is made as an extra feature that if we didn't receive any responces with in 2microseconds we will report to adapter as a pmnak
// why this is an extra feature? since the standard didn't state that the remote partner may not respond. it must respond either with pm resp or pmnak
// but as an extra checking if we didn't receive anything, we made this counter.

always @ (posedge i_clk or negedge i_rst_n) begin
    if (~i_rst_n) begin
        counter_2microsec <= {9{1'b0}};
    end else if (~i_en || (i_msg_done && ~i_rx_msg_valid)) begin // bsafro lma el i_en ynzl aw lma el block yb2a shaghal 3adee bas 3ayz el counter ybd2 3ad awel lma nb3t el pm req
        counter_2microsec <= {9{1'b0}};
    end else if (continue_counting) begin
        counter_2microsec <= counter_2microsec + 1;
    end
end

endmodule 