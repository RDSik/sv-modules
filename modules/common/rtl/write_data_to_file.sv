module write_data_to_file #(
    parameter     DATA_PATH  = "",
    parameter int IQ_NUM     = 2,
    parameter int DATA_WIDTH = 16
) (
    input logic clk_i,

    input logic                              tvalid_i,
    input logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_i
);

    int fid;

    initial begin
        fid = $fopen(DATA_PATH, "wb");

        if (fid == 0) begin
            $fatal("Cannot find file ", DATA_PATH);
        end
    end

    always_ff @(posedge clk_i) begin
        if (tvalid_i) begin
            $fwrite(fid, "%u", int'(signed'(tdata_i[0])));
            $fwrite(fid, "%u", int'(signed'(tdata_i[1])));
        end
    end

endmodule
