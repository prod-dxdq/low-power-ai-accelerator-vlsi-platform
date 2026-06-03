// Module overview:
// This module is a simple accelerator stage that captures a dot-product result into a clocked output register.
// a0-a3 and w0-w3 are the input vector and weight values, dot_result is the internal combinational value, result is the registered output, and rst clears that output.
// In this project, it is a small step between a pure combinational math block and a more controlled accelerator pipeline.
module tiny_ai_accelerator (
    input wire clk,
    input wire rst,

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

    // This wire carries the immediate dot-product value from the submodule.
    wire [9:0] dot_result;

    // This instance provides the combinational vector-math core for the accelerator stage.
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

    // This sequential block clears the output on reset and captures the current dot product on each clock edge.
    always @(posedge clk or posedge rst) begin
        
        if (rst)
            result <= 10'b0;
        else
            result <= dot_result;

    end

endmodule