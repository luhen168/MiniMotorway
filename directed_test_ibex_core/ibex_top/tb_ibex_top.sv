`timescale 1ns / 1ns

import ibex_pkg::*;
module tb_ibex_top #(
  parameter bit          PMPEnable                    = 1'b0,
  parameter int unsigned PMPGranularity               = 0,
  parameter int unsigned PMPNumRegions                = 4,
  parameter int unsigned MHPMCounterNum               = 0,
  parameter int unsigned MHPMCounterWidth             = 40,
  parameter bit          RV32E                        = 1'b0,
  parameter rv32m_e      RV32M                        = RV32MFast,
  parameter rv32b_e      RV32B                        = RV32BNone,
  parameter regfile_e    RegFile                      = RegFileFF,
  parameter bit          BranchTargetALU              = 1'b0,
  parameter bit          WritebackStage               = 1'b0,
  parameter bit          ICache                       = 1'b0,
  parameter bit          ICacheECC                    = 1'b0,
  parameter bit          BranchPredictor              = 1'b0,
  parameter bit          DbgTriggerEn                 = 1'b0,
  parameter int unsigned DbgHwBreakNum                = 1,
  parameter bit          SecureIbex                   = 1'b0,
  parameter bit          ICacheScramble               = 1'b0,
  parameter int unsigned ICacheScrNumPrinceRoundsHalf = 2,
  parameter lfsr_seed_t  RndCnstLfsrSeed              = RndCnstLfsrSeedDefault,
  parameter lfsr_perm_t  RndCnstLfsrPerm              = RndCnstLfsrPermDefault,
  parameter int unsigned DmHaltAddr                   = 32'h1A110800,
  parameter int unsigned DmExceptionAddr              = 32'h1A110808,
  // Default seed and nonce for scrambling
  parameter logic [SCRAMBLE_KEY_W-1:0]   RndCnstIbexKey   = RndCnstIbexKeyDefault,
  parameter logic [SCRAMBLE_NONCE_W-1:0] RndCnstIbexNonce = RndCnstIbexNonceDefault
) (
  
);

  // Clock and Reset
  logic                         clk_i;
  logic                         rst_ni;

  logic                         test_en_i;     // enable all clock gates for testing
  prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i;

  logic [31:0]                  hart_id_i;
  logic [31:0]                  boot_addr_i;

  // Instruction memory interface
  logic                         instr_req_o;
  logic                         instr_gnt_i;
  logic                         instr_rvalid_i;
  logic [31:0]                  instr_addr_o;
  logic [31:0]                  instr_rdata_i;
  logic [6:0]                   instr_rdata_intg_i;
  logic                         instr_err_i;

  // Data memory interface
  logic                         data_req_o;
  logic                         data_gnt_i;
  logic                         data_rvalid_i;
  logic                         data_we_o;
  logic [3:0]                   data_be_o;
  logic [31:0]                  data_addr_o;
  logic [31:0]                  data_wdata_o;
  logic [6:0]                   data_wdata_intg_o;
  logic [31:0]                  data_rdata_i;
  logic [6:0]                   data_rdata_intg_i;
  logic                         data_err_i;

  // Interrupt inputs
  logic                         irq_software_i;
  logic                         irq_timer_i;
  logic                         irq_external_i;
  logic [14:0]                  irq_fast_i;
  logic                         irq_nm_i;       // non-maskeable interrupt

  // Scrambling Interface
  logic                         scramble_key_valid_i;
  logic [SCRAMBLE_KEY_W-1:0]    scramble_key_i;
  logic [SCRAMBLE_NONCE_W-1:0]  scramble_nonce_i;
  logic                         scramble_req_o;

  // Debug Interface
  logic                         debug_req_i;
  crash_dump_t                  crash_dump_o;
  logic                         double_fault_seen_o;

  // RISC-V Formal Interface
  // Does not comply with the coding standards of _i/_o suffixes, but follows
  // the convention of RISC-V Formal Interface Specification.
// `ifdef RVFI
//   output logic                         rvfi_valid;
//   output logic [63:0]                  rvfi_order;
//   output logic [31:0]                  rvfi_insn;
//   output logic                         rvfi_trap;
//   output logic                         rvfi_halt;
//   output logic                         rvfi_intr;
//   output logic [ 1:0]                  rvfi_mode;
//   output logic [ 1:0]                  rvfi_ixl;
//   output logic [ 4:0]                  rvfi_rs1_addr;
//   output logic [ 4:0]                  rvfi_rs2_addr;
//   output logic [ 4:0]                  rvfi_rs3_addr;
//   output logic [31:0]                  rvfi_rs1_rdata;
//   output logic [31:0]                  rvfi_rs2_rdata;
//   output logic [31:0]                  rvfi_rs3_rdata;
//   output logic [ 4:0]                  rvfi_rd_addr;
//   output logic [31:0]                  rvfi_rd_wdata;
//   output logic [31:0]                  rvfi_pc_rdata;
//   output logic [31:0]                  rvfi_pc_wdata;
//   output logic [31:0]                  rvfi_mem_addr;
//   output logic [ 3:0]                  rvfi_mem_rmask;
//   output logic [ 3:0]                  rvfi_mem_wmask;
//   output logic [31:0]                  rvfi_mem_rdata;
//   output logic [31:0]                  rvfi_mem_wdata;
//   output logic [31:0]                  rvfi_ext_pre_mip;
//   output logic [31:0]                  rvfi_ext_post_mip;
//   output logic                         rvfi_ext_nmi;
//   output logic                         rvfi_ext_nmi_int;
//   output logic                         rvfi_ext_debug_req;
//   output logic                         rvfi_ext_debug_mode;
//   output logic                         rvfi_ext_rf_wr_suppress;
//   output logic [63:0]                  rvfi_ext_mcycle;
//   output logic [31:0]                  rvfi_ext_mhpmcounters [10];
//   output logic [31:0]                  rvfi_ext_mhpmcountersh [10];
//   output logic                         rvfi_ext_ic_scr_key_valid;
//   output logic                         rvfi_ext_irq_valid;
// `endif

  // CPU Control Signals
  ibex_mubi_t                   fetch_enable_i;
  logic                         alert_minor_o;
  logic                         alert_major_internal_o;
  logic                         alert_major_bus_o;
  logic                         core_sleep_o;

  // DFT bypass controls
  logic                          scan_rst_ni;

