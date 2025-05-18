boot.bin: src/boot.asm
	nasm src/boot.asm -o build/boot.bin

run: boot.bin
	qemu-system-x86_64 -drive format=raw,file=build/boot.bin