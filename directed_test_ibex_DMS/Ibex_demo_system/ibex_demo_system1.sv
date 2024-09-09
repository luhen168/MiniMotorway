// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// The Ibex demo system, which instantiates and connects the following blocks:
// - Memory bus.
// - Ibex top module.
// - RAM memory to contain code and data.
// - GPIO driving logic.
// - UART for serial communication.
// - Timer.
// - Debug module.
// - SPI for driving LCD screen.
module ibex_demo_system  #(
    parameter ibex_pkg::regfile_e RegFile  = ibex_pkg::RegFileFPGA
)(
    input  logic clk_sys_i,
    input  logic rst_sys_ni,

    // Imem Memory Interface of ibex_demo_system
    // input  logic instr_req, 
    

    // Data Memory Interface of ibex_demo_system
    output logic data_rvalid,
    output logic [31:0] data_rdata
);

  // Internal signal Imem (ram) <-> core
  logic instr_req;
  logic core_instr_req;
  logic instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;
  logic instr_gnt_i ;

  // Internal signal Dmem (ram) <-> core
  logic data_req;
  logic data_we;
  logic [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic data_gnt_i = 1'b1;
  

  assign instr_req = core_instr_req;
  // assign core_instr_req = instr_req;
  assign instr_gnt_i = instr_req;

  always @(posedge clk_sys_i or negedge rst_sys_ni) begin
    if (!rst_sys_ni) begin
      instr_rvalid  <= 1'b0;
    end else begin
      instr_rvalid  <= instr_gnt_i;
    end
  end

  ibex_top #(
    .RegFile         ( RegFile                                 ),
    .MHPMCounterNum  ( 10                                      ),
    .RV32M           ( ibex_pkg::RV32MFast                     ),
    .RV32B           ( ibex_pkg::RV32BNone                     )
    // .DbgTriggerEn    ( DbgTriggerEn                            ),
    // .DbgHwBreakNum   ( DbgHwBreakNum                           ),
    // .DmHaltAddr      ( DEBUG_START + dm::HaltAddress[31:0]     ),
    // .DmExceptionAddr ( DEBUG_START + dm::ExceptionAddress[31:0])
  ) u_top (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .test_en_i  ('b0),
    .scan_rst_ni(1'b1),
    .ram_cfg_i  ('b0),

    .hart_id_i  (32'b0),
    // First instruction executed is at 0x0 + 0x80.
    .boot_addr_i(32'h00100000),

    //Instruction Mem interface
    .instr_req_o       (core_instr_req),
    .instr_gnt_i       (instr_gnt_i),
    .instr_rvalid_i    (instr_rvalid),
    .instr_addr_o      (instr_addr),
    .instr_rdata_i     (instr_rdata),
    .instr_rdata_intg_i('0),
    .instr_err_i       ('0),

    //Data Mem interface
    .data_req_o       (data_req),
    .data_gnt_i       (data_gnt_i),
    .data_rvalid_i    (data_rvalid),
    .data_we_o        (data_we),
    .data_be_o        (data_be),
    .data_addr_o      (data_addr),
    .data_wdata_o     (data_wdata),
    .data_wdata_intg_o(),
    .data_rdata_i     (data_rdata),
    .data_rdata_intg_i('0),
    .data_err_i       (),

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
    .crash_dump_o       (),
    .double_fault_seen_o(),

    .fetch_enable_i        ('1),
    .alert_minor_o         (),
    .alert_major_internal_o(),
    .alert_major_bus_o     (),
    .core_sleep_o          ()
  );


  ram_1p #(
    .Depth      () ,
    .MemInitFile ()
  ) imem (
    .clk_i(clk_sys_i),
    .rst_ni(rst_sys_ni),

    .req_i(instr_req),  // input ibex_demo_system_top
    .we_i(),
    .be_i(),
    .addr_i(instr_addr), // wire internal <-> core 
    .wdata_i(),
    .rvalid_o(instr_rvalid), // wire internal <-> core 
    .rdata_o(instr_rdata)   //  wire internal <-> core  
  );

  ram_1p #( 
    .Depth      () ,
    .MemInitFile ()
  ) dmem (
    .clk_i(clk_sys_i),
    .rst_ni(rst_sys_ni),

    .req_i(data_req),
    .we_i(data_we),
    .be_i(data_be),
    .addr_i(data_addr),
    .wdata_i(data_wdata),
    .rvalid_o(data_rvalid),
    .rdata_o(data_rdata)
  );




endmodule
