module wb_stage (
    input [31:0] alu_data_i,
    input [31:0] dmem_data_i,
    input [3:0] MemtoReg,

    output reg [31:0] w_data_o
);

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
    
endmodule 