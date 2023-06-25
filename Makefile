a:
	nasm stage1.asm -f bin -o stage1.bin
	nasm stage2.asm -f bin -o stage2.bin
	objdump -mi8086 -Mintel -bbinary -Ds stage2.bin
	python3 combine.py stage1.bin stage2.bin
	qemu-system-x86_64 -drive format=raw,file=combined.bin
