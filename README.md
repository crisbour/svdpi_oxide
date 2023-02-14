# SV DPI Oxidie

This repo simply generates a bindgen library for the "svdpi.h" compliant with SystemVerilog standard. The header file is taken from Verilator project.

## Getting Started

### Prerequisites
- `bindgen` requires `clang`

### Use
```
use svdpi::prelude::*;
```

## Tests

Run the test: `cargo test`

### Bindgen tests
Bindgen provides a few minimal tests.

### User tests
There are no user defined tests at the moment, but if you think of some, place them in `src/lib.rs`
