// Module overview:
// This small probe combines a simple combinational function with a registered output.
// a, b, and sel choose the logic result, comb_result is the intermediate value, clk stores that value, rst_n clears y, and y is the registered output.
// In this project, it is a quick workflow-check design for simulation and waveform debugging.
module smoke_probe (
    input wire clk,
    input wire rst_n,
    input wire a,
    input wire b,
    input wire sel,
    output reg y
);
    // This wire holds the immediate combinational choice before it is clocked into y.
    wire comb_result;

    // This combinational assignment selects between XOR and AND behavior with sel.
    assign comb_result = sel ? (a ^ b) : (a & b);

    // This sequential block registers the selected combinational result.
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            y <= 1'b0;
        end else begin
            y <= comb_result;
        end
    end
endmodule