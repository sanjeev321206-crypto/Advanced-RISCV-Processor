
module riscv_processor (
    input wire clk,
    input wire reset,

    output wire [31:0] debug_pc,
    output wire debug_wb_write,
    output wire [4:0] debug_wb_rd,
    output wire [31:0] debug_wb_data
);

    // =====================================================
    // FETCH STAGE
    // =====================================================

    wire [31:0] fetch_pc;
    wire [31:0] fetch_instruction;
    wire [31:0] fetch_pc4;

    wire [31:0] if_pc;
    wire [31:0] if_pc4;
    wire [31:0] if_instruction;

    // =====================================================
    // HAZARD DETECTION
    // =====================================================

    wire pc_write;
    wire if_id_write;
    wire control_stall;

    wire [4:0] id_rs1;
    wire [4:0] id_rs2;

    wire [4:0] ex_rd;
    wire ex_mem_read;

    hazard_detection_unit hazard_unit (
        .if_id_rs1(if_instruction[19:15]),
        .if_id_rs2(if_instruction[24:20]),
        .id_ex_rd(ex_rd),
        .id_ex_mem_read(ex_mem_read),
        .pc_write(pc_write),
        .if_id_write(if_id_write),
        .control_stall(control_stall)
    );

    // =====================================================
    // BRANCH / JUMP REDIRECTION
    // =====================================================

    wire redirect;
    wire [31:0] redirect_target;

    // =====================================================
    // FETCH STAGE INSTANCE
    // =====================================================

    fetch_stage fetch_unit (
        .clk(clk),
        .reset(reset),
        .stall(!pc_write),
        .flush(redirect),
        .redirect(redirect),
        .redirect_target(redirect_target),
        .pc(fetch_pc),
        .instruction(fetch_instruction),
        .pc_plus4(fetch_pc4)
    );

    assign debug_pc = fetch_pc;

    // =====================================================
    // IF / ID PIPELINE REGISTER
    // =====================================================

    if_id_register if_id (
        .clk(clk),
        .reset(reset),
        .stall(!if_id_write),
        .flush(redirect),
        .pc_in(fetch_pc),
        .pc_plus4_in(fetch_pc4),
        .instruction_in(fetch_instruction),
        .pc_out(if_pc),
        .pc_plus4_out(if_pc4),
        .instruction_out(if_instruction)
    );

    // =====================================================
    // DECODE STAGE
    // =====================================================

    wire [31:0] dec_data1;
    wire [31:0] dec_data2;
    wire [31:0] dec_imm;

    wire [4:0] dec_rd;
    wire [2:0] dec_funct3;

    wire dec_reg_write;
    wire dec_mem_read;
    wire dec_mem_write;
    wire dec_mem_to_reg;
    wire dec_alu_src;
    wire dec_branch;
    wire dec_jump;
    wire dec_jalr;
    wire dec_lui;
    wire dec_auipc;

    wire [3:0] dec_alu_control;

    wire wb_write_enable;
    wire [4:0] wb_destination;
    wire [31:0] wb_data;

    decode_stage decode_unit (
        .clk(clk),
        .reset(reset),
        .pc(if_pc),
        .pc_plus4(if_pc4),
        .instruction(if_instruction),

        .wb_reg_write(wb_write_enable),
        .wb_rd(wb_destination),
        .wb_data(wb_data),

        .reg_data1(dec_data1),
        .reg_data2(dec_data2),
        .immediate(dec_imm),

        .rs1(id_rs1),
        .rs2(id_rs2),
        .rd(dec_rd),
        .funct3(dec_funct3),

        .reg_write(dec_reg_write),
        .mem_read(dec_mem_read),
        .mem_write(dec_mem_write),
        .mem_to_reg(dec_mem_to_reg),
        .alu_src(dec_alu_src),
        .branch(dec_branch),
        .jump(dec_jump),
        .jalr(dec_jalr),
        .lui(dec_lui),
        .auipc(dec_auipc),
        .alu_control(dec_alu_control)
    );

    // =====================================================
    // ID / EX PIPELINE REGISTER
    // =====================================================

    wire [31:0] ex_pc;
    wire [31:0] ex_pc4;
    wire [31:0] ex_data1;
    wire [31:0] ex_data2;
    wire [31:0] ex_imm;

    wire [4:0] ex_rs1;
    wire [4:0] ex_rs2;

    wire [3:0] ex_alu_control;

    wire ex_reg_write;
    wire ex_mem_write;
    wire ex_mem_to_reg;
    wire ex_alu_src;
    wire ex_branch;
    wire ex_jump;
    wire ex_jalr;
    wire ex_lui;
    wire ex_auipc;

    reg [2:0] ex_funct3;

    always @(posedge clk or posedge reset) begin
        if (reset || control_stall || redirect)
            ex_funct3 <= 3'b000;
        else
            ex_funct3 <= dec_funct3;
    end

    id_ex_register id_ex (
        .clk(clk),
        .reset(reset),
        .flush(control_stall || redirect),

        .pc_in(if_pc),
        .pc_plus4_in(if_pc4),
        .reg_data1_in(dec_data1),
        .reg_data2_in(dec_data2),
        .immediate_in(dec_imm),

        .rs1_in(id_rs1),
        .rs2_in(id_rs2),
        .rd_in(dec_rd),

        .alu_control_in(dec_alu_control),

        .reg_write_in(dec_reg_write),
        .mem_read_in(dec_mem_read),
        .mem_write_in(dec_mem_write),
        .mem_to_reg_in(dec_mem_to_reg),
        .alu_src_in(dec_alu_src),
        .branch_in(dec_branch),
        .jump_in(dec_jump),
        .jalr_in(dec_jalr),
        .lui_in(dec_lui),
        .auipc_in(dec_auipc),

        .pc_out(ex_pc),
        .pc_plus4_out(ex_pc4),
        .reg_data1_out(ex_data1),
        .reg_data2_out(ex_data2),
        .immediate_out(ex_imm),

        .rs1_out(ex_rs1),
        .rs2_out(ex_rs2),
        .rd_out(ex_rd),

        .alu_control_out(ex_alu_control),

        .reg_write_out(ex_reg_write),
        .mem_read_out(ex_mem_read),
        .mem_write_out(ex_mem_write),
        .mem_to_reg_out(ex_mem_to_reg),
        .alu_src_out(ex_alu_src),
        .branch_out(ex_branch),
        .jump_out(ex_jump),
        .jalr_out(ex_jalr),
        .lui_out(ex_lui),
        .auipc_out(ex_auipc)
    );

    // =====================================================
    // FORWARDING UNIT
    // =====================================================

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    wire [4:0] mem_rd;
    wire mem_to_reg;
    wire mem_reg_write;

    wire [4:0] wb_rd;
    wire wb_reg_write;

    wire [31:0] mem_alu_result;

    forwarding_unit forwarding (
        .id_ex_rs1(ex_rs1),
        .id_ex_rs2(ex_rs2),

        .ex_mem_rd(mem_rd),
        .ex_mem_reg_write(mem_reg_write && !mem_to_reg),

        .mem_wb_rd(wb_rd),
        .mem_wb_reg_write(wb_reg_write),

        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    wire [31:0] forwarded_a;
    wire [31:0] forwarded_b;

    forwarding_mux forward_mux_a (
        .original_data(ex_data1),
        .ex_mem_data(mem_alu_result),
        .mem_wb_data(wb_data),
        .select(forward_a),
        .forwarded_data(forwarded_a)
    );

    forwarding_mux forward_mux_b (
        .original_data(ex_data2),
        .ex_mem_data(mem_alu_result),
        .mem_wb_data(wb_data),
        .select(forward_b),
        .forwarded_data(forwarded_b)
    );

    // =====================================================
    // EXECUTE STAGE
    // =====================================================

    wire [31:0] ex_alu_result;
    wire [31:0] ex_store_data;
    wire [31:0] ex_branch_target;
    wire [31:0] ex_jump_target;
    wire ex_branch_taken;
    wire [31:0] ex_writeback_data;

    execute_stage execute_unit (
        .pc(ex_pc),
        .pc_plus4(ex_pc4),

        .reg_data1(forwarded_a),
        .reg_data2(forwarded_b),
        .immediate(ex_imm),

        .rs1(ex_rs1),
        .rs2(ex_rs2),
        .rd(ex_rd),

        .alu_control(ex_alu_control),
        .alu_src(ex_alu_src),
        .branch(ex_branch),
        .jump(ex_jump),
        .jalr(ex_jalr),
        .lui(ex_lui),
        .auipc(ex_auipc),
        .funct3(ex_funct3),

        .alu_result(ex_alu_result),
        .store_data(ex_store_data),
        .branch_target(ex_branch_target),
        .jump_target(ex_jump_target),
        .branch_taken(ex_branch_taken),
        .writeback_data(ex_writeback_data)
    );

    assign redirect = ex_jump || (ex_branch && ex_branch_taken);

    assign redirect_target =
        ex_jump ? ex_jump_target : ex_branch_target;

    // =====================================================
    // EX / MEM PIPELINE REGISTER
    // =====================================================

    wire [31:0] mem_pc4;
    wire [31:0] mem_write_data;

    wire mem_read;
    wire mem_write;

    reg [2:0] mem_funct3;

    wire [31:0] exmem_result;

    assign exmem_result =
        ex_jump ? ex_pc4 : ex_alu_result;

    always @(posedge clk or posedge reset) begin
        if (reset)
            mem_funct3 <= 3'b000;
        else
            mem_funct3 <= ex_funct3;
    end

    ex_mem_register ex_mem (
        .clk(clk),
        .reset(reset),

        .pc_plus4_in(ex_pc4),
        .alu_result_in(exmem_result),
        .write_data_in(ex_store_data),

        .rd_in(ex_rd),

        .reg_write_in(ex_reg_write),
        .mem_read_in(ex_mem_read),
        .mem_write_in(ex_mem_write),
        .mem_to_reg_in(ex_mem_to_reg),

        .pc_plus4_out(mem_pc4),
        .alu_result_out(mem_alu_result),
        .write_data_out(mem_write_data),

        .rd_out(mem_rd),

        .reg_write_out(mem_reg_write),
        .mem_read_out(mem_read),
        .mem_write_out(mem_write),
        .mem_to_reg_out(mem_to_reg)
    );

    // =====================================================
    // MEMORY STAGE
    // =====================================================

    wire [31:0] memory_read_data;

    memory_stage memory_unit (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(mem_alu_result),
        .write_data(mem_write_data),
        .funct3(mem_funct3),
        .read_data(memory_read_data)
    );

    // =====================================================
    // MEM / WB PIPELINE REGISTER
    // =====================================================

    wire [31:0] wb_alu_result;
    wire [31:0] wb_memory_data;
    wire [31:0] wb_pc4;

    wire wb_mem_to_reg;

    mem_wb_register mem_wb (
        .clk(clk),
        .reset(reset),

        .alu_result_in(mem_alu_result),
        .memory_data_in(memory_read_data),
        .pc_plus4_in(mem_pc4),

        .rd_in(mem_rd),

        .reg_write_in(mem_reg_write),
        .mem_to_reg_in(mem_to_reg),

        .alu_result_out(wb_alu_result),
        .memory_data_out(wb_memory_data),
        .pc_plus4_out(wb_pc4),

        .rd_out(wb_rd),

        .reg_write_out(wb_reg_write),
        .mem_to_reg_out(wb_mem_to_reg)
    );

    // =====================================================
    // WRITEBACK
    // =====================================================

    wire [1:0] wb_select;

    assign wb_select = wb_mem_to_reg ? 2'b01 : 2'b00;

    writeback_mux wb_mux (
        .alu_result(wb_alu_result),
        .memory_data(wb_memory_data),
        .pc_plus4(wb_pc4),
        .result_select(wb_select),
        .writeback_data(wb_data)
    );

    register_writeback wb_control (
        .reg_write(wb_reg_write),
        .rd(wb_rd),
        .writeback_data(wb_data),
        .write_enable(wb_write_enable),
        .destination_register(wb_destination),
        .register_data()
    );

    assign debug_wb_write = wb_write_enable;
    assign debug_wb_rd = wb_destination;
    assign debug_wb_data = wb_data;

endmodule
