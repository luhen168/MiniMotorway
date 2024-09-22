`timescale 1ns/1ns

module tb_riscv;
    
    reg clk;
    reg rst;
  
    riscv_top core (
        .clk(clk),
        .rst(rst) 
    );


    

    always #5 clk = !clk;
    
    initial begin
        clk  = 0;
        rst = 0;
        #10 rst = 1;
        // core.u_id_stage.u_reg_file.regfile[1] = 32'h00000005; // x1 = 5
        // core.u_id_stage.u_reg_file.regfile[2] = 32'h00000007; // x2 = 7
        //#1399 $finish;
        repeat (1000000) @(posedge clk);
        $stop;
    end

    initial begin
        $readmemh("/home/luanle/DigitalDesign/Lab/MiniMotorway/SingleCycleRiscV/Utype/imem.mem", core.u_if_stage.u_imem.mem);
        //$readmemh("/home/luanle/DigitalDesign/IbexDemoSystemQuestasimSimulation/ram.vmem", core.u_if_stage.u_imem.mem);
        
    end

endmodule

