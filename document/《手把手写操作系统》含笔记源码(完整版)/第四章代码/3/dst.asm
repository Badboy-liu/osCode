extern DISPLAY; from C fun
[BITS 16]
[section .text]
global _start
global myprint
_start:
	call DISPLAY ; asm call c function
myprint:
	mov ax,0xb800
	mov es,ax
	mov byte [es:0x00], 'A'
	mov byte [es:0x01],0x07
	ret
