module wb_stage (
    input [31:0] alu_data_i,
    input [31:0] dmem_data_i,
    input MemtoReg,

    output [31:0] w_data_o
);

    mux_2_1 u_mux_2_1 (
        .a(alu_data_i),
        .b(dmem_data_i),
        .sel(MemtoReg),
        .mux_out(w_data_o)
    );
endmodule 