module onehot_to_indx #(
    parameter int MASTER_NUM = 4
) (
    input logic [MASTER_NUM-1:0] onehot_i,

    output logic [$clog2(MASTER_NUM)-1:0] indx_o
);

    always_comb begin
        indx_o = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (onehot_i[i]) begin
                indx_o = i;
            end
        end
    end

endmodule
