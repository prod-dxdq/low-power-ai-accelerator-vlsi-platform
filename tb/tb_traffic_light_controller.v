`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/traffic_light_controller.vcd"
`endif

// Testbench overview:
// This testbench runs the traffic-light controller long enough to see repeated green, yellow, and red phases.
// It is simulation-only code that verifies the controller state machine behavior.
// clk advances the FSM, rst restarts it, and red/yellow/green are the outputs to watch.
// In the platform, this is the main beginner control-logic waveform example.
// In the waveform, check how long each light stays active before the next transition.
module tb_traffic_light_controller;
    // Declare clock, reset, and DUT observation signals.
    reg clk;
    reg rst;

    wire red;
    wire yellow;
    wire green;

    // Instantiate the traffic_light_controller module.
    traffic_light_controller uut (
        .clk(clk),
        .rst(rst),
        .red(red),
        .yellow(yellow),
        .green(green)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    // Test sequence
    initial begin
        clk = 0;
        rst = 1;

        #10;
        rst = 0;

        #180;
        
        $finish;
    end

    // Waveform dump
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_traffic_light_controller);
    end

endmodule
