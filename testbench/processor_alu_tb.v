
`timescale 1ns/1ps

module processor_alu_tb;

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
        begin
            enc_i = {imm[11:0], rs1[4:0], funct3[2:0],
                     rd[4:0], 7'b0010011};
        end
    endfunction

    function [31:0] enc_r;
        input integer funct7;
        input integer rs2;
        input integer rs1;
        input integer funct3;
        input integer rd;
        begin
            enc_r = {funct7[6:0], rs2[4:0], rs1[4:0],
                     funct3[2:0], rd[4:0], 7'b0110011};
        end
    endfunction

    task check_register;
        input integer reg_number;
        input [31:0] expected;
        begin
            if (dut.decode_unit.rf.registers[reg_number] === expected) begin
                $display("PASS: x%0d = %0d (0x%h)",
                         reg_number, expected, expected);
                passed = passed + 1;
            end
            else begin
                $display("FAIL: x%0d expected %0d, got %0d",
                         reg_number, expected,
                         dut.decode_unit.rf.registers[reg_number]);
                failed = failed + 1;
            end
        end
    endtask

    initial begin

        $dumpfile("waveforms/processor_alu.vcd");
        $dumpvars(0, processor_alu_tb);

        #1;

        for (i = 0; i < 256; i = i + 1)
            dut.fetch_unit.instruction_memory_unit.memory[i] = 32'h00000013;

        // Initialize operands
        dut.fetch_unit.instruction_memory_unit.memory[0] = enc_i(10, 0, 0, 1);
        dut.fetch_unit.instruction_memory_unit.memory[1] = 32'h00000013;
        dut.fetch_unit.instruction_memory_unit.memory[2] = 32'h00000013;

        dut.fetch_unit.instruction_memory_unit.memory[3] = enc_i(3, 0, 0, 2);
        dut.fetch_unit.instruction_memory_unit.memory[4] = 32'h00000013;
        dut.fetch_unit.instruction_memory_unit.memory[5] = 32'h00000013;

        // AND x3, x1, x2 = 2
        dut.fetch_unit.instruction_memory_unit.memory[6] =
            enc_r(0, 2, 1, 7, 3);

        // OR x4, x1, x2 = 11
        dut.fetch_unit.instruction_memory_unit.memory[7] =
            enc_r(0, 2, 1, 6, 4);

        // XOR x5, x1, x2 = 9
        dut.fetch_unit.instruction_memory_unit.memory[8] =
            enc_r(0, 2, 1, 4, 5);

        // SLL x6, x1, x2 = 80
        dut.fetch_unit.instruction_memory_unit.memory[9] =
            enc_r(0, 2, 1, 1, 6);

        // SRL x7, x1, x2 = 1
        dut.fetch_unit.instruction_memory_unit.memory[10] =
            enc_r(0, 2, 1, 5, 7);

        // x11 = -16
        dut.fetch_unit.instruction_memory_unit.memory[11] =
            enc_i(-16, 0, 0, 11);

        dut.fetch_unit.instruction_memory_unit.memory[12] = 32'h00000013;
        dut.fetch_unit.instruction_memory_unit.memory[13] = 32'h00000013;

        // SRA x8, x11, x2 = -2
        dut.fetch_unit.instruction_memory_unit.memory[14] =
            enc_r(7'b0100000, 2, 11, 5, 8);

        // SLT x9, x11, x2 = 1
        dut.fetch_unit.instruction_memory_unit.memory[15] =
            enc_r(0, 2, 11, 2, 9);

        // SLTU x10, x11, x2 = 0
        dut.fetch_unit.instruction_memory_unit.memory[16] =
            enc_r(0, 2, 11, 3, 10);

        reset = 1;
        #12;
        reset = 0;

        repeat (45) @(posedge clk);
        #2;

        $display("\n===== EXTENDED PROCESSOR RESULTS =====");

        check_register(1, 10);
        check_register(2, 3);
        check_register(3, 2);
        check_register(4, 11);
        check_register(5, 9);
        check_register(6, 80);
        check_register(7, 1);
        check_register(8, -2);
        check_register(9, 1);
        check_register(10, 0);
        check_register(11, -16);

        $display("\nPASSED: %0d", passed);
        $display("FAILED: %0d", failed);

        if (failed == 0)
            $display("ALL EXTENDED PROCESSOR TESTS PASSED!");

        $finish;
    end

endmodule
