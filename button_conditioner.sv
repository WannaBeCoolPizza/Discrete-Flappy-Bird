module button_conditioner #(
    parameter int DEBOUNCE_CYCLES = 250_000
) (
    input  logic clk,
    input  logic reset,
    input  logic button_n,
    output logic press_pulse
);

    localparam int COUNT_WIDTH =
        (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES);

    logic sync1;
    logic sync2;

    logic pressed;
    logic debounced_pressed;
    logic debounced_pressed_old;

    logic [COUNT_WIDTH-1:0] debounce_count;

    // DE10-Lite push buttons are active-low.
    assign pressed = ~sync2;

    always_ff @(posedge clk) begin
        if (reset) begin
            sync1                <= 1'b1;
            sync2                <= 1'b1;
            debounced_pressed    <= 1'b0;
            debounced_pressed_old<= 1'b0;
            debounce_count       <= '0;
            press_pulse          <= 1'b0;
        end
        else begin
            // Synchronize the asynchronous physical button.
            sync1 <= button_n;
            sync2 <= sync1;

            // Debounce.
            if (pressed == debounced_pressed) begin
                debounce_count <= '0;
            end
            else if (debounce_count == DEBOUNCE_CYCLES - 1) begin
                debounced_pressed <= pressed;
                debounce_count    <= '0;
            end
            else begin
                debounce_count <= debounce_count + 1'b1;
            end

            // Generate one clock-wide pulse when the debounced button is pressed.
            debounced_pressed_old <= debounced_pressed;
            press_pulse <= debounced_pressed & ~debounced_pressed_old;
        end
    end

endmodule
