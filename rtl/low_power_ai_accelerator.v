// Module overview:
// This module wraps a dot-product engine with a clocked output register and an enable control for lower-activity updates.
// a0-a3 and w0-w3 are the data and weights, dot_result is the internal combinational value, and result is the registered accelerator output.
// In this project, it shows how an AI math block can be turned into a simple low-power accelerator stage.
module low_power_ai_accelerator (
    input wire clk,
    input wire rst,
    input wire enable,

    input wire [3:0] a0,
    input wire [3:0] a1,
    input wire [3:0] a2,
    input wire [3:0] a3,

    input wire [3:0] w0,
    input wire [3:0] w1,
    input wire [3:0] w2,
    input wire [3:0] w3,

    output reg [9:0] result
);

    // This wire carries the immediate dot-product result before it is conditionally stored.
    wire [9:0] dot_result;

    // This instance reuses the combinational dot-product block as the core compute engine.
    dot_product_unit dot_product (
        .a0(a0),
        .a1(a1),
        .a2(a2),
        .a3(a3),

        .w0(w0),
        .w1(w1),
        .w2(w2),
        .w3(w3),

        .result(dot_result)
    );

    // This sequential block only captures a new result when enable is high.
    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 10'b0;
        else if (enable)
            result <= dot_result;
    end

endmodule