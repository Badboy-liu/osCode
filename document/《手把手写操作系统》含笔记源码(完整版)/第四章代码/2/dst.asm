extern chooseNUM ; from C fun
[section .data]
num1st dd 39
num2nd dd 44
[section .text]
global _start
global myprint
_start:
	push num2nd
	push num1st
	call chooseNUM
	add esp,4
	mov ebx,0
	mov eax,1
	int 0x80 ;sys_exit
myprint:
	mov edx,[esp + 8 ]
	mov ecx,[esp + 4 ] 
	mov ebx,1
	mov eax,4
	int 0x80 ;sys_wrtie
	ret
