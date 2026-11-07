
module next_pc (
    input wire [31:0] pc,
    input wire [31:0] branch_target,
    input wire [31:0] jump_target,
    input wire branch_taken,
    input wire jump,
    output reg [31:0] next_pc
);

    always @(*) begin
        if (jump)
            next_pc = jump_target;
        else if (branch_taken)
            next_pc = branch_target;
        else
            next_pc = pc + 32'd4;
    end

endmodule
