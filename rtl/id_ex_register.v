
module id_ex_register (
    input wire clk,
    input wire reset,
    input wire flush,

    input wire [31:0] pc_in,
    input wire [31:0] pc_plus4_in,
    input wire [31:0] reg_data1_in,
    input wire [31:0] reg_data2_in,
    input wire [31:0] immediate_in,

    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,
    input wire [4:0] rd_in,

    input wire [3:0] alu_control_in,

    input wire reg_write_in,
    input wire mem_read_in,
    input wire mem_write_in,
    input wire mem_to_reg_in,
    input wire alu_src_in,
    input wire branch_in,
    input wire jump_in,
    input wire jalr_in,
    input wire lui_in,
    input wire auipc_in,

    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] reg_data1_out,
    output reg [31:0] reg_data2_out,
    output reg [31:0] immediate_out,

    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out,

    output reg [3:0] alu_control_out,

    output reg reg_write_out,
    output reg mem_read_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg alu_src_out,
    output reg branch_out,
    output reg jump_out,
    output reg jalr_out,
    output reg lui_out,
    output reg auipc_out
);

    always @(posedge clk or posedge reset) begin

        if (reset || flush) begin

            pc_out <= 0;
            pc_plus4_out <= 0;
            reg_data1_out <= 0;
            reg_data2_out <= 0;
            immediate_out <= 0;

            rs1_out <= 0;
            rs2_out <= 0;
            rd_out <= 0;

            alu_control_out <= 0;

            reg_write_out <= 0;
            mem_read_out <= 0;
            mem_write_out <= 0;
            mem_to_reg_out <= 0;
            alu_src_out <= 0;
            branch_out <= 0;
            jump_out <= 0;
            jalr_out <= 0;
            lui_out <= 0;
            auipc_out <= 0;

        end

        else begin

            pc_out <= pc_in;
            pc_plus4_out <= pc_plus4_in;
            reg_data1_out <= reg_data1_in;
            reg_data2_out <= reg_data2_in;
            immediate_out <= immediate_in;

            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;

            alu_control_out <= alu_control_in;

            reg_write_out <= reg_write_in;
            mem_read_out <= mem_read_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            alu_src_out <= alu_src_in;
            branch_out <= branch_in;
            jump_out <= jump_in;
            jalr_out <= jalr_in;
            lui_out <= lui_in;
            auipc_out <= auipc_in;

        end

    end

endmodule
