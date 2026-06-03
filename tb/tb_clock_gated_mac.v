`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/clock_gated_mac.vcd"
`endif

// Testbench overview:
// This testbench shows how the clock-gated MAC accumulates products only when enable is high.
// It is simulation-only verification code for the sequential DUT.
// clk drives the updates, rst clears acc, enable controls activity, a and b are multiplier inputs, and acc is the value to watch.
// In the platform, this testbench highlights a simple low-power behavior in the waveform.
// In the waveform, check that acc stops changing during the cycle where enable is low.
module tb_clock_gated_mac;
    
    reg clk;
    reg rst;
    reg enable;

    reg [3:0] a;
    reg [3:0] b;

    wire [7:0] acc;

    clock_gated_mac uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .a(a),
        .b(b),
        .acc(acc)
    );

    // Clock
    always begin
        #5 clk = ~clk;
    end

    // Stimulus
    initial begin
        clk = 0;
        rst = 1;
        enable = 0;
        a = 0;
        b = 0;

        #10;
        rst = 0;

        enable = 1;
        a = 3; b = 2; // acc = 0 + 6 = 6
        #10;

        enable = 1;
        a = 4; b = 2; // acc = 6 + 8 = 14
        #10;

        enable = 0; // No change to acc
        a = 1; b = 5; // acc should remain 14
        #10;

        enable = 1;
        a = 2; b = 3; // acc = 14 + 6 = 20
        #10;

        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_clock_gated_mac);
    end

endmodule
