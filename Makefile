IVERILOG ?= iverilog
VVP ?= vvp
IVERILOG_FLAGS ?= -g2012 -Wall
RTL := $(wildcard rtl/*.v)
SIMS := build/tb_program.vvp build/tb_isa.vvp build/tb_alu.vvp

.PHONY: test wave clean

test: $(SIMS)
	$(VVP) -N build/tb_program.vvp
	$(VVP) -N build/tb_isa.vvp
	$(VVP) -N build/tb_alu.vvp

wave: build/tb_program.vvp
	$(VVP) -N build/tb_program.vvp +vcd

build/tb_%.vvp: tb/tb_%.sv $(RTL)
	mkdir -p build
	$(IVERILOG) $(IVERILOG_FLAGS) -s tb_$* -o $@ $(RTL) $<

clean:
	rm -rf build
