module wb_stage (
    input [31:0] alu_data_i, 
    input [31:0] dmem_data_i, 
    input [31:0] pc_add4_i,  // pc+4
    input [31:0] pc_branch, // pc+imm
    input [31:0] imm_i,


    input [3:0]  MemtoReg,
    input storeJalr,
    input ex_branch_i,
    input Branch,
    input wbToReg,
    input selJalOrJalr,
    input selUtype,

    output [31:0] wb_to_rf,
    output [31:0] wb_to_if0,
    output [31:0] wb_to_if1
);

    reg [31:0] w_data_o;
    wire [31:0] mux_storeJalr_o; 
    wire [31:0] mux_selUtype_o;
    
    // Load from dmem or data 
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

    // wb to regfile
    mux_2_1 u_mux_storeJalr (
        .a(w_data_o),
        .b(pc_add4_i),
        .sel(storeJalr),

        .mux_out(mux_storeJalr_o)
    );

    mux_2_1 u_mux_selUtype (
        .a(imm_i),
        .b(pc_branch),
        .sel(selUtype),

        .mux_out(mux_selUtype_o)
    );

    mux_2_1 u_mux_wbToReg (
        .a(mux_storeJalr_o),
        .b(mux_selUtype_o),
        .sel(wbToReg),

        .mux_out(wb_to_rf)
    );

    // wb to if
    mux_2_1 u_mux_Branch (
        .a(pc_add4_i),
        .b(pc_branch),
        .sel(ex_branch_i&Branch),

        .mux_out(wb_to_if0)
    );

    mux_2_1 u_mux_selJalOrJalr (
        .a(pc_branch),
        .b(alu_data_i),
        .sel(selJalOrJalr),

        .mux_out(wb_to_if1)
    );

    
endmodule 