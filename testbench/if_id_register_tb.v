
module if_id_register_tb;

    reg clk;
    reg reset;
    reg stall;
    reg flush;

    reg [31:0] pc_in;
    reg [31:0] instruction_in;

    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    if_id_register uut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .pc_in(pc_in),
        .instruction_in(instruction_in),
        .pc_out(pc_out),
        .instruction_out(instruction_out)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        stall = 0;
        flush = 0;

        pc_in = 0;
        instruction_in = 0;

        #12;
        reset = 0;

        // Normal transfer
        @(negedge clk);
        pc_in = 32'h100;
        instruction_in = 32'h00A00093;

        @(posedge clk);
        #1;

        if (pc_out == 32'h100 &&
            instruction_out == 32'h00A00093)
            $display("PIPELINE TRANSFER PASSED");
        else
            $display("PIPELINE TRANSFER FAILED");

        // Stall should preserve previous values
        @(negedge clk);
        stall = 1;
        pc_in = 32'h200;
        instruction_in = 32'h00100113;

        @(posedge clk);
        #1;

        if (pc_out == 32'h100 &&
            instruction_out == 32'h00A00093)
            $display("STALL TEST PASSED");
        else
            $display("STALL TEST FAILED");

        // Flush should insert a bubble
        @(negedge clk);
        stall = 0;
        flush = 1;

        @(posedge clk);
        #1;

        if (instruction_out == 32'h00000013 &&
            pc_out == 0)
            $display("FLUSH TEST PASSED");
        else
            $display("FLUSH TEST FAILED");

        $display("IF/ID TESTING COMPLETED");

        $finish;

    end

endmodule
