`ifndef TEST_CFG_SV
`define TEST_CFG_SV

class test_cfg_base;
    rand int slave_max_delay  = 10;
    rand int slave_min_delay  = 0;
    rand int master_max_delay = 10;
    rand int master_min_delay = 0;
    rand int max_size         = 100;
    rand int min_size         = 1;
    rand int packet_num       = 10;
         int sim_time         = 100000;

    constraint gen_packet_num_c {
        packet_num inside {[100:500]};
    }

    constraint gen_size_c {
        min_size inside {[1:50]};
        max_size inside {[1:500]};
        max_size >= min_size;
    }

    constraint master_gen_delay_c {
        master_min_delay inside {[0:20]};
        master_max_delay inside {[0:20]};
        master_max_delay >= master_min_delay;
    }

    constraint slave_gen_delay_c {
        slave_min_delay inside {[0:20]};
        slave_max_delay inside {[0:20]};
        slave_max_delay >= slave_min_delay;
    }

    function void post_randomize();
        string str;
        begin
            str = {str, $sformatf("packet_num       : %0d\n", packet_num       )};
            str = {str, $sformatf("min_size         : %0d\n", min_size         )};
            str = {str, $sformatf("max_size         : %0d\n", max_size         )};
            str = {str, $sformatf("master_min_delay : %0d\n", master_min_delay )};
            str = {str, $sformatf("master_max_delay : %0d\n", master_max_delay )};
            str = {str, $sformatf("slave_min_delay  : %0d\n", slave_min_delay  )};
            str = {str, $sformatf("slave_max_delay  : %0d\n", slave_max_delay  )};
            str = {str, $sformatf("sim_time         : %0d\n", sim_time         )};
            $display(str);
        end
    endfunction

endclass

`endif // TEST_CFG_SV
