module alu (
    input [31:0] a,
    input [31:0] b,
    input [4:0] ALUSel,
    output reg [31:0] alu_out
);

    wire [2:0] type;
    assign type = ALUSel [2:0];
    
    always @(ALUSel, a, b) begin
        if(ALUSel[0]==1) begin
            //mul and div
            case (ALUSel[4:2])
                3'h0: alu_out = a*b; // 10: sltu Set Less Than (U)
                3'h1: alu_out = (a < b)?1:0; // 11: sltu Set Less Than (U)
                3'h2: alu_out = (a < b)?1:0; // 12: sltu Set Less Than (U)
                3'h3: alu_out = (a < b)?1:0; // 13: sltu Set Less Than (U)
                3'h4: alu_out = (a < b)?1:0; // 14: sltu Set Less Than (U)
                3'h5: alu_out = (a < b)?1:0; // 15: sltu Set Less Than (U)
                3'h6: alu_out = (a < b)?1:0; // 16: sltu Set Less Than (U)
                3'h7: alu_out = (a < b)?1:0; // 17: sltu Set Less Than (U)
                default: alu_out = 32'b0;
            endcase
        end else begin
            case (ALUSel[4:2])
                3'h0: alu_out = ALUSel[1] ? a - b : a + b;        // SUB/ADD
                3'h4: alu_out = a ^ b;                            // XOR
                3'h6: alu_out = a | b;                            // OR
                3'h7: alu_out = a & b;                            // AND
                3'h1: alu_out = a << b;                           // sll Shift Left Logical
                3'h5: alu_out = ALUSel[1] ? a >> b : a >> b;      // sra Shift Right Arith*/srl Shift Right Logical
                3'h2: alu_out = (a < b)?1:0;                      // slt Set Less Than
                3'h3: alu_out = (a < b)?1:0;                   // sltu Set Less Than (U)
                default: alu_out = 32'b0;
            endcase
        end
    end
endmodule