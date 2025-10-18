`ifndef ENV_SVH
`define ENV_SVH

class env_base #(
    parameter int DATA_WIDTH_IN  = 16,
    parameter int DATA_WIDTH_OUT = 16
);

    test_cfg_base cfg;

    virtual axis_if #(.DATA_WIDTH(DATA_WIDTH_IN)) s_axis;
    virtual axis_if #(.DATA_WIDTH(DATA_WIDTH_OUT)) m_axis;

    typedef struct {
        rand int                       delay;
        rand logic [DATA_WIDTH_IN-1:0] tdata;
        rand logic                     tlast;
    } packet_in_t;

    typedef struct {
        rand int                        delay;
        rand logic [DATA_WIDTH_OUT-1:0] tdata;
        rand logic                      tlast;
    } packet_out_t;

    mailbox #(packet_in_t)  gen2drv;
    mailbox #(packet_in_t)  in_mbx;
    mailbox #(packet_out_t) out_mbx;

    function new(virtual axis_if #(.DATA_WIDTH(DATA_WIDTH_OUT)) m_axis,
                 virtual axis_if #(.DATA_WIDTH(DATA_WIDTH_IN)) s_axis);
        this.s_axis = s_axis;
        this.m_axis = m_axis;
        cfg         = new();
        gen2drv     = new();
        in_mbx      = new();
        out_mbx     = new();
        void'(cfg.randomize());
    endfunction

    task static do_master_gen(int pkt_amount, int size_min, int size_max, int delay_min,
                              int delay_max);
        repeat (pkt_amount) begin
            packet_in_t p;
            int size;
            void'(std::randomize(size) with {size inside {[size_min : size_max]};});
            for (int i = 0; i < size; i = i + 1) begin
                void'(std::randomize(
                    p
                ) with {
                    p.delay inside {[delay_min : delay_max]};
                    p.tlast == (i == size - 1);
                });
                gen2drv.put(p);
            end
        end
    endtask

    task static reset_master();
        s_axis.tvalid <= 0;
        s_axis.tdata  <= 0;
    endtask

    task static drive_master(packet_in_t p);
        repeat (p.delay) @(posedge s_axis.clk_i);
        s_axis.tvalid <= 1;
        s_axis.tdata  <= p.tdata;
        s_axis.tlast  <= p.tlast;
        do begin
            @(posedge s_axis.clk_i);
        end while (~s_axis.tready);
        s_axis.tvalid <= 0;
        s_axis.tlast  <= 0;
    endtask

    task static do_master_drive();
        packet_in_t p;
        forever begin
            @(posedge s_axis.clk_i);
            fork
                forever begin
                    gen2drv.get(p);
                    drive_master(p);
                end
            join_none
            wait (~s_axis.rstn_i);
            disable fork;
            reset_master();
            wait (s_axis.rstn_i);
        end
    endtask

    task static monitor_master();
        packet_in_t p;
        @(posedge s_axis.clk_i);
        if (s_axis.tvalid & s_axis.tready) begin
            p.tdata = s_axis.tdata;
            p.tlast = s_axis.tlast;
            in_mbx.put(p);
        end
    endtask

    task static do_master_monitor();
        forever begin
            wait (s_axis.rstn_i);
            fork
                forever begin
                    monitor_master();
                end
            join_none
            wait (~s_axis.rstn_i);
            disable fork;
        end
    endtask

    task static master(int gen_pkt_amount, int gen_size_min, int gen_size_max, int gen_delay_min,
                       int gen_delay_max);
        fork
            do_master_gen(gen_pkt_amount, gen_size_min, gen_size_max, gen_delay_min, gen_delay_max);
            do_master_drive();
            do_master_monitor();
        join
    endtask

    task static reset_slave();
        m_axis.tready <= 0;
    endtask

    task static drive_slave(int delay_min, int delay_max);
        int delay;
        void'(std::randomize(delay) with {delay inside {[delay_min : delay_max]};});
        repeat (delay) @(posedge m_axis.clk_i);
        m_axis.tready <= 1;
        @(posedge m_axis.clk_i);
        m_axis.tready <= 0;
    endtask

    task static do_slave_drive(int delay_min, int delay_max);
        forever begin
            @(posedge m_axis.clk_i);
            fork
                forever begin
                    drive_slave(delay_min, delay_max);
                end
            join_none
            wait (~m_axis.rstn_i);
            disable fork;
            reset_slave();
            wait (m_axis.rstn_i);
        end
    endtask

    task static monitor_slave();
        packet_out_t p;
        @(posedge m_axis.clk_i);
        if (m_axis.tvalid & m_axis.tready) begin
            p.tdata = m_axis.tdata;
            p.tlast = m_axis.tlast;
            out_mbx.put(p);
        end
    endtask

    task static do_slave_monitor();
        forever begin
            wait (m_axis.rstn_i);
            fork
                forever begin
                    monitor_slave();
                end
            join_none
            wait (~m_axis.rstn_i);
            disable fork;
        end
    endtask

    task static slave(int delay_min, int delay_max);
        fork
            do_slave_drive(delay_min, delay_max);
            do_slave_monitor();
        join
    endtask

    task static check(packet_in_t in, packet_out_t out);
        if (out.tdata !== in.tdata) begin
            $error("%0t Invalid TDATA: Real: %0h, Expected: %0h", $time(), out.tdata, in.tdata);
        end
    endtask

    task automatic do_check(ref bit done, input int pkt_amount);
        int cnt;
        packet_in_t in_p;
        packet_out_t out_p;
        forever begin
            wait (s_axis.rstn_i);
            fork
                forever begin
                    in_mbx.get(in_p);
                    out_mbx.get(out_p);
                    check(in_p, out_p);
                    cnt = cnt + out_p.tlast;
                    if (cnt == pkt_amount) begin
                        break;
                    end
                end
                begin
                    wait (~s_axis.rstn_i);
                end
            join_any
            disable fork;
            if (cnt == pkt_amount) begin
                done = 1;
                break;
            end
        end
    endtask

    task static run(int gen_pkt_amount = cfg.packet_num, int gen_size_min = cfg.min_size,
                    int gen_size_max = cfg.max_size, int gen_delay_min = cfg.master_min_delay,
                    int gen_delay_max = cfg.master_max_delay,
                    int slave_delay_min = cfg.slave_min_delay,
                    int slave_delay_max = cfg.slave_max_delay, int timeout_cycles = cfg.sim_time);
        bit done;
        fork
            master(gen_pkt_amount, gen_size_min, gen_size_max, gen_delay_min, gen_delay_max);
            slave(slave_delay_min, slave_delay_max);
            do_check(done, gen_pkt_amount);
            timeout(timeout_cycles);
        join_none
        wait (done);
        $display("Test was finished!");
`ifdef VERILATOR
        $finish();
`else
        $stop();
`endif
    endtask

    task static timeout(int timeout_cycles);
        repeat (timeout_cycles) @(posedge s_axis.clk_i);
        $display("Test timeout!");
`ifdef VERILATOR
        $finish();
`else
        $stop();
`endif
    endtask

endclass

`endif  // ENV_SVH
