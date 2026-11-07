
`timescale 1ns/1ps

module hazard_detection_tb;

    reg [4:0] if_id_rs1, if_id_rs2, id_ex_rd;
    reg id_ex_mem_read;

    wire pc_write, if_id_write, control_stall;

    hazard_detection_unit dut (
        .if_id_rs1(if_id_rs1),
        .if_id_rs2(if_id_rs2),
        .id_ex_rd(id_ex_rd),
        .id_ex_mem_read(id_ex_mem_read),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_stall(control_stall)
    );

    initial begin

        $dumpfile("waveforms/hazard_detection.vcd");
        $dumpvars(0, hazard_detection_tb);

        // Test 1: Load-use dependency on rs1
        if_id_rs1 = 1;
        if_id_rs2 = 4;
        id_ex_rd = 1;
        id_ex_mem_read = 1;
        #10;

        if (!pc_write && !if_id_write && control_stall)
            $display("TEST 1 PASSED: Load-use hazard detected");

        else
            $display("TEST 1 FAILED");

        // Test 2: Load-use dependency on rs2
        if_id_rs1 = 3;
        if_id_rs2 = 5;
        id_ex_rd = 5;
        id_ex_mem_read = 1;
        #10;

        if (!pc_write && !if_id_write && control_stall)
            $display("TEST 2 PASSED: rs2 dependency detected");

        else
            $display("TEST 2 FAILED");

        // Test 3: No dependency
        if_id_rs1 = 3;
        if_id_rs2 = 4;
        id_ex_rd = 1;
        id_ex_mem_read = 1;
        #10;

        if (pc_write && if_id_write && !control_stall)
            $display("TEST 3 PASSED: No unnecessary stall");

        else
            $display("TEST 3 FAILED");

        // Test 4: Destination x0
        if_id_rs1 = 0;
        if_id_rs2 = 4;
        id_ex_rd = 0;
        id_ex_mem_read = 1;
        #10;

        if (pc_write && if_id_write && !control_stall)
            $display("TEST 4 PASSED: x0 dependency ignored");

        else
            $display("TEST 4 FAILED");

        $finish;

    end

endmodule