//   // Clock and reset signals
//   logic clk_i;
//   logic rst_ni;

//   // Inputs
//   logic [31:0] hart_id_i;
//   logic [31:0] boot_addr_i;
//   logic                         test_en_i;    // enable all clock gates for testing
//   prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i;
//   logic instr_gnt_i;
//   logic instr_rvalid_i;
//   logic [31:0] instr_rdata_i;
//   logic instr_err_i;
//   logic data_gnt_i;
//   logic data_rvalid_i;
//   logic [31:0] data_rdata_i;
//   logic data_err_i;
//   logic [RegFileDataWidth-1:0] rf_rdata_a_ecc_i;
//   logic [RegFileDataWidth-1:0] rf_rdata_b_ecc_i;
//   logic [TagSizeECC-1:0] ic_tag_rdata_i [IC_NUM_WAYS];
//   logic [LineSizeECC-1:0] ic_data_rdata_i [IC_NUM_WAYS];
//   logic ic_scr_key_valid_i;
//   logic irq_software_i;
//   logic irq_timer_i;
//   logic irq_external_i;
//   logic [14:0] irq_fast_i;
//   logic irq_nm_i;
//   logic debug_req_i;


//   // Outputs
//   logic instr_req_o;
//   logic [31:0] instr_addr_o;
//   logic data_req_o;
//   logic data_we_o;
//   logic [3:0] data_be_o;
//   logic [31:0] data_addr_o;
//   logic [31:0] data_wdata_o;
//   logic dummy_instr_id_o;
//   logic dummy_instr_wb_o;
//   logic [4:0] rf_raddr_a_o;
//   logic [4:0] rf_raddr_b_o;
//   logic [4:0] rf_waddr_wb_o;
//   logic rf_we_wb_o;
//   logic [RegFileDataWidth-1:0] rf_wdata_wb_ecc_o;
//   logic [IC_NUM_WAYS-1:0] ic_tag_req_o;
//   logic ic_tag_write_o;
//   logic [IC_INDEX_W-1:0] ic_tag_addr_o;
//   logic [TagSizeECC-1:0] ic_tag_wdata_o;
//   logic [IC_NUM_WAYS-1:0] ic_data_req_o;
//   logic ic_data_write_o;
//   logic [IC_INDEX_W-1:0] ic_data_addr_o;
//   logic [LineSizeECC-1:0] ic_data_wdata_o;
//   logic ic_scr_key_req_o;
//   logic irq_pending_o;
//   crash_dump_t crash_dump_o;
//   logic double_fault_seen_o;

