####################
# Clocks
####################

create_clock -period 20.000 -name clk_i -waveform {0.000 5.000} [get_ports clk_i]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports clk_i]

####################
# I/O constraints
####################

set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports uart_tx_o]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports uart_rx_i]

set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports spi_miso_i]
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports spi_mosi_o]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports spi_clk_o]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports spi_cs_o]

set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports i2c_scl_io]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports i2c_sda_io]

set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports eth_mdc_o]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports eth_mdio_io]

set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33} [get_ports eth_rx_ctl_i]
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33} [get_ports eth_rxd_i[0]]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports eth_rxd_i[1]]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports eth_rxd_i[2]]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports eth_rxd_i[3]]

set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33} [get_ports eth_tx_clk_o]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33} [get_ports eth_tx_ctl_o]
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33} [get_ports eth_txd_o[0]]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33} [get_ports eth_txd_o[1]]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33} [get_ports eth_txd_o[2]]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33} [get_ports eth_txd_o[3]]
