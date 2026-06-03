`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/dot_product_unit.vcd"
`endif

// Testbench overview:
// This testbench applies one input vector and one weight vector to the dot-product unit.
// It is simulation-only code used to verify the combinational math block.
// a0-a3 are the input values, w0-w3 are the weights, and result is the output to inspect.
// In the platform, this verifies one of the first AI-style arithmetic kernels.
// In the waveform, check that result becomes the sum of the four products.
module tb_dot_product_unit;
    reg [3:0] a0, a1, a2, a3;
    reg [3:0] w0, w1, w2, w3;

    wire [9:0] result;

    dot_product_unit uut (
        .a0(a0),
        .a1(a1), 
        .a2(a2), 
        .a3(a3),

        .w0(w0), 
        .w1(w1), 
        .w2(w2), 
        .w3(w3),

        .result(result)
    );

    // This stimulus block applies one vector/weight example and holds it long enough to inspect the dot-product result.
    initial begin
        a0 = 1;
        a1 = 2;
        a2 = 3;
        a3 = 4;

        w0 = 5;
        w1 = 6;
        w2 = 7;
        w3 = 8;

        #10;

        $finish;
    end

    // This block writes the DUT activity into the VCD file for waveform viewing.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_dot_product_unit);
    end

endmodule
