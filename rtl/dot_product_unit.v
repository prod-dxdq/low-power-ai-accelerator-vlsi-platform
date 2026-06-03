// Module overview:
// This module computes a 4-element dot product by multiplying each input value by its matching weight and summing the results.
// a0-a3 hold the input vector values, w0-w3 hold the weight values, and result is the 10-bit summed output.
// In this project, it is one of the first AI-oriented math blocks because dot products are central to inference hardware.
module dot_product_unit (
    input wire [3:0] a0,
    input wire [3:0] a1,
    input wire [3:0] a2,
    input wire [3:0] a3,

    input wire [3:0] w0,
    input wire [3:0] w1,
    input wire [3:0] w2,
    input wire [3:0] w3,

    output wire [9:0] result
);
    // This combinational expression performs the full multiply-and-sum operation for the 4-element vectors.
    assign result = (a0 * w0) + 
                    (a1 * w1) + 
                    (a2 * w2) + 
                    (a3 * w3);

endmodule
