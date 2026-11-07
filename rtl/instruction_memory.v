
module instruction_memory #(
    parameter WORDS = 256
)(
    input wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:WORDS-1];

    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            memory[i] = 32'h00000013;
    end

    assign instruction =
        (address[1:0] == 2'b00 && address < WORDS*4)
        ? memory[address[31:2]]
        : 32'h00000013;

endmodule
