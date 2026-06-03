// Module overview:
// This is a real 2x2 systolic array built from four processing elements instead of four independent MACs.
// a0_in and a1_in are the left-edge A streams, b0_in and b1_in are the top-edge B streams, and c00-c11 are the accumulators from the four cells.
// In this project, it demonstrates how small AI math cells can be tiled into a dataflow accelerator structure.
module systolic_array_2x2 (
    input wire clk,
    input wire rst,
    input wire enable,

    input wire [3:0] a0_in,
    input wire [3:0] a1_in,
    input wire [3:0] b0_in,
    input wire [3:0] b1_in,

    output wire [7:0] c00,
    output wire [7:0] c01,
    output wire [7:0] c10,
    output wire [7:0] c11
);

    // These internal wires carry A values to the right and B values downward between neighboring PEs.
    wire [3:0] a00_to_01;
    wire [3:0] a10_to_11;
    wire [3:0] b00_to_10;
    wire [3:0] b01_to_11;

    // The top-left PE starts the array by consuming the first A stream and the first B stream.
    processing_element pe00 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .a_in(a0_in),
        .b_in(b0_in),
        .a_out(a00_to_01),
        .b_out(b00_to_10),
        .acc(c00)
    );

    // The top-right PE receives A from the left and a fresh B stream from the top edge.
    processing_element pe01 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .a_in(a00_to_01),
        .b_in(b1_in),
        .a_out(),
        .b_out(b01_to_11),
        .acc(c01)
    );

    // The bottom-left PE receives a fresh A stream from the left edge and forwarded B from above.
    processing_element pe10 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .a_in(a1_in),
        .b_in(b00_to_10),
        .a_out(a10_to_11),
        .b_out(),
        .acc(c10)
    );

    // The bottom-right PE combines the delayed A stream from the left with the delayed B stream from above.
    processing_element pe11 (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .a_in(a10_to_11),
        .b_in(b01_to_11),
        .a_out(),
        .b_out(),
        .acc(c11)
    );

endmodule