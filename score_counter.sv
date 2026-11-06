module score_counter (
    input  logic clk,
    input  logic reset,
    input  logic score_pulse,

    output logic [3:0] score_ones,
    output logic [3:0] score_tens
);

    always_ff @(posedge clk) begin
        if (reset) begin
            score_ones <= 4'd0;
            score_tens <= 4'd0;
        end
        else if (score_pulse) begin
            // Stop at 99.
            if ((score_tens == 4'd9) && (score_ones == 4'd9)) begin
                score_ones <= score_ones;
                score_tens <= score_tens;
            end
            else if (score_ones == 4'd9) begin
                // 09 -> 10, 19 -> 20, etc.
                score_ones <= 4'd0;
                score_tens <= score_tens + 4'd1;
            end
            else begin
                score_ones <= score_ones + 4'd1;
            end
        end
    end

endmodule
