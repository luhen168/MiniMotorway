module store_modifier (
    input sb, sh, 
    input [31:0] addr_in,
    input [31:0] data_in,
    // input data_gnt,
    output reg [3:0] data_be_o,
    output reg [31:0] data_out
);
    reg [1:0] rdata_offset;
    
    always @(sb or sh or addr_in or data_in)
    begin
        // Check address align
        rdata_offset = addr_in[1:0];
        case({sb,sh})
            // sw
            2'b00: begin
                case (rdata_offset)
                    2'b00:   data_be_o = 4'b1111;
                    2'b01:   data_be_o = 4'b1110;
                    2'b10:   data_be_o = 4'b1100;
                    2'b11:   data_be_o = 4'b1000;
                    default: data_be_o = 4'b1111;
                endcase // case (data_offset)   
            end

            // sb
            2'b10: begin // Writing a byte
                case (rdata_offset)
                    2'b00:   data_be_o = 4'b0001;
                    2'b01:   data_be_o = 4'b0010;
                    2'b10:   data_be_o = 4'b0100;
                    2'b11:   data_be_o = 4'b1000;
                    default: data_be_o = 4'b1111;
                endcase // case (data_offset)
            end

            // sh
            2'b01: begin // Writing a half word
                case (rdata_offset)
                    2'b00:   data_be_o = 4'b0011;
                    2'b01:   data_be_o = 4'b0110;
                    2'b10:   data_be_o = 4'b1100;
                    2'b11:   data_be_o = 4'b1000;
                    default: data_be_o = 4'b1111;
                endcase // case (data_offset)
            end

            default: data_be_o = 4'b1111;
        endcase
    end


    /////////////////////
    // WData alignment //
    /////////////////////

    // prepare data to be written to the memory
    // we handle misaligned accesses, half word and byte accesses here
    always @(data_in or addr_in) begin
        rdata_offset = addr_in[1:0];
        case (rdata_offset)
            2'b00:   data_out =  data_in[31:0];
            2'b01:   data_out = {data_in[23:0], data_in[31:24]};
            2'b10:   data_out = {data_in[15:0], data_in[31:16]};
            2'b11:   data_out = {data_in[ 7:0], data_in[31: 8]};
            default: data_out =  data_in[31:0];
        endcase // case (data_offset)
    end

endmodule

