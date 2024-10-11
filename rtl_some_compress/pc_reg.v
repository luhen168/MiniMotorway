module pc_reg(
    input i_clk, i_resetn, i_we, 
    input i_data_req, i_data_rvalid,
    input [31:0] i_pc, 
    output reg [31:0] o_pc,
    output reg o_is_stall
);

    reg temp;
    reg check_sig;
    reg en_pc;
    // wire current_req_rvalid;
    // reg next_req_rvalid:
    // assign current_req_rvalid = (i_data_req===1'b1) && (i_data_rvalid===1'b0);
    // next_req_rvalid <= current_req_rvalid;
    // if (next_req_rvalid
    always @(posedge i_clk or negedge i_resetn)
    begin
        temp <= i_data_req;
        check_sig <= (temp !== i_data_rvalid)? 0: 1; // =x neu 1 trong hai la x
        if(!i_resetn) begin
            o_pc <= 32'h80;
            en_pc <= 1'b1;                           // allow fetch
            o_is_stall <= 1'b0;
        end else if(en_pc) begin
            if(i_we) begin                          // not stall: 1 update pc - stall or not rvalid: 0 not update pc
                o_pc <= i_pc;
                o_is_stall <= 1'b0;
                if((check_sig==1'b0) & (temp==1 && i_data_rvalid==0) || (check_sig==1'b0) & (temp==1 && i_data_rvalid===1'bx))
                    en_pc <= 1'b0;
            end
            else begin
                o_is_stall <= 1'b1;
            end
        end else 
            o_pc <= 32'hx;
    end

endmodule
