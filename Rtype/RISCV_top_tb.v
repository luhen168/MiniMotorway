module RISCV_top_tb;
    
    reg clk;
    reg rst;
  
    RISCV_top uut (
        .clk(clk),
        .rst(rst) 
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
       
    end
    initial begin 
        rst = 0;
        #5 rst = 1;
      
    end
    

    initial begin
    // Test RV32I base integer Instruction R-type
    // 31 27 26 25|24 20 |19 15 |14 12 | 11 7 | 6 0
    //    funct7    rs2     rs1  funct3   rd    opcode      
        // add x3, x2, x1
        uut.IMEM.Imemory[0] = 32'b00000000000100010000000110110011;
        // sub x3, x2, x1
        uut.IMEM.Imemory[4] = 32'b01000000000100010000000110110011;
        // xor x3, x2, x1
        uut.IMEM.Imemory[8] = 32'b00000000000100010100000110110011;
        // or x3, x2, x1
        uut.IMEM.Imemory[16] = 32'b00000000000100010110000110110011;
        // and x3, x2, x1
        uut.IMEM.Imemory[20] = 32'b00000000000100010111000110110011;
        // sll x3, x2, x1
        uut.IMEM.Imemory[24] = 32'b00000000000100010001000110110011;
        // srl x3, x2, x1
        uut.IMEM.Imemory[28] = 32'b00000000000100010101000110110011;
        // sra x3, x2, x1
        // uut.IMEM.Imemory[7] = 32'b01000000000100010101000110110011;
        // slt x3, x2, x1
        uut.IMEM.Imemory[32] = 32'b00000000000100010010000110110011;
        // sltu x3, x2, x1
        // uut.IMEM.Imemory[9] = 32'b00000000000100010011000110110011;
      
       // add x3, x1, x3
        //uut.IMEM.Imemory[4] = 32'b00000000001100001000000110110011;
        //uut.IMEM.Imemory[0] = 32'b00000000001000001000000110110011;
        //sub x3, x1, x3 
        //uut.IMEM.Imemory[4] = 32'b01000000001100001000000110110011;
        //lw x3, 8(x1), 
        //uut.IMEM.Imemory[0] = 32'b00000000100000001010000110000011;
        //addi x3, x1, 1
        //uut.IMEM.Imemory[0] = 32'b00000000000100001000000110010011;
        //sw x3, 8(x1)
        // uut.IMEM.Imemory[0] = 32'b00000000001100001010010000100011;
        //auipc x1, 4
        //uut.IMEM.Imemory[0] = 32'b00000000000000000100000010010111;
        //jal jal x1, 2
        //uut.IMEM.Imemory[0] = 32'b00000000001000000000000011101111;
        //LUI x1, 4
        //uut.IMEM.Imemory[0] = 32'b00000000000000000100000010110111;
        //jalr x1, x3, 4
        //uut.IMEM.Imemory[0] = 32'b00000000010000011000000011100111;
        //beq x1, x3, 8 
        //uut.IMEM.Imemory[0] = 32'b00000000001100001000010001100011;
        //bne x1, x3, 8
        //uut.IMEM.Imemory[0] = 32'b00000000001100001001010001100011;
        //blt x1, x3, 8
        //uut.IMEM.Imemory[0] = 32'b00000000001100001100010001100011;
        
        uut.RegisterFile.regfile[1] = 32'h00000005; // x1 = 5
        uut.RegisterFile.regfile[2] = 32'h00000007; // x2 = 7
        uut.RegisterFile.regfile[3] = 32'h00000007; // x3 = 7
        // uut.DMEM.DataMemory[15] = 32'h00000001; 
        
    end

    
    initial begin
        #1000;
        
        $stop;
    end
    
    initial begin
        $monitor("Time = %0d", 
                 $time);
    end

endmodule

