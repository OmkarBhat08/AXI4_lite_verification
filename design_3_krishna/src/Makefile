QUESTA := /home/share/questa.csh
SHELL := /bin/csh

# Default test name (used if TESTNAME not set)
TESTNAME ?= simple_write_test
export TESTNAME

# Build UVM command-line argument: only add +UVM_TESTNAME if TESTNAME is non-empty
UVM_TEST_ARG = $(if $(TESTNAME),+UVM_TESTNAME=$(TESTNAME),)

# UVM include path (adjust to your installation if needed)
UVM_INCDIR = +incdir+/tools/mentor/questasim_10.6c/questasim/uvm-1.1d/../verilog_src/uvm-1.1d/src

# -----------------------------------------------------------------------------
# Help target (default)
# -----------------------------------------------------------------------------
.PHONY: help

help:
	@printf "======================================================================\nUVM Testbench Makefile\n======================================================================\nAvailable targets:\n  make              - Show this help\n  make sim          - Run simulation (compile first!)\n  make <test>_test  - Run a specific test (e.g., make simple_read_test)\n  make compile      - Compile the design\n  make simulate     - Run simulation with current TESTNAME\n  make main         - Full clean + compile + coverage simulation + HTML report\n  make view         - Open coverage report in Firefox\n  make read         - Print coverage summary\n  make clean        - Remove work directory and logs\n\nExamples:\n  make compile\n  make sim\n  make sim TESTNAME=my_test\n  make simple_read_test\n======================================================================\n"
# Other targets
# -----------------------------------------------------------------------------
IGNORE:
	make clean
	make view

.ONESHELL:

all:
	source $(QUESTA)
	make clean
	make compile
	make simulate

r:
	source $(QUESTA)
	make clean
	make compile
	make simulate TESTNAME=$(TESTNAME)

main:
	source $(QUESTA)
	make clean
	vlog -sv +acc +cover +fcover +define axi4_top.sv $(UVM_INCDIR)
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c $(UVM_TEST_ARG) -do "coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit"
	vcover report -html coverage.ucdb -htmldir covReport -details

read:
	source $(QUESTA)
	vcover report -details coverage.ucdb

view:
	firefox ./covReport/index.html

# Simple compile – no stamp tracking
compile:
	/bin/bash -c 'vlog -sv $(UVM_INCDIR) axi4_package.sv axi4_top.sv'

# Simulate – assumes design already compiled
simulate:
	vsim -c top +UVM_VERBOSITY=UVM_MEDIUM $(UVM_TEST_ARG) -do "run -all;exit"

sim: simulate

clean:
	rm -rf transcript work/
	clear
	clear

# Convenience test runners
%_test:
	$(MAKE) simulate TESTNAME=$*_test

r_%:
	$(MAKE) clean compile simulate TESTNAME=$*_test

.PHONY: IGNORE all r main read view compile simulate sim clean %_test r_%
