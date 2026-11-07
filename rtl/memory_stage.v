
module memory_stage (
    input wire clk,
    input wire mem_read,
    input wire mem_write,
    input wire [31:0] address,
    input wire [31:0] write_data,
    input wire [2:0] funct3,
    output wire [31:0] read_data
);

    data_memory dm (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .funct3(funct3),
        .read_data(read_data)
    );

endmodule
