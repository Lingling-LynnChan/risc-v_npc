TOP_MODULE := NPC

SIM_FILE := main.cpp

V_HEADNAME := V$(TOP_MODULE)

V_MAKEFILE := $(V_HEADNAME).mk

V_SOURCES  := $(shell find vsrc -name "*.v")

build:
	@echo "====================build start========================="
	rm -rf ./build
	mkdir ./build
	mkdir ./build/c_obj
	@echo "====================compile start======================="
	riscv64-linux-gnu-gcc -march=rv32i -mabi=ilp32 -ffreestanding -nostdlib -static -Wl,-Ttext=0 -O2 -o build/c_obj/prog csrc/prog.c
	riscv64-linux-gnu-objcopy -j .text -O binary build/c_obj/prog build/c_obj/prog.bin
	@echo "====================verilator start====================="
	verilator -Wall --trace --top-module ${TOP_MODULE} -cc ${V_SOURCES} --exe csrc/${SIM_FILE} --Mdir build --Wno-UNUSEDSIGNAL
	@awk '/^CXXFLAGS =/ {print $0 " -Wno-unused-result"; found=1} !/^CXXFLAGS =/ {print $0} END {if (!found) print "CXXFLAGS = -Wno-unused-result"}' build/$(V_MAKEFILE) > build/$(V_MAKEFILE).tmp && mv build/$(V_MAKEFILE).tmp build/$(V_MAKEFILE)

sim:
	@echo "====================sim start==========================="
	make -j -C build -f ${V_MAKEFILE} ${V_HEADNAME}
	@echo "====================simulation start===================="
	build/${V_HEADNAME} build/c_obj/prog.bin
	@echo "====================waveform start======================"
	gtkwave build/trace.vcd >/dev/null 2>&1 &

dump:
	@echo "====================dump start=========================="
	riscv64-linux-gnu-objdump -d -M no-aliases build/c_obj/prog

pull:
	@echo "====================pull start=========================="
	git pull origin main

push:
	@echo "====================push start=========================="
	git add .
	git commit -m "update `date +'%Y-%m-%d %H:%M:%S'`"
	git push origin main

all: build sim dump