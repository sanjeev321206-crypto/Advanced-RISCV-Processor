
module register_file (
    input wire clk,
    input wire reset,
    input wire reg_write,
    input wire [4:0] read_addr1,
    input wire [4:0] read_addr2,
    input wire [4:0] write_addr,
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] registers [0:31];
    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;
        end
        else if (reg_write && write_addr != 5'd0) begin
            registers[write_addr] <= write_data;
        end
    end

    // Write-back bypass on read port 1
    assign read_data1 =
        (read_addr1 == 5'd0) ? 32'd0 :
        (reg_write && write_addr != 5'd0 &&
         write_addr == read_addr1) ? write_data :
        registers[read_addr1];

    // Write-back bypass on read port 2
    assign read_data2 =
        (read_addr2 == 5'd0) ? 32'd0 :
        (reg_write && write_addr != 5'd0 &&
         write_addr == read_addr2) ? write_data :
        registers[read_addr2];

endmodule
