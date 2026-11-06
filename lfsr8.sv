module lfsr8 (
    input  logic clk,
    input  logic reset,
    output logic [1:0] random_bits
);

    logic [7:0] lfsr;

    always_ff @(posedge clk) begin
        if (reset) begin
            // LFSRs must start from a non-zero seed.
            lfsr <= 8'hA5;
        end
        else begin
            lfsr <= {
                lfsr[6:0],
                lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]
            };
        end
    end

    assign random_bits = lfsr[1:0];

endmodule
