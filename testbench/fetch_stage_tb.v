
module fetch_stage_tb;

    reg clk;
    reg reset;
    reg stall;
    reg flush;
    reg redirect;
    reg [31:0] redirect_target;

    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] pc_plus4;

    fetch_stage uut (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .flush(flush),
        .redirect(redirect),
        .redirect_target(redirect_target),
        .pc(pc),
        .instruction(instruction),
        .pc_plus4(pc_plus4)
    );

    always #5 clk = ~clk;

    initial begin

        $dumpfile("waveforms/fetch_stage.vcd");
        $dumpvars(0, fetch_stage_tb);

        clk = 0;
        reset = 1;
        stall = 0;
        flush = 0;
        redirect = 0;
        redirect_target = 0;

        #12;
        reset = 0;

        #1;
        if (pc == 0 && pc_plus4 == 4)
            $display("PC RESET TEST PASSED");
        else
            $display("PC RESET TEST FAILED");

        @(posedge clk);
        #1;

        if (pc == 4)
            $display("PC INCREMENT TEST PASSED");
        else
            $display("PC INCREMENT TEST FAILED");

        // Stall
        @(negedge clk);
        stall = 1;

        @(posedge clk);
        #1;

        if (pc == 4)
            $display("PC STALL TEST PASSED");
        else
            $display("PC STALL TEST FAILED");

        // Redirect
        @(negedge clk);
        stall = 0;
        redirect = 1;
        redirect_target = 32'h40;

        @(posedge clk);
        #1;

        if (pc == 32'h40)
            $display("PC REDIRECT TEST PASSED");
        else
            $display("PC REDIRECT TEST FAILED");

        $display("FETCH STAGE TESTING COMPLETED");

        $finish;

    end

endmodule
