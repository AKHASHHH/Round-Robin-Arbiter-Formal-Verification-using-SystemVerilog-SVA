`timescale 1ns/1ps

module rr_arbiter (
    input  logic       clk,
    input  logic       reset,
    input  logic [3:0] req,
    output logic [3:0] gnt
);

    logic [1:0] pointer;
    logic [1:0] next_pointer;

    // Sequential state logic
    always_ff @(posedge clk) begin
        if (reset)
            pointer <= 2'b00;
        else
            pointer <= next_pointer;
    end

    // Combinational arbitration logic
    always_comb begin
        gnt = 4'b0000;
        next_pointer = pointer;

        case (pointer)

            // R0 -> R1 -> R2 -> R3
            2'b00: begin
                if (req[0]) begin
                    gnt = 4'b0001;
                    next_pointer = 2'b01;
                end
                else if (req[1]) begin
                    gnt = 4'b0010;
                    next_pointer = 2'b10;
                end
                else if (req[2]) begin
                    gnt = 4'b0100;
                    next_pointer = 2'b11;
                end
                else if (req[3]) begin
                    gnt = 4'b1000;
                    next_pointer = 2'b00;
                end
            end

            // R1 -> R2 -> R3 -> R0
            2'b01: begin
                if (req[1]) begin
                    gnt = 4'b0010;
                    next_pointer = 2'b10;
                end
                else if (req[2]) begin
                    gnt = 4'b0100;
                    next_pointer = 2'b11;
                end
                else if (req[3]) begin
                    gnt = 4'b1000;
                    next_pointer = 2'b00;
                end
                else if (req[0]) begin
                    gnt = 4'b0001;
                    next_pointer = 2'b01;
                end
            end

            // R2 -> R3 -> R0 -> R1
            2'b10: begin
                if (req[2]) begin
                    gnt = 4'b0100;
                    next_pointer = 2'b11;
                end
                else if (req[3]) begin
                    gnt = 4'b1000;
                    next_pointer = 2'b00;
                end
                else if (req[0]) begin
                    gnt = 4'b0001;
                    next_pointer = 2'b01;
                end
                else if (req[1]) begin
                    gnt = 4'b0010;
                    next_pointer = 2'b10;
                end
            end

            // R3 -> R0 -> R1 -> R2
            2'b11: begin
                if (req[3]) begin
                    gnt = 4'b1000;
                    next_pointer = 2'b00;
                end
                else if (req[0]) begin
                    gnt = 4'b0001;
                    next_pointer = 2'b01;
                end
                else if (req[1]) begin
                    gnt = 4'b0010;
                    next_pointer = 2'b10;
                end
                else if (req[2]) begin
                    gnt = 4'b0100;
                    next_pointer = 2'b11;
                end
            end

            default: begin
                gnt = 4'b0000;
                next_pointer = 2'b00;
            end

        endcase
    end

endmodule
