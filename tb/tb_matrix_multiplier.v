`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/matrix_multiplier.vcd"
`endif

// Testbench overview:
// This testbench applies two 2x2 matrices to the combinational matrix multiplier.
// It is simulation-only code used to verify the matrix output values.
// The a signals form matrix A, the b signals form matrix B, and c00-c11 are the matrix C outputs.
// In the platform, this testbench shows how a larger AI-style math block can still be checked with simple waveform inspection.
// In the waveform, verify each c output against one row-by-column multiply-and-sum.
module tb_matrix_multiplier;
    
    reg [3:0] a00, a01, a10, a11;
    reg [3:0] b00, b01, b10, b11;

    wire [8:0] c00, c01, c10, c11;

    matrix_multiplier uut (
        .a00(a00), .a01(a01),
        .a10(a10), .a11(a11),

        .b00(b00), .b01(b01),
        .b10(b10), .b11(b11),

        .c00(c00), .c01(c01),
        .c10(c10), .c11(c11)
    );

    // This stimulus block loads both matrices and leaves them stable so the combinational outputs can settle.
    initial begin
        a00 = 1; a01 = 2;
        a10 = 3; a11 = 4;

        b00 = 5; b01 = 6;
        b10 = 7; b11 = 8;

        #10;

        $finish;
    end

    // This block writes the matrix-multiplier signals into the VCD file.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_matrix_multiplier);
    end
    
endmodule
