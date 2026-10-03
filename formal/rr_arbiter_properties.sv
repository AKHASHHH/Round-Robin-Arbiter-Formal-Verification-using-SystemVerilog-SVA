`timescale 1ns/1ps

module rr_arbiter_properties (
    input logic       clk,
    input logic       reset,
    input logic [3:0] req,
    input logic [3:0] gnt,
    input logic [1:0] pointer
);

    // ============================================================
    // GROUP 1: BASIC SAFETY / PROGRESS
    // ============================================================

    // At most one requester may be granted at a time.
    // 0000 is also legal.
    a_mutual_exclusion:
        assert property (
            @(posedge clk)
            disable iff (reset)
            $onehot0(gnt)
        );

    // A requester may only be granted if it is requesting.
    a_grant_valid:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (gnt & ~req) == 4'b0000
        );

    // If at least one requester is active,
    // at least one grant must be produced.
    a_progress:
        assert property (
            @(posedge clk)
            disable iff (reset)
            |req |-> |gnt
        );


    // ============================================================
    // GROUP 2: ROUND-ROBIN SELECTION CORRECTNESS
    // ============================================================

    // ------------------------------------------------------------
    // Pointer = R0 (00)
    // Priority: R0 -> R1 -> R2 -> R3
    // ------------------------------------------------------------

    a_ptr_r0_choose_r0:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b00 && req[0])
            |-> (gnt == 4'b0001)
        );

    a_ptr_r0_choose_r1:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b00 && !req[0] && req[1])
            |-> (gnt == 4'b0010)
        );

    a_ptr_r0_choose_r2:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b00 && !req[0] && !req[1] && req[2])
            |-> (gnt == 4'b0100)
        );

    a_ptr_r0_choose_r3:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b00 && !req[0] && !req[1] && !req[2] && req[3])
            |-> (gnt == 4'b1000)
        );


    // ------------------------------------------------------------
    // Pointer = R1 (01)
    // Priority: R1 -> R2 -> R3 -> R0
    // ------------------------------------------------------------

    a_ptr_r1_choose_r1:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b01 && req[1])
            |-> (gnt == 4'b0010)
        );

    a_ptr_r1_choose_r2:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b01 && !req[1] && req[2])
            |-> (gnt == 4'b0100)
        );

    a_ptr_r1_choose_r3:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b01 && !req[1] && !req[2] && req[3])
            |-> (gnt == 4'b1000)
        );

    a_ptr_r1_choose_r0:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b01 && !req[1] && !req[2] && !req[3] && req[0])
            |-> (gnt == 4'b0001)
        );


    // ------------------------------------------------------------
    // Pointer = R2 (10)
    // Priority: R2 -> R3 -> R0 -> R1
    // ------------------------------------------------------------

    a_ptr_r2_choose_r2:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b10 && req[2])
            |-> (gnt == 4'b0100)
        );

    a_ptr_r2_choose_r3:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b10 && !req[2] && req[3])
            |-> (gnt == 4'b1000)
        );

    a_ptr_r2_choose_r0:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b10 && !req[2] && !req[3] && req[0])
            |-> (gnt == 4'b0001)
        );

    a_ptr_r2_choose_r1:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b10 && !req[2] && !req[3] && !req[0] && req[1])
            |-> (gnt == 4'b0010)
        );


    // ------------------------------------------------------------
    // Pointer = R3 (11)
    // Priority: R3 -> R0 -> R1 -> R2
    // ------------------------------------------------------------

    a_ptr_r3_choose_r3:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b11 && req[3])
            |-> (gnt == 4'b1000)
        );

    a_ptr_r3_choose_r0:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b11 && !req[3] && req[0])
            |-> (gnt == 4'b0001)
        );

    a_ptr_r3_choose_r1:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b11 && !req[3] && !req[0] && req[1])
            |-> (gnt == 4'b0010)
        );

    a_ptr_r3_choose_r2:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (pointer == 2'b11 && !req[3] && !req[0] && !req[1] && req[2])
            |-> (gnt == 4'b0100)
        );


    // ============================================================
    // GROUP 3: POINTER / STATE TRANSITION CORRECTNESS
    // ============================================================

    // R0 grant -> next priority begins at R1.
    a_r0_grant_updates_pointer:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (!$past(reset) && $past(gnt) == 4'b0001)
            |-> (pointer == 2'b01)
        );

    // R1 grant -> next priority begins at R2.
    a_r1_grant_updates_pointer:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (!$past(reset) && $past(gnt) == 4'b0010)
            |-> (pointer == 2'b10)
        );

    // R2 grant -> next priority begins at R3.
    a_r2_grant_updates_pointer:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (!$past(reset) && $past(gnt) == 4'b0100)
            |-> (pointer == 2'b11)
        );

    // R3 grant -> priority wraps around to R0.
    a_r3_grant_updates_pointer:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (!$past(reset) && $past(gnt) == 4'b1000)
            |-> (pointer == 2'b00)
        );

    // If nobody requested in the previous cycle,
    // the pointer must remain unchanged.
    a_idle_holds_pointer:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (!$past(reset) && $past(req) == 4'b0000)
            |-> (pointer == $past(pointer))
        );


    // ============================================================
    // GROUP 4: BOUNDED FAIRNESS / STARVATION FREEDOM
    // ============================================================

    // A continuously requesting R0 may be denied at most
    // three consecutive arbitration opportunities.
    // If still requesting on the fourth, R0 must be granted.
    a_r0_bounded_fairness:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (req[0] && !gnt[0])[*3] ##1 req[0]
            |-> gnt[0]
        );

    // Same bounded fairness requirement for R1.
    a_r1_bounded_fairness:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (req[1] && !gnt[1])[*3] ##1 req[1]
            |-> gnt[1]
        );

    // Same bounded fairness requirement for R2.
    a_r2_bounded_fairness:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (req[2] && !gnt[2])[*3] ##1 req[2]
            |-> gnt[2]
        );

    // Same bounded fairness requirement for R3.
    a_r3_bounded_fairness:
        assert property (
            @(posedge clk)
            disable iff (reset)
            (req[3] && !gnt[3])[*3] ##1 req[3]
            |-> gnt[3]
        );


    // ============================================================
    // GROUP 5: FORMAL COVERAGE / REACHABILITY
    // ============================================================

    // Check that simultaneous requests from all four requesters
    // are reachable in the formal environment.
    c_full_contention:
        cover property (
            @(posedge clk)
            disable iff (reset)
            req == 4'b1111
        );

    // Check that a complete R0 -> R1 -> R2 -> R3 rotation
    // is reachable while all four requesters remain asserted.
    c_full_round_robin_rotation:
        cover property (
            @(posedge clk)
            disable iff (reset)
            (req == 4'b1111 && gnt == 4'b0001)
            ##1
            (req == 4'b1111 && gnt == 4'b0010)
            ##1
            (req == 4'b1111 && gnt == 4'b0100)
            ##1
            (req == 4'b1111 && gnt == 4'b1000)
        );

endmodule


// ============================================================
// BIND PROPERTY MODULE TO DUT
// ============================================================

bind rr_arbiter rr_arbiter_properties rr_arbiter_properties_inst (
    .clk     (clk),
    .reset   (reset),
    .req     (req),
    .gnt     (gnt),
    .pointer (pointer)
);
