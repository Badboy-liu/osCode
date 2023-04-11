;能够讲第二个扇区里面的内容加载到内存
;第一个程序mbr.asm,loader.asm


LOADER_BASE_ADDR equ 0x900 ;将loader放入0x900
LOADER_START_SECTOR equ 0x2 ;表示LBA方式,我们的loader存在第二块扇区

SECTION MBR vstart=0x7c00
	mov ax,cs   ;将代码段的地址0x7c00,放入计算寄存器
	mov ds,ax   ;将计算寄存器地址放入ds    ds=0x7c00  数据段寄存器
	mov es,ax	;将计算寄存器地址放入es    es=0x7c00  附加寄存器(额外寄存器)
	mov ss,ax	;将计算寄存器地址放入ss    ss=0x7c00  栈基址寄存器
	mov fs,ax	;将计算寄存器地址放入fs    fs=0x7c00  附加寄存器(额外寄存器)
	mov sp,0x7c00  ;将sp指向0x7c00
	mov ax,0xb800  ;ax指向显存的位置(文本模式的显示缓冲区)
	mov gs,ax   ;额外寄存器   将gs指向文本模式缓冲区

;调用10号中断
; AH = 0x06 功能
; AL = 0 表示全部清除
; BH = 上卷行的属性
; (CL,CH) 左上角 x,y
; (DL,DH) 右下角 x,y	
   mov ax,0600h  ;功能
   mov bx,0700h  ;通道号
   mov cx,0      ;左上角
   mov dx,184fh;(80,25)  文本模式就是80*25

   int 10h
;输入当前我们在MBR
   mov byte [gs:0x00],'1'
   mov byte [gs:0x01],0xA4

   mov byte [gs:0x02],' '
   mov byte [gs:0x03],0xA4

   mov byte [gs:0x04],'M'
   mov byte [gs:0x05],0xA4

   mov byte [gs:0x06],'B'
   mov byte [gs:0x07],0xA4

   mov byte [gs:0x08],'R'
   mov byte [gs:0x09],0xA4

   mov eax,LOADER_START_SECTOR   ;这是LBA读入的扇区
   mov bx,LOADER_BASE_ADDR       ;把mbr的基地址给起始寄存器
   mov cx,1                      ;要读取1个扇区
   call rd_disk                  ;读取扇区

   jmp LOADER_BASE_ADDR          ;跳到实际物理地址
rd_disk:
	;eax LBA的扇区号
	;bx  数据写入的内存地址
	;cx  读入的扇区数

	mov esi,eax   ;备份 eax  要读取的第2扇区
	mov di,cx   ;备份 cx     读取扇区数1
	;读写硬盘

	;设置读取的扇区数
	mov dx,0x1f2 ;读取第二个扇区
	mov al,cl    ;读取1个扇区
	out dx,al    ;把读取一个扇区放入dx

	mov eax,esi  ;恢复eax
	;将7-0位写入0x1f3
	mov dx,0x1f3
	out dx,al

	;将15-8位写给1f4
	mov cl,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al

	;23-16位写给1f5
	shr eax,cl
	mov dx,0x1f5
	out dx,al

	;
	shr eax,cl
	and al,0x0f
	or al,0xe0  ;设置7-4位为1110,此时才是LBA模式
	mov dx,0x1f6
	out dx,al


	;向0x1f7写入读命令
	mov dx,0x1f7
	mov al,0x20
	out dx,al

	.not_ready:
	nop ;空指令
	in al,dx
	and al,0x88 ;硬盘准备好存储准备;7位为1表示硬盘忙

	cmp al,0x08 ;表示没准备好
	jnz .not_ready

	;读数据
	mov ax,di
	mov dx,256
	mul dx
	mov cx,ax
	mov dx,0x1f0

	.go_on:
		in ax,dx ;一个个读
		mov [bx],ax
		add bx,2
		loop .go_on
		ret

	times 510-($-$$) db 0	
	dw 0xaa55
