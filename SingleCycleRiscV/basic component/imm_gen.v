module imm_gen(
    input [31:0] instr,
    output reg [31:0] imm_o
);

    wire [6:0] opcode;
    wire [2:0] funct3;              //funct3 from bit 12-14


    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];


    always @(instr) begin
        case(opcode)
            // R-type
            7'b0110011: imm_o = instr;    

            // I-type
            7'b0010011: begin
                if(funct3 == 3'h1 || funct3 == 3'h5) 
                    imm_o = {27'b0,instr[24:20]}; 
                else 
                    imm_o = {20'b0,instr[31:20]};
            end

            // I-type (load)
            7'b0000011: imm_o = {20'b0,instr[31:20]};

            // S-type
            7'b0100011: imm_o = {instr[31:25],instr[11:7]}; 

            // B-type 
            7'b1100011: imm_o = {19'b0,instr[31],instr[7],instr[30:25],instr[11:8],1'b0}; // B-type
            // 7'b1101111:  // J-type
            // 7'b1100111:  // I-type (jalr)
            // 7'b0110111:  // U-type (lui)
            // 7'b0010111:  // U-type (auipc)
            // 7'b1110011:  // I-type (ecall-ebreak)
        endcase
    end
endmodule 