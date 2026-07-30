
# Arty A7-100T - external differential 40.92 MHz clock
# Top-level:
#   input wire sys_diff_clock_clk_p;
#   input wire sys_diff_clock_clk_n;
#   input wire reset;

# External differential clock connected through Pmod JB
# JB pin 3 = D15 = IO_L12P_T1_MRCC_15
# JB pin 4 = C15 = IO_L12N_T1_MRCC_15

set_property -dict { \
    PACKAGE_PIN D15 \
    IOSTANDARD TMDS_33 \
} [get_ports {sys_diff_clock_clk_p}]

set_property -dict { \
    PACKAGE_PIN C15 \
    IOSTANDARD TMDS_33 \
} [get_ports {sys_diff_clock_clk_n}]


# 40.92 MHz timing constraint

create_clock -add \
    -name sys_diff_clock_40p92mhz \
    -period 24.437928 \
    -waveform {0.000000 12.218964} \
    [get_ports {sys_diff_clock_clk_p}]


# Active-high reset using BTN0
# BTN0:
#   released = 0
#   pressed  = 1

set_property -dict { \
    PACKAGE_PIN D9 \
    IOSTANDARD LVCMOS33 \
} [get_ports {reset}]


# Optional asynchronous-reset timing exception
set_false_path -from [get_ports {reset}]

