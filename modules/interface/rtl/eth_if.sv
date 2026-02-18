interface eth_if #(
    parameter int DATA_WIDTH = 4
);

    logic                  mdio_i;
    logic                  mdio_o;
    logic                  mdio_oen;
    logic                  mdc;

    logic [DATA_WIDTH-1:0] txd;
    logic                  tx_ctl;
    logic                  tx_clk;
    logic [DATA_WIDTH-1:0] rxd;
    logic                  rx_ctl;
    logic                  rx_clk;

    modport master(
        input mdio_i,
        output mdio_o,
        output mdio_oen,
        output mdc,
        output txd,
        output tx_ctl,
        output tx_clk,
        input rxd,
        input rx_ctl,
        input rx_clk
    );

    modport slave(
        output mdio_i,
        input mdio_o,
        input mdio_oen,
        input mdc,
        input txd,
        input tx_ctl,
        input tx_clk,
        output rxd,
        output rx_ctl,
        output rx_clk
    );

endinterface
