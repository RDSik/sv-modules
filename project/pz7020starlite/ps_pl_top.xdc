####################
# I/O constraints
####################

set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports uart_tx_o]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports uart_rx_i]
