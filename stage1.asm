org 0x7c00
bits 16

; Constants
NUM_SECTORS equ 1

_start:
	; Disable interrupts
	cli

	; Canonicalize ip
	jmp 0x0000:_start.canon
	.canon:

	; Load segment registers
	xor ax, ax
	mov ds, ax
	mov ss, ax
	mov ax, 0x1000
	mov es, ax

	; Set up stack
	mov sp, 0x7c00

	; Reenable interrupts
	sti

	; Reset disk
	xor ah, ah
	int 0x13
	jc error

	; ; Get drive geometry
	; mov ah, 8
	; xor di, di
	; mov es, di
	; int 0x13
	; jc error

	; Read sectors
	mov cx, NUM_SECTORS
	mov bx, 0x0000
	.rdloop:
		mov ah, 2
		mov al, 1
		int 0x13
		jc error.read
		add bx, 512
		loop .rdloop

	; Jump to stage 2
	jmp 0x0000:0x1000

error.reset:
	mov si, reseterr
	jmp error
error.read:
	mov si, readerr
	jmp error
error:
	push ax
	; Print error message
	mov ah, 0x0e
	xor bh, bh
	.loop:
		lodsb
		test al, al
		jz .done
		int 0x10
		jmp .loop
	.done:
	pop ax
	xor ah, ah
	call printint

	; Infinite loop
	cli
	hlt
	jmp $-1

printint:
	cwd
	mov bx, 10
	div bx
	push dx
	test ax, ax
	jz .done
	call printint
	.done:
	pop ax
	add al, 0x30
	mov ah, 0x0e
	xor bh, bh
	int 0x10
	ret

; Error messages
reseterr: db "Error occurred when resetting disk! Error code: ", 0x0d, 0x0a, 0
readerr: db "Failed to load kernel from disk! Error code: ", 0x0d, 0x0a, 0

; Signature bytes
times 510 - ($ - $$) db 0
db 0x55, 0xaa
