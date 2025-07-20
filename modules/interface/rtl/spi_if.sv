interface spi_if #(
    parameter int CS_WIDTH = 1
);

    logic                clk;
    logic                mosi;
    logic                miso;
    logic [CS_WIDTH-1:0] cs;

    modport master(output clk, output mosi, input miso, output cs);

    modport slave(input clk, input mosi, output miso, input cs);

endinterface
