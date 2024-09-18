module ex_stage(
    input [31:0] r_data1_in,
    input [31:0] r_data2_in,
    input [4:0] ALUSel,

    output [31:0] ex_alu_o
);


    alu u_alu(
        .a(r_data1_in),
        .b(r_data2_in),
        .ALUSel(ALUSel),
        .alu_out(ex_alu_o)
    );


endmodule