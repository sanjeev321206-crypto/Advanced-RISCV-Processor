
module register_file_tb;

    reg clk;
    reg reset;
    reg reg_write;

    reg [4:0] read_addr1;
    reg [4:0] read_addr2;
    reg [4:0] write_addr;

    reg [31:0] write_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    register_file uut (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_addr1(read_addr1),
        .read_addr2(read_addr2),
        .write_addr(write_addr),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("waveforms/register_file.vcd");
        $dumpvars(0, register_file_tb);

        clk = 0;
        reset = 1;
        reg_write = 0;

        read_addr1 = 0;
        read_addr2 = 0;

        write_addr = 0;
        write_data = 0;

        #12;
        reset = 0;

        // Write 100 into x1
        @(negedge clk);
        reg_write = 1;
        write_addr = 1;
        write_data = 100;

        @(negedge clk);
        reg_write = 0;

        read_addr1 = 1;
        #1;

        if (read_data1 == 100)
            $display("REGISTER WRITE/READ PASSED");
        else
            $display("REGISTER WRITE/READ FAILED");

        // Check x0
        read_addr1 = 0;
        #1;

        if (read_data1 == 0)
            $display("ZERO REGISTER TEST PASSED");
        else
            $display("ZERO REGISTER TEST FAILED");

        $finish;

    end

endmodule
