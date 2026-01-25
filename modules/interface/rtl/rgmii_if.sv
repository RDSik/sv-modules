interface rgmii_if;

    localparam int DATA_WIDTH = 4;

    logic [DATA_WIDTH-1:0] txd;
    logic                  tx_ctl;
    logic                  txc;
    logic [DATA_WIDTH-1:0] rxd;
    logic                  rx_ctl;
    logic                  rxc;

endinterface
