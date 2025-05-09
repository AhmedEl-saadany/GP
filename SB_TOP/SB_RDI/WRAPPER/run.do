vlib work
vlog ./*.v
vlog ./*.sv
vlog ../RX/*.v 
vlog ../TX/*.v 
vlog ../credit_loop_control/*.v
vlog ../../../SB_MB/SIDEBAND_TX/SB_TX_FIFO.sv
vlog ../../../SB_MB/SIDEBAND_TX/SB_TX_FSM_Modelling.sv 
vlog ../../../SB_MB/SIDEBAND_TX/SB_CLK_CONTROLLER.sv 
vlog ../../../SB_MB/ANALOG_MODELLING/*.sv
vsim -voptargs=+acc TB_SB_RDI_WRAPPER
do wave_integ.do
run -all 

 

 