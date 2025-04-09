[![Simulation](https://github.com/RDSik/axis-uart/actions/workflows/simulation.yml/badge.svg?branch=master)](https://github.com/RDSik/axis-uart/actions/workflows/simulation.yml)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/RDSik/axis-uart/blob/master/LICENSE.txt)

# AXI-Stream UART module

This is simple UART with AXI-Stream interface, module tested on Tang Primer 20k board. 

If you want build project, program board or run simulation use Makefile. 

## Clone repository:
```bash
git clone https://github.com/RDSik/axis-uart.git
cd axis-uart
```

## Build project (need Gowind IDE):
```bash
make project
```

## Program Tang Primer 20K with OpenFPGALoader:
```bash
make program
```

## Simulation with Verilator:
```bash
make
```

## Wave with Gtkwave:
```bash
make wave
```

## Simulation  with QuestaSim:
```bash
make SIM=questa
```
