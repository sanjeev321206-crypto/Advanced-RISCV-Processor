
`timescale 1ns/1ps

module data_cache_tb;

    reg clk;
    reg reset;
    reg mem_read;
    reg mem_write;

    reg [31:0] address;
    reg [31:0] write_data;

    wire [31:0] read_data;
    wire hit;

    data_cache dut (
        .clk(clk),
        .reset(reset),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(address),
        .write_data(write_data),
        .read_data(read_data),
        .hit(hit)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("waveforms/data_cache.vcd");
        $dumpvars(0, data_cache_tb);

        clk = 0;
        reset = 1;
        mem_read = 0;
        mem_write = 0;
        address = 0;
        write_data = 0;

        #12;
        reset = 0;

        // Test 1: Initial read miss
        mem_read = 1;
        address = 0;
        #1;

        if (!hit)
            $display("TEST 1 PASSED: Initial read miss");
        else
            $display("TEST 1 FAILED");

        // Fill cache
        @(posedge clk);
        #1;

        // Test 2: Read hit after refill
        if (hit && read_data == 100)
            $display("TEST 2 PASSED: Cache refill and read");
        else
            $display("TEST 2 FAILED: hit=%b data=%d", hit, read_data);

        // Test 3: Read another word in same line
        address = 4;
        #1;

        if (hit && read_data == 101)
            $display("TEST 3 PASSED: Same-line word read");
        else
            $display("TEST 3 FAILED: hit=%b data=%d", hit, read_data);

        // Test 4: Write-through store
        mem_read = 0;
        mem_write = 1;
        address = 4;
        write_data = 999;

        @(posedge clk);
        #1;

        if (dut.backing_memory[1] == 999 &&
            dut.cache_data[0][63:32] == 999)
            $display("TEST 4 PASSED: Write-through update");
        else
            $display("TEST 4 FAILED");

        // Test 5: Read stored value
        mem_write = 0;
        mem_read = 1;
        #1;

        if (hit && read_data == 999)
            $display("TEST 5 PASSED: Stored data read");
        else
            $display("TEST 5 FAILED: hit=%b data=%d", hit, read_data);

        // Test 6: Conflict miss
        address = 32'h00000100;
        #1;

        if (!hit)
            $display("TEST 6 PASSED: Conflict miss");
        else
            $display("TEST 6 FAILED");

        $finish;

    end

endmodule
