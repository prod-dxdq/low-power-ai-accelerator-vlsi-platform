// Module overview:
// This module runs four dot-product units in parallel on the same input vector but with four different weight sets.
// a0-a3 are shared input values, each w group is one output channel's weights, and y0-y3 are the four dot-product results.
// In this project, it shows how accelerator throughput can increase by duplicating compute lanes.
module parallel_dot_product_engine (
    input wire [3:0] a0, a1, a2, a3,

    input wire [3:0] w00, w01, w02, w03,
    input wire [3:0] w10, w11, w12, w13,
    input wire [3:0] w20, w21, w22, w23,
    input wire [3:0] w30, w31, w32, w33,

    output wire [9:0] y0,
    output wire [9:0] y1,
    output wire [9:0] y2,
    output wire [9:0] y3
);

    // Each dot-product instance is one parallel lane that produces one output channel.
    dot_product_unit dp0 (
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),
        .w0(w00), .w1(w01), .w2(w02), .w3(w03),
        .result(y0)
    );

    dot_product_unit dp1 (
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),
        .w0(w10), .w1(w11), .w2(w12), .w3(w13),
        .result(y1)
    );

    dot_product_unit dp2 (
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),
        .w0(w20), .w1(w21), .w2(w22), .w3(w23),
        .result(y2)
    );

    dot_product_unit dp3 (
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),
        .w0(w30), .w1(w31), .w2(w32), .w3(w33),
        .result(y3)
    );

endmodule