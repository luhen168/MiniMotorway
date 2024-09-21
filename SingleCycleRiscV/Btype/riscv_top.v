module riscv_top(
     input clk,
     input rst
);

    // Instruction fetch stage
    wire [31:0] instr_data_o;
    wire [31:0] pc_o;

    // Instruction decode stage
    wire [31:0] r_data1_o;
    wire [31:0] r_data2_o;
    wire [31:0] w_data_to_dmem;
    wire [31:0] imm_o;

    // Instruction execute stage
    wire [31:0] pc_branch;
    wire ex_branch_o;
    wire [31:0] ex_alu_o;

    // Data memory stage
    wire [31:0] r_data_to_wb;

    // Write back stage
    wire [31:0] data_wb_to_rf;
    wire [31:0] pc_wb_to_if;
    wire [31:0] pc_add4_i;

    // Controller
    wire [5:0] ALUSel;
    wire ALUSrc;
    wire RegWEn;
    wire MemRW;
    wire [3:0] MemtoReg;
    wire [2:0] selStore;
    wire setJalr;
    wire selPC;
    wire Branch;

    //////////////////
    //  if stage    //
    //              //
    //////////////////
    if_stage u_if_stage(
        .clk(clk),
        .rst(rst),

        .pc_branch_or_add4(pc_wb_to_if),
        .pc_jalr(ex_alu_o),
        .selPC(selPC),

        .pc_add4_to_wb(pc_add4_i),
        .pc_o(pc_o),
        .instr_data_o(instr_data_o)
    );

    //////////////////
    //  id stage    //
    //              //
    //////////////////
    id_stage u_id_stage(
        .clk(clk),
        .rst(rst),

        .w_data_i(data_wb_to_rf),
        .instr_data_i(instr_data_o),
        .ALUSrc(ALUSrc),
        .RegWEn(RegWEn),
        .selStore(selStore),
    
        .imm_o(imm_o),
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
        .imm_in(imm_o),
        .pc_o_in(pc_o),
        
        .ex_branch_o(ex_branch_o),
        .pc_branch(pc_branch),
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
        .pc_add4_i(pc_add4_i),
        .pc_branch(pc_branch),

        .MemtoReg(MemtoReg),
        .setJalr(setJalr),
        .ex_branch_i(ex_branch_o),
        .Branch(Branch),

        .wb_to_rf(data_wb_to_rf),
        .wb_to_if(pc_wb_to_if)
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
        .selStore(selStore),
        .setJalr(setJalr),
        .selPC(selPC),
        .Branch(Branch)
    );


endmodule