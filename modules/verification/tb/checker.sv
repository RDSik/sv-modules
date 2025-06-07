`ifndef CHECKER_SV
`define CHECKER_SV

class checker_base;

    test_cfg_base cfg;

    bit done;
    int cnt;
    bit in_reset;

    mailbox#(packet) in_mbx;
    mailbox#(packet) out_mbx;

    virtual task run();
        begin
            forever begin
                wait(~in_reset);
                fork
                    do_check();
                join
            end
        end
    endtask

    virtual task check(packet in_p, packet out_p);
        begin
            if (out_p.tdata !== in_p.tdata) begin
                $error("%0t Invalid TDATA: Real: %h, Expected: %h",
                    $time(), out_p.tdata, in_p.tdata);
            end
        end
    endtask

    virtual task do_check();
        packet in_p, out_p;
        begin
            forever begin
                in_mbx.get(in_p);
                out_mbx.get(out_p);
                check(in_p, out_p);
                cnt = cnt + out_p.tlast;
                if (cnt == cfg.packet_num) begin
                    done = 1;
                    break;
                end
            end
        end
    endtask

endclass

`endif // CHECKER_SV
