module controller (
    input [31:0] instr,

    output reg [4:0] ALUSel,   // 5bits
    output reg ALUSrc,
    output reg RegWEn,
    output reg MemRW,
    output reg MemtoReg,
    output reg [2:0] selStore
);
    //Core Instruction Format
    wire [6:0] opcode;              //OPCODE from bit 0->6
    wire [2:0] funct3;              //funct3 from bit 12-14
    wire [6:0] funct7;              //funct7 from bit 25-31
    reg [11:0] imm;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];
    // assign imm = instr[31:20];


    // use funct[5] or imm[10] distinguish for each operator
    // & funct[0] to distinguish muldiv and normal arithmetic&logic
    always @(instr) begin
    RegWEn = 0;
    ALUSrc = 0;
    MemRW = 0;
    MemtoReg = 0;
    selStore = 3'b000;
    ALUSel = 5'b00000;
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
                RegWEn = 1;
            end

        // I-type
            7'b0010011: begin 
                imm = instr[31:20];          
                case (funct3)     
                    3'b000: ALUSel = {funct3,2'b0};             // addi
                    3'b111: ALUSel = {funct3,2'b0};             // andi
                    3'b110: ALUSel = {funct3,2'b0};             // ori
                    3'b100: ALUSel = {funct3,2'b0};             // xori
                    3'b001: ALUSel = {funct3,2'b0};             // slli Shift Left Logical
                    3'b101: ALUSel = {funct3,imm[10],1'b0};     // srai /srli
                    3'b010: ALUSel = {funct3,2'b0};             // slti 
                    3'b011: ALUSel = {funct3,2'b0};             //slt S(U)
                    default: ALUSel = {funct3,2'b0};            // ADD
                endcase
                ALUSrc = 1;
                RegWEn = 1;
            end

        // S-type
            7'b0100011: begin 
                // imm = {instr[31:25],instr[11:7]};          
                case (funct3)     
                    3'b000: begin 
                        ALUSel = {3'b0,2'b0};             // sb
                        selStore = 3'b000;
                    end
                    3'b001: begin
                        ALUSel = {3'b0,2'b0};             // sh
                        selStore = 3'b001;
                    end
                    3'b010: begin
                        ALUSel = {3'b0,2'b0};             // sw
                        selStore = 3'b010;
                    end
                    default: ALUSel = {3'b0,2'b0};            // 
                endcase
                ALUSrc = 1;
                MemRW = 1;
            end
        endcase
    end
endmodule
