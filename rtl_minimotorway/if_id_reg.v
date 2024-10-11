module if_id_reg(
    input i_clk, i_resetn, i_we, i_flush, is_auipc, i_valid, i_compress,
    input [31:0] i_if_pc, i_if_instr,
    output reg  [31:0]  o_id_pc, 
    output reg o_valid, o_compress,
    output reg [31:0] o_id_instr
);

    reg [31:0] id_instr;
    wire current_flush;

    // assign current_flush = (i_flush == 1'b1) & (is_auipc == 1'b0) & (i_if_instr[6:0] != 7'b0010111);
    assign current_flush = (i_flush == 1'b1) & (i_if_instr[6:0] != 7'b0010111);

    always @(posedge i_clk or negedge i_resetn)
    begin

        if(!i_resetn)
        begin
            o_compress <= 1'b0;
            o_id_pc    <= 1'b0;
            o_id_instr <= 1'b0;
            o_valid <= 1'b0;
        end

        else if (current_flush == 1'b1) 
        begin
            o_id_pc    <= i_if_pc;
            o_id_instr <= 32'h00000013; // add x0, x0, 0
        end

        else
        begin
            if(i_we)
            begin
                o_id_pc    <= i_if_pc;
                o_id_instr <= i_if_instr;
                o_valid    <= i_valid;
                o_compress <= i_compress;
            end
        end
    end


endmodule
