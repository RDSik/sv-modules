`timescale 1ns / 1ps

module axis_join_rr_arb_tb ();

    localparam int MASTER_NUM = 4;
    localparam int MEM_WIDTH = 16;
    localparam int MEM_DEPTH = 64;
    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic                  clk_i;
    logic                  rstn_i;
    logic [MASTER_NUM-1:0] start_i;
    logic [MASTER_NUM-1:0] stop_i;

    axis_if #(
        .DATA_WIDTH(MEM_WIDTH)
    ) s_axis (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(MEM_WIDTH)
    ) m_axis[MASTER_NUM-1:0] (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    initial begin
        rstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge clk_i);
        rstn_i = 1'b1;
        $display("Reset done in: %0t ns\n.", $time());
    end

    initial begin
        clk_i = 1'b0;
        forever begin
            #(CLK_PER_NS / 2) clk_i = ~clk_i;
        end
    end

    initial begin
        start_i = '0;
        stop_i  = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            #100;
            start_i[i] = 1'b1;
        end
        #2000;
        for (int i = 0; i < MASTER_NUM; i++) begin
            #100;
            stop_i[i] = 1'b1;
        end
    end

    initial begin
        $dumpfile("axis_join_rr_arb_tb.vcd");
        $dumpvars(0, axis_join_rr_arb_tb);
    end

    axis_join_rr_arb #(
        .MASTER_NUM(MASTER_NUM)
    ) dut (
        .s_axis(m_axis),
        .m_axis(s_axis)
    );

    for (genvar i = 0; i < MASTER_NUM; i++) begin
        axis_data_gen #(
            .MEM_WIDTH(MEM_WIDTH),
            .MEM_DEPTH(MEM_DEPTH)
        ) i_axis_data_gen (
            .start_i(start_i[i]),
            .stop_i (stop_i[i]),
            .m_axis (m_axis[i])
        );
    end

endmodule
