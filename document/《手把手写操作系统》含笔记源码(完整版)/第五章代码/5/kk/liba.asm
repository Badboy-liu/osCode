BITS 16
[global printInPos]	;为了将来可以在光标处打印内容
[global putchar]	;输出一个字符
[global getch]		;获得键盘的输入
[global clearScreen]
[global powerOFF]
[global systime]
[global drawPic]
[global callPM]

drawPic:
	pusha
	popa
         mov ah,0fh
         int 10h
         mov ah,0 
         mov al,3
         int 10h
         mov cx,1                 ;字符数量
         mov ah,2
         mov dh,5                 ;5行开始
         mov dl,25                ;25列开始
         int 10h
;*****光标向下动********
line:    mov ah,2
         int 10h
         mov al,15
         mov ah,9
         mov bl,0e0h            ;字符黄色
         int 10h
         inc dh                 ;行增加 
         cmp dh,20               ;20行
         jne line 
         jmp line1
;****光标向右动*****
line1:   mov ah,2
         int 10h
         mov al,15
         mov ah,9
         mov bl,0e0h                ;字符为黄色
         int 10h
         inc dl                  ;列增加
         cmp dl,55                 ;55列
         jne line1
         jmp line2
;*****光标向上动*********
line2:   mov ah,2
         int 10h  
         mov al,15
         mov ah,9
         mov bl,0e0h               ;字符为黄色
         int 10h
         dec dh
         cmp dh,5
         jne line2
         jmp line3  
;***光标向左动***
line3:   mov ah,2
         int 10h
         mov al,15
         mov ah,9
         mov bl,0e0h ;字符为黄色
         int 10h
         dec dl 
         cmp dl,25
         jne line3
l00:     mov ah,7
         mov al,14
         mov bh,20h  ;绿色
         mov ch,6 
         mov cl,26
         mov dh,19
         mov dl,54
         int 10h
;*****时间控制*****
l01:    mov ah,0
        int 1ah
        cmp dl,10
        jnz l01
l1:     mov ah,6
        mov al,14
        mov bh,0f0h ;白色
        mov ch,6
        mov cl,26
        mov dh,19
        mov dl,54
        int 10h
l2:     mov ah,0
        int 1ah
        cmp dl,15
        jnz l2
l3:     mov ah,7
        mov al,14
        mov bh,40h ;红色
        mov ch,6
        mov cl,26
        mov dh,19
        mov dl,54
        int 10h
l4:     mov ah,0
        int 1ah
        cmp dl,30
        jnz l4
l5:     mov ah,6
        mov al,14
        mov bh,0d0h ;品红
        mov ch,6
        mov cl,26
        mov dh,19
        mov dl,54
        int 10h
l004:   mov ah,0
        int 1ah
        cmp dl,10
        jnz l004
l005:   mov ah,7
        mov al,14
        mov bh,30h ;青
        mov ch,6
        mov cl,26
        mov dh,19
        mov dl,54
        int 10h
l006:   mov ah,0
        int 1ah
        cmp dl,10
        jnz l006
l02:    mov ah,7
        mov al,14
        mov bh,20h ;绿色
        mov ch,6
        mov cl,26
        mov dh,19
        mov dl,54
        int 10h
;****时间控制****

  mov ah,2
       mov dh,23
       mov dl,0
       int 10h
      
	retf
systime:
	pusha
	mov al,4	;hour
	out 70h,al
	in  al,71h
	mov ah,al
	mov cl,4
	shr ah,cl
	and al,00001111b
	add ah,30h
	add al,30h

	mov dx,ax
	mov al,dh
	mov bh,0
	mov ah,0Eh
	int 10h
	
	mov al,dl
	mov bh,0
	mov ah,0Eh
	int 10h
	
	mov al, ':'
	mov bh,0
	mov ah,0Eh
	int 10h
	
	;-------minute--------

	mov al,2	;minute
	out 70h,al
	in  al,71h
	mov ah,al
	mov cl,4
	shr ah,cl
	and al,00001111b
	add ah,30h
	add al,30h

	mov dx,ax
	mov al,dh
	mov bh,0
	mov ah,0Eh
	int 10h
	
	mov al,dl
	mov bh,0
	mov ah,0Eh
	int 10h
	
	mov al, ':'
	mov ah,0Eh
	int 10h
