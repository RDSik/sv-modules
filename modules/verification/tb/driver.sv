`ifndef DRIVER_SV
`define DRIVER_SV

class master_driver_base;

    virtual axis_if axis;

    test_cfg_base cfg;

    mailbox#(packet) gen2drv;

    virtual task run();
        packet p;
        begin
            forever begin
                @(posedge axis.clk_i);
                fork
                    forever begin
                        gen2drv.get(p);
                        drive_master(p);
                    end
                join
            end
        end
    endtask

    virtual task drive_master(packet p);
        int delay;
        begin
            /* verilator lint_off CONSTRAINTIGN */
            void'(std::randomize(delay) with {delay inside {
                [cfg.master_min_delay:cfg.master_max_delay]};});
            /* verilator lint_on CONSTRAINTIGN */
            repeat(delay) @(posedge axis.clk_i);
            axis.tvalid = 1'b1;
            axis.tdata  = p.tdata;
            do begin
                @(posedge axis.clk_i);
            end
            while(~axis.tready);
            axis.tvalid = 1'b0;
        end
    endtask

endclass

class slave_driver_base;

    virtual axis_if axis;

    test_cfg_base cfg;

    virtual task run();
        begin
            forever begin
                @(posedge axis.clk_i);
                fork
                    forever begin
                        drive_slave();
                    end
                join
            end
        end
    endtask

    virtual task drive_slave();
        int delay;
        begin
            /* verilator lint_off CONSTRAINTIGN */
            void'(std::randomize(delay) with {delay inside {
                [cfg.slave_min_delay:cfg.slave_max_delay]};});
            /* verilator lint_on CONSTRAINTIGN */
            repeat (delay) @(posedge axis.clk_i);
            axis.tready = 1'b1;
            @(posedge axis.clk_i);
            axis.tready = 1'b0;
        end
    endtask

endclass

`endif // DRIVER_SV
