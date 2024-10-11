module compressed_decoder (
  input clk_i, rst_ni,
  input [31:0] instr_i,
  input is_stall_i,
  output reg [31:0] instr_o,
  output is_compressed_o,
  output stall_req_o,
  output reg illegal_instr_o
);
  ////////////////////////
  // Compressed decoder //
  ////////////////////////
  reg is_single_compress;
  reg [31:0] stalled_instr;
  wire [31:0] current_instr;
  wire [31:0] temp_instr;
  reg [31:0] temp_instr_delay;
  reg is_instr_start_at_mid;
  reg is_instr_start_at_mid_delay;
  assign temp_instr = (is_stall_i | is_instr_start_at_mid) ? {instr_i[15:0], stalled_instr[31:16]} : instr_i;
  assign stall_req_o = (is_compressed_o ? ((current_instr[17:16] != 2'b11) ? 1'b1 : 1'b0) : 1'b0) | is_end_start_at_mid;
  wire is_end_start_at_mid_delay_shadow;
  reg stalled_stall_req;
  wire is_end_start_at_mid;
  assign is_end_start_at_mid = is_compressed_o & (instr_i[17:16] != 2'b11) & is_instr_start_at_mid;
  reg is_end_start_at_mid_delay;
  assign is_end_start_at_mid_delay_shadow = is_end_start_at_mid_delay;
  wire should_correct_two_compress_instr_when_at_mid;
  assign should_correct_two_compress_instr_when_at_mid = is_stall_i & is_instr_start_at_mid & is_instr_start_at_mid_delay;
  reg should_correct_compress_delay;
  assign current_instr = should_correct_compress_delay ? temp_instr_delay : (should_correct_two_compress_instr_when_at_mid ? stalled_instr : (is_end_start_at_mid_delay_shadow ? stalled_instr : temp_instr));

  always @(posedge clk_i or negedge rst_ni) begin
    if (~rst_ni) begin
        should_correct_compress_delay <= 1'b0;
        temp_instr_delay <= 32'h0;
        is_instr_start_at_mid <= 1'b0;
        is_instr_start_at_mid_delay <= 1'b0;
        is_end_start_at_mid_delay <= 1'b0;
    end
    else begin
        should_correct_compress_delay <= should_correct_two_compress_instr_when_at_mid;
        is_instr_start_at_mid_delay <= is_instr_start_at_mid;
        is_end_start_at_mid_delay <= is_end_start_at_mid;
        stalled_instr <= instr_i;
        stalled_stall_req <= is_compressed_o;
        temp_instr_delay <= temp_instr;
    end
  end

  always @(posedge stalled_stall_req) begin
      if (stalled_instr[17:16] == 2'b11) is_instr_start_at_mid <= 1'b1;
      else is_instr_start_at_mid <= 1'b0;
  end

  always@(current_instr) begin
    // By default, forward incoming instruction, mark it as legal.
    instr_o         = current_instr;
    illegal_instr_o = 1'b0;
    is_single_compress = (current_instr[1:0] != 2'b11 & current_instr[17:16] == 2'b11);

    // Check if incoming instruction is compressed.
    case (current_instr[1:0])
      // C0
      2'b00: begin
        case (current_instr[15:13])
          3'b000: begin
            // c.addi4spn -> addi rd', x2, imm
            instr_o = {2'b0, current_instr[10:7], current_instr[12:11], current_instr[5],
                       current_instr[6], 2'b00, 5'h02, 3'b000, 2'b01, current_instr[4:2], 7'b0010011};
            if (current_instr[12:5] == 8'b0)  illegal_instr_o = 1'b1;
          end

          3'b010: begin
            // c.lw -> lw rd', imm(rs1')
            instr_o = {5'b0, current_instr[5], current_instr[12:10], current_instr[6],
                       2'b00, 2'b01, current_instr[9:7], 3'b010, 2'b01, current_instr[4:2], 7'b0000011};
          end

          3'b110: begin
            // c.sw -> sw rs2', imm(rs1')
            instr_o = {5'b0, current_instr[5], current_instr[12], 2'b01, current_instr[4:2],
                       2'b01, current_instr[9:7], 3'b010, current_instr[11:10], current_instr[6],
                       2'b00, 7'b0100011};
          end

          3'b001,
          3'b011,
          3'b100,
          3'b101,
          3'b111: begin
            illegal_instr_o = 1'b1;
          end

          default: begin
            illegal_instr_o = 1'b1;
          end
        endcase
      end

      // C1
      //
      // Register address checks for RV32E are performed in the regular instruction decoder.
      // If this check fails, an illegal instruction exception is triggered and the controller
      // writes the actual faulting instruction to mtval.
      2'b01: begin
        case (current_instr[15:13])
          3'b000: begin
            // c.addi -> addi rd, rd, nzimm
            // c.nop
            instr_o = {{6 {current_instr[12]}}, current_instr[12], current_instr[6:2],
                       current_instr[11:7], 3'b0, current_instr[11:7], 7'b0010011};
          end

          3'b001, 3'b101: begin
            // 001: c.jal -> jal x1, imm
            // 101: c.j   -> jal x0, imm
            instr_o = {current_instr[12], current_instr[8], current_instr[10:9], current_instr[6],
                       current_instr[7], current_instr[2], current_instr[11], current_instr[5:3],
                       {9 {current_instr[12]}}, 4'b0, ~current_instr[15], 7'b1101111};
          end

          3'b010: begin
            // c.li -> addi rd, x0, nzimm
            // (c.li hints are translated into an addi hint)
            instr_o = {{6 {current_instr[12]}}, current_instr[12], current_instr[6:2], 5'b0,
                       3'b0, current_instr[11:7], 7'b0010011};
          end

          3'b011: begin
            // c.lui -> lui rd, imm
            // (c.lui hints are translated into a lui hint)
            instr_o = {{15 {current_instr[12]}}, current_instr[6:2], current_instr[11:7], 7'b0110111};

            if (current_instr[11:7] == 5'h02) begin
              // c.addi16sp -> addi x2, x2, nzimm
              instr_o = {{3 {current_instr[12]}}, current_instr[4:3], current_instr[5], current_instr[2],
                         current_instr[6], 4'b0, 5'h02, 3'b000, 5'h02, 7'b0010011};
            end

            if ({current_instr[12], current_instr[6:2]} == 6'b0) illegal_instr_o = 1'b1;
          end

          3'b100: begin
            case (current_instr[11:10])
              2'b00,
              2'b01: begin
                // 00: c.srli -> srli rd, rd, shamt
                // 01: c.srai -> srai rd, rd, shamt
                // (c.srli/c.srai hints are translated into a srli/srai hint)
                instr_o = {1'b0, current_instr[10], 5'b0, current_instr[6:2], 2'b01, current_instr[9:7],
                           3'b101, 2'b01, current_instr[9:7], 7'b0010011};
                if (current_instr[12] == 1'b1)  illegal_instr_o = 1'b1;
              end

              2'b10: begin
                // c.andi -> andi rd, rd, imm
                instr_o = {{6 {current_instr[12]}}, current_instr[12], current_instr[6:2], 2'b01, current_instr[9:7],
                           3'b111, 2'b01, current_instr[9:7], 7'b0010011};
              end

              2'b11: begin
                case ({current_instr[12], current_instr[6:5]})
                  3'b000: begin
                    // c.sub -> sub rd', rd', rs2'
                    instr_o = {2'b01, 5'b0, 2'b01, current_instr[4:2], 2'b01, current_instr[9:7],
                               3'b000, 2'b01, current_instr[9:7], 7'b0110011};
                  end

                  3'b001: begin
                    // c.xor -> xor rd', rd', rs2'
                    instr_o = {7'b0, 2'b01, current_instr[4:2], 2'b01, current_instr[9:7], 3'b100,
                               2'b01, current_instr[9:7], 7'b0110011};
                  end

                  3'b010: begin
                    // c.or  -> or  rd', rd', rs2'
                    instr_o = {7'b0, 2'b01, current_instr[4:2], 2'b01, current_instr[9:7], 3'b110,
                               2'b01, current_instr[9:7], 7'b0110011};
                  end

                  3'b011: begin
                    // c.and -> and rd', rd', rs2'
                    instr_o = {7'b0, 2'b01, current_instr[4:2], 2'b01, current_instr[9:7], 3'b111,
                               2'b01, current_instr[9:7], 7'b0110011};
                  end

                  3'b100,
                  3'b101,
                  3'b110,
                  3'b111: begin
                    // 100: c.subw
                    // 101: c.addw
                    illegal_instr_o = 1'b1;
                  end

                  default: begin
                    illegal_instr_o = 1'b1;
                  end
                endcase
              end

              default: begin
                illegal_instr_o = 1'b1;
              end
            endcase
          end

          3'b110, 3'b111: begin
            // 0: c.beqz -> beq rs1', x0, imm
            // 1: c.bnez -> bne rs1', x0, imm
            instr_o = {{4 {current_instr[12]}}, current_instr[6:5], current_instr[2], 5'b0, 2'b01,
                       current_instr[9:7], 2'b00, current_instr[13], current_instr[11:10], current_instr[4:3],
                       current_instr[12], 7'b1100011};
          end

          default: begin
            illegal_instr_o = 1'b1;
          end
        endcase
      end

      // C2
      //
      // Register address checks for RV32E are performed in the regular instruction decoder.
      // If this check fails, an illegal instruction exception is triggered and the controller
      // writes the actual faulting instruction to mtval.
      2'b10: begin
        case (current_instr[15:13])
          3'b000: begin
            // c.slli -> slli rd, rd, shamt
            // (c.ssli hints are translated into a slli hint)
            instr_o = {7'b0, current_instr[6:2], current_instr[11:7], 3'b001, current_instr[11:7], 7'b0010011};
            if (current_instr[12] == 1'b1)  illegal_instr_o = 1'b1; // reserved for custom extensions
          end

          3'b010: begin
            // c.lwsp -> lw rd, imm(x2)
            instr_o = {4'b0, current_instr[3:2], current_instr[12], current_instr[6:4], 2'b00, 5'h02,
                       3'b010, current_instr[11:7], 7'b0000011};
            if (current_instr[11:7] == 5'b0)  illegal_instr_o = 1'b1;
          end

          3'b100: begin
            if (current_instr[12] == 1'b0) begin
              if (current_instr[6:2] != 5'b0) begin
                // c.mv -> add rd/rs1, x0, rs2
                // (c.mv hints are translated into an add hint)
                instr_o = {7'b0, current_instr[6:2], 5'b0, 3'b0, current_instr[11:7], 7'b0110011};
              end else begin
                // c.jr -> jalr x0, rd/rs1, 0
                instr_o = {12'b0, current_instr[11:7], 3'b0, 5'b0, 7'b1100111};
                if (current_instr[11:7] == 5'b0) illegal_instr_o = 1'b1;
              end
            end else begin
              if (current_instr[6:2] != 5'b0) begin
                // c.add -> add rd, rd, rs2
                // (c.add hints are translated into an add hint)
                instr_o = {7'b0, current_instr[6:2], current_instr[11:7], 3'b0, current_instr[11:7], 7'b0110011};
              end else begin
                if (current_instr[11:7] == 5'b0) begin
                  // c.ebreak -> ebreak
                  instr_o = {32'h00_10_00_73};
                end else begin
                  // c.jalr -> jalr x1, rs1, 0
                  instr_o = {12'b0, current_instr[11:7], 3'b000, 5'b00001, 7'b1100111};
                end
              end
            end
          end

          3'b110: begin
            // c.swsp -> sw rs2, imm(x2)
            instr_o = {4'b0, current_instr[8:7], current_instr[12], current_instr[6:2], 5'h02, 3'b010,
                       current_instr[11:9], 2'b00, 7'b0100011};
          end

          3'b001,
          3'b011,
          3'b101,
          3'b111: begin
            illegal_instr_o = 1'b1;
          end

          default: begin
            illegal_instr_o = 1'b1;
          end
        endcase
      end

      // Incoming instruction is not compressed.
      2'b11:;

      default: begin
        illegal_instr_o = 1'b1;
      end
    endcase
  end

  assign is_compressed_o = (current_instr[1:0] != 2'b11) & ~is_stall_i;


endmodule



