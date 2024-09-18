module if_stage (
    // Signal synchronous (clk) and acsynchronous (rst)
    input clk,
    input rst,

    input [31:0] pc_in,

    output [31:0] instr_data_o
);
    wire [31:0] pc_out;
    
    // module pc
    pc u_pc (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // module imem
    imem u_imem(
        .r_addr(pc_out),
        .instr(instr_data_o)
    );
    
endmodule