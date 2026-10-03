# ============================================================
# Round-Robin Arbiter Formal Verification Script
# Synopsys VC Formal - FPV
# ============================================================

# 1. Analyze the RTL
analyze -format sverilog rtl/rr_arbiter.sv

# 2. Analyze the SVA property module
analyze -format sverilog formal/rr_arbiter_properties.sv

# 3. Elaborate the DUT
elaborate rr_arbiter

# 4. Define the formal clock
create_clock clk -period 10

# 5. Define active-high reset
create_reset reset -high

# 6. Run Formal Property Verification
check_fv
