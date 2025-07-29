/* verilator lint_off TIMESCALEMOD */
module round_robin_arbiter #(
    parameter int MASTER_NUM = 4
) (
    input  logic                  clk_i,
    input  logic                  rstn_i,
    input  logic                  ack_i,
    input  logic [MASTER_NUM-1:0] req_i,
    output logic [MASTER_NUM-1:0] grant_o
);

    localparam int PTR_WIDTH = $clog2(MASTER_NUM);

    logic [    MASTER_NUM-1:0] req_shift;
    logic [    MASTER_NUM-1:0] grant_shift;

    logic [(MASTER_NUM*2)-1:0] req_shift_double;
    logic [(MASTER_NUM*2)-1:0] grant_shift_double;

    logic [     PTR_WIDTH-1:0] ptr;
    logic [     PTR_WIDTH-1:0] ptr_next;

    assign req_shift_double   = {req_i, req_i} >> ptr;
    assign req_shift          = req_shift_double[MASTER_NUM-1:0];

    assign grant_shift_double = {grant_shift, grant_shift} << ptr;
    assign grant_o            = grant_shift_double[(MASTER_NUM*2)-1:MASTER_NUM];

    always_comb begin
        grant_shift = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (req_shift[i]) begin
                grant_shift[i] = 1'b1;
                break;
            end
        end
    end

    always_comb begin
        ptr_next = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (grant_o[i]) begin
                ptr_next = (i + 1) % MASTER_NUM;
                break;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            ptr <= '0;
        end else if (ack_i) begin
            ptr <= ptr_next;
        end
    end

endmodule
