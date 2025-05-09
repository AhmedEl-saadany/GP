onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /RDI_CONTROLLER_TB/lclk
add wave -noupdate /RDI_CONTROLLER_TB/i_clk_for_rdi_controller
add wave -noupdate /RDI_CONTROLLER_TB/sys_rst
add wave -noupdate /RDI_CONTROLLER_TB/for_scenarios_testing
add wave -noupdate /RDI_CONTROLLER_TB/test_nop_To_active_scenarios
add wave -noupdate /RDI_CONTROLLER_TB/test_nop_To_linkerror_scenarios
add wave -noupdate /RDI_CONTROLLER_TB/test_nop_To_linkreset_scenarios
add wave -noupdate /RDI_CONTROLLER_TB/test_nop_to_disable_scenarios
add wave -noupdate /RDI_CONTROLLER_TB/i_lp_linkerror
add wave -noupdate /RDI_CONTROLLER_TB/test_retrain_scenarios
add wave -noupdate -radix hexadecimal /RDI_CONTROLLER_TB/i_lp_state_req
add wave -noupdate -group RX_SB /RDI_CONTROLLER_TB/i_rx_sb_message
add wave -noupdate -group RX_SB /RDI_CONTROLLER_TB/i_rx_msg_valid
add wave -noupdate -group RX_SB /RDI_CONTROLLER_TB/i_rx_done_send_message
add wave -noupdate -group RX_SB /RDI_CONTROLLER_TB/message_type_rx_bring_up
add wave -noupdate -group TX_SB /RDI_CONTROLLER_TB/o_tx_sb_message
add wave -noupdate -group TX_SB /RDI_CONTROLLER_TB/o_tx_msg_valid
add wave -noupdate -group TX_SB /RDI_CONTROLLER_TB/message_type_tx_bring_up
add wave -noupdate -group FROM_LTSM /RDI_CONTROLLER_TB/i_reset_only_from_ltsm
add wave -noupdate -group FROM_LTSM /RDI_CONTROLLER_TB/i_pl_error_from_ltsm
add wave -noupdate -group FROM_LTSM /RDI_CONTROLLER_TB/i_pl_inband_pres_from_ltsm
add wave -noupdate -group FROM_LTSM /RDI_CONTROLLER_TB/i_pl_train_error_from_ltsm
add wave -noupdate -group FROM_LTSM /RDI_CONTROLLER_TB/i_pl_link_speed_from_ltsm
add wave -noupdate -group GO_LTSM /RDI_CONTROLLER_TB/o_go_to_l1_from_rdi_to_ltsm
add wave -noupdate -group GO_LTSM /RDI_CONTROLLER_TB/o_go_to_l2_from_rdi_to_ltsm
add wave -noupdate -group GO_LTSM /RDI_CONTROLLER_TB/o_go_to_active_from_rdi_to_ltsm
add wave -noupdate -group GO_LTSM /RDI_CONTROLLER_TB/o_go_to_training_from_rdi_to_ltsm
add wave -noupdate -group GO_LTSM /RDI_CONTROLLER_TB/o_go_to_linkerror_from_rdi_to_ltsm
add wave -noupdate -group GO_LTSM /RDI_CONTROLLER_TB/o_go_to_retrain_from_rdi_to_ltsm
add wave -noupdate -group WAKE_BLOCK /RDI_CONTROLLER_TB/i_ltsm_is_waked_up
add wave -noupdate -group WAKE_BLOCK /RDI_CONTROLLER_TB/o_clk_gate_en
add wave -noupdate -group WAKE_BLOCK /RDI_CONTROLLER_TB/o_pl_wake_ack
add wave -noupdate -group WAKE_BLOCK /RDI_CONTROLLER_TB/i_lp_wake_req
add wave -noupdate -group STALL_BLOCK /RDI_CONTROLLER_TB/o_start_stall_hand
add wave -noupdate -group STALL_BLOCK /RDI_CONTROLLER_TB/i_lp_stallack
add wave -noupdate -group STALL_BLOCK /RDI_CONTROLLER_TB/i_stall_done
add wave -noupdate -group STALL_BLOCK /RDI_CONTROLLER_TB/o_pl_stallreq
add wave -noupdate -group CLK_BLOCK /RDI_CONTROLLER_TB/o_start_clk_hand
add wave -noupdate -group CLK_BLOCK /RDI_CONTROLLER_TB/i_clk_done
add wave -noupdate -group CLK_BLOCK /RDI_CONTROLLER_TB/i_lp_clk_ack
add wave -noupdate -group CLK_BLOCK /RDI_CONTROLLER_TB/o_pl_clk_req
add wave -noupdate -expand -group BRING_UP_BLOCK /RDI_CONTROLLER_TB/i_bring_up_done
add wave -noupdate -expand -group BRING_UP_BLOCK /RDI_CONTROLLER_TB/o_rdi_controller_choosen_bring_up
add wave -noupdate -expand -group BRING_UP_BLOCK /RDI_CONTROLLER_TB/i_bring_up_pm_entry_done
add wave -noupdate /RDI_CONTROLLER_TB/i_pmnack_from_pm_entry
add wave -noupdate /RDI_CONTROLLER_TB/o_pl_state_sts
add wave -noupdate -group TIMER /RDI_CONTROLLER_TB/o_start_linkerror_timer
add wave -noupdate -group TIMER /RDI_CONTROLLER_TB/rdi_timer_controller_inst/linkerror_counter
add wave -noupdate -group TIMER /RDI_CONTROLLER_TB/i_linkerror_timeout
add wave -noupdate /RDI_CONTROLLER_TB/o_exit_from_l1
add wave -noupdate /RDI_CONTROLLER_TB/o_exit_from_l2
add wave -noupdate /RDI_CONTROLLER_TB/i_pm_timer_start
add wave -noupdate /RDI_CONTROLLER_TB/o_pl_trdy
add wave -noupdate /RDI_CONTROLLER_TB/i_lp_wake_req_delayed2
add wave -noupdate /RDI_CONTROLLER_TB/current_state
add wave -noupdate /RDI_CONTROLLER_TB/next_state
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/CS
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/NS
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/i_rdi_controller_choosen_bring_up
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/i_rx_busy_from_TX
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/i_rx_done_send_message
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/i_rx_msg_valid
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/i_rx_sb_message
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/IDLE
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/lclk
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/o_General_Bring_Up_done_RX
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/o_tx_msg_valid
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/o_tx_sb_message
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/sys_rst
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/transition_to_CHECK_REQ_MESSG
add wave -noupdate -group RX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/transition_to_RESP_SEND
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/i_rdi_controller_choosen_bring_up
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/i_rx_busy_from_RX
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/i_rx_done_send_message
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/i_rx_msg_valid
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/i_rx_sb_message
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/IDLE
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/lclk
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/o_General_Bring_Up_done_TX
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/o_tx_msg_valid
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/o_tx_sb_message
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/REQ_SEND
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/RETRAIN_REQ
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/RETRAIN_RSP
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/sys_rst
add wave -noupdate -group TX_BRING_UP /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/tx_inst/transition_to_DONE
add wave -noupdate /RDI_CONTROLLER_TB/current_state_tx_bring_up
add wave -noupdate /RDI_CONTROLLER_TB/next_state_tx_bring_up
add wave -noupdate /RDI_CONTROLLER_TB/current_state_rx_bring_up
add wave -noupdate /RDI_CONTROLLER_TB/next_state_rx_bring_up
add wave -noupdate /RDI_CONTROLLER_TB/i_reset_pin_or_soft_ware_clear_error
add wave -noupdate /RDI_CONTROLLER_TB/uut/stall_start
add wave -noupdate /RDI_CONTROLLER_TB/general_bring_up_wrapper_inst/rx_inst/repeat_to_check_Req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {55394 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 240
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
configure wave -timelineunits ns
update
WaveRestoreZoom {51719 ns} {56936 ns}
