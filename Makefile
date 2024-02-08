V_SOURCES := $(shell find vsrc -name "*.v")

build:
	rm -rf ./verilator/
	mkdir ./verilator
	mkdir ./verilator/c_obj
	riscv64-linux-gnu-gcc -march=rv32im -mabi=ilp32 -ffreestanding -nostdlib -static -Wl,-Ttext=0 -O2 -o ./verilator/c_obj/prog ./csrc/prog.c
	riscv64-linux-gnu-objcopy -j .text -O binary ./verilator/c_obj/prog ./verilator/c_obj/prog.bin
	verilator -Wall --top-module NPC -cc ${V_SOURCES} --exe csrc/main.cpp --Mdir verilator

sim:
	make -j -C verilator -f VNPC.mk VNPC
	verilator/VNPC ./verilator/c_obj/prog.bin

dump:
	riscv64-linux-gnu-objdump -d -M no-aliases verilator/c_obj/prog

all:
	@echo "please use 'make build' or 'make sim' to build or simulate the project."