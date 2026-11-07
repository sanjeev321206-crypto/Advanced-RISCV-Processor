
module execute_stage (
    input wire [31:0] pc,
    input wire [31:0] pc_plus4,
    input wire [31:0] reg_data1,
    input wire [31:0] reg_data2,
    input wire [31:0] immediate,

    input wire [4:0] rs1,
    input wire [4:0] rs2,
    input wire [4:0] rd,

    input wire [3:0] alu_control,
    input wire alu_src,
    input wire branch,
    input wire jump,
    input wire jalr,
    input wire lui,
    input wire auipc,
    input wire [2:0] funct3,

    output wire [31:0] alu_result,
    output wire [31:0] store_data,
    output wire [31:0] branch_target,
    output wire [31:0] jump_target,
    output wire branch_taken,
    output wire [31:0] writeback_data
);

    wire [31:0] alu_operand_b;
    wire [31:0] alu_result_internal;
    wire alu_zero;

    alu_operand_mux operand_mux (
        .reg_data(reg_data2),
        .immediate(immediate),
        .alu_src(alu_src),
        .alu_operand(alu_operand_b)
    );

    alu arithmetic_unit (
        .a(reg_data1),
        .b(alu_operand_b),
        .alu_control(alu_control),
        .result(alu_result_internal),
        .zero(alu_zero)
    );

    branch_comparator comparator (
        .operand_a(reg_data1),
        .operand_b(reg_data2),
        .funct3(funct3),
        .branch_taken(branch_taken)
    );

    assign store_data = reg_data2;

    assign alu_result = lui ? immediate :
                        auipc ? pc + immediate :
                        alu_result_internal;

    assign branch_target = pc + immediate;

    assign jump_target = jalr ?
        ((reg_data1 + immediate) & 32'hFFFFFFFE) :
        (pc + immediate);

    assign writeback_data = jump ? pc_plus4 : alu_result;

endmodule
