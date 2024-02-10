TOP_MODULE := NPC

SIM_FILE := main.cpp

V_HEADNAME := V$(TOP_MODULE)

V_MAKEFILE := $(V_HEADNAME).mk

V_SOURCES  := $(shell find vsrc -name "*.v")

build:
	@echo "====================build start========================="
	rm -rf ./verilator/
	mkdir ./verilator
	mkdir ./verilator/c_obj
	@echo "====================compile start======================="
	riscv64-linux-gnu-gcc -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -static -Wl,-Ttext=0 -O2 -o ./verilator/c_obj/prog ./csrc/prog.c
	riscv64-linux-gnu-objcopy -j .text -O binary ./verilator/c_obj/prog ./verilator/c_obj/prog.bin
	@echo "====================verilator start====================="
	verilator -Wall --trace --top-module ${TOP_MODULE} -cc ${V_SOURCES} --exe csrc/${SIM_FILE} --Mdir verilator --Wno-UNUSEDSIGNAL
	@awk '/^CXXFLAGS =/ {print $0 " -Wno-unused-result"; found=1} !/^CXXFLAGS =/ {print $0} END {if (!found) print "CXXFLAGS = -Wno-unused-result"}' verilator/$(V_MAKEFILE) > verilator/$(V_MAKEFILE).tmp && mv verilator/$(V_MAKEFILE).tmp verilator/$(V_MAKEFILE)

sim:
	@echo "====================sim start==========================="
	make -j -C verilator -f ${V_MAKEFILE} ${V_HEADNAME}
	@echo "====================simulation start===================="
	verilator/${V_HEADNAME} ./verilator/c_obj/prog.bin
	@echo "====================waveform start======================"
	gtkwave verilator/trace.vcd

dump:
	@echo "====================dump start=========================="
	riscv64-linux-gnu-objdump -d -M no-aliases verilator/c_obj/prog

pull:
	@echo "====================pull start=========================="
	git pull origin main

push:
	@echo "====================push start=========================="
	git add .
	git commit -m "update `date +'%Y-%m-%d %H:%M:%S'`"
	git push origin main

all: build sim dump