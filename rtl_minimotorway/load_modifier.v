module load_modifier (
    input lb, lh, load_signext,
    input [31:0] data_in,
    input [31:0] addr_in,
    output reg [31:0] data_out
);
    reg [1:0] rdata_offset;

    always @(lb or lh or load_signext or data_in or addr_in)
    begin
        rdata_offset = addr_in[1:0];
        casez({lb,lh,load_signext})
            3'b00?: data_out = data_in;                              
            // lb signed
            3'b101: begin                                            
                case(rdata_offset)
                    2'b00: data_out = {{24{data_in[7]}}, data_in[7:0]};
                    2'b01: data_out = {{24{data_in[15]}}, data_in[15:8]};
                    2'b10: data_out = {{24{data_in[23]}}, data_in[23:16]};
                    2'b11: data_out = {{24{data_in[31]}}, data_in[31:24]};
                endcase
            end
            // lh signed
            3'b011: begin                                             
                case(rdata_offset)
                    2'b00: data_out = {{16{data_in[15]}}, data_in[15:0]};
                    2'b01: data_out = {{16{data_in[23]}}, data_in[23:8]};
                    2'b10: data_out = {{16{data_in[31]}}, data_in[31:16]};
                    2'b11: data_out = {{16{data_in[7]}}, data_in[7:0], data_in[31:24]};
                endcase
            end
            // lb unsigned
            3'b100: begin                                             
                case(rdata_offset)
                    2'b00: data_out = {24'h00_0000, data_in[7:0]};
                    2'b01: data_out = {24'h00_0000, data_in[15:8]};
                    2'b10: data_out = {24'h00_0000, data_in[23:16]};
                    2'b11: data_out = {24'h00_0000, data_in[31:24]};
                endcase
            end
            // lh unsigned
            3'b010: begin                                             
                case(rdata_offset)
                    2'b00: data_out = {16'h0000, data_in[15:0]};
                    2'b01: data_out = {16'h0000, data_in[23:8]};
                    2'b10: data_out = {16'h0000, data_in[31:16]};
                    2'b11: data_out = {16'h0000, data_in[7:0], data_in[31:24]};
                endcase
            end
            default: data_out = data_in;
        endcase
    end
    // always @(lb or lh or load_signext or data_in)
    // begin
    //     casez({lb,lh,load_signext})
    //         3'b000: data_out = data_in;                              // lw
    //         3'b101: data_out = { {24{data_in[7]}}, data_in[7:0] };   // lb
    //         3'b011: data_out = { {16{data_in[15]}}, data_in[15:0] }; // lh
    //         3'b100: data_out = { {24{1'b0}}, data_in[7:0] };         // lbu
    //         3'b010: data_out = { {16{1'b0}}, data_in[15:0] };        // lhu
    //         default: data_out = data_in;
    //     endcase
    // end
endmodule

