`timescale 1ns/1ps

module tb_rr_arbiter;

    logic       clk;
    logic       reset;
    logic [3:0] req;
    logic [3:0] gnt;

    rr_arbiter dut (
        .clk   (clk),
        .reset (reset),
        .req   (req),
        .gnt   (gnt)
    );

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin

        // Initial values
        reset = 1'b1;
        req   = 4'b0000;

        // Hold reset across a rising edge
        @(posedge clk);
        #1;
        reset = 1'b0;

        // TEST 1: All requesters active
        // Expected rotation: R0 -> R1 -> R2 -> R3
        req = 4'b1111;

        repeat (4) begin
            @(posedge clk);
            #1;
            $display("time=%0t req=%b gnt=%b pointer=%b",
                     $time, req, gnt, dut.pointer);
        end

        // TEST 2: Nobody requesting
        req = 4'b0000;

        @(posedge clk);
        #1;

        $display("time=%0t req=%b gnt=%b pointer=%b",
                 $time, req, gnt, dut.pointer);

        // TEST 3: Only R2 requesting
        req = 4'b0100;

        @(posedge clk);
        #1;

        $display("time=%0t req=%b gnt=%b pointer=%b",
                 $time, req, gnt, dut.pointer);

        // TEST 4: R3 and R0 requesting
        req = 4'b1001;

        @(posedge clk);
        #1;

        $display("time=%0t req=%b gnt=%b pointer=%b",
                 $time, req, gnt, dut.pointer);

        $finish;

    end

endmodule
