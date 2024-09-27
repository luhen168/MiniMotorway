#!/bin/bash

# Kiểm tra nếu không có tham số đầu vào
if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename.elf>"
    exit 1
fi

# Lấy tên file ELF từ tham số
elf_file="$1"

# Tạo tên file bin và vmem từ tên file elf
bin_file="${elf_file%.elf}.bin"
vmem_file="${elf_file%.elf}.vmem"

# Chạy các lệnh để chuyển đổi từ ELF sang BIN và sau đó từ BIN sang VMEM
riscv32-unknown-elf-objcopy -O binary "$elf_file" "$bin_file"
srec_cat "$bin_file" -binary -offset 0x0000 -byte-swap 4 -o "$vmem_file" -vmem

echo "Conversion completed: $elf_file -> $bin_file -> $vmem_file"

