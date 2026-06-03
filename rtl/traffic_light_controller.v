`timescale 1ns/1ps

// Module overview:
// This module is a sequential finite-state machine that cycles through green, yellow, and red traffic-light states.
// clk advances the state, rst restarts the sequence, state tracks the active phase, and red/yellow/green drive the outputs.
// In this project, it is a simple control example used to practice FSM design before moving into accelerator datapaths.
module traffic_light_controller (
    input wire clk,
    input wire rst,
    output reg red,
    output reg yellow,
    output reg green
);

    // These state encodings define the three traffic-light phases.
    localparam GREEN_STATE = 2'b00;
    localparam YELLOW_STATE = 2'b01;
    localparam RED_STATE = 2'b10;

    // These constants control how many clock cycles each light remains active.
    localparam integer GREEN_CYCLES = 3;
    localparam integer YELLOW_CYCLES = 1;
    localparam integer RED_CYCLES = 2;

    // These registers store the current FSM state and how long the design has stayed in that state.
    reg [1:0] state;
    reg [1:0] state_count;

    // This sequential block advances the FSM and counts how long each state has been active.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= GREEN_STATE;
            state_count <= 2'd0;
        end else begin
            case (state)
                GREEN_STATE: begin
                    if (state_count == GREEN_CYCLES - 1) begin
                        state <= YELLOW_STATE;
                        state_count <= 2'd0;
                    end else begin
                        state_count <= state_count + 2'd1;
                    end
                end
                YELLOW_STATE: begin
                    if (state_count == YELLOW_CYCLES - 1) begin
                        state <= RED_STATE;
                        state_count <= 2'd0;
                    end else begin
                        state_count <= state_count + 2'd1;
                    end
                end
                RED_STATE: begin
                    if (state_count == RED_CYCLES - 1) begin
                        state <= GREEN_STATE;
                        state_count <= 2'd0;
                    end else begin
                        state_count <= state_count + 2'd1;
                    end
                end
                default: begin
                    state <= GREEN_STATE;
                    state_count <= 2'd0;
                end
            endcase
        end
    end

    // This combinational block decodes the current state into one-hot light outputs.
    always @(*) begin
        red = 1'b0;
        yellow = 1'b0;
        green = 1'b0;

        case (state)
            GREEN_STATE: green = 1'b1;
            YELLOW_STATE: yellow = 1'b1;
            RED_STATE: red = 1'b1;
            default: green = 1'b1;
        endcase
    end

endmodule
