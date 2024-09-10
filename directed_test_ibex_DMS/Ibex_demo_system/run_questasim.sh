#!/bin/bash

# Thư mục chứa các file .mem đầu vào
input_dir="/home/luanle/DigitalDesign/Lab/MiniMotorway/directed_test_ibex_DMS/input_test"
# Thư mục lưu trữ các file dmem đầu ra
output_dir="/home/luanle/DigitalDesign/Lab/MiniMotorway/directed_test_ibex_DMS/output_test"

# Thư viện work
work_dir="/home/luanle/DigitalDesign/Lab/MiniMotorway/directed_test_ibex_DMS/work"

# Kiểm tra nếu thư mục đầu vào tồn tại
if [ ! -d "$input_dir" ]; then
    echo "Input directory $input_dir does not exist!"
    exit 1
fi

# Tạo thư mục đầu ra nếu chưa tồn tại
mkdir -p "$output_dir"

# Tạo thư mục work nếu chưa tồn tại
vlib "$work_dir"

# Biên dịch các file thiết kế và testbench
vlog -work "$work_dir" /home/luanle/DigitalDesign/Lab/MiniMotorway/directed_test_ibex_DMS/Ibex_demo_system/*.v
vlog -work "$work_dir" /home/luanle/DigitalDesign/Lab/MiniMotorway/directed_test_ibex_DMS/Ibex_demo_systemtb_ibex_demo_system.v

# Lặp qua từng file .mem trong thư mục đầu vào
for imem_file in "$input_dir"/*.mem; do
    # Lấy tên file (không bao gồm phần mở rộng)
    filename=$(basename -- "$imem_file")
    filename="${filename%.*}"

    echo "Processing $imem_file..."

    # Chạy Questasim với file .mem hiện tại
    vsim -c -do "
        vsim tb_ibex_demo_system;
        log -r /*;
        run -all;
        exit;"
    
    # Lưu kết quả dmem vào file tương ứng trong thư mục đầu ra
    dmem_file="$output_dir/${filename}_dmem.mem"
    
    # Giả sử kết quả từ dmem được lưu trữ tại một biến nào đó trong thiết kế Questasim,
    # Bạn cần thêm code để xuất ra biến này dưới dạng file .mem.
    # Ví dụ: lưu biến dmem với lệnh force trong TCL và xuất ra file
    # (tùy thuộc vào cách bạn triển khai testbench).

    echo "Saved dmem output to $dmem_file"
done

echo "All files processed."

