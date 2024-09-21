module if_stage (
    input clk,
    input rst,

    input [31:0] pc_branch_or_add4,
    input [31:0] pc_jalr,
    input selPC,

    output [31:0] pc_add4_to_wb,
    output [31:0] pc_o,
    output [31:0] instr_data_o
);
    wire [31:0] pc_add4;
    wire [31:0] pc_in;
    wire [31:0] pc_out;

    mux_2_1 u_mux_2_1 (
        .a(pc_branch_or_add4),
        .b(pc_jalr),
        .sel(selPC),

        .mux_out(pc_in)
    );
    
    // module pc
    pc u_pc (
        .clk(clk),
        .rst(rst),

        .pc_in(pc_in),

        .pc_add4(pc_add4),
        .pc_out(pc_out)
    );

    assign pc_o = pc_out;
    
    // module imem
    imem u_imem(
        .r_addr(pc_out),
        .instr(instr_data_o)
    );

    assign pc_add4_to_wb = pc_add4;

    
endmodule