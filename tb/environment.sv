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
                clock_gen();
                reset_gen($urandom_range(1, 10));
                data_gen();
            join_none
            #sim_time;
            $display("Stop simulation at: %g ns\n", $time);
            `ifdef VERILATOR
            $finish();
            `else
            $stop();
            `endif
        end
    endtask

    task data_gen();
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
                $display("Start bit detected at: %g ns\n", $time);
                #((ratio/2)*clk_per+clk_per);
                $display("Data transmission start in %g ns\n", $time);
                for (int i = 0; i < data_width; i++) begin
                    dut_if.uart_rx_i = tmp_data[i];
                    $display("%d bit detected in %g ns and equal: %b\n", i, $time, tmp_data[i]);
                    #(ratio*clk_per);
                end
                @(posedge dut_if.clk_i);
                dut_if.uart_rx_i = 1'b1;
                $display("Stop bit detected in %g ns\n", $time);
                #(ratio*clk_per);
            end
        end
    endtask

    task reset_gen(int delay);
        begin
            dut_if.arstn_i = 1'b0;
            repeat (delay) @(posedge dut_if.clk_i);
            dut_if.arstn_i = 1'b1;
            $display("Reset done at %g ns\n.", $time);
        end
    endtask

    task clock_gen();
        begin
            dut_if.clk_i = 1'b0;
            forever begin
                #(clk_per/2) dut_if.clk_i = ~dut_if.clk_i;
            end
        end
    endtask

endclass

`endif
