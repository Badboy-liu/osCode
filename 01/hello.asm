; 告诉编译器把程序加载到7c00处,当bios检查完毕就会跳到此处执行
org 07c00h
; 把cs移动到ax   cs是代码段  code Segment  as是cup当前要读取的地址  ds是寄存器存放要访问数据的段地址
mov ax,cs
mov ds,ax
mov es,ax
call Disp
jmp $
Disp:
	mov ax,BootMsg
	mov bp,ax
	mov cx,16
	mov ax,01301h 
	mov bx,000ch
	int 10h 
BootMsg : db "hello,os world"
times 510-($-$$) db 0
dw 0xaa55