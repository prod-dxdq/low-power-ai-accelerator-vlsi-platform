`timescale 1ns/1ns

`ifndef VCD_FILE
`define VCD_FILE "waves/systolic_array_2x2.vcd"
`endif

// Testbench overview:
// This testbench feeds a 2x2 matrix multiply into the systolic array over several clock cycles.
// It is simulation-only code used to show how streamed A data moves horizontally and streamed B data moves vertically.
// clk drives the pipeline, rst clears the array, enable allows the PEs to update, a0_in/a1_in are the left-edge A streams, b0_in/b1_in are the top-edge B streams, and c00-c11 are the outputs.
// In the platform, this is the beginner example of real dataflow through an array instead of isolated parallel MACs.
// In the waveform, watch the streamed inputs first, then watch c00/c01/c10/c11 settle after the pipeline flush cycles.
module tb_systolic_array_2x2;
    reg clk;
    reg rst;
    reg enable;

    reg [3:0] a0_in;
    reg [3:0] a1_in;
    reg [3:0] b0_in;
    reg [3:0] b1_in;

    wire [7:0] c00, c01, c10, c11;

    systolic_array_2x2 uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),

        .a0_in(a0_in),
        .a1_in(a1_in),
        .b0_in(b0_in),
        .b1_in(b1_in),

        .c00(c00), .c01(c01),
        .c10(c10), .c11(c11)
    );

    // This block generates the clock that advances data through the array.
    always begin
        #5 clk = ~clk;
    end

    // This stimulus block streams the matrix values over multiple cycles and then flushes the pipeline with zeros.
    initial begin
        clk = 0;
        rst = 1;
        enable = 0;

        a0_in = 0;
        a1_in = 0;
        b0_in = 0;
        b1_in = 0;

        #10;
        rst = 0;
        enable = 1;

        // Cycle 1: start the first row/column products at the top-left PE.
        a0_in = 1;
        a1_in = 0;
        b0_in = 5;
        b1_in = 0;
        #10;

        // Cycle 2: inject the next A value for row 0, the first A value for row 1,
        // the next B value for column 0, and the first B value for column 1.
        a0_in = 2;
        a1_in = 3;
        b0_in = 7;
        b1_in = 6;
        #10;

        // Cycle 3: flush more data through the array so the lower and right PEs can keep accumulating.
        a0_in = 0;
        a1_in = 4;
        b0_in = 0;
        b1_in = 8;
        #10;

        // Cycle 4: feed zeros to flush the pipeline and let the last PE finish c11.
        a0_in = 0;
        a1_in = 0;
        b0_in = 0;
        b1_in = 0;
        #10;

        enable = 0;
        $finish;
    end

    // This block writes the streamed dataflow behavior into the VCD file.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_systolic_array_2x2);
    end

endmodule