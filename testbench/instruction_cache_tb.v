
`timescale 1ns/1ps

module instruction_cache_tb;

    reg clk;
    reg reset;
    reg [31:0] address;

    wire [31:0] instruction;
    wire hit;

    instruction_cache dut (
        .clk(clk),
        .reset(reset),
        .address(address),
        .instruction(instruction),
        .hit(hit)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("waveforms/instruction_cache.vcd");
        $dumpvars(0, instruction_cache_tb);

        clk = 0;
        reset = 1;
        address = 0;

        #12;
        reset = 0;
        #1;

        // Test 1: Initial cache miss
        if (hit == 0)
            $display("TEST 1 PASSED: Initial cache miss");
        else
            $display("TEST 1 FAILED");

        // Fill cache line
        @(posedge clk);
        #1;

        // Test 2: Cache hit after filling
        if (hit == 1)
            $display("TEST 2 PASSED: Cache hit after fill");
        else
            $display("TEST 2 FAILED");

        // Test 3: Another word in the same line
        address = 32'h00000004;
        #1;

        if (hit == 1)
            $display("TEST 3 PASSED: Same cache line hit");
        else
            $display("TEST 3 FAILED");

        // Test 4: Conflicting address
        address = 32'h00000100;
        #1;

        if (hit == 0)
            $display("TEST 4 PASSED: Conflict miss detected");
        else
            $display("TEST 4 FAILED");

        // Fill conflicting line
        @(posedge clk);
        #1;

        // Test 5: Hit after conflict refill
        if (hit == 1)
            $display("TEST 5 PASSED: Conflict line filled");
        else
            $display("TEST 5 FAILED");

        $finish;

    end

endmodule
