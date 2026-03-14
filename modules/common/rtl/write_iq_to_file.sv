module write_iq_to_file #(
    parameter int IQ_NUM     = 2,
    parameter int DATA_WIDTH = 16,
    parameter     FILE_PATH  = ""
) (
    input logic clk_i,

    input logic                              tvalid_i,
    input logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_i
);

    int fid;

    initial begin
        fid = $fopen(FILE_PATH, "wb");

        if (!fid) begin
            $fatal("Cannot create file '%s'!", FILE_PATH);
        end
    end

    always_ff @(posedge clk_i) begin
        if (tvalid_i) begin
            $fwrite(fid, "%u", int'(signed'(tdata_i[0])));
            $fwrite(fid, "%u", int'(signed'(tdata_i[1])));
        end
    end

endmodule
