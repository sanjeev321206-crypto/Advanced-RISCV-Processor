
module decode_stage (
    input wire clk,
    input wire reset,
    input wire [31:0] pc,
    input wire [31:0] pc_plus4,
    input wire [31:0] instruction,

    input wire wb_reg_write,
    input wire [4:0] wb_rd,
    input wire [31:0] wb_data,

    output wire [31:0] reg_data1,
    output wire [31:0] reg_data2,
    output wire [31:0] immediate,

    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [4:0] rd,
    output wire [2:0] funct3,

    output wire reg_write,
    output wire mem_read,
    output wire mem_write,
    output wire mem_to_reg,
    output wire alu_src,
    output wire branch,
    output wire jump,
    output wire jalr,
    output wire lui,
    output wire auipc,
    output wire [3:0] alu_control
);

    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];

    register_file rf (
        .clk(clk),
        .reset(reset),
        .reg_write(wb_reg_write),
        .read_addr1(rs1),
        .read_addr2(rs2),
        .write_addr(wb_rd),
        .write_data(wb_data),
        .read_data1(reg_data1),
        .read_data2(reg_data2)
    );

    immediate_generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    control_unit cu (
        .instruction(instruction),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc),
        .alu_control(alu_control)
    );

endmodule
