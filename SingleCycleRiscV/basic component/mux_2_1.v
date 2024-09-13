module mux_2_1(
    input sel,
    input [31:0] a, b,
    output [31:0] mux_out
);


assign mux_out = (sel==1'b0) ? a : b;

endmodule