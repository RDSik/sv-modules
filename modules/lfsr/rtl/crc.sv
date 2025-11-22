// --------------------------------------------------------------------------------------
// CRC_MODE only with CRC-8-CCIT, CRC-16-CCIT, CRC-32-MPEG-2 and CRC-64-ISO algorithms
// --------------------------------------------------------------------------------------

/* verilator lint_off TIMESCALEMOD */
module crc #(
    parameter int DATA_WIDTH = 16,
    parameter int CRC_WIDTH  = 16
) (
    input  logic                  clk_i,
    input  logic                  rst_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] data_i,
    output logic [ CRC_WIDTH-1:0] crc_o
);

    if ((CRC_WIDTH != 8) && (CRC_WIDTH != 16) && (CRC_WIDTH != 32) && (CRC_WIDTH != 64)) begin : g_crc_width_err
        $error("Only 8, 16, 32, 64 CRC_WIDTH is available!");
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            crc_o <= '1;
        end else begin
            crc_o <= en_i ? crc_byte(crc_o, data_i) : crc_o;
        end
    end

    function automatic logic [CRC_WIDTH-1:0] crc_byte;
        input [CRC_WIDTH-1:0] crc;
        input [DATA_WIDTH-1:0] data;
        begin
            crc_byte = crc;
            for (int i = DATA_WIDTH - 1; i >= 0; i = i - 1) begin
                crc_byte = crc_bit(crc_byte, data[i]);
            end
        end
    endfunction

    function automatic logic [CRC_WIDTH-1:0] crc_bit;
        input logic [CRC_WIDTH-1:0] crc;
        input logic data;
        begin
            if (CRC_WIDTH == 8) begin
                // x^8 + x^2 + x + 1
                crc_bit    = crc << 1;
                crc_bit[0] = crc[CRC_WIDTH-1] ^ data;
                crc_bit[1] = crc[CRC_WIDTH-1] ^ data ^ crc[0];
                crc_bit[2] = crc[CRC_WIDTH-1] ^ data ^ crc[1];
            end else if (CRC_WIDTH == 16) begin
                // x^16 + x^12 + x^5 + 1
                crc_bit     = crc << 1;
                crc_bit[0]  = crc[CRC_WIDTH-1] ^ data;
                crc_bit[5]  = crc[CRC_WIDTH-1] ^ data ^ crc[4];
                crc_bit[12] = crc[CRC_WIDTH-1] ^ data ^ crc[11];
            end else if (CRC_WIDTH == 32) begin
                // x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
                crc_bit     = crc << 1;
                crc_bit[0]  = crc[CRC_WIDTH-1] ^ data;
                crc_bit[1]  = crc[CRC_WIDTH-1] ^ data ^ crc[0];
                crc_bit[2]  = crc[CRC_WIDTH-1] ^ data ^ crc[1];
                crc_bit[4]  = crc[CRC_WIDTH-1] ^ data ^ crc[3];
                crc_bit[5]  = crc[CRC_WIDTH-1] ^ data ^ crc[4];
                crc_bit[7]  = crc[CRC_WIDTH-1] ^ data ^ crc[6];
                crc_bit[8]  = crc[CRC_WIDTH-1] ^ data ^ crc[7];
                crc_bit[10] = crc[CRC_WIDTH-1] ^ data ^ crc[9];
                crc_bit[11] = crc[CRC_WIDTH-1] ^ data ^ crc[10];
                crc_bit[12] = crc[CRC_WIDTH-1] ^ data ^ crc[11];
                crc_bit[16] = crc[CRC_WIDTH-1] ^ data ^ crc[15];
                crc_bit[22] = crc[CRC_WIDTH-1] ^ data ^ crc[21];
                crc_bit[23] = crc[CRC_WIDTH-1] ^ data ^ crc[22];
                crc_bit[26] = crc[CRC_WIDTH-1] ^ data ^ crc[25];
            end else if (CRC_WIDTH == 64) begin
                // x^64 + x^4 + x^3 + x + 1
                crc_bit    = crc << 1;
                crc_bit[0] = crc[CRC_WIDTH-1] ^ data;
                crc_bit[1] = crc[CRC_WIDTH-1] ^ data ^ crc[0];
                crc_bit[3] = crc[CRC_WIDTH-1] ^ data ^ crc[2];
                crc_bit[4] = crc[CRC_WIDTH-1] ^ data ^ crc[3];
            end
        end
    endfunction

endmodule
