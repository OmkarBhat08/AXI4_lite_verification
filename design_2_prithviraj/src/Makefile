

QUESTA := /home/share/questa.csh
SHELL := /bin/csh

IGNORE:
	make clean
	make view

.ONESHELL:

all:
	source $(QUESTA)
	make clean
	make compile
	make simulate

main:
	source $(QUESTA)
	make clean
	vlog -sv +acc +cover +fcover +define top.sv "+incdir+/tools/mentor/questasim_10.6c/questasim/uvm-1.1d/../verilog_src/uvm-1.1d/src"
	vsim -vopt work.top -voptargs=+acc=npr -assertdebug -l simulation.log -coverage -c -do "coverage save -onexit -assert -directive -cvg -codeAll coverage.ucdb; run -all; exit"
	vcover report -html coverage.ucdb -htmldir covReport -details

read:
	source $(QUESTA)
	vcover report -details coverage.ucdb

view:
	firefox ./covReport/index.html

compile:
	vlog -sv top.sv

simulate:
	vsim -c top +UVM_VERBOSITY=UVM_MEDIUM -do "run -all;exit"

clean:
	rm -rf transcript work/
	clear
	clear
