#process for getting script file directory
variable dispScriptFile [file normalize [info script]]
proc getScriptDirectory {} {
    variable dispScriptFile
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

#change working directory to script file directory
cd [getScriptDirectory]
#set result directory
set resultDir .\/result
#set ip_repo_path to script dir
set ip_repo_path [getScriptDirectory]

#redifine resultDir HERE if needed
#set resutDir C:\/User\/result

file mkdir $resultDir


# CONNECT SYSTEM
create_project NumberClassificator $resultDir  -part xc7z010clg400-1 -force
set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]
create_bd_design "number_classificator"
update_compile_order -fileset sources_1
#add ip-s to main repo
set_property  ip_repo_paths  $ip_repo_path [current_project]
update_ip_catalog
#add zynq
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
#set clock freq to 17MHz
startgroup
set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {17}] [get_bd_cells processing_system7_0]
endgroup
#add AXI_HP
startgroup
set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0 {1} CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64}] [get_bd_cells processing_system7_0]
endgroup
#add interrupt port
startgroup
set_property -dict [list CONFIG.PCW_USE_FABRIC_INTERRUPT {1} CONFIG.PCW_IRQ_F2P_INTR {1}] [get_bd_cells processing_system7_0]
endgroup
#add uart
startgroup
set_property -dict [list CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} CONFIG.PCW_UART1_GRP_FULL_ENABLE {1}] [get_bd_cells processing_system7_0]
endgroup
startgroup
set_property -dict [list CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1}] [get_bd_cells processing_system7_0]
set_property -dict [list CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {1} CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1}] [get_bd_cells processing_system7_0]
endgroup

#creating bram controler
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0
endgroup
set_property -dict [list CONFIG.SINGLE_PORT_BRAM {1}] [get_bd_cells axi_bram_ctrl_0]
#create bram generator and set it to be true dual port
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0
endgroup
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Use_RSTB_Pin {true} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_bd_cells blk_mem_gen_0]
#connect bram controler to bram generetaror
apply_bd_automation -rule xilinx.com:bd_rule:bram_cntlr -config {BRAM "Auto" }  [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA]
#connect zynq to bram controler
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
#add deskew
startgroup
create_bd_cell -type ip -vlnv FTN:user:Deskew:1.0 Deskew_0
endgroup
#connecting zynq with deskew
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" intc_ip "/axi_smc" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins Deskew_0/S00_AXI]
#connecting bram gen with deskew
connect_bd_net [get_bd_pins Deskew_0/address] [get_bd_pins blk_mem_gen_0/addrb]
connect_bd_net [get_bd_pins Deskew_0/out_data] [get_bd_pins blk_mem_gen_0/dinb]
connect_bd_net [get_bd_pins Deskew_0/en] [get_bd_pins blk_mem_gen_0/enb]
connect_bd_net [get_bd_pins Deskew_0/we] [get_bd_pins blk_mem_gen_0/web]
connect_bd_net [get_bd_pins Deskew_0/in_data] [get_bd_pins blk_mem_gen_0/doutb]
connect_bd_net [get_bd_pins blk_mem_gen_0/clkb] [get_bd_pins processing_system7_0/FCLK_CLK0]
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0
endgroup
set_property -dict [list CONFIG.CONST_VAL {0}] [get_bd_cells xlconstant_0]
connect_bd_net [get_bd_pins xlconstant_0/dout] [get_bd_pins blk_mem_gen_0/rstb]
#create concat and connect deskew interrupt to it
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0
endgroup
set_property -dict [list CONFIG.NUM_PORTS {3}] [get_bd_cells xlconcat_0]
connect_bd_net [get_bd_pins Deskew_0/done_interrupt] [get_bd_pins xlconcat_0/In0]
connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]

regenerate_bd_layout

#adding DMA and running connection automation
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0
endgroup
set_property -dict [list CONFIG.c_include_sg {0} CONFIG.c_sg_include_stscntrl_strm {0} CONFIG.c_include_s2mm {0}] [get_bd_cells axi_dma_0]
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/axi_dma_0/M_AXI_MM2S" intc_ip "Auto" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" intc_ip "/axi_smc" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
endgroup
connect_bd_net [get_bd_pins axi_dma_0/mm2s_introut] [get_bd_pins xlconcat_0/In1]
#adding fifo and running connection automation
startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_0
endgroup
connect_bd_intf_net [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins axis_data_fifo_0/S_AXIS]
update_compile_order -fileset sources_1
connect_bd_net [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins rst_ps7_0_16M/interconnect_aresetn]
connect_bd_net [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins processing_system7_0/FCLK_CLK0]

#adding SVM ip, running connection automation and connecting it to fifo
startgroup
create_bd_cell -type ip -vlnv FTN:user:SVM_IP:1.0 SVM_IP_0
endgroup
connect_bd_intf_net [get_bd_intf_pins axis_data_fifo_0/M_AXIS] [get_bd_intf_pins SVM_IP_0/S_AXIS]
startgroup
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {Master "/processing_system7_0/M_AXI_GP0" intc_ip "/axi_smc" Clk_xbar "Auto" Clk_master "Auto" Clk_slave "Auto" }  [get_bd_intf_pins SVM_IP_0/S_AXI]
apply_bd_automation -rule xilinx.com:bd_rule:clkrst -config {Clk "/processing_system7_0/FCLK_CLK0 (16 MHz)" }  [get_bd_pins SVM_IP_0/s_axis_aclk]
endgroup
connect_bd_net [get_bd_pins xlconcat_0/In2] [get_bd_pins SVM_IP_0/interrupt]
#validating design
validate_bd_design
#Creating hdl wrapper
make_wrapper -files [get_files $resultDir/NumberClassificator.srcs/sources_1/bd/number_classificator/number_classificator.bd] -top
add_files -norecurse $resultDir/NumberClassificator.srcs/sources_1/bd/number_classificator/hdl/number_classificator_wrapper.v
#running synthesis and implementation
launch_runs impl_1 -to_step write_bitstream -jobs 4

#exporting hardware
wait_on_run impl_1
update_compile_order -fileset sources_1
file mkdir $resultDir/NumberClassificator.sdk
file copy -force $resultDir/NumberClassificator.runs/impl_1/number_classificator_wrapper.sysdef $resultDir/NumberClassificator.sdk/number_classificator_wrapper.hdf
