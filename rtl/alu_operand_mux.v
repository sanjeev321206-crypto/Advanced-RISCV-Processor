
module alu_operand_mux (
    input wire [31:0] reg_data,
    input wire [31:0] immediate,
    input wire alu_src,
    output wire [31:0] alu_operand
);

    assign alu_operand = alu_src ? immediate : reg_data;

endmodule
