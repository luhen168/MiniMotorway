module add_2_op (a, b, sum); // tuong ung khoi Add trong hinh ve 

    input [31:0] a, b;
    output [31:0] sum;

    assign sum = a + b;

endmodule