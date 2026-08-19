module axil_master #(
    parameter int AXIL_ADDR_WIDTH = 32,
    parameter int AXIL_DATA_WIDTH = 32,
    parameter int MAX_DELAY       = 10,
    parameter int MIN_DELAY       = 5
) (
    axil_if.master m_axil
);

    task automatic master_write_wdata;
        input logic [AXIL_DATA_WIDTH-1:0] data;
        int delay;
        begin
            void'(std::randomize(delay) with {delay inside {[MIN_DELAY : MAX_DELAY]};});
            repeat (delay) @(posedge m_axil.clk_i);
            m_axil.wvalid = '1;
            m_axil.wstrb  = '1;
            m_axil.wdata  = data;
            do begin
                @(posedge m_axil.clk_i);
            end while (~m_axil.wready);
            m_axil.wvalid = '0;
            m_axil.wstrb  = '0;
        end
    endtask

    task automatic master_write_awaddr;
        input logic [AXIL_ADDR_WIDTH-1:0] addr;
        int delay;
        begin
            void'(std::randomize(delay) with {delay inside {[MIN_DELAY : MAX_DELAY]};});
            repeat (delay) @(posedge m_axil.clk_i);
            m_axil.awprot  = 0;
            m_axil.awvalid = 1;
            m_axil.awaddr  = addr;
            do begin
                @(posedge m_axil.clk_i);
            end while (~m_axil.awready);
            m_axil.awvalid = 0;
        end
    endtask

    task automatic master_read_bresp;
        output logic [1:0] bresp;
        int delay;
        begin
            void'(std::randomize(delay) with {delay inside {[MIN_DELAY : MAX_DELAY]};});
            repeat (delay) @(posedge m_axil.clk_i);
            m_axil.bready = 1;
            do begin
                @(posedge m_axil.clk_i);
            end while (~m_axil.bvalid);
            m_axil.bready = 0;
            bresp         = m_axil.bresp;
        end
    endtask

    task automatic master_write_reg;
        input logic [AXIL_ADDR_WIDTH-1:0] addr;
        input logic [AXIL_DATA_WIDTH-1:0] data;
        logic [1:0] bresp;
        begin
            wait (m_axil.arstn_i);
            fork
                master_write_awaddr(addr);
                master_write_wdata(data);
                master_read_bresp(bresp);
            join
            $display("[%0t][WRITE]: addr = 0x%0h, data = 0x%0h, bresp = 0x%0h", $time, addr, data,
                     bresp);

        end
    endtask

    task automatic master_write_araddr;
        input logic [AXIL_ADDR_WIDTH-1:0] addr;
        int delay;
        begin
            void'(std::randomize(delay) with {delay inside {[MIN_DELAY : MAX_DELAY]};});
            repeat (delay) @(posedge m_axil.clk_i);
            m_axil.arprot  = 0;
            m_axil.arvalid = 1;
            m_axil.araddr  = addr;
            do begin
                @(posedge m_axil.clk_i);
            end while (~m_axil.arready);
            m_axil.arvalid = 0;
        end
    endtask

    task automatic master_read_rdata;
        output logic [AXIL_DATA_WIDTH-1:0] data;
        output logic [1:0] rresp;
        int delay;
        begin
            void'(std::randomize(delay) with {delay inside {[MIN_DELAY : MAX_DELAY]};});
            repeat (delay) @(posedge m_axil.clk_i);
            m_axil.rready = 1;
            do begin
                @(posedge m_axil.clk_i);
            end while (~m_axil.rvalid);
            m_axil.rready = 0;
            data          = m_axil.rdata;
            rresp         = m_axil.rresp;
        end
    endtask

    task automatic master_read_reg;
        input logic [AXIL_ADDR_WIDTH-1:0] addr;
        output logic [AXIL_DATA_WIDTH-1:0] data;
        logic [1:0] rresp;
        begin
            wait (m_axil.arstn_i);
            fork
                master_write_araddr(addr);
                master_read_rdata(data, rresp);
            join
            $display("[%0t][READ]: addr = 0x%0h, data = 0x%0h, rresp = 0x%0h", $time, addr, data,
                     rresp);
        end
    endtask

endmodule
