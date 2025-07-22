`ifndef ENV_SV
`define ENV_SV

class env_base;

    master_agent_base master;
    slave_agent_base  slave;
    checker_base      check;

    function new();
        master = new();
        slave  = new();
        check  = new();
    endfunction

    virtual task run();
        begin
            fork
                master.run();
                slave.run();
                check.run();
            join
        end
    endtask

endclass

`endif  // ENV_SV
