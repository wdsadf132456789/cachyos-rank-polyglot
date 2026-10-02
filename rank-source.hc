// Helper to read a small text file into a buffer
Bool ReadFileStr(U8 *path, U8 *buf, I64 max_len) {
    I64 file = FOpen(path, "r");
    if (!file) return FALSE;
    MemSet(buf, 0, max_len);
    FGets(buf, max_len, file);
    FClose(file);
    // Trim trailing newline if present
    I64 len = StrLen(buf);
    if (len > 0 && buf[len-1] == '\n') buf[len-1] = 0;
    return TRUE;
}

U0 Main() {
    U8 os_name[64] = "CachyOS";
    U8 init_sys[32] = "systemd";
    U8 boot_loader[32] = "Limine";

    // 1. Read OS from /etc/os-release
    I64 file = FOpen("/etc/os-release", "r");
    if (file) {
        U8 line[128];
        while (FGets(line, sizeof(line), file)) {
            if (StrNCmp(line, "NAME=", 5) == 0) {
                // Strip quotes if any
                U8 *p = &line[5];
                // Simple copy ignoring quotes
                I64 i = 0;
                while (*p && *p != '\n' && *p != '"' && i < 63) {
                    os_name[i++] = *p++;
                }
                os_name[i] = 0;
                break;
            }
        }
        FClose(file);
    }

    // 2. Read Init System from /proc/1/comm
    U8 comm_buf[32];
    if (ReadFileStr("/proc/1/comm", comm_buf, sizeof(comm_buf))) {
        StrCpy(init_sys, comm_buf);
    }

    // 3. Detect Bootloader based on common paths (/boot presence)
    // Checking for Limine, GRUB, Systemd-boot
    if (FileFind("/boot/limine") || FileFind("/boot/EFI/BOOT/BOOTX64.EFI")) {
        // Can be customized or checked dynamically via efibootmgr / boot files
        StrCpy(boot_loader, "Limine / UEFI");
    } else if (FileFind("/boot/grub")) {
        StrCpy(boot_loader, "GRUB");
    }

    // Print final dynamic output for fastfetch
    Print("⚡ %s | Init: %s | Boot: %s\n", os_name, init_sys, boot_loader);
}

Main;
