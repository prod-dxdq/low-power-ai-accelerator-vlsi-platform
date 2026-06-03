// Module overview:
// This module is a sequential multiply-accumulate block with an enable input that imitates simple clock-gating behavior.
// a and b are multiplied together, acc stores the running sum, rst clears the stored value, and enable allows new accumulation.
// In this project, it demonstrates a low-power idea: avoid unnecessary state updates when the block is idle.
module clock_gated_mac (
    input wire clk,
    input wire rst,
    input wire enable,

    input wire [3:0] a,
    input wire [3:0] b,

    output reg [7:0] acc
);

    // This sequential block clears the accumulator on reset and only updates it when enable is asserted.
    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            acc <= 8'b00000000;
        end

        else if (enable) begin
            acc <= acc + (a * b);
        end
        
    end

endmodule