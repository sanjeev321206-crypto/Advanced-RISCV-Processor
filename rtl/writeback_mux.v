
module writeback_mux (
    input wire [31:0] alu_result,
    input wire [31:0] memory_data,
    input wire [31:0] pc_plus4,
    input wire [1:0] result_select,
    output reg [31:0] writeback_data
);

    always @(*) begin
        case (result_select)
            2'b00: writeback_data = alu_result;
            2'b01: writeback_data = memory_data;
            2'b10: writeback_data = pc_plus4;
            default: writeback_data = alu_result;
        endcase
    end

endmodule
