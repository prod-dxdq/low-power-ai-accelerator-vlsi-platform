`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/counter.vcd"
`endif

// Testbench overview:
// This testbench releases reset and then lets the counter run for several cycles.
// It is simulation-only code used to verify the sequential counter module.
// clk is the timing reference, rst clears the DUT, and count is the value to watch.
// In the platform, this is one of the first waveform examples for learning state over time.
// In the waveform, look for count returning to zero on reset and then incrementing every clock edge.
module tb_counter;
    
    reg clk;
    reg rst;

    wire [3:0] count;

    counter uut (
        .clk(clk),
        .rst(rst),
        .count(count)
    );

    // Clock: flips every 5 ns
    always begin
        #5 clk = ~ clk;
    end

    // Test sequence
    initial begin
        clk = 0;
        rst = 1;

        #10;
        rst = 0;

        #200;

        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_counter);
    end

endmodule
