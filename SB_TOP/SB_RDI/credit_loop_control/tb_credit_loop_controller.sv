`timescale 1ns/1ps

module tb_credit_loop_controller();

// Clock and reset
reg clk;
reg rst_n;

// Testbench control
integer test_num;
integer error_count;

// credit_notifier signals
reg tx_fifo_read_en;
wire pl_cfg_crd;

// credit_counter signals
reg lp_cfg_crd;
reg rising_edge_pl_cfg_vld;
wire adapter_is_full;

// Clock generation
always #5 clk = ~clk;  // 100MHz clock

// Device Under Test
credit_loop_controller dut (
    .i_clk(clk),
    .i_rst_n(rst_n),
    
    // credit_notifier
    .i_tx_fifo_read_en(tx_fifo_read_en),
    .o_pl_cfg_crd(pl_cfg_crd),
    
    // credit_counter
    .i_lp_cfg_crd(lp_cfg_crd),
    .i_rising_edge_pl_cfg_vld(rising_edge_pl_cfg_vld),
    .o_adapter_is_full(adapter_is_full)
);

// Test stimulus
initial begin
    // Initialize
    clk = 0;
    rst_n = 0;
    tx_fifo_read_en = 0;
    lp_cfg_crd = 0;
    rising_edge_pl_cfg_vld = 0;
    error_count = 0;
    test_num = 0;
    
    // Reset sequence
    #20;
    rst_n = 1;
    #10;
    
    // Test 1: Basic credit notification
    test_num = 1;
    $display("Test %0d: Verify credit notification", test_num);
    repeat(4) begin
        tx_fifo_read_en = 1;
        #10;
        tx_fifo_read_en = 0;
        #20;
    end
    if (pl_cfg_crd !== 1'b1) begin
        $error("Test %0d failed: Expected pl_cfg_crd high", test_num);
        error_count++;
    end
    
    // Test 2: Credit consumption
    test_num = 2;
    $display("Test %0d: Verify credit consumption", test_num);
    // Generate some credits first
    lp_cfg_crd = 1;
    #10;
    lp_cfg_crd = 0;
    #10;
    
    // Consume credits
    repeat(3) begin
        rising_edge_pl_cfg_vld = 1;
        #10;
        rising_edge_pl_cfg_vld = 0;
        #20;
    end
    
    // Test 3: Adapter full condition
    test_num = 3;
    $display("Test %0d: Verify adapter full condition", test_num);
    // Drain all credits
    while (!adapter_is_full) begin
        rising_edge_pl_cfg_vld = 1;
        #10;
        rising_edge_pl_cfg_vld = 0;
        #10;
    end
    if (adapter_is_full !== 1'b1) begin
        $error("Test %0d failed: Expected adapter_is_full high", test_num);
        error_count++;
    end
    
    // Test 4: Concurrent operations
    test_num = 4;
    $display("Test %0d: Verify concurrent credit operations", test_num);
    fork
        // Credit generation thread
        begin
            repeat(10) begin
                tx_fifo_read_en = 1;
                #10;
                tx_fifo_read_en = 0;
                #30;
            end
        end
        
        // Credit consumption thread
        begin
            repeat(5) begin
                rising_edge_pl_cfg_vld = 1;
                #10;
                rising_edge_pl_cfg_vld = 0;
                #50;
            end
        end
        
        // LP credit thread
        begin
            #100;
            lp_cfg_crd = 1;
            #10;
            lp_cfg_crd = 0;
        end
    join
    
    // Summary
    if (error_count == 0)
        $display("All tests PASSED");
    else
        $display("%0d tests FAILED", error_count);
    
    $stop;
end

// Monitoring
always @(posedge clk) begin
    $display("Time=%0t: credits=%0d, pl_cfg_crd=%b, full=%b", 
             $time, dut.credit_counter_inst.adapter_avaliable_credits, 
             pl_cfg_crd, adapter_is_full);
end

// Assertions
always @(posedge clk) begin
    // Check credit counter never goes negative
    if (dut.credit_counter_inst.adapter_avaliable_credits > 6'd32) begin
        $error("Credit counter overflow detected");
        error_count++;
    end
    
    // Check credit pulse width
    if (pl_cfg_crd && !$past(pl_cfg_crd)) begin
        #1; // Check it's still high after 1ns
        if (!pl_cfg_crd) begin
            $error("pl_cfg_crd pulse too short");
            error_count++;
        end
    end
end

endmodule