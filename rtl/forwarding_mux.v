
module forwarding_mux (
    input wire [31:0] original_data,
    input wire [31:0] ex_mem_data,
    input wire [31:0] mem_wb_data,
    input wire [1:0] select,

    output reg [31:0] forwarded_data
);

    always @(*) begin
        case (select)
            2'b00: forwarded_data = original_data;
            2'b10: forwarded_data = ex_mem_data;
            2'b01: forwarded_data = mem_wb_data;
            default: forwarded_data = original_data;
        endcase
    end

endmodule
