module mux_3_1(
    input [1:0] sel,
    input [31:0] a, b, c,
    output reg [31:0] mux_out
);

    always@(sel, a, b, c) begin   
        case(sel)
            2'b00: mux_out = a;
            2'b01: mux_out = b;
            2'b10: mux_out = c;
            default: mux_out = a;
        endcase
    end
endmodule