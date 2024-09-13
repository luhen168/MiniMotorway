module cpu(
    input i_clk, i_resetn,
    output [31:0] instr,
    output [31:0] pc,
    output [31:0] addr_out, 
    output [31:0] mem_out,
    output is_compressed_o,
    output illegal_instr_o
);

    wire [31:0] core_dmem_in, core_dmem_out; // input/output data memory for core
    wire wmem;
    
    assign mem_out = core_dmem_in;
    assign addr_out = 32'h0; //default
    
    core core1 (
        .i_clk(i_clk), .i_resetn(i_resetn),
        .i_instr(instr),
        .i_dmem(core_dmem_in), 
        .o_pc(pc),   
        .o_addr(addr_out),  
        .o_dmem(core_dmem_out), 
        .o_wmem(wmem),
        .is_compressed_o(is_compressed_o),
        .illegal_instr_o(illegal_instr_o)
    );
    
    data_mem dmem (
        .i_clk(i_clk), .we(wmem),
        .i_data(core_dmem_out),
        .i_addr(addr_out),
        .o_data(core_dmem_in)
    );
    
    instruction_mem imem (
        .i_addr(pc),
        .o_instr(instr)
    );
    

endmodule
