onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/i_clk
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/i_rst_n
add wave -noupdate -expand -group SB_RDI_TX_ENCODER -expand -group RDI /TB_SB_RDI_ENCODER/i_msg_no
add wave -noupdate -expand -group SB_RDI_TX_ENCODER -expand -group RDI /TB_SB_RDI_ENCODER/i_msg_valid
add wave -noupdate -expand -group SB_RDI_TX_ENCODER -expand -group RDI /TB_SB_RDI_ENCODER/o_msg_done
add wave -noupdate -expand -group SB_RDI_TX_ENCODER -group Adapter /TB_SB_RDI_ENCODER/i_lp_cfg_vld
add wave -noupdate -expand -group SB_RDI_TX_ENCODER -group Adapter -radix hexadecimal /TB_SB_RDI_ENCODER/i_lp_cfg
add wave -noupdate -expand -group SB_RDI_TX_ENCODER -group Adapter -radix binary /TB_SB_RDI_ENCODER/i_lp_cfg
add wave -noupdate -expand -group SB_RDI_TX_ENCODER -group Adapter /TB_SB_RDI_ENCODER/o_pl_cerror
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/i_fifo_full
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/o_fifo_data
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/o_fifo_write_en
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/decoded_message
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/CS_tb
add wave -noupdate -expand -group SB_RDI_TX_ENCODER /TB_SB_RDI_ENCODER/NS_tb
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/i_clk
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/i_rst_n
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/i_write_enable
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/i_read_enable
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/i_data_in
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/o_data_out
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/o_empty
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/o_ser_done_sampled
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/o_full
add wave -noupdate -expand -group FIFO -expand /TB_SB_RDI_ENCODER/FIFO_inst/memory
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/write_count
add wave -noupdate -expand -group FIFO /TB_SB_RDI_ENCODER/FIFO_inst/read_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {145000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 95
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
WaveRestoreZoom {50656 ps} {239344 ps}
