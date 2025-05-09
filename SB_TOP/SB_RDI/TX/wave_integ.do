onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/i_clk
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/i_rst_n
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/i_lp_cfg_vld
add wave -noupdate -expand -group {RDI ENCODER} -radix hexadecimal /TB_SB_RDI_ENCODER/dut/i_lp_cfg
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/i_msg_no
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/i_msg_valid
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/i_adapter_is_waked_up
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/i_fifo_full
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/o_pl_nerror
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/o_msg_done
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/o_wake_adapter
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/o_fifo_data
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/dut/o_fifo_write_en
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/CS_tb
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/NS_tb
add wave -noupdate -expand -group {RDI ENCODER} /TB_SB_RDI_ENCODER/decoded_message
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/i_clk
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/i_rst_n
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/i_write_enable
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/i_read_enable
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/i_data_in
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/o_data_out
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/o_empty
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/o_dont_send_zeros
add wave -noupdate -group FIFO -radix unsigned /TB_SB_RDI_ENCODER/tx_fifo_dut/write_count
add wave -noupdate -group FIFO -radix unsigned /TB_SB_RDI_ENCODER/tx_fifo_dut/read_count
add wave -noupdate -group FIFO /TB_SB_RDI_ENCODER/tx_fifo_dut/memory
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/i_clk
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/i_rst_n
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/i_ser_done
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/i_empty
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/i_packet_finished
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/i_read_enable_sampled
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/i_dont_send_zeros
add wave -noupdate -group FSM -color Magenta /TB_SB_RDI_ENCODER/fsm_model/o_read_enable
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/tx_fifo_dut/o_ser_done_sampled
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/o_clk_en
add wave -noupdate -group FSM /TB_SB_RDI_ENCODER/fsm_model/cs
add wave -noupdate -group CLK_CONTROLLER /TB_SB_RDI_ENCODER/clock_controller_dut/i_pll_clk
add wave -noupdate -group CLK_CONTROLLER /TB_SB_RDI_ENCODER/clock_controller_dut/i_rst_n
add wave -noupdate -group CLK_CONTROLLER /TB_SB_RDI_ENCODER/clock_controller_dut/i_enable
add wave -noupdate -group CLK_CONTROLLER /TB_SB_RDI_ENCODER/clock_controller_dut/o_pack_finished
add wave -noupdate -group CLK_CONTROLLER /TB_SB_RDI_ENCODER/clock_controller_dut/o_ser_done
add wave -noupdate -group CLK_CONTROLLER /TB_SB_RDI_ENCODER/clock_controller_dut/TXCKSB
add wave -noupdate -group SERIALIZER /TB_SB_RDI_ENCODER/SB_TX_SERIALIZER_inst/i_pll_clk
add wave -noupdate -group SERIALIZER /TB_SB_RDI_ENCODER/SB_TX_SERIALIZER_inst/i_rst_n
add wave -noupdate -group SERIALIZER -radix hexadecimal /TB_SB_RDI_ENCODER/SB_TX_SERIALIZER_inst/i_data_in
add wave -noupdate -group SERIALIZER /TB_SB_RDI_ENCODER/SB_TX_SERIALIZER_inst/i_enable
add wave -noupdate -group SERIALIZER /TB_SB_RDI_ENCODER/SB_TX_SERIALIZER_inst/i_pack_finished
add wave -noupdate -group SERIALIZER /TB_SB_RDI_ENCODER/clock_controller_dut/TXCKSB
add wave -noupdate -group SERIALIZER /TB_SB_RDI_ENCODER/SB_TX_SERIALIZER_inst/TXDATASB
add wave -noupdate -group {CREDIT LOOP} /TB_SB_RDI_ENCODER/credit_loop_controller_inst/i_clk
add wave -noupdate -group {CREDIT LOOP} /TB_SB_RDI_ENCODER/credit_loop_controller_inst/i_rst_n
add wave -noupdate -group {CREDIT LOOP} /TB_SB_RDI_ENCODER/credit_loop_controller_inst/i_tx_fifo_read_en
add wave -noupdate -group {CREDIT LOOP} -color Yellow /TB_SB_RDI_ENCODER/credit_loop_controller_inst/o_pl_cfg_crd
add wave -noupdate -group {CREDIT LOOP} /TB_SB_RDI_ENCODER/credit_loop_controller_inst/o_adapter_is_full
add wave -noupdate -group {CREDIT LOOP} -radix binary /TB_SB_RDI_ENCODER/credit_loop_controller_inst/credit_notifier_inst/i_srcid
add wave -noupdate -group {CREDIT LOOP} /TB_SB_RDI_ENCODER/credit_loop_controller_inst/credit_notifier_inst/CS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {162000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
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
WaveRestoreZoom {0 ps} {640896 ps}
