
module control_unit (
    input wire [31:0] instruction,

    output reg reg_write,
    output reg mem_read,
    output reg mem_write,
    output reg mem_to_reg,
    output reg alu_src,

    output reg branch,
    output reg jump,
    output reg jalr,
    output reg lui,
    output reg auipc,

    output reg [3:0] alu_control
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    always @(*) begin

        // Default values
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        mem_to_reg = 0;
        alu_src = 0;

        branch = 0;
        jump = 0;
        jalr = 0;
        lui = 0;
        auipc = 0;

        alu_control = ALU_ADD;

        case (opcode)

            // R-type instructions
            7'b0110011: begin

                reg_write = 1;

                case (funct3)

                    3'b000:
                        alu_control =
                            (funct7 == 7'b0100000) ?
                            ALU_SUB : ALU_ADD;

                    3'b111: alu_control = ALU_AND;
                    3'b110: alu_control = ALU_OR;
                    3'b100: alu_control = ALU_XOR;
                    3'b001: alu_control = ALU_SLL;
                    3'b101:
                        alu_control =
                            (funct7 == 7'b0100000) ?
                            ALU_SRA : ALU_SRL;

                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;

                    default: reg_write = 0;

                endcase
            end

            // I-type arithmetic
            7'b0010011: begin

                reg_write = 1;
                alu_src = 1;

                case (funct3)

                    3'b000: alu_control = ALU_ADD;
                    3'b111: alu_control = ALU_AND;
                    3'b110: alu_control = ALU_OR;
                    3'b100: alu_control = ALU_XOR;
                    3'b001: alu_control = ALU_SLL;
                    3'b010: alu_control = ALU_SLT;
                    3'b011: alu_control = ALU_SLTU;

                    3'b101:
                        alu_control =
                            (funct7 == 7'b0100000) ?
                            ALU_SRA : ALU_SRL;

                    default: reg_write = 0;

                endcase
            end

            // Load instructions
            7'b0000011: begin

                reg_write = 1;
                mem_read = 1;
                mem_to_reg = 1;
                alu_src = 1;
                alu_control = ALU_ADD;

            end

            // Store instructions
            7'b0100011: begin

                mem_write = 1;
                alu_src = 1;
                alu_control = ALU_ADD;

            end

            // Branch instructions
            7'b1100011: begin

                branch = 1;

                case (funct3)

                    3'b000,
                    3'b001,
                    3'b100,
                    3'b101,
                    3'b110,
                    3'b111: alu_control = ALU_SUB;

                    default: branch = 0;

                endcase
            end

            // JAL
            7'b1101111: begin

                reg_write = 1;
                jump = 1;

            end

            // JALR
            7'b1100111: begin

                reg_write = 1;
                jump = 1;
                jalr = 1;
                alu_src = 1;

            end

            // LUI
            7'b0110111: begin

                reg_write = 1;
                lui = 1;

            end

            // AUIPC
            7'b0010111: begin

                reg_write = 1;
                auipc = 1;
                alu_src = 1;

            end

            default: begin
                // Unsupported instruction: retain safe defaults
            end

        endcase

    end

endmodule
