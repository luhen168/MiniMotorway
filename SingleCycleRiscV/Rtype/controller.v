module controller (
    input [31:0] instr,
    output reg [4:0] ALUSel,
    output reg RegWEn

);
    //Core Instruction Format
    wire [6:0] opcode;              //OPCODE from bit 0->6
    wire [2:0] funct3;              //funct3 from bit 12-14
    wire [6:0] funct7;              //funct7 from bit 25-31

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

     always @(instr) begin
        case (opcode)                
        // R-type               
            7'b0110011: begin          
                if(funct7[0]==1) begin
                    case (funct3)     
                        3'h0: ALUSel = {funct3,funct7[1:0]}; 
                        3'h1: ALUSel = {funct3,funct7[1:0]};  // 
                        3'h2: ALUSel = {funct3,funct7[1:0]};  // 
                        3'h3: ALUSel = {funct3,funct7[1:0]};  // 
                        3'h4: ALUSel = {funct3,funct7[1:0]};  //
                        3'h5: ALUSel = {funct3,funct7[1:0]};  //
                        3'h6: ALUSel = {funct3,funct7[1:0]};  // 
                        3'h7: ALUSel = {funct3,funct7[1:0]};  //
                        default: ALUSel = {funct3,funct7[1:0]}; // 
                    endcase
                end else begin
                    case (funct3)     
                        3'b000: ALUSel = {funct3,funct7[5],1'b0};   // SUB/ADD
                        3'b111: ALUSel = {funct3,2'b0};             // AND
                        3'b110: ALUSel = {funct3,2'b0};             // OR
                        3'b100: ALUSel = {funct3,2'b0};             // XOR
                        3'b001: ALUSel = {funct3,2'b0};             //sll Shift Left Logical
                        3'b101: ALUSel = {funct3,funct7[5],1'b0};   //sra /srl
                        3'b010: ALUSel = {funct3,2'b0};             //slt 
                        3'b011: ALUSel = {funct3,2'b0};             //slt S(U)
                        default: ALUSel = {funct3,2'b0};            // ADD
                    endcase
                end
                // ALUSrc = 0;
                RegWEn = 1;
            end
        endcase
    end
endmodule
