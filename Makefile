TOP_MODULE  := top

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

ysyxpull:
	@echo "====================pull start=========================="
	cd .. && git pull origin main

ysyxpush: ysyxclean
	@echo "====================push ysyx==========================="
	cd .. && git add .
	cd .. && git commit -m "update `date +'%Y-%m-%d %H:%M:%S'`"
	cd .. && git push origin main

push: copy2xilinx
	@echo "====================push start=========================="
	git add .
	git commit -m "update `date +'%Y-%m-%d %H:%M:%S'`"
	git push origin main

copy2xilinx:
	@echo "====================copy start=========================="
	find ${XILINX_PATH} -type f ! -iname 'FPGA_*' -delete
	rsync -av --exclude='cpp_*' vsrc/ ${XILINX_PATH}/

ysyxclean:
	@echo "====================clean ysyx=========================="
	cd ../nemu && make clean
	cd ../am-kernels/tests/cpu-tests && make clean
	cd ../abstract-machine && make clean

all: build sim dump
