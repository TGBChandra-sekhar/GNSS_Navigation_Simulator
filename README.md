# Arty A7 FPGA-Based GPS L1 Navigation Signal Simulator with MicroBlaze–BRAM Data Exchange

This repository contains the FPGA RTL, MicroBlaze firmware, block design, simulation files, and supporting outputs for a GPS L1 navigation signal simulator implemented on the **Digilent Arty A7-100T FPGA board**.

The design generates GPS L1 C/A and precision-code sequences, receives navigation-message words from a MicroBlaze processor through true dual-port BRAM, converts the parallel NAV data into a 50-bit/s serial stream, and combines the NAV bit stream with the generated PRN codes.

> The design uses a Xilinx MicroBlaze soft processor and custom RTL logic inside the same FPGA. Communication between the processor side and the navigation-signal-generation logic is performed through true dual-port block RAM.

---

##  Overview

A GPS L1 baseband signal is formed by combining navigation-message data with a pseudorandom noise spreading code. This project implements the following functions on an **Arty A7 XC7A100T FPGA**:

- GPS L1 C/A-code generation  
- Precision-code generation used by this project  
- Navigation-data transfer from MicroBlaze to FPGA logic  
- True dual-port BRAM-based handshaking  
- Parallel-to-serial conversion of a 300-bit NAV subframe  
- NAV-data serialization at 50 bits/s  
- XOR combination of the NAV data with generated PRN codes  
- Common 40.92 MHz clock operation for the processor, BRAM, counters, and code generators  

The processor-side firmware writes NAV-message words into BRAM. The FPGA-side control logic detects the completion flag, reads the NAV words, loads them into a shift register, and serializes them using the 50 Hz NAV-data timing pulse.

This simulator is intended for FPGA development, digital baseband verification, GNSS receiver testing, and navigation-signal-generation experiments. It does not include an RF upconverter or an RF power-amplifier stage.

---

##  Features

- GPS L1 C/A-code generation  
- Precision-code generation and timing alignment  
- 1.023 MHz C/A-code chip timing derived from 40.92 MHz  
- 50 Hz navigation-data bit timing  
- 300-bit GPS NAV subframe handling  
- MicroBlaze-based NAV-data processing  
- True dual-port BRAM communication  
- AXI BRAM Controller interface on MicroBlaze side  
- Native BRAM Port-B interface on custom RTL side  
- Request and completion control-word handshake  
- Parallel NAV-word capture and serial NAV-bit generation  
- XOR operation between NAV data and PRN code  
- Differential external 40.92 MHz clock support  
- Vivado behavioural simulation support  
- Modular Verilog and C source-code organisation  

---

##  System Architecture

The complete system contains two logical sections:

###  **Processor Side**

The processor side contains:

- MicroBlaze soft processor  
- AXI Interconnect  
- AXI BRAM Controller  
- Local MicroBlaze memory  
- Processor System Reset IP  
- MicroBlaze Debug Module  
- Vitis application for NAV-data generation and BRAM control  

The MicroBlaze accesses BRAM through **Port A** using the AXI BRAM Controller.

###  **FPGA Logic Side**

The FPGA logic side contains:

- C/A-code generator  
- Precision-code generator  
- NAV-data control state machine  
- BRAM Port-B controller  
- 300-bit parallel-to-serial shift register  
- 50 Hz NAV-data timing generator  
- Code timing and epoch generators  
- NAV-data and PRN-code XOR logic  
- Top-level GNSS signal-simulator wrapper  

The custom RTL accesses the same BRAM through **Port B**.

---

##  BRAM Communication Protocol

The communication between MicroBlaze and the navigation-simulator control logic uses BRAM location 0 as a control/status location.

###  Control Words

| Control word | Meaning |
|---|---|
| `0x0000CDCD` | FPGA logic requests a new NAV-data subframe |
| `0x00000000` | Control location is cleared |
| `0x0CEDCEDC` | MicroBlaze has completed writing the NAV data |

###  BRAM Memory Map

| BRAM location | MicroBlaze byte address | Purpose |
|---|---:|---|
| Word 0 | Base + `0x00` | Request/completion control word |
| Word 1 | Base + `0x04` | NAV word 0 |
| Word 2 | Base + `0x08` | NAV word 1 |
| Word 3 | Base + `0x0C` | NAV word 2 |
| ... | ... | ... |
| Word 10 | Base + `0x28` | NAV word 9 |

