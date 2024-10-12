module mul_block
(
    input           clk_i,
    input           rst_i,

    // Operation select
    
    input [4:0]     aluc,

    // Operands
    input [31:0]    operand_ra_i,
    input [31:0]    operand_rb_i,

    // Result
    output wire     ready_o,  // tín hiệu báo đã nhân xong (rồi xong cũng không dùng, quên ko xóa luôn)
    output [31:0]   result_o
);


//-------------------------------------------------------------
// Multiplier
//-------------------------------------------------------------
reg [32:0]   mul_operand_a_q;
reg [32:0]   mul_operand_b_q;
reg          mulhi_sel_q;

//-------------------------------------------------------------
// Multiplier
//-------------------------------------------------------------
wire [64:0]  mult_result_w;
reg  [32:0]  operand_b_r;
reg  [32:0]  operand_a_r;

wire mult_inst_w    = ((aluc == 5'b01001) || (aluc == 5'b01010) || (aluc == 5'b01011) || (aluc == 5'b01100));


always @ (operand_ra_i or aluc)
begin
    if (aluc == 5'b01011)
        operand_a_r = {operand_ra_i[31], operand_ra_i[31:0]};
    else if (aluc == 5'b01010)
        operand_a_r = {operand_ra_i[31], operand_ra_i[31:0]};
    else // MULHU || MUL
        operand_a_r = {1'b0, operand_ra_i[31:0]};
end

always @ (operand_rb_i or aluc)
begin
    if (aluc == 5'b01011)
        operand_b_r = {1'b0, operand_rb_i[31:0]};
    else if (aluc == 5'b01010)
        operand_b_r = {operand_rb_i[31], operand_rb_i[31:0]};
    else // MULHU || MUL
        operand_b_r = {1'b0, operand_rb_i[31:0]};
end

// Pipeline flops for multiplier
always @(posedge clk_i or negedge rst_i)
if (!rst_i)
begin
    mul_operand_a_q <= 33'b0;
    mul_operand_b_q <= 33'b0;
    mulhi_sel_q     <= 1'b0;
end
else if (mult_inst_w)
begin
    mul_operand_a_q <= operand_a_r;
    mul_operand_b_q <= operand_b_r;
    
    if(aluc == 5'b01001)
        mulhi_sel_q     <= 1'b0;
    else 
        mulhi_sel_q     <= 1'b1;

end
else
begin
    mul_operand_a_q <= 33'b0;
    mul_operand_b_q <= 33'b0;
    mulhi_sel_q     <= 1'b0;
end



assign mult_result_w = {{ 32 {mul_operand_a_q[32]}}, mul_operand_a_q}*{{ 32 {mul_operand_b_q[32]}}, mul_operand_b_q};
assign result_o = mulhi_sel_q ? mult_result_w[63:32] : mult_result_w[31:0];

assign ready_o = (mult_inst_w) ? 1'b0 : 1'b1;
endmodule