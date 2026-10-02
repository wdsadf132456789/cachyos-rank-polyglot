#include <stdio.h>
#include <stdlib.h>
#include <sys/sysinfo.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define FIFO_PATH "/tmp/rank_pipe"

int main() {
    struct sysinfo si;
    sysinfo(&si);
    
    // Create FIFO if it doesn't exist
    mkfifo(FIFO_PATH, 0666);

    int fd = open(FIFO_PATH, O_WRONLY | O_NONBLOCK);
    if (fd != -1) {
        char buffer[128];
        int len = snprintf(buffer, sizeof(buffer), "UPTIME:%ld|RAM:%ld", si.uptime, si.freeram / 1024 / 1024);
        write(fd, buffer, len);
        close(fd);
    }
    
    printf("Raw C-Probe dispatched telemetry via FIFO pipe.\n");
    return 0;
}
