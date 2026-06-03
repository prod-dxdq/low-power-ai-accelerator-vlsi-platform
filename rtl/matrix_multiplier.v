// Module overview:
// This module performs a 2x2 matrix multiplication using combinational multiply-and-add expressions.
// The a inputs describe matrix A, the b inputs describe matrix B, and c00-c11 are the four outputs of matrix C.
// In this project, it shows how the dot-product idea scales into a larger matrix operation.
module matrix_multiplier (
    input wire [3:0] a00, a01,
    input wire [3:0] a10, a11,

    input wire [3:0] b00, b01,
    input wire [3:0] b10, b11,

    output wire [8:0] c00, c01,
    output wire [8:0] c10, c11
);

    // These combinational assignments compute each matrix output from one row of A and one column of B.
    assign c00 = (a00 * b00) + (a01 * b10);
    assign c01 = (a00 * b01) + (a01 * b11);

    assign c10 = (a10 * b00) + (a11 * b10);
    assign c11 = (a10 * b01) + (a11 * b11);

endmodule