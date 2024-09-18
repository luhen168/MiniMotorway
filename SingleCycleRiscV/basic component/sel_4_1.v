module sel_4_1 (  // 1 in and 4 out 
    input [31:0] r_data2_in,
    input [2:0] selStore,

    output reg [31:0] w_data
);

    always @(r_data2_in) begin
        case(selStore) 
            3'b000: w_data = {24'b0, r_data2_in[7:0]};
            3'b001: w_data = {16'b0, r_data2_in[15:0]};
            3'b010: w_data = r_data2_in;
        endcase 
    end
endmodule