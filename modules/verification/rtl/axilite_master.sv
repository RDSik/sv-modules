module axilite_master #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
) (
    axil_if.slave s_axil
);

    task automatic master_write_wdata(int delay_min, int delay_max, logic [DATA_WIDTH-1:0] data);
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

    task automatic master_write_awaddr(int delay_min, int delay_max, logic [ADDR_WIDTH-1:0] addr);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.awvalid = '1;
        s_axil.awaddr  = addr;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.awready);
        s_axil.awvalid = '0;
    endtask

    task automatic master_write_reg(logic [ADDR_WIDTH-1:0] addr, logic [DATA_WIDTH-1:0] data,
                                    int master_delay_min, int master_delay_max);
        wait (s_axil.rstn_i);
        fork
            master_write_awaddr(master_delay_min, master_delay_max, addr);
            master_write_wdata(master_delay_min, master_delay_max, data);
        join
        $display("[%0t] Write addr = 0x%0h, wdata = 0x%0h", $time, addr, data);
    endtask

    task automatic master_write_araddr(int delay_min, int delay_max, logic [ADDR_WIDTH-1:0] addr);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.arvalid = '1;
        s_axil.araddr  = addr;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.arready);
        s_axil.arvalid = '0;
    endtask

    task automatic master_read_rdata(int delay_min, int delay_max,
                                     output logic [DATA_WIDTH-1:0] data);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge s_axil.clk_i);
        s_axil.rready = '1;
        do begin
            @(posedge s_axil.clk_i);
        end while (~s_axil.rvalid);
        s_axil.rready = '0;
        data          = s_axil.rdata;
    endtask

    task automatic master_read_reg(logic [ADDR_WIDTH-1:0] addr, output logic [DATA_WIDTH-1:0] data,
                                   int master_delay_min, int master_delay_max);
        wait (s_axil.rstn_i);
        fork
            master_write_araddr(master_delay_min, master_delay_max, addr);
            master_read_rdata(master_delay_min, master_delay_max, data);
        join
        $display("[%0t] Read addr = 0x%0h, wdata = 0x%0h", $time, addr, data);
    endtask

endmodule
