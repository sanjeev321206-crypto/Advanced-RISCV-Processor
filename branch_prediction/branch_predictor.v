
module branch_predictor #(
    parameter INDEX_BITS = 4,
    parameter ENTRIES = (1 << INDEX_BITS)
)(
    input wire clk,
    input wire reset,

    input wire [31:0] predict_pc,
    output wire predicted_taken,

    input wire update_en,
    input wire [31:0] update_pc,
    input wire actual_taken
);

    reg [1:0] prediction_table [0:ENTRIES-1];

    wire [INDEX_BITS-1:0] predict_index;
    wire [INDEX_BITS-1:0] update_index;

    integer i;

    assign predict_index = predict_pc[INDEX_BITS+1:2];
    assign update_index = update_pc[INDEX_BITS+1:2];

    assign predicted_taken =
        prediction_table[predict_index][1];

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            for (i = 0; i < ENTRIES; i = i + 1)
                prediction_table[i] <= 2'b01;
        end

        else if (update_en) begin

            if (actual_taken) begin
                if (prediction_table[update_index] != 2'b11)
                    prediction_table[update_index] <=
                        prediction_table[update_index] + 1'b1;
            end

            else begin
                if (prediction_table[update_index] != 2'b00)
                    prediction_table[update_index] <=
                        prediction_table[update_index] - 1'b1;
            end

        end
    end

endmodule
