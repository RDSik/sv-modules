// --------------------------------------------------------------------------------------
// CRC_MODE only with CRC-8-CCIT, CRC-16-CCIT, CRC-32-MPEG-2 and CRC-64-ISO algorithms
// --------------------------------------------------------------------------------------

/* verilator lint_off TIMESCALEMOD */
module crc #(
    parameter int   DATA_WIDTH = 16,
    parameter int   CRC_WIDTH  = 16,
    parameter logic LSB_FIRST  = 0,
    parameter logic INVERT_OUT = 0,
    parameter logic LEFT_SHIFT = 1
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

    logic [CRC_WIDTH-1:0] crc_reg;

    always @(posedge clk_i) begin
        if (rst_i) begin
            crc_reg <= '1;
        end else begin
            crc_reg <= en_i ? crc_byte(crc_reg, data_i) : crc_reg;
        end
    end

    assign crc_o = (INVERT_OUT) ? ~crc_reg : crc_reg;

    function automatic logic [CRC_WIDTH-1:0] crc_byte;
        input [CRC_WIDTH-1:0] crc;
        input [DATA_WIDTH-1:0] data;
        begin
            crc_byte = crc;
            if (LSB_FIRST) begin
                for (int i = 0; i < DATA_WIDTH; i = i + 1) begin
                    crc_byte = crc_bit(crc_byte, data[i]);
                end
            end else begin
                for (int i = DATA_WIDTH - 1; i >= 0; i = i - 1) begin
                    crc_byte = crc_bit(crc_byte, data[i]);
                end
            end
        end
    endfunction

    function automatic logic [CRC_WIDTH-1:0] crc_bit;
        input logic [CRC_WIDTH-1:0] crc;
        input logic data;
        logic feedback;
        begin
            if (LEFT_SHIFT) begin
                feedback = crc[CRC_WIDTH-1] ^ data;
                crc_bit  = crc << 1;
                if (CRC_WIDTH == 8) begin
                    // x^8 + x^2 + x + 1
                    crc_bit[0] = feedback;
                    crc_bit[1] = feedback ^ crc[0];
                    crc_bit[2] = feedback ^ crc[1];
                end else if (CRC_WIDTH == 16) begin
                    // x^16 + x^12 + x^5 + 1
                    crc_bit[0]  = feedback;
                    crc_bit[5]  = feedback ^ crc[4];
                    crc_bit[12] = feedback ^ crc[11];
                end else if (CRC_WIDTH == 32) begin
                    // x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
                    crc_bit[0]  = feedback;
                    crc_bit[1]  = feedback ^ crc[0];
                    crc_bit[2]  = feedback ^ crc[1];
                    crc_bit[4]  = feedback ^ crc[3];
                    crc_bit[5]  = feedback ^ crc[4];
                    crc_bit[7]  = feedback ^ crc[6];
                    crc_bit[8]  = feedback ^ crc[7];
                    crc_bit[10] = feedback ^ crc[9];
                    crc_bit[11] = feedback ^ crc[10];
                    crc_bit[12] = feedback ^ crc[11];
                    crc_bit[16] = feedback ^ crc[15];
                    crc_bit[22] = feedback ^ crc[21];
                    crc_bit[23] = feedback ^ crc[22];
                    crc_bit[26] = feedback ^ crc[25];

                end else if (CRC_WIDTH == 64) begin
                    // x^64 + x^4 + x^3 + x + 1
                    crc_bit[0] = feedback;
                    crc_bit[1] = feedback ^ crc[0];
                    crc_bit[3] = feedback ^ crc[2];
                    crc_bit[4] = feedback ^ crc[3];
                end
            end else begin
                feedback = crc[0] ^ data;
                crc_bit  = crc >> 1;
                if (CRC_WIDTH == 8) begin
                    // x^8 + x^2 + x + 1
                    crc_bit[7] = feedback;
                    crc_bit[6] = feedback ^ crc[7];
                    crc_bit[5] = feedback ^ crc[6];
                end else if (CRC_WIDTH == 16) begin
                    // x^16 + x^12 + x^5 + 1
                    crc_bit[15] = feedback;
                    crc_bit[10] = feedback ^ crc[11];
                    crc_bit[3]  = feedback ^ crc[4];
                end else if (CRC_WIDTH == 32) begin
                    // x^32 + x^26 + x^23 + x^22 + x^16 + x^12 + x^11 + x^10 + x^8 + x^7 + x^5 + x^4 + x^2 + x + 1
                    crc_bit[31] = feedback;
                    crc_bit[30] = feedback ^ crc[31];
                    crc_bit[29] = feedback ^ crc[30];
                    crc_bit[27] = feedback ^ crc[28];
                    crc_bit[26] = feedback ^ crc[27];
                    crc_bit[24] = feedback ^ crc[25];
                    crc_bit[23] = feedback ^ crc[24];
                    crc_bit[21] = feedback ^ crc[22];
                    crc_bit[20] = feedback ^ crc[21];
                    crc_bit[19] = feedback ^ crc[20];
                    crc_bit[15] = feedback ^ crc[16];
                    crc_bit[9]  = feedback ^ crc[10];
                    crc_bit[8]  = feedback ^ crc[9];
                    crc_bit[5]  = feedback ^ crc[6];

                end else if (CRC_WIDTH == 64) begin
                    // x^64 + x^4 + x^3 + x + 1
                    crc_bit[63] = feedback;
                    crc_bit[62] = feedback ^ crc[63];
                    crc_bit[60] = feedback ^ crc[61];
                    crc_bit[59] = feedback ^ crc[60];
                end
            end
        end
    endfunction

endmodule
