`timescale 1ns / 1ns
module sc_cpu_tb();

    logic clk, resetn;
    logic [31:0] instr, pc, addr_out, mem_out;
    
    
    /*************************** DUT ******************************/
    cpu cpu_dut (
        .i_clk(clk), .i_resetn(resetn),
        .instr(instr),
        .pc(pc),
        .addr_out(addr_out), 
        .mem_out(mem_out)    
    );
    /**************************************************************/
    initial
    begin
        $readmemh("/home/luanle/DigitalDesign/Lab/MiniMotorway/add-01.mem", cpu_dut.imem.rom);
	    //$readmemh("/home/luanle/DigitalDesign/Lab/MiniMotorway/SingleCycleRiscV/imem.mem", cpu_dut.imem.rom);
    end
    //begin
    //    $readmemh("test_compressed.mem", cpu_dut.imem.rom);
    //end
    
    //begin
    //    $readmemh("test_muldiv.mem", cpu_dut.imem.rom);
    //end
    
    always #5 clk = !clk;
    
    initial begin
           clk  = 0;
           resetn = 0;
           #10 resetn = 1;
           //#1399 $finish;
            repeat (100000) @(posedge clk);
            $stop;
    end
    
        
endmodule


