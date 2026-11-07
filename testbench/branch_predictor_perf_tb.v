`timescale 1ns/1ps

module branch_predictor_perf_tb;

    reg clk = 0;
    reg reset = 1;
    reg [31:0] predict_pc = 32'h40;
    reg update_en = 0;
    reg [31:0] update_pc = 32'h40;
    reg actual_taken = 0;

    wire predicted_taken;

    integer correct = 0;
    integer incorrect = 0;
    integer total = 0;
    integer i;
    real accuracy;

    reg outcome;

    branch_predictor dut (
        .clk(clk),
        .reset(reset),
        .predict_pc(predict_pc),
        .predicted_taken(predicted_taken),
        .update_en(update_en),
        .update_pc(update_pc),
        .actual_taken(actual_taken)
    );

    always #5 clk = ~clk;

    task measure_outcome;
        input outcome;
        begin
            @(negedge clk);
            update_en = 0;
            actual_taken = outcome;
            #1;

            total = total + 1;

            if (predicted_taken === outcome) begin
                correct = correct + 1;
            end
            else begin
                incorrect = incorrect + 1;
            end

            update_en = 1;
            @(posedge clk);
            #1;
            update_en = 0;
        end
    endtask

    initial begin
        $dumpfile("waveforms/branch_predictor_perf.vcd");
        $dumpvars(0, branch_predictor_perf_tb);

        #12;
        reset = 0;

        // Two repetitions of 8 taken, followed by 8 not-taken.
        for (i = 0; i < 2; i = i + 1) begin
            repeat (8)
                measure_outcome(1'b1);

            repeat (8)
                measure_outcome(1'b0);
        end

        accuracy = (correct * 100.0) / total;

        $display("\n===== BRANCH PREDICTOR PERFORMANCE =====");
        $display("Total predictions : %0d", total);
        $display("Correct predictions: %0d", correct);
        $display("Incorrect predictions: %0d", incorrect);
        $display("Prediction accuracy: %0.2f%%", accuracy);
        $display("========================================");

        $finish;
    end

endmodule
