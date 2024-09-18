module riscv_Rtype_top(
     input clk,
     input rst
);

    // Instruction fetch stage
    wire [31:0] pc_in;
    wire [31:0] instr_data_o;

    // Instruction decode stage
    wire [31:0] r_data1_o;
    wire [31:0] r_data2_o;

    // Instruction execute stage
    wire [31:0] ex_alu_o;

    // Controller
    wire RegWEn;
    wire [4:0] ALUSel;

    //////////////////
    //  if stage    //
    //              //
    //////////////////
    if_stage u_if_stage(
        .clk(clk),
        .rst(rst),

        .pc_in(pc_in),
        .instr_data_o(instr_data_o)
    );

    //////////////////
    //  id stage    //
    //              //
    //////////////////
    id_stage u_id_stage(
        .clk(clk),
        .rst(rst),

        .w_data_i(ex_alu_o),
        .instr_data_i(instr_data_o),

        .RegWEn(RegWEn),

        .r_data1_o(r_data1_o),
        .r_data2_o(r_data2_o)
    );

    //////////////////
    //  ex stage    //
    //              //
    //////////////////
    ex_stage u_ex_stage(
        .r_data1_in(r_data1_o),
        .r_data2_in(r_data2_o),
        .ALUSel(ALUSel),

        .ex_alu_o(ex_alu_o)
    );

    //////////////////
    //  Controller  //
    //              //
    //////////////////
    controller controller(
        .instr(instr_data_o),
        .ALUSel(ALUSel),
        .RegWEn(RegWEn)
    );


endmodule