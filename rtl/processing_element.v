// Module overview:
// This processing element is the basic building block of a systolic array in this platform.
// a_in is the value that moves to the right, b_in is the value that moves downward, a_out and b_out forward those streams, and acc stores the local multiply-accumulate result.
// Larger array-based compute blocks are built by connecting many copies of this cell together.
module processing_element (
    input wire clk,
    input wire rst,
    input wire enable,

    input wire [3:0] a_in,
    input wire [3:0] b_in,

    output reg [3:0] a_out,
    output reg [3:0] b_out,
    output reg [7:0] acc
);

    // This sequential block resets the forwarded data and accumulator, or updates all three together when enable is high.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_out <= 4'b0000;
            b_out <= 4'b0000;
            acc <= 8'b00000000;
        end else if (enable) begin
            // This operation performs the local multiply-accumulate step for the PE.
            acc <= acc + (a_in * b_in);

            // This forwards the A stream horizontally to the PE on the right.
            a_out <= a_in;

            // This forwards the B stream vertically to the PE below.
            b_out <= b_in;
        end
    end

endmodule