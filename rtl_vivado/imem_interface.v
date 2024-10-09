/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off WIDTHEXPAND */
module imem_interface(
  // CORE to imem_interface
  input [31:0] pc_addr_i,
  input [31:0] instr_rdata_i,  // Data read from Imem
  
  // IMEM to imem_interface
  input  instr_rvalid_i,
  input  instr_gnt_i,
  input [6:0] instr_rdata_intg_i,
  input instr_err_i,

  // input data_req_d,
  // input data_rvalid,
  // input en_pc,
  output instr_req_o,
  output [31:0] instr_addr_o,
  output [31:0] instr_rdata_o // Data send into core

);

reg data_req_q;
wire [31:0] unused_intg_i;
wire unused_err_i;

// always @(data_req_d) begin
//     data_req_q = data_req_d;
// end
// unused input signal
assign unused_intg_i = instr_rdata_intg_i;
assign unused_err_i = instr_err_i;

// assign instr_req_o = en_pc ? 1'b1 : 1'b0 ;

assign instr_req_o = 1'b1 ;
assign instr_addr_o = pc_addr_i;
assign instr_rdata_o = (instr_gnt_i & instr_rvalid_i) ? instr_rdata_i : 32'h00000013;

endmodule




