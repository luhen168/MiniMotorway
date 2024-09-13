module ALU (
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_sel,
    output reg [31:0] alu_out
);
    always @(alu_sel, a, b) 
        begin
            case (alu_sel)
                4'b0000: alu_out = a & b;       // AND
                4'b0001: alu_out = a | b;       // OR
                4'b0010: alu_out = a + b;       // ADD
                4'b0110: alu_out = a - b;       // SUB
                4'b0011: alu_out = a ^ b;       // XOR
                4'b0100: alu_out = a << b;      //sll Shift Left Logical
                4'b0101: alu_out = a >> b;      //srl Shift Right Logical
                //4'b1000: alu_out = a >> b;    //sra Shift Right Arith*
                4'b0111: alu_out = (a < b)?1:0; //slt Set Less Than
                //4'b1001: alu_out = (a < b)?1:0; //sltu Set Less Than (U)
                default: alu_out = 32'b0;
            endcase
        end
endmodule