Each NAV word is written as a 32-bit value. The FPGA-side control logic uses the required 30 NAV bits from each word:

```text
10 NAV words × 30 bits = 300 NAV bits
```

A 300-bit GPS NAV subframe requires:

```text
300 bits ÷ 50 bits/s = 6 seconds
```

###  Handshake Sequence

```text
FPGA Port B writes 0x0000CDCD into BRAM word 0
                         ↓
MicroBlaze reads the request flag
                         ↓
MicroBlaze clears BRAM word 0
                         ↓
MicroBlaze writes 10 NAV words into BRAM words 1 to 10
                         ↓
MicroBlaze writes 0x0CEDCEDC into BRAM word 0
                         ↓
FPGA Port B detects the completion flag
                         ↓
FPGA reads the 10 NAV words
                         ↓
FPGA loads the 300-bit NAV shift register
                         ↓
NAV bits are transmitted serially at 50 bits/s
                         ↓
The next NAV-data request is generated
```

Port A and Port B must not write BRAM word 0 at the same time.

---

##  Clock Architecture

The design operates internally at **40.92 MHz**.

The 40.92 MHz clock is used for:

- MicroBlaze  
- AXI Interconnect  
- AXI BRAM Controller  
- BRAM Port A and Port B  
- C/A-code generator  
- Precision-code generator  
- NAV-data control logic  
- Epoch generators  
- Counters and serializers  

The design supports an external differential 40.92 MHz clock connected to a clock-capable differential input pair on the Arty A7 board.

Top-level clock ports:

```verilog
input wire sys_diff_clock_clk_p;
input wire sys_diff_clock_clk_n;
```

The positive and negative clock inputs are connected to the Clocking Wizard, which provides the internal system clock and the `locked` signal used by the Processor System Reset IP.

---

##  Repository Structure

```text
├── Coarse_Aquisition_Code/
│   ├── ca_code.v
│   ├── ca_top_wrapper.v
│   ├── x1_register.v
│   ├── x2_register.v
│   └── related C/A-code modules
│
├── Precision_Code/
│   ├── p_top_wrapper.v
│   ├── clk_div_4.v
│   └── related precision-code modules
│
├── Navigation_Data_Control/
│   ├── nav_sim_control.v
│   ├── epoch_50hz.v
│   ├── epoch_1p5.v
│   ├── epoch_6sec.v
│   └── epoch_tow.v
│
├── Vitis_code/
│   └── control_logic.c
│
├── Top_Wrapper_PL_PS_Interface/
│   ├── gnss_top_wrapper.v
│   └── block-design wrapper files
│
├── Block_design/
│   ├── MicroBlaze
│   ├── AXI Interconnect
│   ├── AXI BRAM Controller
│   ├── Block Memory Generator
│   ├── Clocking Wizard
│   └── Processor System Reset
│
├── Constraints/
│   └── Arty A7 clock and reset constraints
│
├── Test_Bench/
│   └── tb_gnss_top_wrapper.v
│
├── Output_files/
│   ├── bitstream
│   ├── hardware platform
│   └── executable files
│
└── README.md
```

---

##  Component Details

###  **Coarse_Aquisition_Code/**

Contains Verilog modules used for GPS L1 C/A-code generation.

The C/A-code generator uses the required shift-register logic and produces the PRN code at a chip rate of approximately **1.023 MHz**.

*Role:*  
✔ Generate the GPS L1 C/A PRN sequence  
✔ Provide parallel C/A-code outputs for simulation and verification  
✔ Support PRN-code timing and epoch generation  

---

###  **Precision_Code/**

Contains Verilog modules used for precision-code generation and project-specific timing alignment.

*Role:*  
✔ Generate the precision-code sequence used by the simulator  
✔ Provide timing-aligned code outputs  
✔ Support final code and NAV-data combination  

---

###  **Navigation_Data_Control/**

Contains the FPGA-side BRAM control logic and NAV-data serialization logic.

The `nav_sim_control.v` module performs the following operations:

- Writes the NAV-data request flag into BRAM  
- Waits for the MicroBlaze completion flag  
- Reads 10 NAV words from BRAM  
- Captures 300 NAV bits  
- Loads the NAV-data shift register  
- Outputs one NAV bit for every 50 Hz timing pulse  
- Requests the next subframe after completion  

