
module register_writeback (
    input wire reg_write,
    input wire [4:0] rd,
    input wire [31:0] writeback_data,

    output wire write_enable,
    output wire [4:0] destination_register,
    output wire [31:0] register_data
);

    assign write_enable = reg_write && (rd != 5'd0);
    assign destination_register = rd;
    assign register_data = writeback_data;

endmodule
