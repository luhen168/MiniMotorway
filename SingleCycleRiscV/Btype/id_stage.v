module id_stage(
    input clk,
    input rst,

    input [31:0] instr_data_i,
    input [31:0] w_data_i,
    input RegWEn,
    input ALUSrc,
    input [2:0] selStore,

    output [31:0] imm_o,
    output [31:0] r_data1_o,
    output [31:0] r_data2_o,
    output [31:0] w_data_o
);

    wire [31:0] r_data2;
    wire [31:0] imm_to_mux;

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
        .r_data2(r_data2)

    );

    // module imm_gen
    imm_gen u_imm_gen (
        .instr(instr_data_i),

        .imm_o(imm_to_mux)
    );

    assign imm_o = imm_to_mux;

    // module mux
    mux_2_1 u_mux(
        .sel(ALUSrc),
        .a(r_data2),
        .b(imm_to_mux),
        .mux_out(r_data2_o)
    
    );

    // module sel 1-in and 4-out
    sel_4_1 u_sel_4_1 (
        .r_data2_in(r_data2),
        .selStore(selStore),
        
        .w_data(w_data_o)
    );



endmodule