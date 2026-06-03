`timescale 1ns/1ns

`ifndef VCD_FILE
`define VCD_FILE "waves/parallel_dot_product_engine.vcd"
`endif

// Testbench overview:
// This testbench drives one input vector into four dot-product lanes running in parallel.
// It is simulation-only code used to verify the parallel datapath outputs.
// a0-a3 are the shared inputs, each w group is one lane's weights, and y0-y3 are the results to watch.
// In the platform, this shows how multiple compute lanes can process the same data at once.
// In the waveform, compare y0-y3 and confirm that each lane produces its own dot product in parallel.
module tb_parallel_dot_product_engine;
    reg [3:0] a0, a1, a2, a3;

    reg [3:0] w00, w01, w02, w03;
    reg [3:0] w10, w11, w12, w13;
    reg [3:0] w20, w21, w22, w23;
    reg [3:0] w30, w31, w32, w33;

    wire [9:0] y0, y1, y2, y3;

    parallel_dot_product_engine uut (
        .a0(a0), .a1(a1), .a2(a2), .a3(a3),

        .w00(w00), .w01(w01), .w02(w02), .w03(w03),
        .w10(w10), .w11(w11), .w12(w12), .w13(w13),
        .w20(w20), .w21(w21), .w22(w22), .w23(w23),
        .w30(w30), .w31(w31), .w32(w32), .w33(w33),

        .y0(y0), .y1(y1), .y2(y2), .y3(y3)
    );

    // This stimulus block loads one shared input vector and four weight sets so all output lanes can be compared at once.
    initial begin
        a0 = 1; a1 = 2; a2 = 3; a3 = 4;

        w00 = 1; w01 = 1; w02 = 1; w03 = 1; // y0 = 10
        w10 = 2; w11 = 2; w12 = 2; w13 = 2; // y1 = 20
        w20 = 3; w21 = 3; w22 = 3; w23 = 3; // y2 = 30
        w30 = 4; w31 = 4; w32 = 4; w33 = 4; // y3 = 40

        #10;

        $finish;
    end

    // This block writes the parallel lane activity into the VCD file.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_parallel_dot_product_engine);
    end

endmodule