module ex_stage(
    input [31:0] r_data1_in,
    input [31:0] r_data2_in,
    input [3:0] alu_sel,

    output ex_alu_o
);

alu u_alu(
    .a(r_data1_in),
    .b(r_data2_in),
    .alu_sel(alu_sel),
    .alu_out(ex_alu_o)
);


endmodule