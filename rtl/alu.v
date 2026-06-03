// Module overview:
// This ALU is a small combinational datapath block that performs one operation on two 4-bit inputs.
// Inputs a and b are the operands, op selects the function, and result changes immediately with the inputs.
// In this project, it is an early arithmetic building block that leads into larger accelerator datapaths.
module alu (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [2:0] op,
    output reg [3:0] result
);

    // This combinational block selects which arithmetic or logic operation to perform.
    always @(*) begin
        case (op)

            2'b00: result = a + b; // ADD
            2'b01: result = a - b; // SUB
            2'b10: result = a & b; // AND
            2'b11: result = a | b; // OR

            default : result = 4'b0000;
        
        endcase
    end

endmodule