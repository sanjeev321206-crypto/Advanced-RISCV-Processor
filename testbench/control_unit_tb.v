
module control_unit_tb;

    reg [31:0] instruction;

    wire reg_write;
    wire mem_read;
    wire mem_write;
    wire mem_to_reg;
    wire alu_src;

    wire branch;
    wire jump;
    wire jalr;
    wire lui;
    wire auipc;

    wire [3:0] alu_control;

    control_unit uut (
        .instruction(instruction),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src(alu_src),
        .branch(branch),
        .jump(jump),
        .jalr(jalr),
        .lui(lui),
        .auipc(auipc),
        .alu_control(alu_control)
    );

    initial begin

        // ADD x1,x2,x3
        instruction = 32'h003100B3;
        #10;

        if (reg_write && alu_control == 4'b0000)
            $display("ADD CONTROL PASSED");
        else
            $display("ADD CONTROL FAILED");

        // SUB x1,x2,x3
        instruction = 32'h403100B3;
        #10;

        if (reg_write && alu_control == 4'b0001)
            $display("SUB CONTROL PASSED");
        else
            $display("SUB CONTROL FAILED");

        // LW x1,0(x2)
        instruction = 32'h00012083;
        #10;

        if (reg_write && mem_read && mem_to_reg && alu_src)
            $display("LW CONTROL PASSED");
        else
            $display("LW CONTROL FAILED");

        // SW x1,0(x2)
        instruction = 32'h00112023;
        #10;

        if (mem_write && alu_src)
            $display("SW CONTROL PASSED");
        else
            $display("SW CONTROL FAILED");

        // BEQ x2,x3,0
        instruction = 32'h00310063;
        #10;

        if (branch)
            $display("BEQ CONTROL PASSED");
        else
            $display("BEQ CONTROL FAILED");

        // JAL x1,0
        instruction = 32'h000000EF;
        #10;

        if (jump && reg_write)
            $display("JAL CONTROL PASSED");
        else
            $display("JAL CONTROL FAILED");

        $display("CONTROL UNIT TESTING COMPLETED");

        $finish;

    end

endmodule
