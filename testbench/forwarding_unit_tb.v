
`timescale 1ns/1ps

module forwarding_unit_tb;

    reg [4:0] id_ex_rs1, id_ex_rs2;
    reg [4:0] ex_mem_rd, mem_wb_rd;
    reg ex_mem_reg_write, mem_wb_reg_write;

    wire [1:0] forward_a, forward_b;

    forwarding_unit dut (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .ex_mem_rd(ex_mem_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_rd(mem_wb_rd),
        .mem_wb_reg_write(mem_wb_reg_write),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    initial begin

        $dumpfile("waveforms/forwarding_unit.vcd");
        $dumpvars(0, forwarding_unit_tb);

        // Test 1: EX/MEM forwarding
        id_ex_rs1 = 1;
        id_ex_rs2 = 2;
        ex_mem_rd = 1;
        mem_wb_rd = 0;
        ex_mem_reg_write = 1;
        mem_wb_reg_write = 0;
        #10;

        if (forward_a == 2'b10)
            $display("TEST 1 PASSED: EX/MEM forwarding");
        else
            $display("TEST 1 FAILED");

        // Test 2: MEM/WB forwarding
        id_ex_rs1 = 3;
        id_ex_rs2 = 4;
        ex_mem_rd = 0;
        mem_wb_rd = 3;
        ex_mem_reg_write = 0;
        mem_wb_reg_write = 1;
        #10;

        if (forward_a == 2'b01)
            $display("TEST 2 PASSED: MEM/WB forwarding");
        else
            $display("TEST 2 FAILED");

        // Test 3: EX/MEM priority
        id_ex_rs1 = 5;
        ex_mem_rd = 5;
        mem_wb_rd = 5;
        ex_mem_reg_write = 1;
        mem_wb_reg_write = 1;
        #10;

        if (forward_a == 2'b10)
            $display("TEST 3 PASSED: EX/MEM priority");
        else
            $display("TEST 3 FAILED");

        // Test 4: No forwarding
        id_ex_rs1 = 6;
        id_ex_rs2 = 7;
        ex_mem_rd = 1;
        mem_wb_rd = 2;
        #10;

        if (forward_a == 2'b00 && forward_b == 2'b00)
            $display("TEST 4 PASSED: No forwarding required");
        else
            $display("TEST 4 FAILED");

        $finish;
    end

endmodule