//   // CPU Control Signals
//   ibex_mubi_t fetch_enable_i;
//   logic alert_minor_o;
//   logic alert_major_internal_o;
//   logic alert_major_bus_o;
//   logic core_sleep_o;

//   // DFT bypass controls
//   logic scan_rst_ni;
  

  // Instantiate the ibex_top
  ibex_top u_ibex_top_i(
    .clk_i (clk_i),
    .rst_ni(rst_ni),

    .test_en_i  ('b0),
    .scan_rst_ni(1'b1),
    .ram_cfg_i  ('b0),

    .hart_id_i  (32'b0),
    // First instruction executed is at 0x0 + 0x80.
    .boot_addr_i(32'h00100000),

    .instr_req_o       (instr_req_o),
    .instr_gnt_i       (instr_gnt_i),
    .instr_rvalid_i    (instr_rvalid_i),
    .instr_addr_o      (instr_addr_o),
    .instr_rdata_i     (instr_rdata_i),
    .instr_rdata_intg_i('0),
    .instr_err_i       ('0),

    .data_req_o       (data_req_o),
    .data_gnt_i       (data_gnt_i),
    .data_rvalid_i    (data_rvalid_i),
    .data_we_o        (data_we_o),
    .data_be_o        (data_be_o),
    .data_addr_o      (data_addr_o),
    .data_wdata_o     (data_wdata_o),
    .data_wdata_intg_o(data_wdata_intg_o),
    .data_rdata_i     (data_rdata_i),
    .data_rdata_intg_i('0),
    .data_err_i       (data_err_i),

    .irq_software_i(1'b0),
    .irq_timer_i   (),
    .irq_external_i(1'b0),
    .irq_fast_i    (),
    .irq_nm_i      (1'b0),

    .scramble_key_valid_i('0),
    .scramble_key_i      ('0),
    .scramble_nonce_i    ('0),
    .scramble_req_o      (),

    .debug_req_i        (),
    // .debug_req_i        (dm_debug_req),
    .crash_dump_o       (),
    .double_fault_seen_o(),

    .fetch_enable_i        ('1),
    .alert_minor_o         (),
    .alert_major_internal_o(),
    .alert_major_bus_o     (),
    .core_sleep_o          ()
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
    // rf_rdata_a_ecc_i = 32'h00000000;
    // rf_rdata_b_ecc_i = 32'h00000000;
    irq_software_i = 0;
    irq_timer_i = 0;
    irq_external_i = 0;
    irq_fast_i = 15'h0;
    irq_nm_i = 0;
    debug_req_i = 0;

    // Instruction memory interface
    // instr_gnt_i = 0;
    // instr_rvalid_i = 0;
    instr_gnt_i = 1;
    instr_rvalid_i = 1;
    instr_err_i = 0;
    #10;
    instr_rdata_i = 32'h00702503; // Lệnh 1 lw x10, 7

    // Data memory interface
    #10;
    data_gnt_i = 1;
    #10;
    data_rvalid_i = 1;
    data_err_i = 0;
    data_rdata_i = 32'hFF;

    #10;
    data_gnt_i = 0;
    #10;
    data_rvalid_i = 0;
    // instr_rdata_i = 32'h05056593; // Lệnh 2 ori x11, x10, 80
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

