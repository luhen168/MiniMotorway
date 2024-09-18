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
    wire [31:0] w_data_to_dmem;

    // Instruction execute stage
    wire [31:0] ex_alu_o;

    // Data memory stage
    wire [31:0] r_data_to_wb;

    // Write back stage
    wire [31:0] data_wb_to_reg;

    // Controller
    wire [4:0] ALUSel;
    wire ALUSrc;
    wire RegWEn;
    wire MemRW;
    wire MemtoReg;
    wire [2:0] selStore;

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

        .w_data_i(data_wb_to_reg),
        .instr_data_i(instr_data_o),
        .ALUSrc(ALUSrc),
        .RegWEn(RegWEn),
        .selStore(selStore),
    
        .r_data1_o(r_data1_o),
        .r_data2_o(r_data2_o),
        .w_data_o(w_data_to_dmem)
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
    //  dmem stage  //
    //              //
    //////////////////
    dmem_stage u_dmem_stage(
        .clk(clk),
        .rst(rst),

        .MemRW(MemRW),
        .w_data_i(w_data_to_dmem),
        .addr_i(ex_alu_o),

        .r_data_o(r_data_to_wb)
    );

    //////////////////
    //  wb stage    //
    //              //
    //////////////////
    wb_stage u_wb_stage(
        .alu_data_i(ex_alu_o),
        .dmem_data_i(r_data_to_wb),
        .MemtoReg(MemtoReg),

        .w_data_o(data_wb_to_reg)
    );

    //////////////////
    //  Controller  //
    //              //
    //////////////////
    controller controller(
        .instr(instr_data_o),

        .ALUSel(ALUSel),
        .ALUSrc(ALUSrc),
        .RegWEn(RegWEn),
        .MemRW(MemRW),
        .MemtoReg(MemtoReg),
        .selStore(selStore)
    );


endmodule