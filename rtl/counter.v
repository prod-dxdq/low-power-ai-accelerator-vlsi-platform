// Module overview:
// This counter is a simple sequential circuit that increments once per clock after reset is released.
// clk drives the updates, rst clears the counter, and count is the current 4-bit state.
// In this project, it is a small warm-up example for stateful digital logic before the accelerator blocks.
module counter (
    input wire clk,
    input wire rst,
    output reg [3:0] count
);

    // This sequential block either clears the counter or advances it by one count per cycle.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 4'b0000;
        end
        else begin
            count <= count + 1;
        end
    end

endmodule