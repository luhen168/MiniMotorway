module id_stage(
    input clk,
    input rst,

    input [31:0] instr_data_i,
    input [31:0] w_data_i,
    input RegWEn,

    output [31:0] r_data1_o,
    output [31:0] r_data2_o
);

    // module registerFile
    reg_file u_reg_file (
        .clk(clk),
        .rst(rst),

        .r_reg1(instr_data_i[19:15]), // rs1
        .r_reg2(instr_data_i[24:20]), //rs2
        .w_reg(instr_data_i[11:7]),   //rd
        .w_data(w_data_i),            // data write in
        .RegWEn(RegWEn),

        .r_data1(r_data1_o),
        .r_data2(r_data2_o)

    );


endmodule