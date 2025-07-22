`ifndef AGENT_SV
`define AGENT_SV

class master_agent_base;

    master_gen_base     master_gen;
    master_monitor_base master_monitor;
    master_driver_base  master_driver;

    function new();
        master_gen     = new();
        master_monitor = new();
        master_driver  = new();
    endfunction

    virtual task run();
        begin
            fork
                master_gen.run();
                master_driver.run();
                master_monitor.run();
            join
        end
    endtask

endclass

class slave_agent_base;

    slave_monitor_base slave_monitor;
    slave_driver_base  slave_driver;

    function new();
        slave_monitor = new();
        slave_driver  = new();
    endfunction

    virtual task run();
        begin
            fork
                slave_driver.run();
                slave_monitor.run();
            join
        end
    endtask

endclass

`endif  // AGENT_SV
