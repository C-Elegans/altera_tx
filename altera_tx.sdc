## Generated SDC file "altera_tx.sdc"

## Copyright (C) 1991-2013 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 13.0.0 Build 156 04/24/2013 SJ Web Edition"

## DATE    "Sat Nov 25 16:07:24 2017"

##
## DEVICE  "EP4CE22F17C6"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {CLOCK_50} -period 20.000 -waveform { 0.000 10.000 } [get_ports { CLOCK_50 }]
create_clock -name {clk} -period 10.000 -waveform { 0.000 5.000 } [get_nets {pllinst|altpll_component|auto_generated|wire_pll1_clk[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -rise_to [get_clocks {CLOCK_50}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLOCK_50}] -fall_to [get_clocks {CLOCK_50}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -add_delay -max -clock [get_clocks {clk}]  5.000 [get_ports {MOSI}]
set_input_delay -add_delay -max -clock [get_clocks {clk}]  5.000 [get_ports {SCK}]
set_input_delay -add_delay -max -clock [get_clocks {clk}]  5.000 [get_ports {SSEL}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  10.000 [get_ports {SW[0]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  10.000 [get_ports {SW[1]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  10.000 [get_ports {SW[2]}]
set_input_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  10.000 [get_ports {SW[3]}]


#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[0]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[1]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[2]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[3]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[4]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[5]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[6]}]
set_output_delay -add_delay -max -clock [get_clocks {CLOCK_50}]  2.000 [get_ports {DAC_OUT[7]}]
set_output_delay -add_delay -max -clock [get_clocks {clk}]  2.000 [get_ports {MISO}]
set_output_delay -add_delay -min -clock [get_clocks {clk}]  0.000 [get_ports {MISO}]


#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

