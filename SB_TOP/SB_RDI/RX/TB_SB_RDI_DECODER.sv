`timescale 1ns/1ps

module TB_SB_RDI_DECODER;

// Clock and reset
reg i_clk;
reg i_rst_n;

// Credit loop control signals
reg i_adapter_is_full;
reg i_clk_is_ungated;
reg i_adapter_is_waked_up;

// RX DESER signals
reg i_deser_done;
reg [63:0] i_deser_data;

// Outputs
wire o_deser_done_sampled;
wire [31:0] o_pl_cfg;
wire o_pl_cfg_vld;
wire o_pl_nerror;
wire o_wake_adapter;
wire o_msg_valid;
wire [3:0] o_msg_no;

// FIFO signals
wire fifo_empty;
wire fifo_full;

// Instantiate DUT
SB_RDI_DECODER dut (
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_adapter_is_full(i_adapter_is_full),
    .i_clk_is_ungated(i_clk_is_ungated),
    .i_adapter_is_waked_up(i_adapter_is_waked_up),
    .i_deser_done(i_deser_done),
    .i_deser_data(i_deser_data),
    .o_deser_done_sampled(o_deser_done_sampled),
    .o_pl_cfg(o_pl_cfg),
    .o_pl_cfg_vld(o_pl_cfg_vld),
    .o_pl_nerror(o_pl_nerror),
    .o_wake_adapter(o_wake_adapter),
    .o_msg_valid(o_msg_valid),
    .o_msg_no(o_msg_no)
);

// State enumeration for monitoring
typedef enum {
    IDLE         = 3'b000,
    FIFO_READ    = 3'b001,
    DECODING     = 3'b011,
    RDI_MSG      = 3'b010,
    ADAPTER_MSG  = 3'b110,
    ERROR_REPORT = 3'b111,
    MSG_WITHOUT_DATA = 3'b101,
    MSG_WITH_DATA    = 3'b100
} states_e;

states_e CS_tb, NS_tb;

// Assign state values for monitoring
always @(*) begin
    CS_tb = states_e'(dut.CS);
    NS_tb = states_e'(dut.NS);
end

// Clock generation
initial begin
    i_clk = 0;
    forever #5 i_clk = ~i_clk; // 100MHz clock
end

// Message decoder for waveform viewing
string decoded_message;

always @(*) begin
    if (o_msg_valid) begin
        case (o_msg_no)
            4'd1: begin
                decoded_message = "LinkMgmt.RDI.Req.Active";                          
            end
            4'd2: begin
                decoded_message = "LinkMgmt.RDI.Req.L1";                           
            end
            4'd3: begin
                decoded_message = "LinkMgmt.RDI.Req.L2";                            
            end
            4'd4: begin
                decoded_message = "LinkMgmt.RDI.Req.LinkReset";                            
            end
            4'd5: begin
                decoded_message = "LinkMgmt.RDI.Req.LinkError";                          
            end
            4'd6: begin
                decoded_message = "LinkMgmt.RDI.Req.Retrain";                            
            end
            4'd7: begin
                decoded_message = "LinkMgmt.RDI.Req.Disable";                            
            end
            4'd8: begin
                decoded_message = "LinkMgmt.RDI.Rsp.Active";                            
            end
            4'd9: begin
                decoded_message = "LinkMgmt.RDI.Rsp.PMNAK";                           
            end
            4'd10: begin
                decoded_message = "LinkMgmt.RDI.Rsp.L1";             
            end
            4'd11: begin
                decoded_message = "LinkMgmt.RDI.Rsp.L2";             
            end
            4'd12: begin
                decoded_message = "LinkMgmt.RDI.Rsp.LinkReset";              
            end
            4'd13: begin
                decoded_message = "LinkMgmt.RDI.Rsp.LinkError";             
            end
            4'd14: begin
                decoded_message = "LinkMgmt.RDI.Rsp.Retrain";             
            end
            4'd15: begin
                decoded_message = "LinkMgmt.RDI.Rsp.Disable";             
            end
            default: begin                      
                decoded_message = "Unknown Message Number";
            end
        endcase
    end else if (o_pl_cfg_vld) begin
        decoded_message = "Adapter Configuration";
    end
    else begin
        decoded_message = "No Valid Message";
    end
end

// Task to send RDI message
task send_rdi_message;
    input [3:0] message_num;
    reg [7:0] msgcode;
    reg [7:0] msgsubcode;
    begin
        msgcode = (message_num <= 7) ? 8'h01 : 8'h02; // Requests or responses
        
        case (message_num)
            1: msgsubcode = 8'h01;
            2: msgsubcode = 8'h04;
            3: msgsubcode = 8'h08;
            4: msgsubcode = 8'h09;
            5: msgsubcode = 8'h0A;
            6: msgsubcode = 8'h0B;
            7: msgsubcode = 8'h0C;
            8: msgsubcode = 8'h01;
            9: msgsubcode = 8'h02;
            10: msgsubcode = 8'h04;
            11: msgsubcode = 8'h08;
            12: msgsubcode = 8'h09;
            13: msgsubcode = 8'h0A;
            14: msgsubcode = 8'h0B;
            15: msgsubcode = 8'h0C;
            default: msgsubcode = 8'h00;
        endcase
        
        // Create the message
        i_deser_data = {
            // phase_1
            1'b0, // dp
            1'b0, // cp (will be calculated)
            3'b000, // reserved
            3'b110, // dstid (PHY)
            16'h0000, // reserved
            msgsubcode,
            // phase_0
            3'b010, // srcid
            7'b0000000, // reserved
            msgcode,
            9'b000000000, // reserved
            5'b10010 // opcode_msg_without_data
        };
        
        // Calculate and insert cp
        i_deser_data[63] = ^i_deser_data[31:0] ^ ^{i_deser_data[62:32], i_deser_data[30:0]};
        
        // Send the message
        i_deser_done = 1;
        @(posedge i_clk);
        // i_deser_done = 0;
        // @(posedge i_clk);
    end
endtask

// Task to send adapter message
task send_adapter_message;
    input with_data;
    input [31:0] data_phase0;
    input [31:0] data_phase1;
    begin
        if (~with_data) begin
            // Header phase 0
            i_deser_data [31:0]= {
                3'b010, // srcid
                7'b0000000, // reserved
                8'h01, // msgcode
                9'b000000000, // reserved
                with_data ? 5'b11011 : 5'b10010 // opcode
            };
            
            // Header phase 1
            i_deser_data [62:32]= {
                1'b0, // dp
                1'b0, // cp
                3'b000, // reserved
                3'b001, // dstid (D2D)
                16'h0000, // reserved
                8'h01 // msgsubcode
            };
            // Calculate and insert cp
            i_deser_data[63] = ^i_deser_data[31:0] ^ ^{i_deser_data[62:32], i_deser_data[30:0]};

            i_deser_done = 1;
            @(posedge i_clk);
        end else begin
            // Header phase 0
            i_deser_data [31:0]= {
                3'b010, // srcid
                7'b0000000, // reserved
                8'h01, // msgcode
                9'b000000000, // reserved
                with_data ? 5'b11011 : 5'b10010 // opcode
            };
            
            // Header phase 1
            i_deser_data [62:32]= {
                1'b0, // dp
                1'b0, // cp
                3'b000, // reserved
                3'b001, // dstid (D2D)
                16'h0000, // reserved
                8'h01 // msgsubcode
            };
            // Calculate and insert cp
            i_deser_data[63] = ^i_deser_data[31:0] ^ ^{i_deser_data[62:32], i_deser_data[30:0]};

            i_deser_done = 1;
            @(posedge i_clk);

            repeat (32) @ (posedge i_clk);      

            i_deser_data[63] = {data_phase1,data_phase0};  
            i_deser_done = 1;
            @(posedge i_clk);  
        end
        //i_deser_done = 0;
    end
endtask

// Main test sequence
initial begin
    // Initialize
    i_rst_n = 0;
    i_adapter_is_full = 0;
    i_clk_is_ungated = 1;
    i_adapter_is_waked_up = 0;
    i_deser_done = 0;
    i_deser_data = 0;
    
    // Reset sequence
    #20 i_rst_n = 1;
    $display("[%0t] Reset released", $time);
    
    // Wait a few clocks after reset
    repeat(5) @(posedge i_clk);
    
    // Test Case 1: RDI Messages (Requests 1-7)
    $display("\n[%0t] Test Case 1: RDI Requests (1-7)", $time);
    for (int i=1; i<=7; i++) begin
        send_rdi_message(i);
        wait(o_msg_valid);
        $display("[%0t] Received: %s (msg_no: %0d)", $time, decoded_message, o_msg_no);
        repeat (3) @(posedge i_clk);
        i_adapter_is_waked_up = 1; // elmafrood msh far2 m3aya
        @(posedge i_clk);           
        i_adapter_is_waked_up = 0; // elmafrood msh far2 m3aya
        repeat(2) @(posedge i_clk);
    end
    
    // Test Case 2: RDI Messages (Responses 8-15)
    $display("\n[%0t] Test Case 2: RDI Responses (8-15)", $time);
    for (int i=8; i<=15; i++) begin
        send_rdi_message(i);
        wait(o_msg_valid);
        $display("[%0t] Received: %s (msg_no: %0d)", $time, decoded_message, o_msg_no);
        repeat(2) @(posedge i_clk);
    end
    
    // Test Case 3: Adapter Message (without data)
    $display("\n[%0t] Test Case 3: Adapter Message (no data)", $time);
    i_adapter_is_waked_up = 1;
    send_adapter_message(0, 0, 0);
    wait(o_pl_cfg_vld);
    $display("[%0t] Received Adapter Config: 0x%h", $time, o_pl_cfg);
    repeat(5) @(posedge i_clk);
    
    // Test Case 4: Adapter Message (with data)
    $display("\n[%0t] Test Case 4: Adapter Message (with data)", $time);
    send_adapter_message(1, 32'hDEADBEEF, 32'hCAFEBABE);
    wait(o_pl_cfg_vld);
    $display("[%0t] Received Adapter Config: 0x%h", $time, o_pl_cfg);
    repeat(5) @(posedge i_clk);
    
    // Test Case 5: Adapter Full condition
    $display("\n[%0t] Test Case 5: Adapter Full", $time);
    i_adapter_is_full = 1;
    send_adapter_message(0, 0, 0);
    repeat(10) @(posedge i_clk);
    i_adapter_is_full = 0;
    i_adapter_is_waked_up = 1;
    @(posedge i_clk);
    i_adapter_is_waked_up = 0;
    
    // Test Case 6: Error Condition (Invalid dstid)
    $display("\n[%0t] Test Case 6: Invalid dstid", $time);
    i_deser_data = {
        // phase_1
        1'b0, // dp
        1'b0, // cp
        3'b000, // reserved
        3'b011, // invalid dstid
        16'h0000, // reserved
        8'h01,
        // phase_0
        3'b010, // srcid
        7'b0000000, // reserved
        8'h01, // msgcode
        9'b000000000, // reserved
        5'b10010 // opcode
    };
    // Calculate and insert cp
    i_deser_data[63] = ^i_deser_data[31:0] ^ ^{i_deser_data[62:32], i_deser_data[30:0]};
    i_deser_done = 1;
    @(posedge i_clk);
    i_deser_done = 0;
    wait(o_pl_nerror);
    $display("[%0t] Error detected as expected", $time);
    i_adapter_is_waked_up = 1;
    @(posedge i_clk);
    i_adapter_is_waked_up = 0;
    
    // End simulation
    #100;
    $display("\n[%0t] Simulation complete", $time);
    $stop;
end

always @ (posedge o_deser_done_sampled) begin
    repeat (3) @(posedge i_clk);
    i_deser_done = 0;
end
// Monitor important signals
always @(posedge i_clk) begin
    if (o_msg_valid) begin
        $display("[%0t] RDI Message: %s (msg_no: %0d)", $time, decoded_message, o_msg_no);
    end
    if (o_pl_cfg_vld) begin
        $display("[%0t] Adapter Config: 0x%h", $time, o_pl_cfg);
    end
    if (o_pl_nerror) begin
        $display("[%0t] Error detected!", $time);
    end
    if (o_wake_adapter) begin
        $display("[%0t] Wake adapter signal asserted", $time);
    end
end

endmodule