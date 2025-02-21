`ifndef ENV_SV
`define ENV_SV

class environment;

    local virtual axis_uart_top_if dut_if;

    int clk_freq;
    int baud_rate;
    int data_width;
    int clk_per;

    function new(virtual axis_uart_top_if dut_if, int clk_per, int clk_freq, int baud_rate, int data_width);
        this.dut_if     = dut_if;
        this.clk_per    = clk_per;
        this.clk_freq   = clk_freq;
        this.baud_rate  = baud_rate;
        this.data_width = data_width;
    endfunction

    task run();
        begin
            rst_gen();
            data_gen(10);
            $display("Stop simulation at: %g ns\n", $time);
        end
    endtask

    task data_gen(int n);
        int ratio = clk_freq/baud_rate;
        begin
            repeat (n) begin
                dut_if.rx_i = 1'b0;
                $display("Start bit detected at: %g ns\n", $time);
                #((ratio/2)*clk_per);
                $display("Data transmission start in %g ns\n", $time);
                for (int i = 0; i < data_width; i++) begin
                    /* verilator lint_off WIDTHTRUNC */
                    dut_if.rx_i = $urandom_range(0, 1);
                    /* verilator lint_on WIDTHTRUNC */
                    $display("%d bit detected in %g ns\n", i, $time);
                    #(ratio*clk_per);
                end
                @(posedge dut_if.clk_i);
                dut_if.rx_i = 1'b1;
                $display("Stop bit detected in %g ns", $time);
                #(ratio*clk_per);
            end
        end
    endtask

    task rst_gen();
        begin
            dut_if.arstn_i = 1'b0;
            $display("Reset at %g ns\n.", $time);
            @(posedge dut_if.clk_i);
            dut_if.arstn_i = 1'b1;
        end
    endtask

    task clk_gen();
        begin
            dut_if.clk_i = 1'b0;
            forever begin
                #(clk_per/2) dut_if.clk_i = ~dut_if.clk_i;
            end
        end
    endtask

endclass

`endif
