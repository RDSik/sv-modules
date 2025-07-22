`ifndef MONITOR_SV
`define MONITOR_SV

class master_monitor_base;

    virtual axis_if   axis;

    mailbox #(packet) in_mbx;

    virtual task run();
        begin
            forever begin
                wait (axis.rstn_i);
                fork
                    forever begin
                        monitor_master();
                    end
                join
            end
        end
    endtask

    virtual task monitor_master();
        packet p;
        begin
            @(posedge axis.clk_i);
            if (axis.tvalid & axis.tready) begin
                p = new();
                p.tdata = axis.tdata;
                p.tlast = axis.tlast;
                in_mbx.put(p);
            end
        end
    endtask

endclass

class slave_monitor_base;

    virtual axis_if   axis;

    mailbox #(packet) out_mbx;

    virtual task run();
        begin
            forever begin
                wait (axis.rstn_i);
                fork
                    forever begin
                        monitor_slave();
                    end
                join
            end
        end
    endtask

    virtual task monitor_slave();
        packet p;
        begin
            @(posedge axis.clk_i);
            if (axis.tvalid & axis.tready) begin
                p = new();
                p.tdata = axis.tdata;
                p.tlast = axis.tlast;
                out_mbx.put(p);
            end
        end
    endtask

endclass

`endif  // MONITOR_SV
