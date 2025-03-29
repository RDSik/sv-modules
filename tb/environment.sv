`ifndef ENV_SV
`define ENV_SV

class environment;

    local virtual axis_uart_top_if dut_if;

    int clk_freq;
    int baud_rate;
    int data_width;
    int clk_per;
    int sim_time;

    function new(virtual axis_uart_top_if dut_if, int clk_per, int clk_freq, int baud_rate, int data_width, int sim_time);
        this.dut_if     = dut_if;
        this.clk_per    = clk_per;
        this.clk_freq   = clk_freq;
        this.baud_rate  = baud_rate;
        this.data_width = data_width;
        this.sim_time   = sim_time;
    endfunction

    task run();
        begin
            fork
                clock_gen(clk_per);
                reset_gen();
                data_gen(clk_freq, baud_rate);
            join_none
            time_out(sim_time);
        end
    endtask

    task data_gen(int clk_freq, int baud_rate);
        int ratio = clk_freq/baud_rate;
        logic [7:0] tmp_data;
        begin
            wait(dut_if.arstn_i);
            forever begin
                /* verilator lint_off WIDTHTRUNC */
                tmp_data = $urandom_range(0, (2**data_width)-1);
                /* verilator lint_on WIDTHTRUNC */
                $display("Data to transmit: 8'b%b - 8'h%h\n", tmp_data, tmp_data);
                dut_if.uart_rx_i = 1'b0;
                $display("Start bit detected in %g ns\n", $time);
                repeat ((ratio/2)+1) @(posedge dut_if.clk_i);
                for (int i = 0; i < data_width; i++) begin
                    dut_if.uart_rx_i = tmp_data[i];
                    $display("%d bit detected in %g ns and equal: %b\n", i, $time, tmp_data[i]);
                    repeat (ratio) @(posedge dut_if.clk_i);
                end
                @(posedge dut_if.clk_i);
                dut_if.uart_rx_i = 1'b1;
                $display("Stop bit detected in %g ns\n", $time);
                repeat (ratio) @(posedge dut_if.clk_i);
            end
        end
    endtask

    task reset_gen();
        begin
            dut_if.arstn_i = 1'b0;
            repeat ($urandom_range(1, 10)) @(posedge dut_if.clk_i);
            dut_if.arstn_i = 1'b1;
            $display("Reset done in %g ns\n.", $time);
        end
    endtask

    task clock_gen(int clk_per);
        begin
            dut_if.clk_i = 1'b0;
            forever begin
                #(clk_per/2) dut_if.clk_i = ~dut_if.clk_i;
            end
        end
    endtask

    task time_out(int sim_time);
        begin
            repeat (sim_time) @(posedge dut_if.clk_i);
            $display("Stop simulation at: %g ns\n", $time);
            `ifdef VERILATOR
            $finish();
            `else
            $stop();
            `endif
        end
    endtask

endclass

`endif
