`timescale 1ns/1ps

// Testbench overview:
// This testbench feeds a 2x2 matrix multiply into the AI accelerator core over several clock cycles.
// It is simulation-only code used to show how streamed A data enters from the left and streamed B data enters from the top.
// clk drives the pipeline, rst clears the accelerator, enable allows the systolic array to update,
// a0_in/a1_in are the left-edge A streams, b0_in/b1_in are the top-edge B streams, and c00-c11 are the outputs.
// In the platform, this verifies the final top-level AI accelerator wrapper.
// In the waveform, watch the streamed inputs first, then watch c00/c01/c10/c11 settle after the pipeline flush cycles.

module tb_ai_accelerator_core;

    reg clk;
    reg rst;
    reg enable;

    reg [3:0] a0_in;
    reg [3:0] a1_in;
    reg [3:0] b0_in;
    reg [3:0] b1_in;

    wire [7:0] c00;
    wire [7:0] c01;
    wire [7:0] c10;
    wire [7:0] c11;

    // This block connects the testbench signals to the AI accelerator core.
    ai_accelerator_core uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),

        .a0_in(a0_in),
        .a1_in(a1_in),
        .b0_in(b0_in),
        .b1_in(b1_in),

        .c00(c00),
        .c01(c01),
        .c10(c10),
        .c11(c11)
    );

    // This block generates the clock that advances data through the accelerator.
    always begin
        #5 clk = ~clk;
    end

    // This stimulus block streams the matrix values over multiple cycles and then flushes the pipeline with zeros.
    // The previous version of this testbench drove both A rows and both B columns at the same time,
    // which breaks real systolic timing. In this array, row 1 data and column 1 data must be injected
    // one cycle later so the lower and right PEs see operands that were forwarded through their neighbors.
    // That timing bug left c01 and c10 short by one product each, even though the wrapper port mapping was correct.
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

        // Cycle 1:
        // Start only the top-left PE. This matches real systolic dataflow where the second row and
        // second column have not reached their dependent PEs yet.
        a0_in = 1;
        a1_in = 0;
        b0_in = 5;
        b1_in = 0;
        #10;

        // Cycle 2:
        // Inject the next row-0 and col-0 values while also starting row-1 and col-1.
        // This lines up the forwarded operands so c01 and c10 accumulate the missing cross terms.
        a0_in = 2;
        a1_in = 3;
        b0_in = 7;
        b1_in = 6;
        #10;

        // Cycle 3:
        // Keep feeding the staggered streams long enough for the right and lower PEs to receive
        // their second non-zero operands through the real PE-to-PE forwarding paths.
        a0_in = 0;
        a1_in = 4;
        b0_in = 0;
        b1_in = 8;
        #10;

        // Cycle 4:
        // Flush the systolic pipeline with zeros so the last forwarded values can reach c11.
        a0_in = 0;
        a1_in = 0;
        b0_in = 0;
        b1_in = 0;
        #10;

        enable = 0;

        // These checks document the intended top-level result and prove that the wrapper now
        // preserves the same behavior as the standalone systolic array testbench.
        $display("Final outputs: c00=%0d c01=%0d c10=%0d c11=%0d", c00, c01, c10, c11);
        if ((c00 !== 8'd19) || (c01 !== 8'd22) || (c10 !== 8'd43) || (c11 !== 8'd50)) begin
            $error("ai_accelerator_core mismatch: expected c00=19 c01=22 c10=43 c11=50");
        end

        #10;

        $finish;
    end

    // This block creates the waveform file used by GTKWave.
    initial begin
        $dumpfile("waves/ai_accelerator_core.vcd");
        $dumpvars(0, tb_ai_accelerator_core);
    end

endmodule