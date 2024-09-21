module imem(
    input [31:0] r_addr,
    output [31:0] instr
);

    reg [31:0] mem [0:16384];  // 64 regs each reg have 32bits

    assign instr = mem[r_addr[31:2]]; 
    // assign instr = mem[r_addr]; 

endmodule