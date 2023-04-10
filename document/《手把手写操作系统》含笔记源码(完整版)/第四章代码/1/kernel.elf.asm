[BITS 16]
[section .text]
global _start
_start:
	mov ax,0xb800
	mov es,ax
	
	mov byte [es:0x00], 'K'
	mov byte [es:0x01], 0x07
