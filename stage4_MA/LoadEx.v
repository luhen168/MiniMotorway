module LoadEx (
    input  [31:0] data_in,          // Input
    input  [2:0] MemSize,           // Memory size: 000 - byte, 001 - halfword, 010 - word, 011 - byte(U), 100 - half(U)
    output reg  [31:0] data_out     // Extended output
);

    always @(data_in or MemSize) begin
        case (MemSize)
            3'b000: data_out = {{24{data_in[7]}}, data_in[7:0]};       // lb & Load Byte & rd = M[rs1+imm][0:7] & Sign-extend byte
            3'b001: data_out = {{16{data_in[15]}}, data_in[15:0]};     // lh & Load Half & rd = M[rs1+imm][0:15] & Sign-extend half-word
            3'b010: data_out = data_in;                                // lw & Load Word & rd = M[rs1+imm][0:31] & Sign-extend word
            3'b011: data_out = {24'b0, data_in[7:0]};                  // lbu & Load Byte (U) & rd = M[rs1+imm][0:7] & zero-extends
            3'b100: data_out = {16'b0, data_in[15:0]};                 // lhu & Load Half (U) & rd = M[rs1+imm][0:15] & zero-extends
            default: out = 32'b0;
        endcase
    end
endmodule