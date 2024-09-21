`timescale 1ns/1ns

module RISCV_top_tb;
    
    reg clk;
    reg rst;
  
    riscv_Rtype_top core (
        .clk(clk),
        .rst(rst) 
    );


    

    always #5 clk = !clk;
    
    initial begin
        clk  = 0;
        rst = 0;
        #10 rst = 1;
        core.u_id_stage.u_reg_file.regfile[1] = 32'h00000005; // x1 = 5
        core.u_id_stage.u_reg_file.regfile[2] = 32'h00000007; // x2 = 7
        //#1399 $finish;
        repeat (150) @(posedge clk);
        $stop;
    end

    initial begin
        $readmemh("/home/luanle/DigitalDesign/Lab/MiniMotorway/SingleCycleRiscV/imem.mem", core.u_if_stage.u_imem.mem);
    end

endmodule

