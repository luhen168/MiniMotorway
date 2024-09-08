module DMEM(
	input clk, MemRW,
	input [31:0] addr, Write_data,
	output [31:0] DataB,
);

	reg [31:0] DataMemory [0:63];

	always@(posedge clk) begin
		if(MemRW)
			DataMemory[addr] <= Write_data;
	end
	assign DataB = (MemRW) ? 32'h0 : DataMemory[addr];

endmodule