*Role:*  
✔ Control BRAM Port-B transactions  
✔ Synchronize MicroBlaze and FPGA data exchange  
✔ Convert parallel NAV words into a serial NAV-data stream  

---

###  **Vitis_code/**

Contains the embedded C application executed by MicroBlaze.

The MicroBlaze firmware:

- Polls BRAM word 0  
- Detects `0x0000CDCD`  
- Clears the request flag  
- Writes 10 NAV words into BRAM  
- Cycles through the configured NAV-data frames  
- Writes `0x0CEDCEDC` after completing the transfer  

*Role:*  
✔ Supply NAV data to FPGA logic  
✔ Control the BRAM communication protocol  
✔ Provide a software-controlled NAV-data source  

---

###  **Top_Wrapper_PL_PS_Interface/**

Contains the top-level wrapper that integrates:

- Differential clock input  
- Clocking Wizard output  
- MicroBlaze block design  
- BRAM Port-B interface  
- C/A-code generator  
- Precision-code generator  
- NAV-data serializer  
- PRN and NAV-data XOR logic  
- Simulation and debug signals  

*Role:*  
✔ Integrate the complete FPGA design  
✔ Connect processor-side and RTL-side modules  
✔ Provide top-level FPGA input and output ports  

---

###  **Block_design/**

Contains the Vivado IP Integrator design.

Main IP blocks:

| IP block | Purpose |
|---|---|
| MicroBlaze | NAV-data processor and BRAM controller |
| MicroBlaze Debug Module | JTAG-based processor debug |
| AXI Interconnect | Connects MicroBlaze to AXI peripherals |
| AXI BRAM Controller | Provides MicroBlaze access to BRAM Port A |
| Block Memory Generator | True dual-port shared BRAM |
| Clocking Wizard | Receives and conditions the 40.92 MHz clock |
| Processor System Reset | Generates synchronized processor and AXI resets |
| Local Memory | Stores the MicroBlaze program and data |

---

###  **Test_Bench/**

Contains the top-level behavioural simulation environment.

The testbench verifies:

- Differential clock generation  
- Reset operation  
- Clocking Wizard output  
- C/A-code sequence generation  
- Precision-code sequence generation  
- BRAM Port-A transactions  
- BRAM Port-B transactions  
- Request and completion flags  
- NAV-data capture  
- NAV-data serialization  
- PRN and NAV-data combination  

---

##  Main Source Files

| File | Purpose |
|---|---|
| `gnss_top_wrapper.v` | Complete top-level GNSS signal-simulator integration |
| `nav_sim_control.v` | BRAM Port-B handshake and NAV-data serializer |
| `control_logic.c` | MicroBlaze BRAM control and NAV-data writer |
| `ca_code.v` | C/A-code generation logic |
| `ca_top_wrapper.v` | C/A-code top-level wrapper |
| `p_top_wrapper.v` | Precision-code top-level wrapper |
| `epoch_50hz.v` | NAV-data bit timing generator |
| `epoch_1p5.v` | 1.5-second epoch generator |
| `epoch_6sec.v` | 6-second NAV-subframe epoch generator |
| `epoch_tow.v` | Time-of-week-related epoch logic |
| `tb_gnss_top_wrapper.v` | Top-level behavioural testbench |

---

##  Compiled Outputs

| File | Purpose |
|---|---|
| `GNSS_control_logic.elf` | MicroBlaze executable for BRAM and NAV-data control |
| `gnss_top_wrapper.bit` | FPGA configuration bitstream |
| `gnss_top_wrapper.xsa` | Vivado hardware platform exported to Vitis |

The exact output filenames may vary depending on the Vivado and Vitis project names.

---

##  Build and Deployment

###  FPGA Design in Vivado

1. Create or open the Vivado project for the Arty A7-100T.  
2. Select the correct target device or board:
   - Board: Digilent Arty A7-100T  
   - Device: `XC7A100T-2CSG324`  
3. Add all Verilog source files.  
4. Add the top-level wrapper and testbench.  
5. Create the MicroBlaze block design.  
6. Configure the Block Memory Generator as true dual-port BRAM.  
7. Connect:
   - BRAM Port A to the AXI BRAM Controller  
   - BRAM Port B to `nav_sim_control.v`  
