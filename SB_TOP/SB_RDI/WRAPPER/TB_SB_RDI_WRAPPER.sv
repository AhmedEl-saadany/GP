`timescale 1ns/1ps
module TB_SB_RDI_WRAPPER;
/**************************************
 * PARAMETERS
**************************************/
localparam DELAY_CYCLES = 3;
/**************************************
 * SIGNALS
**************************************/
// Clock and reset
reg i_clk_pll;
bit i_clk_rdi;
bit i_clk_fifo;
reg i_rst_n;
// Adapter signals
reg i_lp_cfg_vld;
reg [31:0] i_lp_cfg;
wire i_lp_cfg_crd;
wire pl_nerror_encoder;
wire pl_nerror_decoder;
wire o_pl_cfg_crd;
reg  clk_is_ungated;
// RDI FSM signals
reg [3:0] i_msg_no;
reg i_msg_valid;
wire o_msg_done;
wire [3:0] o_msg_no;
wire o_msg_valid;
wire wake_adapter_encoder;
reg  i_adapter_is_waked_up;

///////////////////////////////////////////////////////////////////////////////////
// DON'T TOUCH THIS SIGNALS
///////////////////////////////////////////////////////////////////////////////////
// TX FIFO signals
wire [63:0] o_fifo_data_encoder;
wire [63:0] o_real_fifo_data;
wire fifo_write_en;
wire fifo_read_en;
wire fifo_full;
wire fifo_empty;
wire o_ser_done_sampled;
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
wire wake_adapter_decoder;
string decoded_message;
wire decoder_rising_edge_pl_cfg_vld;
// CREDIT LOOP CONTROLLER signals
wire adapter_is_full;
// TX ENCODER signals
string encoded_message;
wire o_delete_data;
//////////////////////////////////////////////////////////////////////////////////
/**********************************************************************************************************************
************************************************ INSTANIATING DUT *****************************************************
***********************************************************************************************************************/
SB_RDI_ENCODER dut (
    .i_clk              (i_clk_rdi),
    .i_rst_n            (i_rst_n),
    .i_lp_cfg_vld       (i_lp_cfg_vld),
    .i_lp_cfg           (i_lp_cfg),
    .i_msg_no           (i_msg_no),
    .i_msg_valid        (i_msg_valid),
    .i_adapter_is_waked_up (i_adapter_is_waked_up),
    .i_fifo_full        (fifo_full),
    .o_pl_nerror        (pl_nerror_encoder),
    .o_msg_done         (o_msg_done),
    .o_fifo_data        (o_fifo_data_encoder),
    .o_fifo_write_en    (fifo_write_en),
    .o_delete_data      (o_delete_data),
    .o_wake_adapter     (wake_adapter_encoder)
);


SB_TX_FIFO tx_fifo_dut (
	.i_clk         (i_clk_rdi),
	.i_rst_n       (i_rst_n),
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

SB_CLOCK_CONTROLLER clock_controller_dut (
    .i_pll_clk      (i_clk_pll), //
    .i_rst_n        (i_rst_n), //
    .i_enable       (o_clk_ser_en), // 
    .o_pack_finished(o_pack_finished), //
    .o_ser_done     (ser_done), //
    .TXCKSB         (TXCKSB) //
);

SB_TX_FSM_Modelling fsm_model (
	.i_rst_n          (i_rst_n),
	.i_clk            (i_clk_pll),
	.i_ser_done       (ser_done),
	.i_empty          (fifo_empty),
	.i_packet_finished(o_pack_finished),
	.i_read_enable_sampled(o_ser_done_sampled),
	.o_read_enable    (fifo_read_en),
    .i_dont_send_zeros  (o_dont_send_zeros),
	.o_clk_en         (o_clk_ser_en)
);

SB_TX_SERIALIZER SB_TX_SERIALIZER_inst (
    .i_pll_clk          (i_clk_pll),
    .i_rst_n            (i_rst_n),
    .i_data_in          (o_real_fifo_data),
    .i_enable           (o_clk_ser_en),
    .i_pack_finished    (o_pack_finished),
    .TXDATASB           (TXDATA_SB)
);

credit_loop_controller credit_loop_controller_inst (
    .i_clk                      (i_clk_rdi),
    .i_rst_n                    (i_rst_n),
    // credit notifier signals
    .i_srcid                    (o_real_fifo_data[30:29]),
    .i_tx_fifo_read_en          (o_ser_done_sampled),
    .i_fifo_data_is_zeros       (o_dont_send_zeros),
    .o_pl_cfg_crd               (o_pl_cfg_crd),
    // credit counter signals
    .i_lp_cfg_crd               (i_lp_cfg_crd),
    .i_rising_edge_pl_cfg_vld   (decoder_rising_edge_pl_cfg_vld),
    .o_adapter_is_full          (adapter_is_full)
);

SB_RX_DESER SB_RX_DESER_inst(
    .i_clk                  (TXCKSB),
    .i_clk_pll              (i_clk_pll),
    .i_rst_n                (i_rst_n),
    .ser_data_in            (TXDATA_SB),
    .i_de_ser_done_sampled  (o_deser_done_sampled),
    .par_data_out           (deser_data),
    .de_ser_done            (deser_done)
);


SB_RDI_DECODER SB_RDI_DECODER_inst (
    .i_clk                  (i_clk_rdi),
    .i_rst_n                (i_rst_n),
    .i_adapter_is_full      (adapter_is_full),
    .i_clk_is_ungated       (clk_is_ungated),                  
    .i_adapter_is_waked_up  (i_adapter_is_waked_up),    
    .i_deser_done           (deser_done),
    .i_deser_data           (deser_data),
    .o_rising_edge_pl_cfg_vld (decoder_rising_edge_pl_cfg_vld),
    .o_deser_done_sampled   (o_deser_done_sampled),
    .o_pl_cfg               (o_pl_cfg),
    .o_pl_cfg_vld           (o_pl_cfg_vld),
    .o_pl_nerror            (pl_nerror_decoder),
    .o_wake_adapter         (wake_adapter_decoder),
    .o_msg_valid            (o_msg_valid),
    .o_msg_no               (o_msg_no)
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
    i_clk_rdi = 0;
    forever #2 i_clk_rdi = ~i_clk_rdi; // 100MHz clock
end
/**********************************************************************************************************************
******************************************************* TASKS *********************************************************
***********************************************************************************************************************/
/**************************************
 * SEND ADAPTER MESSAGE TASK
**************************************/
task send_adapter_message;
    input string with_data;
    reg [4:0]  random_value;
    reg [31:0] HEADER_PHASE_0;
    logic [31:0] HEADER_PHASE_1;
    reg [31:0] DATA_PHASE_0;
    reg [31:0] DATA_PHASE_1;
    random_value  = $urandom;
    HEADER_PHASE_0 = {3'b001,24'b0,(with_data == "no_data")? 5'b10010 : (with_data == "with_data")? 5'b11011 : 5'b10010};     // {srcid, XXXXXX , opcode}
    HEADER_PHASE_1 = {5'b00000,3'b001,24'b0}; // {5'bXXXXX, dstid , XXXX}
    DATA_PHASE_0   = $urandom;
    DATA_PHASE_1   = $urandom;
    begin
        if (with_data == "no_data") begin
            // Header phase 0
            i_lp_cfg = HEADER_PHASE_0; 
            i_lp_cfg_vld = 1;
            @(posedge i_clk_rdi);
            
            // Header phase 1
            i_lp_cfg = HEADER_PHASE_1;
            i_lp_cfg_vld = 1;
            @(posedge i_clk_rdi);
            i_lp_cfg_vld = 0;

        end else if (with_data == "with_data") begin
            // Header phase 0
            i_lp_cfg = HEADER_PHASE_0;
            i_lp_cfg_vld = 1;
            @(posedge i_clk_rdi);
            
            // Header phase 1
            i_lp_cfg = HEADER_PHASE_1;
            i_lp_cfg_vld = 1;
            @(posedge i_clk_rdi);

            // Data phase 0
            i_lp_cfg = DATA_PHASE_0;
            i_lp_cfg_vld = 1;
            @(posedge i_clk_rdi);

            // Data phase 1
            i_lp_cfg = DATA_PHASE_1;
            i_lp_cfg_vld = 1;
            @(posedge i_clk_rdi);
            i_lp_cfg_vld = 0;      
        end
    end
endtask
/**************************************
 * SEND RDI MESSAGE TASK
**************************************/
task send_rdi_message (
    input [3:0] msg_no
);
    i_msg_no = msg_no;
    i_msg_valid = 1;
    @(posedge o_msg_done);
    wait(~i_msg_valid);
    @(posedge i_clk_rdi);
endtask
/**********************************************************************************************************************
********************************************* STIMILUS GENERATION *****************************************************
***********************************************************************************************************************/
initial begin
    // Initialize
    i_rst_n = 0;
    i_lp_cfg_vld = 0;
    i_lp_cfg = 0;
    i_msg_no = 0;
    i_msg_valid = 0;
    i_adapter_is_waked_up = 0;
    clk_is_ungated = 0;
    
    // Reset sequence
    #20 i_rst_n = 1;
    $display("[%0t] Reset released", $time);
    
    // Wait a few clocks after reset
    repeat(5) @(posedge i_clk_rdi);
    
    /********************************************************
     * RDI MESSAGES TESTS
    *********************************************************/
    // Test Case 1: RDI Messages (Requests 1-7)
    $display("\n[%0t] Test Case 1: RDI Requests (1-7)", $time);
    for (int i=1; i<=7; i++) begin
        send_rdi_message (i);
    end
    // Test Case 2: RDI Messages (Responses 8-15)
    $display("\n[%0t] Test Case 2: RDI Responses (8-15)", $time);
    for (int i=8; i<=15; i++) begin
        send_rdi_message (i);
    end
    repeat(5) @(posedge i_clk_rdi);
    /********************************************************
     * ADAPTER VALID MESSAGES TESTS
    *********************************************************/
    // Test Case 3: LP Configuration (Message without data)
    $display("\n[%0t] Test Case 3: LP Config (No Data)", $time);
    send_adapter_message ("no_data");
    repeat(5) @(posedge i_clk_rdi);
    
    // Test Case 4: LP Configuration (Message with data)
    $display("\n[%0t] Test Case 4: LP Config (With Data)", $time);
    send_adapter_message ("with_data");
    repeat(5) @(posedge i_clk_rdi);

    // Test Case 9: LP Configuration (2 Message without data)
    $display("\n[%0t] Test Case 9: LP Config (2 Message without data)", $time);
    send_adapter_message ("no_data");
    send_adapter_message ("no_data");
    repeat(5) @(posedge i_clk_rdi);
    /********************************************************
     * ADAPTER ERROR MESSAGES TESTS
    *********************************************************/   
    // Test Case 5: Error Condition (Invalid opcode)
    $display("\n[%0t] Test Case 5: Error Condition", $time);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b11111}; // Invalid opcode
    i_lp_cfg_vld = 1;
    @(posedge i_clk_rdi);
    i_lp_cfg_vld = 0;
    repeat(10) @(posedge i_clk_rdi);

    // Test Case 6: Error Condition (msg with data with only 2 clock cycle valid)
    $display("\n[%0t] Test Case 6: Error Condition", $time);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b11011}; 
    i_lp_cfg_vld = 1;
    @(posedge i_clk_rdi);
    i_lp_cfg = {3'b110, 7'b0, 8'h41, 9'b1, 5'b11011};
    @(posedge i_clk_rdi);
    i_lp_cfg_vld = 0;
    repeat(10) @(posedge i_clk_rdi);
    
    // Test Case 7: Error Condition (msg with data with only 3 clock cycle valid)
    $display("\n[%0t] Test Case 7: Error Condition", $time);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b11011}; 
    i_lp_cfg_vld = 1;
    @(posedge i_clk_rdi);
    i_lp_cfg = {3'b110, 7'b0, 8'h41, 9'b1, 5'b11011};
    @(posedge i_clk_rdi);
    i_lp_cfg = {3'b110, 7'b1, 8'h4C, 9'b1, 5'b10011};
    @(posedge i_clk_rdi);
    i_lp_cfg_vld = 0;
    repeat(10) @(posedge i_clk_rdi);

    // Test Case 8: Error Condition (msg without data with only 1 clock cycle valid)
    $display("\n[%0t] Test Case 7: Error Condition", $time);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b10010}; 
    i_lp_cfg_vld = 1;
    @(posedge i_clk_rdi);
    i_lp_cfg = {3'b111, 7'b0, 8'h01, 9'b1, 5'b10110}; 
    i_lp_cfg_vld = 0;
    repeat(10) @(posedge i_clk_rdi);

    #10000;
    $display("\n[%0t] Simulation complete", $time);
    $stop;
end
/**********************************************************************************************************************
********************************************* MODELLING INPUT SIGNALS *************************************************
***********************************************************************************************************************/
/****************************************
 * modelling de-assertion of i_msg_valid
****************************************/
always @ (o_msg_done) begin
    if (o_msg_done) begin
    @(posedge i_clk_rdi);
    i_msg_valid = 0;
    end
end
/****************************************
 * modelling assertion of clk_is_ungated
****************************************/
always @ (posedge i_msg_valid) begin
    repeat (6) @(posedge i_clk_rdi);
    clk_is_ungated = 1;
end
/***********************************************
 * modelling assertion of i_adapter_is_waked_up
************************************************/
always @ (posedge wake_adapter_encoder) begin
    repeat (4) @(posedge i_clk_rdi);
    i_adapter_is_waked_up = 1;
    wait (~wake_adapter_encoder);
    @(posedge i_clk_rdi);
    i_adapter_is_waked_up = 0;
end

always @ (posedge wake_adapter_decoder) begin
    repeat (4) @(posedge i_clk_rdi);
    i_adapter_is_waked_up = 1;
    wait (~wake_adapter_decoder);
    @(posedge i_clk_rdi);
    i_adapter_is_waked_up = 0;
end
/**********************************************************************************************************************
************************************************ FOR DEBUGGING ONLY ***************************************************
***********************************************************************************************************************/
typedef enum {      DECODING_TX             = 3'b000,
                    HEADER_PHASE0_CAPTURED  = 3'b001,
                    HEADER_PHASE1_CAPTURED  = 3'b011,
                    DATA_PHASE0_CAPTURED    = 3'b010,
                    DATA_PHASE1_CAPTURED    = 3'b110,
                    ERROR_REPORT_TX         = 3'b111,
                    RDI_MSG_TX              = 3'b101
} states_encoder;

states_encoder CS_encoder,NS_encoder;

always @(*) begin
    CS_encoder = states_encoder'(dut.CS);
    NS_encoder = states_encoder'(dut.NS);
end

typedef enum {
    IDLE                = 3'b000,
    FIFO_READ           = 3'b001,
    DECODING_RX         = 3'b011,
    RDI_MSG_RX          = 3'b010,
    ADAPTER_MSG         = 3'b110,
    ERROR_REPORT_RX     = 3'b111,
    MSG_WITHOUT_DATA    = 3'b101,
    MSG_WITH_DATA       = 3'b100
} states_decoder;

states_decoder CS_decoder, NS_decoder;

always @(*) begin
    CS_decoder = states_decoder'(SB_RDI_DECODER_inst.CS);
    NS_decoder = states_decoder'(SB_RDI_DECODER_inst.NS);
end

logic [7:0] msgcode,msgsubcode;

always @ (*) begin
    msgcode = o_fifo_data_encoder[21:14];    // phase_0[21:14]
    msgsubcode = o_fifo_data_encoder[39:32]; // phase_1[7:0]
    if (fifo_write_en) begin
        if (msgcode == 8'h01 && ~i_lp_cfg_vld) begin // Requests
            case (msgsubcode)
                8'h01: encoded_message = "LinkMgmt.RDI.Req.Active";
                8'h04: encoded_message = "LinkMgmt.RDI.Req.L1";
                8'h08: encoded_message = "LinkMgmt.RDI.Req.L2";
                8'h09: encoded_message = "LinkMgmt.RDI.Req.LinkReset";
                8'h0A: encoded_message = "LinkMgmt.RDI.Req.LinkError";
                8'h0B: encoded_message = "LinkMgmt.RDI.Req.Retrain";
                8'h0C: encoded_message = "LinkMgmt.RDI.Req.Disable";
                default: encoded_message = "Unknown Request";
            endcase
        end
        else if (msgcode == 8'h02 && ~i_lp_cfg_vld) begin // Responses
            case (msgsubcode)
                8'h01: encoded_message = "LinkMgmt.RDI.Rsp.Active";
                8'h02: encoded_message = "LinkMgmt.RDI.Rsp.PMNAK";
                8'h04: encoded_message = "LinkMgmt.RDI.Rsp.L1";
                8'h08: encoded_message = "LinkMgmt.RDI.Rsp.L2";
                8'h09: encoded_message = "LinkMgmt.RDI.Rsp.LinkReset";
                8'h0A: encoded_message = "LinkMgmt.RDI.Rsp.LinkError";
                8'h0B: encoded_message = "LinkMgmt.RDI.Rsp.Retrain";
                8'h0C: encoded_message = "LinkMgmt.RDI.Rsp.Disable";
                default: encoded_message = "Unknown Response";
            endcase
        end
        else if ( i_lp_cfg_vld && o_fifo_data_encoder[4:0] == 5'b10010) begin
            encoded_message = "Adapter.Packet.with.no.data";
        end
        else if ( i_lp_cfg_vld && o_fifo_data_encoder[4:0] == 5'b11011) begin
            encoded_message = "Adapter.Packet.with.data";
        end else begin
            encoded_message = "FALSE!!.Adapter.Packet";
        end
    end 
    $display("[%0t] Decoded: %s (Code: %h, SubCode: %h)", 
            $time, encoded_message, msgcode, msgsubcode);
end


always @(*) begin
    if (o_msg_valid) begin
        case (o_msg_no)
            4'd1:    decoded_message = "LinkMgmt.RDI.Req.Active";                          
            4'd2:    decoded_message = "LinkMgmt.RDI.Req.L1";                           
            4'd3:    decoded_message = "LinkMgmt.RDI.Req.L2";                            
            4'd4:    decoded_message = "LinkMgmt.RDI.Req.LinkReset";                            
            4'd5:    decoded_message = "LinkMgmt.RDI.Req.LinkError";                          
            4'd6:    decoded_message = "LinkMgmt.RDI.Req.Retrain";                            
            4'd7:    decoded_message = "LinkMgmt.RDI.Req.Disable";                            
            4'd8:    decoded_message = "LinkMgmt.RDI.Rsp.Active";                            
            4'd9:    decoded_message = "LinkMgmt.RDI.Rsp.PMNAK";                           
            4'd10:   decoded_message = "LinkMgmt.RDI.Rsp.L1";             
            4'd11:   decoded_message = "LinkMgmt.RDI.Rsp.L2";             
            4'd12:   decoded_message = "LinkMgmt.RDI.Rsp.LinkReset";              
            4'd13:   decoded_message = "LinkMgmt.RDI.Rsp.LinkError";             
            4'd14:   decoded_message = "LinkMgmt.RDI.Rsp.Retrain";             
            4'd15:   decoded_message = "LinkMgmt.RDI.Rsp.Disable";             
            default: decoded_message = "Unknown Message Number";
        endcase
    end else if (o_pl_cfg_vld) begin
        decoded_message = "Adapter Configuration";
    end
    else begin
        decoded_message = "No Valid Message";
    end
end
endmodule

