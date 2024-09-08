module Memory_Access(
    input clk, MemRW, RegWEn,
    input [1:0] WBSel,
    input [31:0] pc, alu_in, DataB_in, inst_in,
    output [31:0] DataD, inst_out,
    output RegWEn_out
);
    wire [31:0] sum, DataB_w;

    DMEM DMEM(
        .clk(clk),
        .MemRW(MemRW),
        .addr(alu_in),
        .Write_data(DataB_in),
        .DataB(DataB_w)
    );

    Add Add2(
        .a(32'b100),
        .b(pc),
        .sum(sum)
    );

    mux_3_1 mux_3_1(
        .sel(WBSel),
        .a(DataB_w),
        .b(alu_in),
        .c(sum),
        .mux_out(DataD)
    );

    LoadEx LoadEx(
        .data_in(),
        .MemSize(),
        .data_out()
    );

    assign inst_out = inst_in;
    assign RegWEn_out = RegWEn;

endmodule