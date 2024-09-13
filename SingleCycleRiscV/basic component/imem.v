module IMEM(
    input [31:0] r_addr,
    output [31:0] inst
);

    reg [31:0] Imemory [0:63];  // 64 regs each reg have 32bits

    assign inst = Imemory[r_addr]; 
endmodule