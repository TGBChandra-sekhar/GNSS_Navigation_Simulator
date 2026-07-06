# GNSS Navigation Simulator  
**Kintex-7 FPGA Based Baseband Signal Generation and NAV Data Synchronization for GPS L1 Simulator**

This repository contains the FPGA and supporting code for a GPS L1 Global Navigation Satellite System (GNSS) simulator. It generates GPS L1 C/A baseband signals and synchronizes NAV data for GPS signal simulation using a Xilinx Kintex-7 FPGA platform.

> ⚙️ The design supports baseband generation of GPS L1 coarse/acquisition and precision codes, NAV data bit synchronization, and top-level FPGA integration between PL (Programmable Logic) and PS (Processing System).

---

##  Overview

GPS L1 signals transmit a pseudorandom noise (PRN) code modulated with navigation data that contains satellite ephemeris and timing information. This project implements the following on a **Kintex-7 FPGA**:

- Generation of GPS L1 baseband spreading codes  
- Navigation data synchronization  
- Integration of PS (e.g., ARM on Zynq or external CPU) and FPGA logic  
- Output of synthesized baseband signals for simulation or test hardware  

This FPGA-centric simulator is useful for testing GNSS receivers, validating tracking loops, and developing GNSS signal processing algorithms in hardware.

---

##  Features

-  GPS L1 C/A coarse acquisition code generator  
-  Precision Nav Code generation and alignment  
-  Coarse and Fine synchronization logic  
-  PL-PS interface for control and data synchronization  
-  Bitstream and compiled binaries included (`*.bit`, `*.elf`)  
-  Modular Verilog architecture

---

##  Repository Structure
```
├── Coarse_Aquisition_Code/
├── PS_Code/
├── Precision_Code/
├── Top_Wrapper_PL_PS_Interface/
├── GNSS_control_logic.elf
├── gnss_top_wrapper.bit
└── README.md
```
---

##  Component Details

###  **Coarse_Aquisition_Code/**  
Contains Verilog modules responsible for generating and acquiring the **GPS L1 C/A coarse acquisition code**.  
This includes logic to produce PRN sequences, early/late code correlations, and integration blocks used for coarse code synchronization.

*Role:*  
✔ Generate the standard 1,023-chip C/A PRN codes for all GPS satellites  
✔ Support coarse code phase alignment for initial synchronization

---

###  **Precision_Code/**  
Contains Verilog modules used for *precision code* generation used in final alignment of the spreading code.  
This might include logic for higher resolution code phase control and fine timing adjustments.

*Role:*  
✔ Generate high-resolution spreading codes  
✔ Improve timing accuracy during synchronization

---

###  **PS_Code/**  
Includes C or embedded software code that runs on the **processing system (PS)** — typically an ARM core, microcontroller, or custom soft-CPU.  
This code:

- Coordinates FPGA logic configuration  
- Manages NAV data streams (e.g., subframe data)  
- Sends configuration and control to PL

*Role:*  
✔ Control and supervise PL modules  
✔ Load NAV data and timing parameters

---

###  **Top_Wrapper_PL_PS_Interface/**  
Top-level FPGA wrapper combining all PL modules and the interface logic with PS.  
This includes the FPGA bit-level integration, clock management, bus interfaces (AXI, bus wrappers), and synchronization units.

*Role:*  
✔ Integrate PRN/code generation + NAV sync blocks  
✔ Expose control/status registers to PS  
✔ Tie hardware modules into a bitstream

---

###  **Compiled Binaries**

| File | Purpose |
|------|---------|
| **GNSS_control_logic.elf** | Executable for PS/ARM controlling FPGA logic |
| **gnss_top_wrapper.bit** | Synthesized FPGA configuration bitstream |

These files are ready to load on a target hardware platform (e.g., **Xilinx Kintex-7 board**) with a compatible boot loader.

---

##  Build & Deployment

###  FPGA Synthesis

1. Open the project in **Vivado** (or equivalent Xilinx tools).  
2. Import Verilog modules from the directories:  
   - `Coarse_Aquisition_Code/`  
   - `Precision_Code/`  
   - `Top_Wrapper_PL_PS_Interface/`  
3. Connect clocks, reset logic, and PS interface IP blocks.  
4. Generate the `gnss_top_wrapper.bit` bitstream.

###  PS Firmware

1. Use **ARM GCC / SDK** to compile `PS_Code` into `GNSS_control_logic.elf`.  
2. Load ELF via boot loader or debugging interface.

---

##  Usage

1. Program the **Kintex-7 FPGA** with `gnss_top_wrapper.bit`.  
2. Boot the PS with `GNSS_control_logic.elf`.  
3. Use UART/Console or API to configure GPS signal parameters (PRN, timing).  
4. Observe baseband output for synthesized GPS L1 waveforms.

The simulator supports control of GPS satellite parameters and NAV message alignment for realistic baseband production.

---

##  Notes

- This simulator focuses on baseband signal generation and data synchronization — it does **not** include full RF front-end IF upconversion.  
- GPS L1 code formats and NAV message structures follow GNSS standards as used in GPS receivers and simulators.

---
If you want, I can also help you generate a **technical block diagram** or **user guide PDF** for this project!
---

## Tools Used
  - Xilinx Vivado
  - vitis 
  - GitHub
    

---
##  Author
**Chandra Sekhar Tanuku**
* Focus Areas: **VLSI Design, FPGA, Digital Communication Systems**
---

