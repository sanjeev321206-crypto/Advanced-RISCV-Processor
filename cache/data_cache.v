
module data_cache #(
    parameter CACHE_LINES = 16
)(
    input wire clk,
    input wire reset,

    input wire mem_read,
    input wire mem_write,

    input wire [31:0] address,
    input wire [31:0] write_data,

    output reg [31:0] read_data,
    output wire hit
);

    reg valid [0:CACHE_LINES-1];
    reg [23:0] tag [0:CACHE_LINES-1];
    reg [127:0] cache_data [0:CACHE_LINES-1];

    // Local 4 KB backing memory
    reg [31:0] backing_memory [0:1023];

    wire [3:0] index;
    wire [23:0] address_tag;
    wire [1:0] word_offset;

    integer i;

    assign index = address[7:4];
    assign address_tag = address[31:8];
    assign word_offset = address[3:2];

    assign hit = valid[index] &&
                 (tag[index] == address_tag);

    // Initialize backing memory with recognizable values
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            backing_memory[i] = 32'd100 + i;
    end

    // Cache and memory updates
    always @(posedge clk or posedge reset) begin

        if (reset) begin
            for (i = 0; i < CACHE_LINES; i = i + 1) begin
                valid[i] <= 1'b0;
                tag[i] <= 0;
                cache_data[i] <= 0;
            end
        end

        else if (mem_write) begin

            // Write-through to backing memory
            backing_memory[address[11:2]] <= write_data;

            // Update cache if the line is already present
            if (hit) begin
                cache_data[index][word_offset*32 +: 32]
                    <= write_data;
            end

        end

        else if (mem_read && !hit) begin

            // Fill the complete 16-byte cache line
            valid[index] <= 1'b1;
            tag[index] <= address_tag;

            cache_data[index][31:0] <=
                backing_memory[{address[11:4], 2'b00}];

            cache_data[index][63:32] <=
                backing_memory[{address[11:4], 2'b01}];

            cache_data[index][95:64] <=
                backing_memory[{address[11:4], 2'b10}];

            cache_data[index][127:96] <=
                backing_memory[{address[11:4], 2'b11}];

        end

    end

    // Combinational read
    always @(*) begin

        read_data = 32'b0;

        if (mem_read && hit) begin
            read_data =
                cache_data[index][word_offset*32 +: 32];
        end

    end

endmodule
