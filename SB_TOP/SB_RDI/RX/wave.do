onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/i_clk
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/i_rst_n
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/i_adapter_is_full
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/i_clk_is_ungated
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/i_adapter_is_waked_up
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/i_deser_done
add wave -noupdate -expand -group DECODER -radix binary /TB_SB_RDI_DECODER/i_deser_data
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/i_deser_data
add wave -noupdate -expand -group DECODER -color Blue /TB_SB_RDI_DECODER/o_pl_cfg
add wave -noupdate -expand -group DECODER -color Blue /TB_SB_RDI_DECODER/o_pl_cfg_vld
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/o_pl_nerror
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/o_wake_adapter
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/o_msg_valid
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/o_msg_no
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/decoded_message
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/dut/fifo_wr_en
add wave -noupdate -expand -group DECODER -color Magenta /TB_SB_RDI_DECODER/dut/fifo_rd_en
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/dut/fifo_empty
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/dut/fifo_full
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/CS_tb
add wave -noupdate -expand -group DECODER /TB_SB_RDI_DECODER/NS_tb
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/i_clk
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/i_rst_n
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/i_write_enable
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/i_read_enable
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/i_data_in
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/o_data_out
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/o_empty
add wave -noupdate -group FIFO /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/o_full
add wave -noupdate -group FIFO -expand /TB_SB_RDI_DECODER/dut/SB_RDI_RX_FIFO/memory
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1905529 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 215
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
WaveRestoreZoom {1741885 ps} {2086430 ps}
