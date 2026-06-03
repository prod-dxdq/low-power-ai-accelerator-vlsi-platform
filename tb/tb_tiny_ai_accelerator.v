`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/tiny_ai_accelerator.vcd"
`endif

// Testbench overview:
// This testbench applies one vector and one set of weights to the tiny accelerator and lets the registered result update.
// It is simulation-only code for checking the clocked wrapper around the dot-product block.
// clk and rst control timing, a0-a3 and w0-w3 are the inputs, and result is the registered output to watch.
// In the platform, this testbench shows the step from pure combinational math to a clocked accelerator stage.
// In the waveform, watch result stay at zero through reset and then capture the dot-product value on a clock edge.
module tb_tiny_ai_accelerator;
    
    reg clk;
    reg rst;

    reg [3:0] a0,a1,a2,a3;
    reg [3:0] w0,w1,w2,w3;

    wire [9:0] result;

    tiny_ai_accelerator uut (
        .clk(clk),
        .rst(rst),

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

    // This stimulus block loads one dot-product example, releases reset, and waits for the registered result.
    initial begin
        
        clk = 0;
        rst = 1;

        a0 = 1;
        a1 = 2;
        a2 = 3;
        a3 = 4;

        w0 = 5;
        w1 = 6;
        w2 = 7;
        w3 = 8;

        #10;
        rst = 0;

        #20;

        $finish;

    end

    // This block writes the DUT activity into the VCD file.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_tiny_ai_accelerator);
    end
    
endmodule
