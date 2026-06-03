// Module overview:
// This MAC unit is a sequential multiply-accumulate block that keeps adding a*b into acc every clock cycle.
// a and b are the multiplier inputs, acc is the stored running sum, clk advances the state, and rst clears it.
// In this project, it is a core datapath primitive that later grows into dot products and arrays.
module mac_unit (
    input wire clk,
    input wire rst,

    input wire [3:0] a,
    input wire [3:0] b,

    output reg [7:0] acc
);

    // This sequential block either clears the accumulator or adds the new product into it.
    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            acc <= 8'b00000000;
        end
        else begin
            acc <= acc + (a * b);
        end
    end

endmodule