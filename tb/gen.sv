`ifndef GEN_SV
`define GEN_SV

class master_gen_base;

    test_cfg_base cfg;

    mailbox#(packet) gen2drv;

    virtual task run();
        begin
            repeat(cfg.packet_num) begin
                gen_master();
            end
        end
    endtask

    virtual task gen_master();
        packet p;
        int size;
        begin
            /* verilator lint_off CONSTRAINTIGN */
            void'(std::randomize(size) with {size inside {
                [cfg.min_size:cfg.max_size]};});
            /* verilator lint_on CONSTRAINTIGN */
            for(int i = 0; i < size; i = i + 1) begin
                p = create_packet();
                void'(p.randomize());
                gen2drv.put(p);
            end
        end
    endtask

    virtual function packet create_packet();
        packet p;
        begin
            p = new();
            return p;
        end
    endfunction

endclass

`endif // GEN_SV
