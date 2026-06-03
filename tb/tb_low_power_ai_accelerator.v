`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/low_power_ai_accelerator.vcd"
`endif

// Testbench overview:
// This testbench shows the low-power accelerator capturing a dot-product result only when enable is high.
// It is simulation-only verification code for the sequential top-level accelerator stage.
// clk drives the capture, rst clears result, enable controls whether a new value is stored, and result is the main output to watch.
// In the platform, this demonstrates how math hardware can be wrapped with a low-activity control signal.
// In the waveform, compare the changing inputs to the registered result that only updates on enabled clock edges.
module tb_low_power_ai_accelerator;

    reg clk;
    reg rst;
    reg enable;

    reg [3:0] a0,a1,a2,a3;
    reg [3:0] w0,w1,w2,w3;

    wire [9:0] result;

    low_power_ai_accelerator uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
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

    // This block generates the clock used by the registered accelerator output stage.
    always begin
        #5 clk = ~clk;
    end

    // This stimulus block changes the inputs while enable is both active and inactive so the hold behavior is visible.
    initial begin
        clk = 0;
        rst = 1;
        enable = 0;

        a0 = 1; a1 = 2; a2 = 3; a3 = 4;
        w0 = 5; w1 = 6; w2 = 7; w3 = 8;

        #10;
        rst = 0;

        enable = 1;
        #10; // result should become 70

        enable = 0;
        a0 = 2; a1 = 2; a2 = 2; a3 = 2;
        w0 = 1; w1 = 1; w2 = 1; w3 = 1;
        #10; // result should stay 70

        enable = 1;
        #10; // result should become 8

        $finish;
    end

    // This block writes the top-level accelerator signals into the VCD file.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_low_power_ai_accelerator);
    end

endmodule