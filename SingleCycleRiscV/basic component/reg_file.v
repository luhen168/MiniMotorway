module reg_file (
    input clk,
    input rst,

    input [4:0] w_reg,      // addr of reg to write data
    input [4:0] r_reg1,     // addr of reg1 to read data
    input [4:0] r_reg2,     // addr of reg2 to read data
    input [31:0] w_data,    // data to write into w_reg
    input RegWEn,           // control write data (1/0~write/read)

    output [31:0] r_data1,  // read data from reg1
    output [31:0] r_data2   // read data from reg2
);

    integer i;
    reg [31:0] regfile [0:31]; // 32 registers x0-x31, each reg have 32bits

    //write data
    always @(posedge clk or negedge rst) begin
        if(!rst) begin
            for(i = 0; i < 32 ; i = i+1) begin
                regfile[i] = 32'h0;
            end
        end else if (RegWEn) begin 
            regfile[w_reg] <= w_data; // if write signal is enable 
        end
    end

    //read data
    assign r_data1 = (r_reg1 != 0) ? regfile[r_reg1] : 32'h0;    // get data when have addr reg
    assign r_data2 = (r_reg2 != 0) ? regfile[r_reg2] : 32'h0;    // get data when have addr reg 
endmodule