module power_on_reset (
    input  logic clk,
    output logic reset
);

    // Quartus supports register power-up initialization on Intel FPGAs.
    logic [3:0] count = 4'hF;

    always_ff @(posedge clk) begin
        if (count != 4'd0)
            count <= count - 1'b1;
    end

    assign reset = (count != 4'd0);

endmodule
