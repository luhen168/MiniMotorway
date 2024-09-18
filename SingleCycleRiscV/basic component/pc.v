module pc(
	input clk,
	input rst,
	input [31:0] pc_in,
	output reg [31:0] pc_out
);


add_2_op u_add_2_op(
	.a(4),        //default decimal
	.b(pc_out),	  
	.sum(pc_in)
);

always@(posedge clk or negedge rst) 
	begin
	  if(~rst)
	    pc_out <= 32'h0;
	  else
		pc_out <= pc_in;  
	end


endmodule