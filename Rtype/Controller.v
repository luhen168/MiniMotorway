module Controller (
    input [31:0] inst,
    output reg [3:0] ALUSel,
    output reg RegWEn

);
    always @(inst) begin
        case (inst[6:0])                // Check Opcode
            7'b0110011: begin           // R-type
                case (inst[14:12])      // Check funct3
                    3'b000: ALUSel = (inst[30] == 0) ? 4'b0010 : 4'b0110; // ADD/SUB
                    3'b111: ALUSel = 4'b0000;  // AND
                    3'b110: ALUSel = 4'b0001;  // OR
                    3'b100: ALUSel = 4'b0011;  // XOR
                    3'b001: ALUSel = 4'b0100;  //sll Shift Left Logical
                    3'b101: ALUSel = (inst[30] == 0) ? 4'b0101 : 4'b1000; //srl Shift Right Logical/sra Shift Right Arith*
                    3'b010: ALUSel = 4'b0111;  //slt Set Less Than
                    3'b011: ALUSel = 4'b1001;  //slt Set Less Than (U)
                    default: ALUSel = 4'b0010; // ADD
                endcase
                RegWEn = 1;
            end
        endcase
    end
endmodule
