
`timescale 1ns/1ps

module branch_predictor_tb;

    reg clk, reset;
    reg [31:0] predict_pc;
    reg update_en;
    reg [31:0] update_pc;
    reg actual_taken;

    wire predicted_taken;

    branch_predictor #(
        .INDEX_BITS(4)
    ) dut (
        .clk(clk),
        .reset(reset),
        .predict_pc(predict_pc),
        .predicted_taken(predicted_taken),
        .update_en(update_en),
        .update_pc(update_pc),
        .actual_taken(actual_taken)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("waveforms/branch_predictor.vcd");
        $dumpvars(0, branch_predictor_tb);

        clk = 0;
        reset = 1;
        predict_pc = 32'h00000040;
        update_pc = 32'h00000040;
        update_en = 0;
        actual_taken = 0;

        #12;
        reset = 0;
        #1;

        // Initial state: weakly not taken
        if (predicted_taken == 0)
            $display("TEST 1 PASSED: Initial not-taken prediction");
        else
            $display("TEST 1 FAILED");

        // First taken outcome: 01 -> 10
        @(negedge clk);
        update_en = 1;
        actual_taken = 1;

        @(negedge clk);
        update_en = 0;
        #1;

        if (predicted_taken == 1)
            $display("TEST 2 PASSED: Predictor learns taken");
        else
            $display("TEST 2 FAILED");

        // Second taken outcome: 10 -> 11
        @(negedge clk);
        update_en = 1;
        actual_taken = 1;

        @(negedge clk);
        update_en = 0;
        #1;

        if (predicted_taken == 1)
            $display("TEST 3 PASSED: Strongly taken prediction");
        else
            $display("TEST 3 FAILED");

        // First not-taken outcome: 11 -> 10
        @(negedge clk);
        update_en = 1;
        actual_taken = 0;

        @(negedge clk);
        update_en = 0;
        #1;

        if (predicted_taken == 1)
            $display("TEST 4 PASSED: Predictor retains taken prediction");
        else
            $display("TEST 4 FAILED");

        // Second not-taken outcome: 10 -> 01
        @(negedge clk);
        update_en = 1;
        actual_taken = 0;

        @(negedge clk);
        update_en = 0;
        #1;

        if (predicted_taken == 0)
            $display("TEST 5 PASSED: Predictor learns not taken");
        else
            $display("TEST 5 FAILED");

        $finish;

    end

endmodule
