`timescale 1ns / 1ns

import ibex_pkg::*;
module ibex_core_tb #(
  parameter bit          PMPEnable         = 1'b0,
  parameter int unsigned PMPGranularity    = 0,
  parameter int unsigned PMPNumRegions     = 4,
  parameter int unsigned MHPMCounterNum    = 0,
  parameter int unsigned MHPMCounterWidth  = 40,
  parameter bit          RV32E             = 1'b0,
  parameter rv32m_e      RV32M             = RV32MFast,
  parameter rv32b_e      RV32B             = RV32BNone,
  parameter bit          BranchTargetALU   = 1'b0,
  parameter bit          WritebackStage    = 1'b0,
  parameter bit          ICache            = 1'b0,
  parameter bit          ICacheECC         = 1'b0,
  parameter int unsigned BusSizeECC        = BUS_SIZE,
  parameter int unsigned TagSizeECC        = IC_TAG_SIZE,
  parameter int unsigned LineSizeECC       = IC_LINE_SIZE,
  parameter bit          BranchPredictor   = 1'b0,
  parameter bit          DbgTriggerEn      = 1'b0,
  parameter int unsigned DbgHwBreakNum     = 1,
  parameter bit          ResetAll          = 1'b0,
  parameter lfsr_seed_t  RndCnstLfsrSeed   = RndCnstLfsrSeedDefault,
  parameter lfsr_perm_t  RndCnstLfsrPerm   = RndCnstLfsrPermDefault,
  parameter bit          SecureIbex        = 1'b0,
  parameter bit          DummyInstructions = 1'b0,
  parameter bit          RegFileECC        = 1'b0,
  parameter int unsigned RegFileDataWidth  = 32,
  parameter bit          MemECC            = 1'b0,
  parameter int unsigned MemDataWidth      = MemECC ? 32 + 7 : 32,
  parameter int unsigned DmHaltAddr        = 32'h1A110800,
  parameter int unsigned DmExceptionAddr   = 32'h1A110808
) (

);

  // Clock and reset signals
  logic clk_i;
  logic rst_ni;

  // Inputs
  logic [31:0] hart_id_i;
  logic [31:0] boot_addr_i;
  logic instr_gnt_i;
  logic instr_rvalid_i;
  logic [31:0] instr_rdata_i;
  logic instr_err_i;
  logic data_gnt_i;
  logic data_rvalid_i;
  logic [31:0] data_rdata_i;
  logic data_err_i;
  logic [RegFileDataWidth-1:0] rf_rdata_a_ecc_i;
  logic [RegFileDataWidth-1:0] rf_rdata_b_ecc_i;
  logic [TagSizeECC-1:0] ic_tag_rdata_i [IC_NUM_WAYS];
  logic [LineSizeECC-1:0] ic_data_rdata_i [IC_NUM_WAYS];
  logic ic_scr_key_valid_i;
  logic irq_software_i;
  logic irq_timer_i;
  logic irq_external_i;
  logic [14:0] irq_fast_i;
  logic irq_nm_i;
  logic debug_req_i;
  ibex_mubi_t fetch_enable_i;

  // Outputs
  logic instr_req_o;
  logic [31:0] instr_addr_o;
  logic data_req_o;
  logic data_we_o;
  logic [3:0] data_be_o;
  logic [31:0] data_addr_o;
  logic [31:0] data_wdata_o;
  logic dummy_instr_id_o;
  logic dummy_instr_wb_o;
  logic [4:0] rf_raddr_a_o;
  logic [4:0] rf_raddr_b_o;
  logic [4:0] rf_waddr_wb_o;
  logic rf_we_wb_o;
  logic [RegFileDataWidth-1:0] rf_wdata_wb_ecc_o;
  logic [IC_NUM_WAYS-1:0] ic_tag_req_o;
  logic ic_tag_write_o;
  logic [IC_INDEX_W-1:0] ic_tag_addr_o;
  logic [TagSizeECC-1:0] ic_tag_wdata_o;
  logic [IC_NUM_WAYS-1:0] ic_data_req_o;
  logic ic_data_write_o;
  logic [IC_INDEX_W-1:0] ic_data_addr_o;
  logic [LineSizeECC-1:0] ic_data_wdata_o;
  logic ic_scr_key_req_o;
  logic irq_pending_o;
  crash_dump_t crash_dump_o;
  logic double_fault_seen_o;
  logic alert_minor_o;
  logic alert_major_internal_o;
  logic alert_major_bus_o;
  ibex_mubi_t core_busy_o;

  // Instantiate the ibex_core
  ibex_core uut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .hart_id_i(hart_id_i),
    .boot_addr_i(boot_addr_i),
    .instr_req_o(instr_req_o),
    .instr_gnt_i(instr_gnt_i),
    .instr_rvalid_i(instr_rvalid_i),
    .instr_addr_o(instr_addr_o),
    .instr_rdata_i(instr_rdata_i),
    .instr_err_i(instr_err_i),
    .data_req_o(data_req_o),
    .data_gnt_i(data_gnt_i),
    .data_rvalid_i(data_rvalid_i),
    .data_we_o(data_we_o),
    .data_be_o(data_be_o),
    .data_addr_o(data_addr_o),
    .data_wdata_o(data_wdata_o),
    .data_rdata_i(data_rdata_i),
    .data_err_i(data_err_i),
    .dummy_instr_id_o(dummy_instr_id_o),
    .dummy_instr_wb_o(dummy_instr_wb_o),
    .rf_raddr_a_o(rf_raddr_a_o),
    .rf_raddr_b_o(rf_raddr_b_o),
    .rf_waddr_wb_o(rf_waddr_wb_o),
    .rf_we_wb_o(rf_we_wb_o),
    .rf_wdata_wb_ecc_o(rf_wdata_wb_ecc_o),
    .rf_rdata_a_ecc_i(rf_rdata_a_ecc_i),
    .rf_rdata_b_ecc_i(rf_rdata_b_ecc_i),
    .ic_tag_req_o(ic_tag_req_o),
    .ic_tag_write_o(ic_tag_write_o),
    .ic_tag_addr_o(ic_tag_addr_o),
    .ic_tag_wdata_o(ic_tag_wdata_o),
    .ic_tag_rdata_i(ic_tag_rdata_i),
    .ic_data_req_o(ic_data_req_o),
    .ic_data_write_o(ic_data_write_o),
    .ic_data_addr_o(ic_data_addr_o),
    .ic_data_wdata_o(ic_data_wdata_o),
    .ic_data_rdata_i(ic_data_rdata_i),
    .ic_scr_key_valid_i(ic_scr_key_valid_i),
    .ic_scr_key_req_o(ic_scr_key_req_o),
    .irq_software_i(irq_software_i),
    .irq_timer_i(irq_timer_i),
    .irq_external_i(irq_external_i),
    .irq_fast_i(irq_fast_i),
    .irq_nm_i(irq_nm_i),
    .irq_pending_o(irq_pending_o),
    .debug_req_i(debug_req_i),
    .crash_dump_o(crash_dump_o),
    .double_fault_seen_o(double_fault_seen_o),
    .fetch_enable_i(fetch_enable_i),
    .alert_minor_o(alert_minor_o),
    .alert_major_internal_o(alert_major_internal_o),
    .alert_major_bus_o(alert_major_bus_o),
    .core_busy_o(core_busy_o)
  );

  // Clock generation
  always #5 clk_i = ~clk_i;

  // Test sequence
  initial begin
    // Initialize inputs
    clk_i = 0;
    rst_ni = 0;
    // Release reset after some time
    #10 rst_ni = 1;
    hart_id_i = 32'h0;
    boot_addr_i = 32'h00010000;
    // instr_gnt_i = 0;
    // instr_rvalid_i = 0;
    instr_gnt_i = 1;
    instr_rvalid_i = 1;
    instr_rdata_i = 32'h00000000;
    instr_err_i = 0;
    data_gnt_i = 1;
    data_rvalid_i = 1;
    data_rdata_i = 32'h00000000;
    data_err_i = 0;
    rf_rdata_a_ecc_i = 32'h00000000;
    rf_rdata_b_ecc_i = 32'h00000000;
    irq_software_i = 0;
    irq_timer_i = 0;
    irq_external_i = 0;
    irq_fast_i = 15'h0;
    irq_nm_i = 0;
    debug_req_i = 0;
    fetch_enable_i = IbexMuBiOn;

   

    // Feed instructions to the core

    // instr_rdata_i = 32'h00302503; // Lệnh 1 lw x10, 3
    // #10;
    // instr_rdata_i = 32'h05056593; // Lệnh 2
    // #10;
    // instr_rdata_i = 32'h00500613; // Lệnh 3
    // #10;
    // instr_rdata_i = 32'h014000ef; // Lệnh 4
    // #10;
    // instr_rdata_i = 32'h00c02023; // Lệnh 5
    // #10;
    // instr_rdata_i = 32'h00002683; // Lệnh 6
    // #10;
    // instr_rdata_i = 32'h0005f713; // Lệnh 7
    // #10;
    // instr_rdata_i = 32'h00e00c63; // Lệnh 8
    // #10;
    // instr_rdata_i = 32'h00b007b3; // Lệnh 9
    // #10;
    // instr_rdata_i = 32'h00000837; // Lệnh 10
    // #10;
    // instr_rdata_i = 32'h00c86813; // Lệnh 11
    // #10;
    // instr_rdata_i = 32'h00480067; // Lệnh 12
    // #10;
    // instr_rdata_i = 32'h00180813; // Lệnh 13
    // #10;
    // instr_rdata_i = 32'hfffff8b7; // Lệnh 14
    // #10;
    // instr_rdata_i = 32'h4108d893; // Lệnh 15
    // #10;
    // instr_rdata_i = 32'h01100463; // Lệnh 16
    // #10;

    #13990;
    // Stop simulation
    $stop;
  end
endmodule

