
module immediate_generator_tb;

    reg [31:0] instruction;
    wire [31:0] immediate;

    immediate_generator uut (
        .instruction(instruction),
        .immediate(immediate)
    );

    initial begin

        // ADDI x1,x0,10
        instruction = 32'h00A00093;
        #10;

        if (immediate == 10)
            $display("I-TYPE PASSED");
        else
            $display("I-TYPE FAILED: %h", immediate);

        // SW x1,8(x2)
        instruction = 32'h00112423;
        #10;

        if (immediate == 8)
            $display("S-TYPE PASSED");
        else
            $display("S-TYPE FAILED: %h", immediate);

        // BEQ x0,x0,8
        instruction = 32'h00000463;
        #10;

        if (immediate == 8)
            $display("B-TYPE PASSED");
        else
            $display("B-TYPE FAILED: %h", immediate);

        // LUI x1,0x12345
        instruction = 32'h123450B7;
        #10;

        if (immediate == 32'h12345000)
            $display("U-TYPE PASSED");
        else
            $display("U-TYPE FAILED: %h", immediate);

        // JAL x1,8
        instruction = 32'h008000EF;
        #10;

        if (immediate == 8)
            $display("J-TYPE PASSED");
        else
            $display("J-TYPE FAILED: %h", immediate);

        $display("IMMEDIATE GENERATOR TESTING COMPLETED");

        $finish;

    end

endmodule