;-------------------seconde
	
	mov al,0	;minute
	out 70h,al
	in  al,71h
	mov ah,al
	mov cl,4
	shr ah,cl
	and al,00001111b
	add ah,30h
	add al,30h

	mov dx,ax
	mov al,dh
	mov bh,0
	mov ah,0Eh
	int 10h
	
	mov al,dl
	mov bh,0
	mov ah,0Eh
	int 10h
	
	mov al,0Ah
	mov bh,0
	mov ah,0Eh
	int 10h
	
	mov al,0Dh
	mov bh,0
	mov ah,0Eh
	int 10h
	
	popa
	retf
powerOFF:
	mov ax,5307h
	mov bx,0001h
	mov cx,0003h
	int 15h

clearScreen:
	push ax
	mov ax,0003h
	int 10h
	pop ax
	retf
getch:				;这是一个函数，我们从键盘中读取一个字符到tempc的变量，使用的是16号中断
	mov ah,0	;功能号
	int 16h
	mov ah,0	;读取字符，al存的是读到字符，同时置ah为0，为返回值作准备
	retf
	
putchar:			;在光标处打印一个字符到屏幕，用的bios的10号中断
	pusha
	mov bp,sp
	add bp,16+4		;参数地址
	mov al,[bp]		;al=要打印的字符
	mov bh,0		;bh=页码
	mov ah,0Eh		;0Eh是中断
	int 10h
	popa
	retf
	
printInPos:			;在指定的位置显示字符串
	pusha
	mov si, sp		;在我们的printInPos中，我们用到了bp，所以我们用si来为参数寻址
	add si,16+4		;首个参数的地址
	mov ax, cs
	mov ds, ax
	mov bp,[si]		;BP指向了当前串的偏移地址
	mov ax, ds		;ES：BP=串地址
	mov es,	ax		;置ES= DS
	mov cx,[si+4]	;cx，=串长
	mov ax,1301h	;AH=13(功能号)，AL=01h表示字符串显示完毕之后，光标应当置于串的末尾
	mov bx,0007h	;bh=0,表示0号页，bl=07，表示黑底白字
	mov dh, [si+8]	;行号=0
	mov dl,[si+12]	;列号=0
	int 10h			;使用BIOS的10h，显示一行字符
	popa
	retf

callPM:				;进入保护模式	
	mov eax,	20 ;Kernel_START_SECTOR ;LBA 读入的扇区 我们用dd命令将我们制作的保护模式的二进制代码，从20号扇区开始写入
	mov bx,		0x9000 ;Kernel_BASE_ADDR		;写入的地址   我们决定将我们的保护模式，放置到0x9000处
	mov cx,		10	;等待读入的扇区数，我们决定大约10个左右
	call rd_disk
	
	jmp 0x9000		;调到实际的物理内存

rd_disk:
	;eax LBA的扇区号
	;bx 数据写入的内存地址
	;cx 读入的扇区数
	
	mov esi,eax		;备份eax
	mov di,cx		;备份cx
	
;读写硬盘
	mov dx, 0x1f2
	mov al, cl
	out dx, al
	mov eax,esi

;将LBA的地址存入0x1f3，0x1f6
	
	;7-0位写入0x1f3
	mov dx, 0x1f3
	out dx,al
	
	;15-8位写给1f4
	mov cl,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al
	
	;23-16位写给1f5
	shr eax,cl
	mov dx,0x1f5
	out dx,al
	
	shr eax,cl
	and al,0x0f
	or al,0xe0	;设置7-4位为1110，此时才是lBA模式
	mov dx,0x1f6
	out dx,al
	
	;向0x1f7写入读命令
	mov dx,0x1f7
	mov al,0x20
	out dx,al
	
	;检测硬盘状态
	.not_ready:
	nop
	in al,dx
	and al,0x88; 4位为1，表示可以传输，7位为1表示硬盘忙
	cmp al,0x08
	jnz .not_ready
	
	;读数据
	mov ax,di
	mov dx, 256
	mul dx
	mov cx,ax
	mov dx,0x1f0
	
	.go_on:
		in ax,dx
		mov [bx],ax
		add bx,2
		loop .go_on
		ret
