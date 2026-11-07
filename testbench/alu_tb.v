
module alu_tb;

    reg [31:0] a, b;
    reg [3:0] alu_control;

    wire [31:0] result;
    wire zero;

    alu uut (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial begin

        $dumpfile("waveforms/alu.vcd");
        $dumpvars(0, alu_tb);

        // ADD: 10 + 20 = 30
        a = 10;
        b = 20;
        alu_control = 4'b0000;
        #10;

        if (result == 30)
            $display("ADD TEST PASSED");
        else
            $display("ADD TEST FAILED");

        // SUB: 20 - 10 = 10
        a = 20;
        b = 10;
        alu_control = 4'b0001;
        #10;

        if (result == 10)
            $display("SUB TEST PASSED");
        else
            $display("SUB TEST FAILED");

        // AND
        a = 32'hF0;
        b = 32'h0F;
        alu_control = 4'b0010;
        #10;

        if (result == 0)
            $display("AND TEST PASSED");
        else
            $display("AND TEST FAILED");

        // OR
        a = 32'hF0;
        b = 32'h0F;
        alu_control = 4'b0011;
        #10;

        if (result == 32'hFF)
            $display("OR TEST PASSED");
        else
            $display("OR TEST FAILED");

        // XOR
        a = 32'hF0;
        b = 32'h0F;
        alu_control = 4'b0100;
        #10;

        if (result == 32'hFF)
            $display("XOR TEST PASSED");
        else
            $display("XOR TEST FAILED");

        // Signed comparison
        a = -5;
        b = 3;
        alu_control = 4'b1000;
        #10;

        if (result == 1)
            $display("SLT TEST PASSED");
        else
            $display("SLT TEST FAILED");

        $display("ALU TESTING COMPLETED");

        $finish;

    end

endmodule
