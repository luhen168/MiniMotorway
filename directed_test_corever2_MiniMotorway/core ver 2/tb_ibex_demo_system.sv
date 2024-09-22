`timescale 1ns / 1ns

import ibex_pkg::*;
module tb_ibex_demo_system #(
  parameter int                 GpiWidth       = 8,
  parameter int                 GpoWidth       = 16,
  parameter int                 PwmWidth       = 12,
  parameter int unsigned        ClockFrequency = 50_000_000,
  parameter int unsigned        BaudRate       = 115_200,
  parameter ibex_pkg::regfile_e RegFile        = ibex_pkg::RegFileFPGA,
  parameter                     SRAMInitFile   = "ram.vmem"
) (
  
);

  // Clock and Reset
  logic clk_sys_i;
  logic rst_sys_ni;
  

  // Instantiate the ibex_top
  ibex_demo_system #(
      .SRAMInitFile(SRAMInitFile)
  ) u_ibex_demo_system_i(
      .clk_sys_i(clk_sys_i),
      .rst_sys_ni(rst_sys_ni),

      .gp_i(),
      .gp_o(),
      .pwm_o(),
      .uart_rx_i(),
      .uart_tx_o(),
      .spi_rx_i(),
      .spi_tx_o(),
      .spi_sck_o(),

      .tck_i(),    // JTAG test clock pad
      .tms_i(),    // JTAG test mode select pad
      .trst_ni(),  // JTAG test reset pad
      .td_i(),     // JTAG test data input pad
      .td_o()      // JTAG test data output pad
  );

  // Clock generation
  initial begin
    clk_sys_i = 0;
    forever #10 clk_sys_i = ~clk_sys_i;
  end

  // Test sequence
  initial begin
    // Initialize inputs
    rst_sys_ni = 0;
    // Release reset after some time
    #20 rst_sys_ni = 1;
    //Stop simulation
    //repeat (100000) @(posedge clk_sys_i);
    //$stop;
  end

  // initial begin
  //   $readmemh("/home/luanle/IBEX_synthesis/rtl/test_program.mem", u_ibex_demo_system_i.imem_dmem.u_ram.u_impl_generic.mem);
  //   //#13990;
  //   // Stop simulation
  //   //$stop;
  // end
endmodule

