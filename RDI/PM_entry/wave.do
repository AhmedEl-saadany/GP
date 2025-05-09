onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/dut1/i_clk
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/dut1/i_en
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/dut1/i_clk_div_ratio
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/dut1/i_req_L1_or_L2
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/dut1/i_msg_valid
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/i_msg_no_1_string
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/dut1/i_msg_done
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/dut1/o_msg_valid
add wave -noupdate -expand -group PM_1 /tb_PM_entry_wrapper/o_msg_no_1_string
add wave -noupdate -expand -group PM_1 -color Magenta /tb_PM_entry_wrapper/dut1/o_test_done
add wave -noupdate -expand -group PM_1 -color Magenta /tb_PM_entry_wrapper/dut1/o_pm_nak
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/IDLE
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/WAIT_FOR_RX_TO_RESP
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/SEND_PM_REQ
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/TEST_FINISHED
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_clk
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_rst_n
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_rx_msg_valid
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_en
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_req_L1_or_L2
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_clk_div_ratio
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_msg_done
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_msg_valid
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/i_msg_no
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/o_msg_valid
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/o_msg_no
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/o_test_done
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/o_pm_nak
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/CS
add wave -noupdate -expand -group PM_1 -group TX /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/NS
add wave -noupdate -expand -group PM_1 -group TX -radix unsigned /tb_PM_entry_wrapper/dut1/pm_entry_tx_inst/counter_2microsec
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/IDLE
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/WAIT_FOR_PM_REQ
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/SEND_PM_RESP
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/TEST_FINISHED
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_clk
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_rst_n
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_en
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_force_exit
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_req_L1_or_L2
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_clk_div_ratio
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_msg_done
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_msg_valid
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/i_msg_no
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/o_msg_valid
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/o_msg_no
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/o_test_done
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/CS
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/NS
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/counter_1microsec
add wave -noupdate -expand -group PM_1 -group RX /tb_PM_entry_wrapper/dut1/pm_entry_rx_inst/start_count
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/dut2/i_clk
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/dut2/i_en
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/dut2/i_clk_div_ratio
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/dut2/i_req_L1_or_L2
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/dut2/i_msg_valid
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/i_msg_no_2_string
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/dut2/i_msg_done
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/dut2/o_msg_valid
add wave -noupdate -group PM_2 /tb_PM_entry_wrapper/o_msg_no_2_string
add wave -noupdate -group PM_2 -color Magenta /tb_PM_entry_wrapper/dut2/o_test_done
add wave -noupdate -group PM_2 -color Magenta /tb_PM_entry_wrapper/dut2/o_pm_nak
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/IDLE
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/WAIT_FOR_RX_TO_RESP
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/SEND_PM_REQ
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/TEST_FINISHED
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_clk
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_rst_n
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_rx_msg_valid
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_en
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_req_L1_or_L2
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_clk_div_ratio
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_msg_done
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_msg_valid
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/i_msg_no
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/o_msg_valid
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/o_msg_no
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/o_test_done
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/o_pm_nak
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/CS
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/NS
add wave -noupdate -group PM_2 -group TX /tb_PM_entry_wrapper/dut2/pm_entry_tx_inst/counter_2microsec
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/IDLE
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/WAIT_FOR_PM_REQ
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/SEND_PM_RESP
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/TEST_FINISHED
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_clk
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_en
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_req_L1_or_L2
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_clk_div_ratio
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_msg_done
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_msg_valid
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_msg_no
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/o_msg_valid
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/o_msg_no
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/o_test_done
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/CS
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/NS
add wave -noupdate -group PM_2 -group RX -radix unsigned /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/counter_1microsec
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/start_count
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/IDLE
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/WAIT_FOR_PM_REQ
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/SEND_PM_RESP
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/TEST_FINISHED
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_clk
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_en
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_req_L1_or_L2
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_clk_div_ratio
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_msg_done
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_msg_valid
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/i_msg_no
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/o_msg_valid
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/o_msg_no
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/o_test_done
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/CS
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/NS
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/counter_1microsec
add wave -noupdate -group PM_2 -group RX /tb_PM_entry_wrapper/dut2/pm_entry_rx_inst/start_count
add wave -noupdate -group serializer_2 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_2/i_pll_clk
add wave -noupdate -group serializer_2 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_2/i_rst_n
add wave -noupdate -group serializer_2 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_2/i_data_in
add wave -noupdate -group serializer_2 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_2/i_enable
add wave -noupdate -group serializer_2 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_2/i_pack_finished
add wave -noupdate -group serializer_2 /tb_PM_entry_wrapper/clock_controller_2/TXCKSB
add wave -noupdate -group serializer_2 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_2/TXDATASB
add wave -noupdate -group encoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_ENCODER_inst/i_clk
add wave -noupdate -group encoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_ENCODER_inst/i_rst_n
add wave -noupdate -group encoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_ENCODER_inst/i_msg_no
add wave -noupdate -group encoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_ENCODER_inst/i_msg_valid
add wave -noupdate -group encoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_ENCODER_inst/o_msg_done
add wave -noupdate -group encoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_ENCODER_inst/o_fifo_data
add wave -noupdate -group encoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_ENCODER_inst/o_fifo_write_en
add wave -noupdate -group serializer_1 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_1/i_pll_clk
add wave -noupdate -group serializer_1 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_1/i_rst_n
add wave -noupdate -group serializer_1 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_1/i_data_in
add wave -noupdate -group serializer_1 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_1/i_enable
add wave -noupdate -group serializer_1 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_1/i_pack_finished
add wave -noupdate -group serializer_1 /tb_PM_entry_wrapper/clock_controller_1/TXCKSB
add wave -noupdate -group serializer_1 /tb_PM_entry_wrapper/SB_TX_SERIALIZER_1/TXDATASB
add wave -noupdate -group deserializer_2 /tb_PM_entry_wrapper/SB_RX_DESER_2/i_clk
add wave -noupdate -group deserializer_2 /tb_PM_entry_wrapper/SB_RX_DESER_2/i_clk_pll
add wave -noupdate -group deserializer_2 /tb_PM_entry_wrapper/SB_RX_DESER_2/i_rst_n
add wave -noupdate -group deserializer_2 /tb_PM_entry_wrapper/SB_RX_DESER_2/ser_data_in
add wave -noupdate -group deserializer_2 /tb_PM_entry_wrapper/SB_RX_DESER_2/i_de_ser_done_sampled
add wave -noupdate -group deserializer_2 /tb_PM_entry_wrapper/SB_RX_DESER_2/par_data_out
add wave -noupdate -group deserializer_2 /tb_PM_entry_wrapper/SB_RX_DESER_2/de_ser_done
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/IDLE
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/FIFO_READ
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/DECODING
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/RDI_MSG
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/ADAPTER_MSG
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/ERROR_REPORT
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/MSG_WITHOUT_DATA
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/MSG_WITH_DATA
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/i_clk
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/i_rst_n
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/i_adapter_is_full
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/i_clk_is_ungated
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/i_adapter_is_waked_up
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/i_deser_done
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/i_deser_data
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/o_rising_edge_pl_cfg_vld
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/o_deser_done_sampled
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/o_msg_valid
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/o_msg_no
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/CS
add wave -noupdate -group decoder_2 /tb_PM_entry_wrapper/sb_rdi_wrapper_2/SB_RDI_DECODER_inst/NS
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/IDLE
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/FIFO_READ
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/DECODING
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/RDI_MSG
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/ADAPTER_MSG
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/ERROR_REPORT
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/MSG_WITHOUT_DATA
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/MSG_WITH_DATA
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/i_clk
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/i_rst_n
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/i_adapter_is_full
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/i_clk_is_ungated
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/i_deser_done
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/i_deser_data
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/o_msg_valid
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/o_msg_no
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/CS
add wave -noupdate -group decoder_1 /tb_PM_entry_wrapper/sb_rdi_wrapper_1/SB_RDI_DECODER_inst/NS
add wave -noupdate -group deserializer_1 /tb_PM_entry_wrapper/SB_RX_DESER_1/i_clk
add wave -noupdate -group deserializer_1 /tb_PM_entry_wrapper/SB_RX_DESER_1/i_clk_pll
add wave -noupdate -group deserializer_1 /tb_PM_entry_wrapper/SB_RX_DESER_1/i_rst_n
add wave -noupdate -group deserializer_1 /tb_PM_entry_wrapper/SB_RX_DESER_1/ser_data_in
add wave -noupdate -group deserializer_1 /tb_PM_entry_wrapper/SB_RX_DESER_1/i_de_ser_done_sampled
add wave -noupdate -group deserializer_1 /tb_PM_entry_wrapper/SB_RX_DESER_1/par_data_out
add wave -noupdate -group deserializer_1 /tb_PM_entry_wrapper/SB_RX_DESER_1/de_ser_done
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/i_clk
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/i_rst_n
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/i_tx_fifo_read_en
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/i_srcid
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/i_fifo_data_is_zeros
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/i_lp_cfg_crd
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/i_rising_edge_pl_cfg_vld
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/o_pl_cfg_crd
add wave -noupdate -expand -group {credit loop} /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/o_adapter_is_full
add wave -noupdate -radix unsigned /tb_PM_entry_wrapper/sb_rdi_wrapper_2/credit_loop_controller_inst/credit_counter_inst/adapter_avaliable_credits
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {146000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 222
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {7039462 ps} {8216870 ps}