8. Connect all MicroBlaze, AXI, BRAM, and RTL clocks to the 40.92 MHz system clock.  
9. Connect the Clocking Wizard `locked` output to `proc_sys_reset/dcm_locked`.  
10. Add the Arty A7 differential-clock and reset XDC file.  
11. Validate the block design.  
12. Generate output products.  
13. Create the HDL wrapper.  
14. Run synthesis.  
15. Run implementation.  
16. Generate the bitstream.  
17. Export the hardware platform as an XSA file.

###  MicroBlaze Firmware in Vitis

1. Create a Vitis platform from the exported XSA file.  
2. Create a standalone MicroBlaze application.  
3. Add `control_logic.c`.  
4. Confirm that the BRAM base-address macro matches the Vivado address map:

```c
#define BRAM_BASE_0 XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR
```

5. Build the application.  
6. Generate `GNSS_control_logic.elf`.  
7. Load the FPGA bitstream.  
8. Download and run the ELF on MicroBlaze.

---

##  Simulation

For behavioural simulation:

1. Add `tb_gnss_top_wrapper.v` as the simulation top.  
2. Generate complementary differential clock inputs:

```verilog
always #12.218964 begin
    sys_diff_clock_clk_p = ~sys_diff_clock_clk_p;
    sys_diff_clock_clk_n = ~sys_diff_clock_clk_n;
end
```

3. Apply reset for sufficient clock cycles.  
4. Associate the MicroBlaze ELF file with `microblaze_0` for simulation.  
5. Regenerate the block-design output products.  
6. Run behavioural simulation.  
7. Verify the following waveform sequence:

```text
FPGA writes 0x0000CDCD
MicroBlaze detects the request
MicroBlaze writes the NAV words
MicroBlaze writes 0x0CEDCEDC
FPGA reads the NAV words
NAV serializer outputs all 300 bits
```

During accelerated simulation, epoch counter limits may be reduced. Hardware builds must use the correct counter values for real 1.023 MHz, 50 Hz, 1.5-second, and 6-second timing.

---

##  Usage

1. Connect a compatible external differential 40.92 MHz clock source.  
2. Program the Arty A7 FPGA with `gnss_top_wrapper.bit`.  
3. Download `GNSS_control_logic.elf` to MicroBlaze.  
4. Start the MicroBlaze application.  
5. Verify the control-word handshake through UART, ILA, or Vivado simulation.  
6. Observe the generated:
   - C/A code  
   - Precision code  
   - NAV-data bit stream  
   - PRN/NAV XOR output  
7. Use the digital output as an input to the next signal-processing or RF-generation stage.

---

##  Important Notes

- The Arty A7 does not contain a hard ARM Processing System. MicroBlaze is a soft processor implemented inside the FPGA fabric.  
- “Processor side” and “FPGA logic side” are used as logical descriptions of the architecture.  
- BRAM Port-A AXI addresses are byte addresses such as `0x00`, `0x04`, and `0x08`.  
- Native BRAM Port-B address interpretation depends on the generated BRAM interface configuration.  
- The MicroBlaze and FPGA logic must use the same BRAM word locations and control-word definitions.  
- BRAM read latency must match the state-machine wait cycles used in `nav_sim_control.v`.  
- The request flag should be generated only after the previous 300-bit NAV subframe has completed.  
- The Clocking Wizard `locked` output must be connected to the Processor System Reset IP.  
- The MicroBlaze ELF must be associated with the processor during behavioural simulation.  
- The external differential clock source must be electrically compatible with the selected Arty A7 input standard.  
- This project produces digital baseband signals only. It does not directly generate an L1 RF carrier at 1575.42 MHz.  
- Transmission of simulated GNSS RF signals must comply with applicable legal and laboratory-safety requirements. Use conducted or properly shielded test setups where required.

---

##  Tools Used

- Xilinx Vivado 2025.1  
- Xilinx Vitis  
- Verilog HDL  
- Embedded C  
- Vivado IP Integrator  
- Vivado Simulator  
- MicroBlaze  
- GitHub  

---

##  Target Hardware

- **Board:** Digilent Arty A7-100T  
- **FPGA:** Xilinx Artix-7 XC7A100T  
- **Package:** CSG324  
- **Speed grade:** -2  
- **System clock:** External differential 40.92 MHz  

---

##  Author

**Chandra Sekhar Tanuku**

*Focus Areas: FPGA Design, VLSI, Digital Communication Systems, Embedded Systems, and GNSS Signal Processing*

---
