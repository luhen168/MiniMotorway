module ex_stage(
    input [31:0] r_data1_in,
    input [31:0] r_data2_in,
    input [5:0] ALUSel,
    input [31:0] imm_in,
    input [31:0] pc_o_in,

    output ex_branch_o,
    output [31:0] pc_branch,
    output [31:0] ex_alu_o
);

    add_2_op u_add_2_op (
        .a(imm_in),
        .b(pc_o_in),
        .sum(pc_branch)
    );

    alu u_alu(
        .a(r_data1_in),
        .b(r_data2_in),
        .ALUSel(ALUSel),
        .logic_out(ex_branch_o),
        .alu_out(ex_alu_o)
    );


endmodule