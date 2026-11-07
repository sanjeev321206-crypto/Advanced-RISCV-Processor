
`timescale 1ns/1ps

module forwarding_mux_tb;

    reg [31:0] original_data;
    reg [31:0] ex_mem_data;
    reg [31:0] mem_wb_data;
    reg [1:0] select;

    wire [31:0] forwarded_data;

    forwarding_mux dut (
        .original_data(original_data),
        .ex_mem_data(ex_mem_data),
        .mem_wb_data(mem_wb_data),
        .select(select),
        .forwarded_data(forwarded_data)
    );

    initial begin

        $dumpfile("waveforms/forwarding_mux.vcd");
        $dumpvars(0, forwarding_mux_tb);

        original_data = 32'd10;
        ex_mem_data = 32'd20;
        mem_wb_data = 32'd30;

        select = 2'b00;
        #10;
        if (forwarded_data == 10)
            $display("TEST 1 PASSED: Original data selected");
        else
            $display("TEST 1 FAILED");

        select = 2'b10;
        #10;
        if (forwarded_data == 20)
            $display("TEST 2 PASSED: EX/MEM data selected");
        else
            $display("TEST 2 FAILED");

        select = 2'b01;
        #10;
        if (forwarded_data == 30)
            $display("TEST 3 PASSED: MEM/WB data selected");
        else
            $display("TEST 3 FAILED");

        $finish;
    end

endmodule
