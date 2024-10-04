module store_modifier (
    input sb, sh, 
    input [31:0] addr_in,
    input [31:0] data_in,
    output reg [31:0] data_out
);
    reg [1:0] rdata_offset;

   always @(sb or sh or data_in or addr_in)
    begin
        rdata_offset = addr_in[1:0];
        case({sb,sh})
            // sw
            2'b00: data_out = data_in;                              
            // sb
            2'b10: begin                                            
                case(rdata_offset)
                    2'b00: data_out = {{24{data_in[7]}}, data_in[7:0]};
                    2'b01: data_out = {{24{data_in[15]}}, data_in[15:8]};
                    2'b10: data_out = {{24{data_in[23]}}, data_in[23:16]};
                    2'b11: data_out = {{24{data_in[31]}}, data_in[31:24]};
                endcase
            end
            // sh
            2'b01: begin                                             
                case(rdata_offset)
                    2'b00: data_out = {{16{data_in[15]}}, data_in[15:0]};
                    2'b01: data_out = {{16{data_in[23]}}, data_in[23:8]};
                    2'b10: data_out = {{16{data_in[31]}}, data_in[31:16]};
                    2'b11: data_out = {{16{data_in[7]}}, data_in[7:0], data_in[31:24]};
                endcase
            end
            default: data_out = data_in;
        endcase
    end
    // always @(sb or sh or data_in)
    // begin
    //     case({sb,sh})
    //         2'b00: data_out = data_in;                      // sw
    //         2'b01: data_out = { {16{1'b0}}, data_in[15:0]}; // sh
    //         2'b10: data_out = { {24{1'b0}}, data_in[7:0]};  // sb
    //         default: data_out = data_in;                    // sw
    //     endcase
    // end
endmodule

