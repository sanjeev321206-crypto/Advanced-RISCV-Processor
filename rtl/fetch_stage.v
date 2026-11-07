
module fetch_stage #(
    parameter IMEM_WORDS = 256
)(
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,

    input wire redirect,
    input wire [31:0] redirect_target,

    output wire [31:0] pc,
    output wire [31:0] instruction,
    output wire [31:0] pc_plus4
);

    wire [31:0] next_pc_value;

    program_counter pc_unit (
        .clk(clk),
        .reset(reset),
        .enable(!stall),
        .next_pc(next_pc_value),
        .pc(pc)
    );

    instruction_memory #(
        .WORDS(IMEM_WORDS)
    ) instruction_memory_unit (
        .address(pc),
        .instruction(instruction)
    );

    assign pc_plus4 = pc + 32'd4;

    assign next_pc_value =
        redirect ? redirect_target : pc_plus4;

endmodule
