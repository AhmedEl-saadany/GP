module SB_TX_WRAPPER (
	input 				i_clk,
	input 				i_rst_n,
	input               i_start_pattern_req,
	input               i_rdi_msg,
	input 				i_data_valid,
	input 				i_msg_valid,
	input 		[3:0] 	i_state,
	input 		[3:0] 	i_sub_state,
	input 		[3:0] 	i_msg_no,
	input       [2:0]   i_msg_info,
	input 		[15:0] 	i_data_bus,
	input               i_rx_sb_pattern_samp_done,
	input               i_rx_sb_rsp_delivered,
	//input               i_ser_done,
	input               i_stop_cnt,
	input 				i_tx_point_sweep_test_en,
	input 		[1:0]  	i_tx_point_sweep_test,
	input 		[1:0]	i_rdi_msg_code,
	input 		[3:0] 	i_rdi_msg_sub_code,
	input 		[1:0] 	i_rdi_msg_info,
	output reg          o_start_pattern_done,
	output reg          o_time_out,
	//output reg  [63:0]  o_tx_data_out,
	output reg          o_busy,
	output     			TXCKSB,           // Clock output
    output     			TXDATASB          // Data output
	);

	wire packet_valid; 
	wire start_count;  
	wire [63:0] framed_packet_phase;
	wire [61:0] header; 
	wire [63:0] data;   
	wire header_valid; 
	wire d_valid; 
	wire header_encoder_enable;
	wire data_encoder_enable;
	wire header_frame_enable;
	wire data_frame_enable;
	wire packet_enable;
	wire [63:0] tx_data_out;
	wire pattern_valid;

	wire divided_clk;            // Divided clock (100 MHz)
    wire pack_finished;
    wire ser_done;
    wire write_enable;
    wire [63:0] fifo_data;
    wire fifo_empty;
    wire ser_enable;
    wire fifo_full;
    wire last_pack;
    wire ser_done_sync;
    wire ser_done_sampled;
    wire clk_ser_enable;
    wire clk_ser_en;
    wire read_enable;

    assign write_enable = (packet_valid || pattern_valid);
    assign ser_enable = (~fifo_full);  // ser_done for the packet framing block
    assign clk_ser_enable = (~fifo_empty && ser_done);

    // Instantiate Clock Divider by 8
    Clock_Divider_by_8 clock_divider_dut (
        .i_pll_clk      (i_clk), //
        .i_rst_n        (i_rst_n), //
        .o_divided_clk  (divided_clk) //
    );

    // Instantiate SB_CLOCK_CONTROLLER
    SB_CLOCK_CONTROLLER clock_controller_dut (
        .i_pll_clk      (i_clk), //
        .i_rst_n        (i_rst_n), //
        .i_enable       (clk_ser_en), // needed from the fifo to indicate that there is packet in fifo
        .o_pack_finished(pack_finished), //
        .o_ser_done     (ser_done), //
        .last_pack      (last_pack),
        .i_ser_done_sampled(ser_done_sampled),
        .TXCKSB         (TXCKSB) //
    );

    SB_TX_FSM_Modelling fsm_model (
    	.i_rst_n          (i_rst_n),
    	.i_clk            (i_clk),
    	.i_ser_done       (ser_done),
    	.i_empty          (fifo_empty),
    	.i_packet_finished(pack_finished),
    	.i_read_enable_sampled(ser_done_sampled),
    	.o_read_enable    (read_enable),
    	.o_clk_en         (clk_ser_en)
    );

    // Instantiate SB_TX_SERIALIZER
    SB_TX_SERIALIZER tx_serializer_dut (
        .i_pll_clk		(i_clk), //
        .i_rst_n 		(i_rst_n), //
        .i_data_in 		(fifo_data), //
        .i_enable 		(clk_ser_en), //
        .i_pack_finished(pack_finished), //
        .last_pack      (last_pack),
        .TXDATASB 		(TXDATASB) //
    );

    // DF_SYNC #(
	// 	.WIDTH(1) ) 
	// ff_sync (
	// 	.clk       (divided_clk),
	// 	.rst_n     (i_rst_n),
	// 	.async_data(ser_done),
	// 	.sync_data (ser_done_sync)	
	// );

    SB_TX_FIFO tx_fifo_dut (
    	.i_clk         (divided_clk),
    	.i_rst_n       (i_rst_n),
    	.i_data_in     (tx_data_out), //
    	.i_write_enable(write_enable), //
    	.i_read_enable (read_enable), //
    	.o_data_out    (fifo_data), //
    	.o_empty       (fifo_empty), //
    	.o_ser_done_sampled(ser_done_sampled),
    	.o_full        (fifo_full) //
    );

	SB_PACKET_ENCODER_WRAPPER packet_encoder_dut (
		.i_clk                    (divided_clk),//
		.i_rst_n                  (i_rst_n),//
		.i_start_pattern_req      (i_start_pattern_req),//
		.i_rx_sb_pattern_samp_done(i_rx_sb_pattern_samp_done),//
		.i_rx_sb_rsp_delivered    (i_rx_sb_rsp_delivered),//
		.i_ser_done               (ser_enable),//
		.o_time_out               (o_time_out),//
		.o_start_pattern_done     (o_start_pattern_done),//
		.i_packet_valid           (packet_valid),//
		.i_timeout_ctr_start      (start_count), //
		.i_framed_packet_phase    (framed_packet_phase), //
		.o_final_packet           (tx_data_out), //
		.o_pattern_valid          (pattern_valid),
		.i_stop_cnt               (i_stop_cnt) //
	);

	SB_PACKET_FRAMING packet_framing_dut (
		.i_clk                (divided_clk), //
		.i_rst_n              (i_rst_n), //
		.i_ser_done           (ser_enable), //
		.i_header             (header), //
		.i_data               (data), //
		.i_header_valid       (header_frame_enable), //
		.i_d_valid            (data_frame_enable), //
		.o_framed_packet_phase(framed_packet_phase), //
		.o_timeout_ctr_start  (start_count), //
		.o_packet_valid       (packet_valid) //
	);

	SB_HEADER_ENCODER header_encoder_dut (
		.i_clk             (divided_clk), //
		.i_rst_n           (i_rst_n), //
		.i_rdi_msg         (i_rdi_msg), //
		.i_data_valid      (data_encoder_enable), //
		.i_msg_valid       (header_encoder_enable), //
		.i_state           (i_state), //
		.i_sub_state       (i_sub_state), //
		.i_msg_no          (i_msg_no), //
		.i_msg_info        (i_msg_info), //
		.o_header          (header), //
		.o_header_valid    (header_valid), //
		.i_rdi_msg_code          (i_rdi_msg_code), //
		.i_rdi_msg_info          (i_rdi_msg_info), //
		.i_rdi_msg_sub_code      (i_rdi_msg_sub_code), //
		.i_tx_point_sweep_test   (i_tx_point_sweep_test), //
		.i_tx_point_sweep_test_en(i_tx_point_sweep_test_en) //
	);

	SB_DATA_ENCODER data_encoder_dut (
		.i_clk         (divided_clk), //
		.i_rst_n       (i_rst_n), //
		.i_data_valid  (data_encoder_enable), //
		.i_msg_valid   (header_encoder_enable), //
		.i_state       (i_state), //
		.i_sub_state   (i_sub_state), //
		.i_msg_no      (i_msg_no), //
		.i_data_bus    (i_data_bus), //
		.o_data_encoded(data), //
		.o_d_valid     (d_valid), //
		.i_rdi_msg               (i_rdi_msg), //
		.i_tx_point_sweep_test   (i_tx_point_sweep_test), //
		.i_tx_point_sweep_test_en(i_tx_point_sweep_test_en) //
	);

	SB_FSM sb_fsm_dut (
		.i_clk                  (divided_clk), //
		.i_rst_n                (i_rst_n), //
		.i_msg_valid            (i_msg_valid), //
		.i_data_valid           (i_data_valid),
		.i_start_pattern_req    (i_start_pattern_req), //
		.i_rx_sb_rsp_delivered  (i_rx_sb_rsp_delivered), //
		.i_d_valid              (d_valid), //
		.i_header_valid         (header_valid), //
		.i_packet_valid         (packet_valid), //
		.i_start_pattern_done   (o_start_pattern_done), //
		.o_header_encoder_enable(header_encoder_enable), //
		.o_data_encoder_enable  (data_encoder_enable), //
		.o_header_frame_enable  (header_frame_enable), //
		.o_data_frame_enable    (data_frame_enable), //
		//.o_packet_enable        (packet_enable), //
		.o_busy                 (o_busy) //
		);

endmodule : SB_TX_WRAPPER
