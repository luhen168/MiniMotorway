module RISCV_top(
     input clk,
     input rst
);

    //PC wire Add and IMEM
    wire [31:0] sum, pc_out;
    //IMEM and Decode wire
    wire [31:0] inst;
    //RegisterFile and ALU wire
    wire [31:0] r_data1, r_data2, alu_out;
    //Controller and ALU
    wire [3:0] ALUSel;
    //Controller and Decode
    wire RegWEn;

    //////////////////
    //  Instruction //
    //  Fetch       //
    //////////////////

    PC PC (
        .clk(clk),
        .rst(rst),
        .pc_in(sum),
        .pc_out(pc_out)
    );

    Add Add (
        .a(32'h4),
        .b(pc_out),
        .sum(sum)
    );

    IMEM IMEM (
        .r_addr(pc_out),
        .inst(inst)
    );

    //////////////////
    //  Decode      //
    //              //
    //////////////////

    RegisterFile RegisterFile (
        .clk(clk),
        .w_reg(inst[11:7]),   //rd
        .r_reg2(inst[24:20]), //rs2
        .r_reg1(inst[19:15]), //rs1
        .w_data(alu_out),
        .RegWEn(RegWEn),
        .r_data1(r_data1),
        .r_data2(r_data2)
    );

    ALU ALU (
        .a(r_data1),
        .b(r_data2),
        .ALUSel(ALUSel),
        .alu_out(alu_out)
    );

    //////////////////
    //  Controller  //
    //              //
    //////////////////
    Controller Controller(
        .inst(inst),
        .ALUSel(ALUSel),
        .RegWEn(RegWEn)
    );


endmodule