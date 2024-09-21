module wb_stage (
    input [31:0] alu_data_i,
    input [31:0] dmem_data_i,
    input [31:0] pc_add4_i,
    input [31:0] pc_branch,

    input [3:0]  MemtoReg,
    input setJalr,
    input ex_branch_i,
    input Branch,

    output [31:0] wb_to_rf,
    output [31:0] wb_to_if
);

    reg [31:0] w_data_o;

    always @(alu_data_i or dmem_data_i or MemtoReg) begin
        case(MemtoReg)
            // dmem to wb
            4'b0001: w_data_o = dmem_data_i [7:0];
            4'b0011: w_data_o = dmem_data_i [15:0];
            4'b0101: w_data_o = dmem_data_i;
            4'b1001: w_data_o = {24'b0, dmem_data_i [7:0]};
            4'b1011: w_data_o = {16'b0, dmem_data_i [15:0]};

            // alu to wb
            4'b0000: w_data_o = alu_data_i;

        endcase
    end

    mux_2_1 u_mux_jalr_to_wb (
        .a(w_data_o),
        .b(pc_add4_i),
        .sel(setJalr),

        .mux_out(wb_to_rf)
    );

    mux_2_1 u_mux_pc_branch_or_add4 (
        .a(pc_add4_i),
        .b(pc_branch),
        .sel(ex_branch_i&Branch),

        .mux_out(wb_to_if)
    );

    
endmodule 