module dmem_stage (
    input clk,
    input rst,
    
    input MemRW,
    input [31:0] w_data_i,
    input [31:0] addr_i,

    output [31:0] r_data_o
);

    reg [31:0] dmem [0:16383]; //64KiB
    integer i;

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            for(i =0 ; i < 16384 ; i = i + 1)
                dmem[i] = 32'b0;
        end
        if(MemRW)
            dmem[addr_i] = w_data_i;
    end
    
    
    assign r_data_o = dmem[addr_i];

endmodule
