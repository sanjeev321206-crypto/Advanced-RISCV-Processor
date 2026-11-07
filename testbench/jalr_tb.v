
`timescale 1ns/1ps

module jalr_tb;

    reg clk = 0;
    reg reset = 1;

    wire [31:0] debug_pc;
    wire debug_wb_write;
    wire [4:0] debug_wb_rd;
    wire [31:0] debug_wb_data;

    integer passed = 0;
    integer failed = 0;
    integer i;

    riscv_processor dut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_wb_write(debug_wb_write),
        .debug_wb_rd(debug_wb_rd),
        .debug_wb_data(debug_wb_data)
    );

    always #5 clk = ~clk;

    function [31:0] enc_i;
        input integer imm;
        input integer rs1;
        input integer funct3;
        input integer rd;
        input integer opcode;
        begin
            enc_i = {imm[11:0], rs1[4:0], funct3[2:0],
                     rd[4:0], opcode[6:0]};
        end
    endfunction

    task check_register;
        input integer reg_number;
        input [31:0] expected;
        begin
            if (dut.decode_unit.rf.registers[reg_number] === expected) begin
                $display("PASS: x%0d = %0d", reg_number, expected);
                passed = passed + 1;
            end else begin
                $display("FAIL: x%0d expected %0d got %0d",
                    reg_number, expected,
                    dut.decode_unit.rf.registers[reg_number]);
                failed = failed + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("waveforms/jalr.vcd");
        $dumpvars(0, jalr_tb);

        #1;

        for (i = 0; i < 256; i = i + 1)
            dut.fetch_unit.instruction_memory_unit.memory[i] = 32'h00000013;

        // PC 0: x1 = 16
        dut.fetch_unit.instruction_memory_unit.memory[0] =
            enc_i(16, 0, 0, 1, 7'b0010011);

        // PC 4: JALR x2, 0(x1) -> PC 16
        dut.fetch_unit.instruction_memory_unit.memory[1] =
            enc_i(0, 1, 0, 2, 7'b1100111);

        // PC 8: Must be skipped
        dut.fetch_unit.instruction_memory_unit.memory[2] =
            enc_i(99, 0, 0, 4, 7'b0010011);

        // PC 12: Must be skipped
        dut.fetch_unit.instruction_memory_unit.memory[3] =
            enc_i(77, 0, 0, 5, 7'b0010011);

        // PC 16: Target instruction
        dut.fetch_unit.instruction_memory_unit.memory[4] =
            enc_i(42, 0, 0, 3, 7'b0010011);

        reset = 1;
        #12;
        reset = 0;

        repeat (30) @(posedge clk);
        #2;

        $display("\n===== JALR TEST RESULTS =====");

        check_register(1, 16);
        check_register(2, 8);
        check_register(3, 42);
        check_register(4, 0);
        check_register(5, 0);

        $display("\nPASSED: %0d", passed);
        $display("FAILED: %0d", failed);

        if (failed == 0)
            $display("ALL JALR TESTS PASSED!");

        $finish;
    end

endmodule
