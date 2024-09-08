module RegisterFile (
    input clk,
    input [4:0] w_reg,      //addr of write reg
    input [4:0] r_reg1,     //addr of read reg2
    input [4:0] r_reg2,     //addr of read reg1
    input [31:0] w_data,    //data to write reg
    input RegWEn,           //control
    output [31:0] r_data1,  //data to read1
    output [31:0] r_data2   //data to read2
);

    reg [31:0] regfile [0:31]; // 32 registers x0-x31, each reg have 32bits

    always @(posedge clk) begin
        if (RegWEn) regfile[w_reg] <= w_data; // if write signal is enable 
    end

    assign r_data1 = (r_reg1 != 0) ? regfile[r_reg1] : 32'b0;    // get data when have addr reg
    assign r_data2 = (r_reg2 != 0) ? regfile[r_reg2] : 32'b0;    // get data when have addr reg 
endmodule