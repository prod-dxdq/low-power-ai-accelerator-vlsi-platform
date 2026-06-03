`timescale 1ns/1ns

`ifndef VCD_FILE
`define VCD_FILE "waves/smoke_probe.vcd"
`endif

`define CHECK_Y(expected_value) \
    if (y !== expected_value) begin \
        $display("FAIL expected y=%0b got y=%0b at time %0t", expected_value, y, $time); \
        $finish_and_return(1); \
    end

// Testbench overview:
// This testbench is a small workflow check that verifies a registered output against several expected logic cases.
// It is simulation-only code and uses a helper macro to stop immediately if the DUT output is wrong.
// clk drives the DUT, rst_n releases reset, a/b/sel are the input controls, and y is the output being checked.
// In the platform, this is the fastest sanity check for the Verilog simulation flow.
// In the waveform, watch the input combinations change and then see y update on the following clock edge.
module tb_smoke_probe;
    reg clk;
    reg rst_n;
    reg a;
    reg b;
    reg sel;
    wire y;

    smoke_probe dut (
        .clk(clk),
        .rst_n(rst_n),
        .a(a),
        .b(b),
        .sel(sel),
        .y(y)
    );

    // This compact block generates the clock for the smoke test.
    always #5 clk = ~clk;

    // This stimulus block walks through several logic cases and checks the registered output after each clock edge.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_smoke_probe);

        clk = 1'b0;
        rst_n = 1'b0;
        a = 1'b0;
        b = 1'b0;
        sel = 1'b0;

        #12;
        `CHECK_Y(1'b0);

        rst_n = 1'b1;
        a = 1'b1;
        b = 1'b1;
        sel = 1'b0;
        @(posedge clk);
        #1;
        `CHECK_Y(1'b1);

        a = 1'b1;
        b = 1'b0;
        sel = 1'b0;
        @(posedge clk);
        #1;
        `CHECK_Y(1'b0);

        a = 1'b1;
        b = 1'b0;
        sel = 1'b1;
        @(posedge clk);
        #1;
        `CHECK_Y(1'b1);

        a = 1'b1;
        b = 1'b1;
        sel = 1'b1;
        @(posedge clk);
        #1;
        `CHECK_Y(1'b0);

        $display("PASS smoke_probe");
        $finish;
    end
endmodule

    `undef CHECK_Y