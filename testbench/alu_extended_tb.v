
`timescale 1ns/1ps

module alu_extended_tb;

    reg [31:0] a, b;
    reg [3:0] alu_control;
    wire [31:0] result;
    wire zero;

    integer passed = 0;
    integer failed = 0;

    alu dut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    task check;
        input [3:0] operation;
        input [31:0] operand_a;
        input [31:0] operand_b;
        input [31:0] expected;
        begin
            a = operand_a;
            b = operand_b;
            alu_control = operation;
            #10;

            if (result === expected) begin
                $display("PASS: ALU control=%b result=%h",
                         operation, result);
                passed = passed + 1;
            end else begin
                $display("FAIL: control=%b expected=%h actual=%h",
                         operation, expected, result);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/alu_extended.vcd");
        $dumpvars(0, alu_extended_tb);

        check(4'b0010, 32'hF0F0, 32'h0FF0, 32'h00F0);
        check(4'b0011, 32'hF000, 32'h00F0, 32'hF0F0);
        check(4'b0100, 32'hAAAA, 32'hFFFF, 32'h5555);
        check(4'b0101, 32'd3, 32'd2, 32'd12);
        check(4'b0110, 32'd32, 32'd2, 32'd8);
        check(4'b0111, -32'sd16, 32'd2, -32'sd4);
        check(4'b1000, -32'sd5, 32'd3, 32'd1);
        check(4'b1000, 32'd3, 32'd5, 32'd1);
        check(4'b1001, 32'hFFFFFFFF, 32'd1, 32'd0);
        check(4'b1001, 32'd1, 32'd2, 32'd1);

        $display("\n===== EXTENDED ALU RESULTS =====");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);

        if (failed == 0)
            $display("ALL EXTENDED ALU TESTS PASSED!");

        $finish;
    end

endmodule
