#include <stdio.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

#define BRAM_CTRL_0 0x40000000
#define REG_NUM     5

int fid;
unsigned int *map_base0;

int sigintHandler(int sig_num) {

    printf("\n Terminating using Ctrl+C \n");
    fflush(stdout);

    close(fid);

    munmap(map_base0, REG_NUM);

    return 0;
}

int main(int argc, char **argv) {
    signal(SIGINT, sigintHandler);

    fid = open("/dev/mem", O_RDWR | O_SYNC);

    if (fid < 0) {
        printf("can not open /dev/mem \n");
        return (-1);
    }   

    printf("/dev/mem is open \n");

    map_base0 = mmap(NULL, REG_NUM * 4, PROT_READ | PROT_WRITE, MAP_SHARED, fid, BRAM_CTRL_0);

    if (map_base0 == 0) {
        printf("NULL pointer\n");
    }   
    else {
        printf("mmap successful\n");
    }   

        unsigned long addr;
        unsigned int content;
        int i;

        addr = (unsigned long)(map_base0 + 2);
        content = 0xc;
        map_base0[2] = content;
        printf("%2dth data, address: 0x%lx data_read: 0x%x\t\t\n", i, addr, content);

        // control_reg
        addr = (unsigned long)(map_base0 + 0);
        content = 0x2;
        map_base0[0] = content;
        printf("%2dth data, address: 0x%lx data_write: 0x%x\t\t\n", i, addr, content);

        // control_reg
        addr = (unsigned long)(map_base0 + 2);
        content = 0x2;
        map_base0[2] = content;
        printf("%2dth data, address: 0x%lx data_write: 0x%x\t\t\n", i, addr, content);
        
        // clk_divider_reg
        addr = (unsigned long)(map_base0 + 1);
        content = 0x1b2; // 50e6/115200
        map_base0[1] = content;
        printf("%2dth data, address: 0x%lx data_write: 0x%x\t\t\n", i, addr, content);

        // tx_data_reg
        addr = (unsigned long)(map_base0 + 3);
        content = 0xfc;
        map_base0[3] = content;
        printf("%2dth data, address: 0x%lx data_write: 0x%x\t\t\n", i, addr, content);

        // control_reg
        for (i = 1; i <= 4; i++) {
            addr = (unsigned long)(map_base0 + 0);
            content = i;
            map_base0[0] = content;
            sleep(1);
            printf("%2dth data, address: 0x%lx data_read: 0x%x\t\t\n", i, addr, content);
        }

        sleep(1);

        // rx_data_reg
        addr = (unsigned long)(map_base0 + 4);
        content = map_base0[4];
        printf("%2dth data, address: 0x%lx data_write: 0x%x\t\t\n", i, addr, content);
}
