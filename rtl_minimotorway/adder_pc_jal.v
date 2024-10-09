
module adder_pc_jal (
    input [31:0] a, b,
    output [31:0] sum
);

assign sum = a + b - 4;

endmodule


