// module mux_3to1 #(
//     parameter DATAWIDTH = 32
// ) (
//     input [DATAWIDTH-1:0] inputA, inputB, inputC,
//     input [1:0] select,
//     output reg [DATAWIDTH-1:0] selected_out
// );

//     always @(*)
//     casex(select)
//         2'b00:
//             selected_out = inputA;
//         2'b01:
//             selected_out = inputB;
//         2'b10:
//             selected_out = inputC;
//         default:
//             selected_out = 32'bx;
//     endcase
// endmodule

module mux_3to1 #(
    parameter DATAWIDTH = 32
) (
    input [DATAWIDTH-1:0] inputA, inputB, inputC,
    input [1:0] select,
    input [31:0] i_if_instr,
    output reg [DATAWIDTH-1:0] selected_out
);

    always @(*)
    casex(select)
        2'b00:
            selected_out = inputA;
        2'b01:
            selected_out = inputB;
        2'b10: begin
            if (i_if_instr[6:0] == 7'b0010111) selected_out = inputA;
            else selected_out = inputC;
        end
        default:
            selected_out = 32'bx;
    endcase
endmodule