
`timescale 1ns/1ps

module processor_tb;

    reg clk = 0;
    reg reset = 1;

    wire [31:0] debug_pc;
    wire debug_wb_write;
    wire [4:0] debug_wb_rd;
    wire [31:0] debug_wb_data;

    integer passed = 0;
    integer failed = 0;
    integer i;

    // Performance measurement
    integer cycle_count = 0;
    integer completion_cycle = 0;
    integer instruction_count = 10;
    reg measurement_done = 0;
    real cpi;

    riscv_processor dut (
        .clk(clk),
        .reset(reset),
        .debug_pc(debug_pc),
        .debug_wb_write(debug_wb_write),
        .debug_wb_rd(debug_wb_rd),
        .debug_wb_data(debug_wb_data)
    );

    always #5 clk = ~clk;

    always @(posedge clk) begin
        if (!reset)
            cycle_count = cycle_count + 1;
    end

    always @(negedge clk) begin
        if (!reset && debug_wb_write && debug_wb_rd == 5'd8
            && !measurement_done) begin
            completion_cycle = cycle_count;
            measurement_done = 1;
        end
    end

    // I-type instruction encoder
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

    // R-type instruction encoder
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

    // S-type instruction encoder
    function [31:0] enc_s;
        input integer imm;
        input integer rs2;
        input integer rs1;
        input integer funct3;
        begin
            enc_s = {imm[11:5], rs2[4:0], rs1[4:0],
                     funct3[2:0], imm[4:0], 7'b0100011};
        end
    endfunction

    // B-type instruction encoder
    function [31:0] enc_b;
        input integer imm;
        input integer rs2;
        input integer rs1;
        input integer funct3;
        begin
            enc_b = {imm[12], imm[10:5], rs2[4:0],
                     rs1[4:0], funct3[2:0],
                     imm[4:1], imm[11], 7'b1100011};
        end
    endfunction

    task check_register;
        input integer reg_number;
        input [31:0] expected;
        begin
            if (dut.decode_unit.rf.registers[reg_number] === expected) begin
                $display("PASS: x%0d = %0d", reg_number, expected);
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



    always @(negedge clk) begin
        if (!reset && dut.ex_rd == 5'd4) begin
            $display("\n===== FORWARDING TRACE =====");
            $display("EX: rs1=%0d rs2=%0d rd=%0d",
                dut.ex_rs1, dut.ex_rs2, dut.ex_rd);
            $display("EX/MEM: rd=%0d reg_write=%b mem_to_reg=%b alu=%0d",
                dut.mem_rd, dut.mem_reg_write, dut.mem_to_reg,
                dut.mem_alu_result);
            $display("MEM/WB: rd=%0d reg_write=%b data=%0d",
                dut.wb_rd, dut.wb_reg_write, dut.wb_data);
            $display("SELECT: A=%b B=%b",
                dut.forward_a, dut.forward_b);
            $display("OPERANDS: A=%0d B=%0d",
                dut.forwarded_a, dut.forwarded_b);
            $display("============================\n");
        end
    end

    initial begin

        $dumpfile("waveforms/processor.vcd");
        $dumpvars(0, processor_tb);

        // Wait for instruction memory initialization
        #1;

        // Program initialization
        for (i = 0; i < 256; i = i + 1)
            dut.fetch_unit.instruction_memory_unit.memory[i] = 32'h00000013;

        // 0: x1 = 5
        dut.fetch_unit.instruction_memory_unit.memory[0] =
            enc_i(5, 0, 0, 1, 7'b0010011);

        // 1: x2 = 7
        dut.fetch_unit.instruction_memory_unit.memory[1] =
            enc_i(7, 0, 0, 2, 7'b0010011);

        // 2: x3 = x1 + x2 = 12
        dut.fetch_unit.instruction_memory_unit.memory[2] =
            enc_r(0, 2, 1, 0, 3);

        // 3: x4 = x3 - x1 = 7
        dut.fetch_unit.instruction_memory_unit.memory[3] =
            enc_r(7'b0100000, 1, 3, 0, 4);

        // 4: Store x3 at address 0
        dut.fetch_unit.instruction_memory_unit.memory[4] =
            enc_s(0, 3, 0, 2);

        // 5: Load word from address 0 into x5
        dut.fetch_unit.instruction_memory_unit.memory[5] =
            enc_i(0, 0, 2, 5, 7'b0000011);

        // 6: x6 = x5 + x2 (load-use hazard)
        dut.fetch_unit.instruction_memory_unit.memory[6] =
            enc_r(0, 2, 5, 0, 6);

        // 7: x7 = 19
        dut.fetch_unit.instruction_memory_unit.memory[7] =
            enc_i(19, 0, 0, 7, 7'b0010011);

        // 8: BEQ x6, x7, +8 (skip next instruction)
        dut.fetch_unit.instruction_memory_unit.memory[8] =
            enc_b(8, 7, 6, 0);

        // 9: Should be skipped
        dut.fetch_unit.instruction_memory_unit.memory[9] =
            enc_i(99, 0, 0, 8, 7'b0010011);

        // 10: x8 = 42
        dut.fetch_unit.instruction_memory_unit.memory[10] =
            enc_i(42, 0, 0, 8, 7'b0010011);

        // Reset processor
        reset = 1;
        #12;
        reset = 0;

        // Run processor
        wait (measurement_done);

        // Allow the writeback operation to commit
        @(posedge clk);
        #1;

        cpi = completion_cycle / 10.0;

        $display("\\n========== PERFORMANCE ANALYSIS ==========");
        $display("Executed Instructions : %0d", instruction_count);
        $display("Execution Cycles       : %0d", completion_cycle);
        $display("Measured CPI           : %0.2f", cpi);
        $display("Clock Period           : 10 ns");
        $display("Execution Time         : %0d ns", completion_cycle * 10);
        $display("==========================================");

        $display("\n========== PROCESSOR RESULTS ==========");

        check_register(1, 5);
        check_register(2, 7);
        check_register(3, 12);
        check_register(4, 7);
        check_register(5, 12);
        check_register(6, 19);
        check_register(7, 19);
        check_register(8, 42);

        // Verify stored word
        if ({
            dut.memory_unit.dm.memory[3],
            dut.memory_unit.dm.memory[2],
            dut.memory_unit.dm.memory[1],
            dut.memory_unit.dm.memory[0]
        } === 32'd12) begin
            $display("PASS: Memory[0] = 12");
            passed = passed + 1;
        end
        else begin
            $display("FAIL: Memory[0] expected 12");
            failed = failed + 1;
        end

        $display("\n======================================");
        $display("PASSED: %0d", passed);
        $display("FAILED: %0d", failed);
        $display("======================================");

        if (failed == 0)
            $display("ALL PROCESSOR TESTS PASSED!");
        else
            $display("PROCESSOR TESTS NEED DEBUGGING!");

        $finish;
    end

endmodule
