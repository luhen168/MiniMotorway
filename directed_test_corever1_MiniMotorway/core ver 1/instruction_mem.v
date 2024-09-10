module instruction_mem (
    input [31:0] i_addr,
    output [31:0] o_instr
);
    reg [31:0] rom [0:16384];
    assign o_instr = rom[i_addr[31:2]];
                   
endmodule
