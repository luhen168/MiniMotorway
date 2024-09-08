module PC(
	input clk,
	input rst,
	input [31:0] pc_in,
	output reg [31:0] pc_out
);

always@(posedge clk or negedge rst) 
	begin
	  if(~rst)
	    pc_out <= 32'b0;
	  else
		pc_out <= pc_in;  
	end
endmodule