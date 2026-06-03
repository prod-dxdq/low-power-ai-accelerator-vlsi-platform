`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/mac_unit.vcd"
`endif

// Testbench overview:
// This testbench feeds several input pairs into the MAC unit so the accumulator grows over time.
// It is simulation-only code that verifies the sequential multiply-accumulate behavior.
// clk and rst control the timing, a and b are multiplier inputs, and acc is the output to watch.
// In the platform, this is the verification partner for one of the core accelerator datapath blocks.
// In the waveform, look for acc adding a new product every clock cycle after reset.
module tb_mac_unit;
    
    reg clk;
    reg rst;

    reg [3:0] a;
    reg [3:0] b;

    wire [7:0] acc;

    mac_unit uut (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .acc(acc)
    );

    // Clock
    always begin
        #5 clk = ~ clk;
    end

    // Stimulus
    initial begin
        clk = 0;
        rst = 1;
        a = 0;
        b = 0;

        #10;
        rst = 0;

        a = 3; b = 2;   // acc = 0 + 6 = 6
        #10;
        
        a = 4; b = 2;   // acc = 6 + 8 = 14
        #10;

        a = 1; b = 5;   // acc = 14 + 5 = 19
        #10;

        a = 2; b = 3;   // acc = 19 + 6 = 25
        #10;

        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_mac_unit);
    end
endmodule
