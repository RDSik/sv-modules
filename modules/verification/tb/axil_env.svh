`ifndef AXIL_ENV_SVH
`define AXIL_ENV_SVH

`include "../../verification/tb/cfg.svh"

class axil_env #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
);

    test_cfg_base cfg;

    virtual axil_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) s_axil;

    function new(
    virtual axil_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) s_axil);
        this.s_axil = s_axil;
        cfg         = new();
        void'(cfg.randomize());
    endfunction

    task automatic master_write_wdata(input logic [DATA_WIDTH-1:0] data, int delay_min,
                                      int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.wvalid = '1;
        s_axil.wstrb  = '1;
        s_axil.wdata  = data;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.wready);
        s_axil.wvalid = '0;
        s_axil.wstrb  = '0;
    endtask

    task automatic master_write_awaddr(input logic [ADDR_WIDTH-1:0] addr, int delay_min,
                                       int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.awprot  = 0;
        s_axil.awvalid = 1;
        s_axil.awaddr  = addr;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.awready);
        s_axil.awvalid = 0;
    endtask

    task automatic master_read_bresp(output logic [1:0] bresp, int delay_min, int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.bready = 1;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.bvalid);
        s_axil.bready = 0;
        bresp         = s_axil.bresp;
    endtask

    task automatic master_write_reg(
        input logic [ADDR_WIDTH-1:0] addr, input logic [DATA_WIDTH-1:0] data,
        int master_delay_min = cfg.master_min_delay, int master_delay_max = cfg.master_max_delay);
        logic bresp;
        wait (s_axil.arstn_i);
        fork
            master_write_awaddr(addr, master_delay_min, master_delay_max);
            master_write_wdata(data, master_delay_min, master_delay_max);
            master_read_bresp(bresp, master_delay_min, master_delay_max);
        join
        $display("[%0t][WRITE]: addr = 0x%0h, data = 0x%0h, bresp = 0x%0h", $time, addr, data,
                 bresp);
    endtask

    task automatic master_write_araddr(input logic [ADDR_WIDTH-1:0] addr, int delay_min,
                                       int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.arprot  = 0;
        s_axil.arvalid = 1;
        s_axil.araddr  = addr;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.arready);
        s_axil.arvalid = 0;
    endtask

    task automatic master_read_rdata(output logic [DATA_WIDTH-1:0] data, output logic [1:0] rresp,
                                     int delay_min, int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.rready = 1;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.rvalid);
        s_axil.rready = 0;
        data          = s_axil.rdata;
        rresp         = s_axil.rresp;
    endtask

    task automatic master_read_reg(
        input logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data,
        int master_delay_min = cfg.master_min_delay, int master_delay_max = cfg.master_max_delay);
        logic [1:0] rresp;
        wait (s_axil.arstn_i);
        fork
            master_write_araddr(addr, master_delay_min, master_delay_max);
            master_read_rdata(data, rresp, master_delay_min, master_delay_max);
        join
        $display("[%0t][READ]: addr = 0x%0h, data = 0x%0h, rresp = 0x%0h", $time, addr, data,
                 rresp);
    endtask

endclass

`endif  // AXIL_ENV_SVH
