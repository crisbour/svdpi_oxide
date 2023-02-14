VERILOG_SOURCES = adder.sv

DPI_PROJECT_PATH = ./svdpi_add
DPI_LIB = $(DPI_PROJECT_PATH)/target/release/libadd_model

.PHONY: compile

all: compile
	vsim -sv_lib $(DPI_LIB) -evcddump -c tb -do "run -all; quit -f"
# vsim -evcddump -c tb -do "vcd file dump.vcd; vcd add tb/_if/*; run -all; quit -f"

compile: $(VERILOG_SOURCES)
	vlib work
	vlog $(VERILOG_SOURCES)
#	@$(foreach sv_file,$(VERILOG_SOURCES), vlog $(sv_file))
	vlog testbench_pkg.sv
	vlog add_tb.sv

compile_lib: $(DPI_LIB).so

$(DPI_LIB).so: $(DPI_PROJECT_PATH)/src/lib.rs
	cargo build --manifest-path=$(DPI_PROJECT_PATH)/Cargo.toml --release

clean:
	rm -rf work vsim.wlf transcript
	cargo clean --manifest-path=$(DPI_PROJECT_PATH)/Cargo.toml

debug:
	vsim -voptargs="+acc" tb
