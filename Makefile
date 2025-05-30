all: run

build/boot_1.bin: src/boot/boot_1.asm
	nasm src/boot/boot_1.asm -o build/boot_1.bin

build/boot_2.bin: src/boot/boot_2.asm
	nasm src/boot/boot_2.asm -o build/boot_2.bin

build/boot.bin: build/boot_1.bin build/boot_2.bin
	cat build/boot_1.bin build/boot_2.bin > build/boot.bin

run: build/boot.bin
	qemu-system-x86_64 -drive format=raw,file=build/boot.bin
