onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/dut/i_clk
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/dut/i_rst_n
add wave -noupdate -group ENCODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/dut/i_lp_cfg_vld
add wave -noupdate -group ENCODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/dut/i_lp_cfg
add wave -noupdate -group ENCODER -expand -group ADAPTER_MSGS -radix binary /TB_SB_RDI_WRAPPER/dut/i_lp_cfg
add wave -noupdate -group ENCODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/dut/o_pl_nerror
add wave -noupdate -group ENCODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/dut/i_adapter_is_waked_up
add wave -noupdate -group ENCODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/dut/o_wake_adapter
add wave -noupdate -group ENCODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/dut/i_msg_no
add wave -noupdate -group ENCODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/dut/i_msg_valid
add wave -noupdate -group ENCODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/dut/o_msg_done
add wave -noupdate -group ENCODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/encoded_message
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/dut/i_fifo_full
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/dut/o_fifo_data
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/dut/o_fifo_write_en
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/dut/o_delete_data
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/CS_encoder
add wave -noupdate -group ENCODER /TB_SB_RDI_WRAPPER/NS_encoder
add wave -noupdate -group SERIALIZER /TB_SB_RDI_WRAPPER/SB_TX_SERIALIZER_inst/i_pll_clk
add wave -noupdate -group SERIALIZER /TB_SB_RDI_WRAPPER/SB_TX_SERIALIZER_inst/i_rst_n
add wave -noupdate -group SERIALIZER /TB_SB_RDI_WRAPPER/SB_TX_SERIALIZER_inst/i_data_in
add wave -noupdate -group SERIALIZER /TB_SB_RDI_WRAPPER/SB_TX_SERIALIZER_inst/i_enable
add wave -noupdate -group SERIALIZER /TB_SB_RDI_WRAPPER/SB_TX_SERIALIZER_inst/i_pack_finished
add wave -noupdate -group SERIALIZER /TB_SB_RDI_WRAPPER/clock_controller_dut/TXCKSB
add wave -noupdate -group SERIALIZER /TB_SB_RDI_WRAPPER/SB_TX_SERIALIZER_inst/TXDATASB
add wave -noupdate -group DESERIALIZER /TB_SB_RDI_WRAPPER/SB_RX_DESER_inst/i_clk
add wave -noupdate -group DESERIALIZER /TB_SB_RDI_WRAPPER/SB_RX_DESER_inst/i_clk_pll
add wave -noupdate -group DESERIALIZER /TB_SB_RDI_WRAPPER/SB_RX_DESER_inst/i_rst_n
add wave -noupdate -group DESERIALIZER /TB_SB_RDI_WRAPPER/SB_RX_DESER_inst/ser_data_in
add wave -noupdate -group DESERIALIZER /TB_SB_RDI_WRAPPER/SB_RX_DESER_inst/i_de_ser_done_sampled
add wave -noupdate -group DESERIALIZER /TB_SB_RDI_WRAPPER/SB_RX_DESER_inst/par_data_out
add wave -noupdate -group DESERIALIZER /TB_SB_RDI_WRAPPER/SB_RX_DESER_inst/de_ser_done
add wave -noupdate -expand -group DECODER /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/i_clk
add wave -noupdate -expand -group DECODER /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/i_rst_n
add wave -noupdate -expand -group DECODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/i_adapter_is_full
add wave -noupdate -expand -group DECODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/o_pl_cfg
add wave -noupdate -expand -group DECODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/o_pl_cfg_vld
add wave -noupdate -expand -group DECODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/o_pl_nerror
add wave -noupdate -expand -group DECODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/o_wake_adapter
add wave -noupdate -expand -group DECODER -expand -group ADAPTER_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/i_adapter_is_waked_up
add wave -noupdate -expand -group DECODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/i_clk_is_ungated
add wave -noupdate -expand -group DECODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/o_msg_valid
add wave -noupdate -expand -group DECODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/o_msg_no
add wave -noupdate -expand -group DECODER -group RDI_MSGS /TB_SB_RDI_WRAPPER/decoded_message
add wave -noupdate -expand -group DECODER -expand -group DESER /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/i_deser_done
add wave -noupdate -expand -group DECODER -expand -group DESER -radix hexadecimal /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/i_deser_data
add wave -noupdate -expand -group DECODER -expand -group DESER /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/o_deser_done_sampled
add wave -noupdate -expand -group DECODER /TB_SB_RDI_WRAPPER/CS_decoder
add wave -noupdate -expand -group DECODER /TB_SB_RDI_WRAPPER/NS_decoder
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/i_clk
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/i_rst_n
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER -expand -group NOTIFIER /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/i_tx_fifo_read_en
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER -expand -group NOTIFIER -radix binary /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/i_srcid
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER -expand -group NOTIFIER -color Yellow /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/o_pl_cfg_crd
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER -group COUNTER /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/i_rising_edge_pl_cfg_vld
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER -group COUNTER -radix unsigned /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/credit_counter_inst/adapter_avaliable_credits
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER -group COUNTER /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/o_adapter_is_full
add wave -noupdate -expand -group CREDIT_LOOP_CONTROLLER /TB_SB_RDI_WRAPPER/credit_loop_controller_inst/credit_notifier_inst/CS
add wave -noupdate -group DECODER_FIFO /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/i_clk
add wave -noupdate -group DECODER_FIFO /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/i_rst_n
add wave -noupdate -group DECODER_FIFO /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/i_write_enable
add wave -noupdate -group DECODER_FIFO /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/i_read_enable
add wave -noupdate -group DECODER_FIFO /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/i_data_in
add wave -noupdate -group DECODER_FIFO -radix binary /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/o_data_out
add wave -noupdate -group DECODER_FIFO /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/o_empty
add wave -noupdate -group DECODER_FIFO /TB_SB_RDI_WRAPPER/SB_RDI_DECODER_inst/SB_RDI_RX_FIFO/o_full
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3112151 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 196
configure wave -valuecolwidth 100
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
WaveRestoreZoom {2227448 ps} {4679928 ps}
