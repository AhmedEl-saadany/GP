`timescale 1ns/1ps

module TB_SB_RDI_ENCODER;

// Clock and reset
reg i_clk_pll;
bit i_clk_rdi;
bit i_clk_fifo;
reg i_rst_n;

// Adapter signals
reg i_lp_cfg_vld;
reg [31:0] i_lp_cfg;
wire i_lp_cfg_crd;

// RDI FSM signals
reg [3:0] i_msg_no;
reg i_msg_valid;

// TX FIFO signals
reg i_fifo_full;
wire o_pl_nerror;
wire o_msg_done;
wire [63:0] o_fifo_data;
wire [63:0] o_real_fifo_data;
wire o_fifo_write_en;
wire empty;
wire o_ser_done_sampled,i_adapter_is_waked_up,o_wake_adapter;
wire o_clk_ser_en;
wire o_pack_finished;
wire ser_done;
wire TXCKSB;
wire TXDATA_SB;
wire read_enable;

// Instantiate DUT
SB_RDI_ENCODER dut (
    .i_clk              (i_clk_rdi),
    .i_rst_n            (i_rst_n),
    .i_lp_cfg_vld       (i_lp_cfg_vld),
    .i_lp_cfg           (i_lp_cfg),
    .i_msg_no           (i_msg_no),
    .i_msg_valid        (i_msg_valid),
    .i_adapter_is_waked_up (1'b1),
    .i_fifo_full        (i_fifo_full),
    .o_pl_nerror        (o_pl_nerror),
    .o_msg_done         (o_msg_done),
    .o_fifo_data        (o_fifo_data),
    .o_fifo_write_en    (o_fifo_write_en),
    .o_wake_adapter     (o_wake_adapter)
);


SB_TX_FIFO tx_fifo_dut (
	.i_clk         (i_clk_rdi),
	.i_rst_n       (i_rst_n),
	.i_data_in     (o_fifo_data), //
	.i_write_enable(o_fifo_write_en), //
	.i_read_enable (read_enable), //
	.o_data_out    (o_real_fifo_data), //
	.o_empty       (empty), //
	.o_ser_done_sampled(o_ser_done_sampled),
    .o_dont_send_zeros  (o_dont_send_zeros),
	.o_full        (i_fifo_full) //
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
	.i_empty          (empty),
	.i_packet_finished(o_pack_finished),
	.i_read_enable_sampled(o_ser_done_sampled),
	.o_read_enable    (read_enable),
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
wire o_pl_cfg_crd;
wire adapter_is_full;
credit_loop_controller credit_loop_controller_inst (
    .i_clk                      (i_clk_rdi),
    .i_rst_n                    (i_rst_n),
    .i_srcid                    (o_real_fifo_data[30:29]),
    // credit notifier signals
    .i_tx_fifo_read_en          (o_ser_done_sampled),
    .o_pl_cfg_crd               (o_pl_cfg_crd),
    // credit counter signals
    .i_lp_cfg_crd               (i_lp_cfg_crd),
    .i_rising_edge_pl_cfg_vld   (decoder_rising_edge_pl_cfg_vld),
    .o_adapter_is_full          (adapter_is_full)
);

typedef enum {      DECODING                = 3'b000,
                    HEADER_PHASE0_CAPTURED  = 3'b001,
                    HEADER_PHASE1_CAPTURED  = 3'b011,
                    DATA_PHASE0_CAPTURED    = 3'b010,
                    DATA_PHASE1_CAPTURED    = 3'b110,
                    ERROR_REPORT            = 3'b111,
                    RDI_MSG                 = 3'b101} states_e;

states_e CS_tb,NS_tb;

always @(*) begin
    CS_tb = states_e'(dut.CS);
    NS_tb = states_e'(dut.NS);
end
// Clock generation
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
// Message decoder for waveform viewing
string decoded_message;

logic [7:0] msgcode,msgsubcode;

always @ (*) begin
    msgcode = o_fifo_data[21:14];    // phase_0[21:14]
    msgsubcode = o_fifo_data[39:32]; // phase_1[7:0]
    if (o_fifo_write_en) begin
        if (msgcode == 8'h01 && ~i_lp_cfg_vld) begin // Requests
            case (msgsubcode)
                8'h01: decoded_message = "LinkMgmt.RDI.Req.Active";
                8'h04: decoded_message = "LinkMgmt.RDI.Req.L1";
                8'h08: decoded_message = "LinkMgmt.RDI.Req.L2";
                8'h09: decoded_message = "LinkMgmt.RDI.Req.LinkReset";
                8'h0A: decoded_message = "LinkMgmt.RDI.Req.LinkError";
                8'h0B: decoded_message = "LinkMgmt.RDI.Req.Retrain";
                8'h0C: decoded_message = "LinkMgmt.RDI.Req.Disable";
                default: decoded_message = "Unknown Request";
            endcase
        end
        else if (msgcode == 8'h02 && ~i_lp_cfg_vld) begin // Responses
            case (msgsubcode)
                8'h01: decoded_message = "LinkMgmt.RDI.Rsp.Active";
                8'h02: decoded_message = "LinkMgmt.RDI.Rsp.PMNAK";
                8'h04: decoded_message = "LinkMgmt.RDI.Rsp.L1";
                8'h08: decoded_message = "LinkMgmt.RDI.Rsp.L2";
                8'h09: decoded_message = "LinkMgmt.RDI.Rsp.LinkReset";
                8'h0A: decoded_message = "LinkMgmt.RDI.Rsp.LinkError";
                8'h0B: decoded_message = "LinkMgmt.RDI.Rsp.Retrain";
                8'h0C: decoded_message = "LinkMgmt.RDI.Rsp.Disable";
                default: decoded_message = "Unknown Response";
            endcase
        end
        else if ( i_lp_cfg_vld && o_fifo_data[4:0] == 5'b10010) begin
            decoded_message = "Adapter.Packet.with.no.data";
        end
        else if ( i_lp_cfg_vld && o_fifo_data[4:0] == 5'b11011) begin
            decoded_message = "Adapter.Packet.with.data";
        end else begin
            decoded_message = "FALSE!!.Adapter.Packet";
        end
    end 
    $display("[%0t] Decoded: %s (Code: %h, SubCode: %h)", 
            $time, decoded_message, msgcode, msgsubcode);
end


// Main test sequence
initial begin
    // Initialize
    i_rst_n = 0;
    i_lp_cfg_vld = 0;
    i_lp_cfg = 0;
    i_msg_no = 0;
    i_msg_valid = 0;
    //i_fifo_full = 0;
    decoded_message = "None";
    
    // Reset sequence
    #20 i_rst_n = 1;
    $display("[%0t] Reset released", $time);
    
    // Wait a few clocks after reset
    repeat(5) @(posedge i_clk_rdi);
    
    // Test Case 1: RDI Messages (Requests 1-7)
    $display("\n[%0t] Test Case 1: RDI Requests (1-7)", $time);
    for (int i=1; i<=1; i++) begin
        i_msg_no = i;
        if (i <= 3) begin
            i_msg_valid = 1;
        end else begin
            @(posedge i_clk_rdi);
            i_msg_valid = 1;
        end
        repeat(10) @(posedge i_clk_rdi);
    end
    i_msg_valid = 0;
    repeat(2) @(posedge i_clk_rdi);
    // Test Case 2: RDI Messages (Responses 8-15)
    $display("\n[%0t] Test Case 2: RDI Responses (8-15)", $time);
    for (int i=8; i<=8; i++) begin
        i_msg_no = i;
        i_msg_valid = 1;
        repeat(2) @(posedge i_clk_rdi);
    end
    repeat(5) @(posedge i_clk_rdi);

    // Test Case 3: LP Configuration (Message without data)
    $display("\n[%0t] Test Case 3: LP Config (No Data)", $time);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b10010}; // Valid header
    i_lp_cfg_vld = 1;
    @(posedge i_clk_rdi);
    i_lp_cfg = {1'b0, 1'b0, 3'b0, 3'b110, 16'b0, 8'h00}; // Valid phase1
    @(posedge i_clk_rdi);
    i_lp_cfg_vld = 0;
    repeat(5) @(posedge i_clk_rdi);
    
    // Test Case 4: LP Configuration (Message with data)
    $display("\n[%0t] Test Case 4: LP Config (With Data)", $time);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b11011}; // Valid header with data
    i_lp_cfg_vld = 1;
    @(posedge i_clk_rdi);
    i_lp_cfg = {1'b0, 1'b0, 3'b0, 3'b110, 16'b0, 8'h00}; // Valid phase1
    @(posedge i_clk_rdi);
    i_lp_cfg = 32'hDEADBEEF; // Data phase0
    @(posedge i_clk_rdi);
    i_lp_cfg = 32'hCAFEBABE; // Data phase1
    @(posedge i_clk_rdi);
    i_lp_cfg_vld = 0;
    repeat(5) @(posedge i_clk_rdi);
    
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

    // Test Case 9: LP Configuration (2 Message without data)
    $display("\n[%0t] Test Case 9: LP Config (2 Message without data)", $time);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b10010}; // Valid header
    i_lp_cfg_vld = 1;
    @(posedge i_clk_rdi);
    i_lp_cfg = {1'b0, 1'b0, 3'b0, 3'b110, 16'b0, 8'h01}; // Valid phase1
    @(posedge i_clk_rdi);
    i_lp_cfg = {3'b001, 7'b0, 8'h01, 9'b0, 5'b10010};
    @(posedge i_clk_rdi);
    i_lp_cfg = {1'b1, 1'b1, 3'b101, 3'b110, 16'b0, 8'h51};
    @(posedge i_clk_rdi);
    i_lp_cfg_vld = 0;
    repeat(5) @(posedge i_clk_rdi);

    // // Test Case 6: FIFO Full Condition
    // $display("\n[%0t] Test Case 6: FIFO Full", $time);
    // i_fifo_full = 1;
    // i_msg_no = 1;
    // i_msg_valid = 1;
    // repeat(5) @(posedge i_clk_rdi);
    // i_fifo_full = 0;
    
    // End simulation
    #10000000;
    $display("\n[%0t] Simulation complete", $time);
    $stop;
end

always @ (o_msg_done) begin
    if (o_msg_done) begin
    @(posedge i_clk_rdi);
    i_msg_valid = 0;
    end
end

// Monitor important signals
always @(posedge i_clk_rdi) begin
    if (o_fifo_write_en) begin
        $display("[%0t] FIFO Write: Data = 0x%h", $time, o_fifo_data);
    end
    if (o_pl_nerror) begin
        $display("[%0t] Error detected!", $time);
    end
end

endmodule