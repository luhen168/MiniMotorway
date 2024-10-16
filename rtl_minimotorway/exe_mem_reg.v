module exe_mem_reg(
    input i_clk, i_resetn, 
    // Control signals from EXE stage
    input i_exe_mem2reg, i_exe_wmem, i_exe_wreg, i_exe_loadsignext,
    // Input for store
    input i_exe_lsb, i_exe_lsh, [3:0] i_data_be,
    // Data from EXE stage 
    input [4:0] i_exe_rd,
    input [31:0] i_exe_data, i_exe_dmem, 
    // Control signals to MEM stage
    output reg o_mem_mem2reg, o_mem_wmem, o_mem_wreg, o_mem_loadsignext,
    // Output for store
    output reg o_mem_lsb, o_mem_lsh, [3:0] o_data_be,
    // Data to MEM stage
    output reg [4:0] o_mem_rd,
    output reg [31:0] o_mem_data, o_mem_dmem
);

    always @(posedge i_clk or negedge i_resetn)
    begin
        if(!i_resetn)
        begin
            // Control signals
            o_mem_mem2reg     <= 0;
            o_mem_wmem        <= 0;
            o_mem_wreg        <= 0;
            o_mem_lsb         <= 0;
            o_mem_lsh         <= 0;
            o_data_be         <= 4'b1111;
            o_mem_loadsignext <= 0;
            // Data
            o_mem_data        <= 'b0;
            o_mem_rd          <= 'b0;
            o_mem_dmem        <= 'b0;
        end

        else
        begin
        // Control signals
        o_mem_mem2reg     <= i_exe_mem2reg;
        o_mem_wmem        <= i_exe_wmem;
        o_mem_wreg        <= i_exe_wreg;
        o_mem_lsb         <= i_exe_lsb;
        o_mem_lsh         <= i_exe_lsh;
        o_data_be         <= i_data_be;
        o_mem_loadsignext <= i_exe_loadsignext;
        // Data
        o_mem_data        <= i_exe_data;
        o_mem_rd          <= i_exe_rd;
        o_mem_dmem        <= i_exe_dmem;
        end
    end

endmodule
