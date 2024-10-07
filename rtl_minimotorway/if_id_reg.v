module if_id_reg(
    input i_clk, i_resetn, i_we, i_flush, is_auipc,
    input [31:0] i_if_p4, i_if_pc, i_if_instr,
    output reg  [31:0] o_id_p4, o_id_pc, 
    output reg [31:0] o_id_instr
);

    reg [31:0] id_instr;
    wire current_flush;
    reg next_flush;

    assign current_flush = (i_flush == 1'b1) & (is_auipc != 1'b1);


    always @(posedge i_clk or negedge i_resetn)
    begin
        next_flush <= current_flush;
        if(!i_resetn)
        begin
            o_id_p4    <= 1'b0;
            o_id_pc    <= 1'b0;
            o_id_instr <= 1'b0;
        end

        else if ((current_flush == 1'b1) || (next_flush == 1'b1))
        begin
            o_id_p4    <= i_if_p4;
            o_id_pc    <= i_if_pc;
            o_id_instr <= 32'h00000013; // add x0, x0, 0
        end

        else
        begin
            if(i_we)
            begin
                o_id_p4    <= i_if_p4;
                o_id_pc    <= i_if_pc;
                o_id_instr <= i_if_instr;
            end
        end
    end


endmodule
