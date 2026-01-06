
module crc32 #(
    parameter int DATA_WIDTH = 8,
    parameter int CRC_WIDTH  = 32
) (
    input  logic                  clk_i,
    input  logic                  rst_i,
    input  logic [DATA_WIDTH-1:0] data_i,
    input  logic                  crc_en_i,
    output logic [ CRC_WIDTH-1:0] crc_data_o
);

    logic [DATA_WIDTH-1:0] data_t;

    always_comb begin
        for (int i = 0; i < DATA_WIDTH; i++) begin
            data_t[DATA_WIDTH-1-i] = data_i[i];
        end
    end

    logic [CRC_WIDTH-1:0] crc_next;

    assign crc_next[0] = crc_data_o[24] ^ crc_data_o[30] ^ data_t[0] ^ data_t[6];
    assign crc_next[1] = crc_data_o[24] ^ crc_data_o[25] ^ crc_data_o[30] ^ crc_data_o[31] 
                     ^ data_t[0] ^ data_t[1] ^ data_t[6] ^ data_t[7];
    assign crc_next[2] = crc_data_o[24] ^ crc_data_o[25] ^ crc_data_o[26] ^ crc_data_o[30] 
                     ^ crc_data_o[31] ^ data_t[0] ^ data_t[1] ^ data_t[2] ^ data_t[6] 
                     ^ data_t[7];
    assign crc_next[3] = crc_data_o[25] ^ crc_data_o[26] ^ crc_data_o[27] ^ crc_data_o[31] 
                     ^ data_t[1] ^ data_t[2] ^ data_t[3] ^ data_t[7];
    assign crc_next[4] = crc_data_o[24] ^ crc_data_o[26] ^ crc_data_o[27] ^ crc_data_o[28] 
                     ^ crc_data_o[30] ^ data_t[0] ^ data_t[2] ^ data_t[3] ^ data_t[4] 
                     ^ data_t[6];
    assign crc_next[5] = crc_data_o[24] ^ crc_data_o[25] ^ crc_data_o[27] ^ crc_data_o[28] 
                     ^ crc_data_o[29] ^ crc_data_o[30] ^ crc_data_o[31] ^ data_t[0] 
                     ^ data_t[1] ^ data_t[3] ^ data_t[4] ^ data_t[5] ^ data_t[6] 
                     ^ data_t[7];
    assign crc_next[6] = crc_data_o[25] ^ crc_data_o[26] ^ crc_data_o[28] ^ crc_data_o[29] 
                     ^ crc_data_o[30] ^ crc_data_o[31] ^ data_t[1] ^ data_t[2] ^ data_t[4] 
                     ^ data_t[5] ^ data_t[6] ^ data_t[7];
    assign crc_next[7] = crc_data_o[24] ^ crc_data_o[26] ^ crc_data_o[27] ^ crc_data_o[29] 
                     ^ crc_data_o[31] ^ data_t[0] ^ data_t[2] ^ data_t[3] ^ data_t[5] 
                     ^ data_t[7];
    assign crc_next[8] = crc_data_o[0] ^ crc_data_o[24] ^ crc_data_o[25] ^ crc_data_o[27] 
                     ^ crc_data_o[28] ^ data_t[0] ^ data_t[1] ^ data_t[3] ^ data_t[4];
    assign crc_next[9] = crc_data_o[1] ^ crc_data_o[25] ^ crc_data_o[26] ^ crc_data_o[28] 
                     ^ crc_data_o[29] ^ data_t[1] ^ data_t[2] ^ data_t[4] ^ data_t[5];
    assign crc_next[10] = crc_data_o[2] ^ crc_data_o[24] ^ crc_data_o[26] ^ crc_data_o[27] 
                     ^ crc_data_o[29] ^ data_t[0] ^ data_t[2] ^ data_t[3] ^ data_t[5];
    assign crc_next[11] = crc_data_o[3] ^ crc_data_o[24] ^ crc_data_o[25] ^ crc_data_o[27] 
                     ^ crc_data_o[28] ^ data_t[0] ^ data_t[1] ^ data_t[3] ^ data_t[4];
    assign crc_next[12] = crc_data_o[4] ^ crc_data_o[24] ^ crc_data_o[25] ^ crc_data_o[26] 
                     ^ crc_data_o[28] ^ crc_data_o[29] ^ crc_data_o[30] ^ data_t[0] 
                     ^ data_t[1] ^ data_t[2] ^ data_t[4] ^ data_t[5] ^ data_t[6];
    assign crc_next[13] = crc_data_o[5] ^ crc_data_o[25] ^ crc_data_o[26] ^ crc_data_o[27] 
                     ^ crc_data_o[29] ^ crc_data_o[30] ^ crc_data_o[31] ^ data_t[1] 
                     ^ data_t[2] ^ data_t[3] ^ data_t[5] ^ data_t[6] ^ data_t[7];
    assign crc_next[14] = crc_data_o[6] ^ crc_data_o[26] ^ crc_data_o[27] ^ crc_data_o[28] 
                     ^ crc_data_o[30] ^ crc_data_o[31] ^ data_t[2] ^ data_t[3] ^ data_t[4]
                     ^ data_t[6] ^ data_t[7];
    assign crc_next[15] =  crc_data_o[7] ^ crc_data_o[27] ^ crc_data_o[28] ^ crc_data_o[29]
                     ^ crc_data_o[31] ^ data_t[3] ^ data_t[4] ^ data_t[5] ^ data_t[7];
    assign crc_next[16] = crc_data_o[8] ^ crc_data_o[24] ^ crc_data_o[28] ^ crc_data_o[29] 
                     ^ data_t[0] ^ data_t[4] ^ data_t[5];
    assign crc_next[17] = crc_data_o[9] ^ crc_data_o[25] ^ crc_data_o[29] ^ crc_data_o[30] 
                     ^ data_t[1] ^ data_t[5] ^ data_t[6];
    assign crc_next[18] = crc_data_o[10] ^ crc_data_o[26] ^ crc_data_o[30] ^ crc_data_o[31] 
                     ^ data_t[2] ^ data_t[6] ^ data_t[7];
    assign crc_next[19] = crc_data_o[11] ^ crc_data_o[27] ^ crc_data_o[31] ^ data_t[3] ^ data_t[7];
    assign crc_next[20] = crc_data_o[12] ^ crc_data_o[28] ^ data_t[4];
    assign crc_next[21] = crc_data_o[13] ^ crc_data_o[29] ^ data_t[5];
    assign crc_next[22] = crc_data_o[14] ^ crc_data_o[24] ^ data_t[0];
    assign crc_next[23] = crc_data_o[15] ^ crc_data_o[24] ^ crc_data_o[25] ^ crc_data_o[30] 
                      ^ data_t[0] ^ data_t[1] ^ data_t[6];
    assign crc_next[24] = crc_data_o[16] ^ crc_data_o[25] ^ crc_data_o[26] ^ crc_data_o[31] 
                      ^ data_t[1] ^ data_t[2] ^ data_t[7];
    assign crc_next[25] = crc_data_o[17] ^ crc_data_o[26] ^ crc_data_o[27] ^ data_t[2] ^ data_t[3];
    assign crc_next[26] = crc_data_o[18] ^ crc_data_o[24] ^ crc_data_o[27] ^ crc_data_o[28] 
                      ^ crc_data_o[30] ^ data_t[0] ^ data_t[3] ^ data_t[4] ^ data_t[6];
    assign crc_next[27] = crc_data_o[19] ^ crc_data_o[25] ^ crc_data_o[28] ^ crc_data_o[29] 
                      ^ crc_data_o[31] ^ data_t[1] ^ data_t[4] ^ data_t[5] ^ data_t[7];
    assign crc_next[28] = crc_data_o[20] ^ crc_data_o[26] ^ crc_data_o[29] ^ crc_data_o[30] 
                      ^ data_t[2] ^ data_t[5] ^ data_t[6];
    assign crc_next[29] = crc_data_o[21] ^ crc_data_o[27] ^ crc_data_o[30] ^ crc_data_o[31] 
                      ^ data_t[3] ^ data_t[6] ^ data_t[7];
    assign crc_next[30] = crc_data_o[22] ^ crc_data_o[28] ^ crc_data_o[31] ^ data_t[4] ^ data_t[7];
    assign crc_next[31] = crc_data_o[23] ^ crc_data_o[29] ^ data_t[5];

    always @(posedge clk_i) begin
        if (rst_i) begin
            crc_data_o <= '1;
        end else if (crc_en_i) begin
            crc_data_o <= crc_next;
        end
    end

endmodule
