`timescale 1ns/1ps

`ifndef VCD_FILE
`define VCD_FILE "waves/alu.vcd"
`endif

// Testbench overview:
// This testbench exercises each ALU operation one after another and records the output waveform.
// It is simulation-only code, so it is not hardware that gets synthesized.
// a and b are the operands, op selects the ALU function, and result is the DUT output to watch.
// In the platform, this is the verification companion for the beginner arithmetic block.
// In the waveform, look for result stepping through add, subtract, AND, and OR.
module tb_alu;
    
    reg [3:0] a;
    reg [3:0] b;
    reg [1:0] op;

    wire [3:0] result;

    alu uut (
        .a(a),
        .b(b),
        .op(op),
        .result(result)
    );

    // This stimulus block applies one operand pair and steps through each ALU operation code.
    initial begin
        $dumpfile(`VCD_FILE);
        $dumpvars(0, tb_alu);

        a = 4'b0101; // 5
        b = 4'b0011; // 3

        op = 2'b00; #10; // ADD: 5 + 3 = 8
        op = 2'b01; #10; // SUB: 5 - 3 = 2
        op = 2'b10; #10; // AND
        op = 2'b11; #10; // OR

        $finish;
    end
endmodule
