
module instruction_cache #(
    parameter CACHE_LINES = 16
)(
    input wire clk,
    input wire reset,

    input wire [31:0] address,

    output reg [31:0] instruction,
    output reg hit
);

    reg valid [0:CACHE_LINES-1];
    reg [23:0] tag [0:CACHE_LINES-1];
    reg [127:0] cache_data [0:CACHE_LINES-1];

    reg [31:0] memory [0:255];

    wire [3:0] index;
    wire [23:0] address_tag;
    wire [1:0] word_offset;

    integer i;

    assign index = address[7:4];
    assign address_tag = address[31:8];
    assign word_offset = address[3:2];

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013;
    end

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid[i] <= 0;
                tag[i] <= 0;
                cache_data[i] <= 0;
            end
        end

        else if (!valid[index] || tag[index] != address_tag) begin

            valid[index] <= 1;
            tag[index] <= address_tag;

            cache_data[index][31:0] <= memory[{address[7:4], 2'b00}];
            cache_data[index][63:32] <= memory[{address[7:4], 2'b01}];
            cache_data[index][95:64] <= memory[{address[7:4], 2'b10}];
            cache_data[index][127:96] <= memory[{address[7:4], 2'b11}];

        end

    end

    always @(*) begin

        if (valid[index] && tag[index] == address_tag) begin
            hit = 1'b1;

            case (word_offset)
                2'b00: instruction = cache_data[index][31:0];
                2'b01: instruction = cache_data[index][63:32];
                2'b10: instruction = cache_data[index][95:64];
                2'b11: instruction = cache_data[index][127:96];
            endcase

        end

        else begin
            hit = 1'b0;
            instruction = 32'h00000013;
        end

    end

endmodule
