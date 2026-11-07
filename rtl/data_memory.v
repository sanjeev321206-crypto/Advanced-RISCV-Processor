
module data_memory #(
    parameter BYTES = 4096
)(
    input wire clk,
    input wire mem_read,
    input wire mem_write,

    input wire [2:0] funct3,
    input wire [31:0] address,
    input wire [31:0] write_data,

    output reg [31:0] read_data
);

    reg [7:0] memory [0:BYTES-1];

    integer i;
    reg [31:0] raw_word;

    always @(*) begin

        raw_word = 32'd0;

        if (address < BYTES-3) begin
            raw_word = {
                memory[{address[31:2],2'b00}+3],
                memory[{address[31:2],2'b00}+2],
                memory[{address[31:2],2'b00}+1],
                memory[{address[31:2],2'b00}]
            };
        end

        read_data = 32'd0;

        if (mem_read && address < BYTES) begin

            case (funct3)

                3'b000:
                    read_data = {
                        {24{memory[address][7]}},
                        memory[address]
                    };

                3'b001:
                    read_data = {
                        {16{memory[address+1][7]}},
                        memory[address+1],
                        memory[address]
                    };

                3'b010:
                    read_data = raw_word;

                3'b100:
                    read_data = {24'd0, memory[address]};

                3'b101:
                    read_data = {
                        16'd0,
                        memory[address+1],
                        memory[address]
                    };

                default:
                    read_data = 32'd0;

            endcase

        end

    end

    always @(posedge clk) begin

        if (mem_write && address < BYTES) begin

            case (funct3)

                // SB
                3'b000:
                    memory[address] <= write_data[7:0];

                // SH
                3'b001:
                    if (address < BYTES-1) begin
                        memory[address] <= write_data[7:0];
                        memory[address+1] <= write_data[15:8];
                    end

                // SW
                3'b010:
                    if (address < BYTES-3) begin
                        memory[{address[31:2],2'b00}] <= write_data[7:0];
                        memory[{address[31:2],2'b00}+1] <= write_data[15:8];
                        memory[{address[31:2],2'b00}+2] <= write_data[23:16];
                        memory[{address[31:2],2'b00}+3] <= write_data[31:24];
                    end

                default: begin
                end

            endcase

        end

    end

endmodule
