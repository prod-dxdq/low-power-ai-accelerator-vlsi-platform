// Module overview:
// This RTL module is the top-level AI accelerator core for the project.
// It wraps the real 2x2 systolic array and exposes simple streaming inputs and matrix outputs.
// clk drives the array, rst clears the internal processing elements, enable allows computation,
// a0_in/a1_in are the left-edge A input streams, b0_in/b1_in are the top-edge B input streams,
// and c00-c11 are the final accumulated matrix multiplication outputs.
// In the platform, this module represents the main low-power AI accelerator block that future
// synthesis, schematic generation, and report parsing scripts should target.

module ai_accelerator_core (
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

    // This block instantiates the real 2x2 systolic array.
    // The systolic array is the compute engine of the AI accelerator.
    systolic_array_2x2 systolic_core (
        .clk(clk),
        .rst(rst),
        .enable(enable),

        .a0_in(a0_in),
        .a1_in(a1_in),
        .b0_in(b0_in),
        .b1_in(b1_in),

        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

endmodule