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

    task static slave_write_wdata(int delay_min, int delay_max, logic [DATA_WIDTH-1:0] data);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.wvalid <= 1;
        s_axil.wdata  <= data;
        do begin
            @(posedge s_axis.clk_i);
        end while (~s_axil.wready);
        s_axil.wvalid <= 0;
        $display("[%0t] Write wdata = 0x%0h", $time, data);
    endtask

    task static slave_write_awaddr(int delay_min, int delay_max, logic [ADDR_WIDTH-1:0] addr);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.awvalid <= 1;
        s_axil.awaddr  <= addr;
        do begin
            @(posedge s_axis.clk_i);
        end while (~s_axil.awready);
        s_axil.awvalid <= 0;
        $display("[%0t] Write awaddr = 0x%0h", $time, addr);
    endtask

    task static slave_write_reg(logic [ADDR_WIDTH-1:0] addr, logic [DATA_WIDTH-1:0] data,
                                int slave_delay_min = cfg.slave_min_delay,
                                int slave_delay_max = cfg.slave_max_delay);
        wait (~s_axis.rstn_i);
        slave_write_awaddr(slave_delay_min, slave_delay_max, addr);
        slave_write_wdata(slave_delay_min, slave_delay_max, data);
    endtask

    task static slave_write_araddr(int delay_min, int delay_max, logic [ADDR_WIDTH-1:0] addr);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.arvalid <= 1;
        s_axil.araddr  <= addr;
        do begin
            @(posedge s_axis.clk_i);
        end while (~s_axil.arready);
        s_axil.arvalid <= 0;
        $display("[%0t] Write araddr = 0x%0h", $time, addr);
    endtask

    task static slave_read_rdata(int delay_min, int delay_max);
        logic [DATA_WIDTH-1:0] data;
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.arready <= 1;
        do begin
            @(posedge s_axis.clk_i);
        end while (~s_axil.arvalid);
        s_axil.arready <= 0;
        data           <= s_axil.rdata;
        $display("[%0t] Read rdara = 0x%0h", $time, data);
        return data;
    endtask

    task static slave_read_reg(logic [ADDR_WIDTH-1:0] addr,
                               int slave_delay_min = cfg.slave_min_delay,
                               int slave_delay_max = cfg.slave_max_delay);
        logic [DATA_WIDTH-1:0] data;
        wait (~s_axis.rstn_i);
        slave_write_araddr(slave_delay_min, slave_delay_max, addr);
        slave_read_rdata(slave_delay_min, slave_delay_max, data);
        return data;
    endtask

endclass

`endif  // AXIL_ENV_SVH
