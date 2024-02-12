TOP_MODULE  := NPC

SIM_FILE    := main.cpp

USE_MARCH   := rv32i

USE_MABI    := ilp32

V_HEADNAME  := V$(TOP_MODULE)

V_MAKEFILE  := $(V_HEADNAME).mk

V_SOURCES   := $(shell find vsrc -name "*.v")

XILINX_PATH := "/mnt/c/Users/Lingl/Documents/FPGA_Projects/NPC/NPC.srcs/sources_1/new/"

clean:
	@echo "====================clean start========================="
	rm -rf ./build
	mkdir ./build
	mkdir ./build/c_obj

build: clean
	@echo "====================build start========================="
	riscv64-linux-gnu-gcc -march=${USE_MARCH} -mabi=${USE_MABI} -ffreestanding -nostdlib -static -Wl,-Ttext=0 -O2 -o build/c_obj/prog csrc/prog.c
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

pullysyx:
	@echo "====================pull start=========================="
	cd ysyx && git pull origin main
	@echo "====================copy start=========================="
	cp -a -r ysyx/abstract-machine/* ../abstract-machine
	cp -a -r ysyx/am-kernels/* ../am-kernels
	cp -a -r ysyx/fceux-am/* ../fceux-am
	cp -a -r ysyx/nemu/* ../nemu

push: copy2push
	@echo "====================push start=========================="
	git add .
	git commit -m "update `date +'%Y-%m-%d %H:%M:%S'`"
	git push origin main

pushysyx: copy2ysyx
	@echo "====================push ysyx==========================="
	cd ysyx && git add .
	cd ysyx && git commit -m "update `date +'%Y-%m-%d %H:%M:%S'`"
	cd ysyx && git push origin main

ysyxclean:
	@echo "====================clean ysyx=========================="
	cd ../nemu && make clean
	cd ../am-kernels/tests/cpu-tests && make clean
	cd ../abstract-machine && make clean

copy2ysyx: ysyxclean
	@echo "====================copy start=========================="
	cd ysyx && rm -rf abstract-machine am-kernels fceux-am nemu
	cd ysyx && mkdir abstract-machine am-kernels fceux-am nemu
	cp -a -r ../abstract-machine/* ysyx/abstract-machine
	cp -a -r ../am-kernels/* ysyx/am-kernels
	cp -a -r ../fceux-am/* ysyx/fceux-am
	cp -a -r ../nemu/* ysyx/nemu

copy2push:
	@echo "====================copy start=========================="
	find ${XILINX_PATH} -type f -delete
	cp vsrc/* ${XILINX_PATH}

all: build sim dump