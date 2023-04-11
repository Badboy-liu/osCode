
DA_32 EQU	4000h;32位
DA_C EQU 98h; 只执行代码段的属性
DA_DRW	EQU 92h;可读写的数据段
DA_DRWA EQU 93h;存在的已访问的可读写的
DA_LDT EQU 82h;省局
SA_TIL EQU 4;具体的任务

;这句话是一个计算式，其中包含一些二进制运算符和常数。假设%2和%3是16位的整数变量：

;">>" 是右移位运算符，表示将%2变量中的二进制数向右移动8位（即一个字节），相当于将%2除以256取整。
;"&" 是按位与运算符，用于将运算符两侧的二进制数进行逐位比较，只有当两个数的对应位都是1时，结果的对应位才是1，否则为0。在这个例子中，& 0F00h把0F00h与计算结果的高8位进行按位与操作，保留高8位中的值，并清除低8位。
;"|" 是按位或运算符，用于将两侧的二进制数的每个对应位上的值进行或运算，得到的结果中的每个对应位置上的值可看作是两侧对应位置上的值中的最大值，结果是一个新的二进制数。在这个例子中，使用 " | (%3 & 0F0FFh) "将计算结果的低8位与%3中的低12位进行按位或操作，得到一个新的16位二进制数。
;因此，这个计算式的含义是：提取16位变量%2的高8位的值并将它左移8位，然后将其与16位变量%3的低12位进行按位或操作，得到一个新的16位二进制数值。
%macro Descriptor 3
	dw %2 & 0FFFFh	;段界限1 （2字节）
	dw %1 & 0FFFFh	;段基址1 (2字节）
	db (%1 >> 16) & 0FFh	;段基址2 （1字节）
	dw ((%2 >> 8) & 0F00h) | (%3 &0F0FFh) ;属性1 + 段界限2+属性2 （2字节）
	db (%1 >> 24) & 0FFh	;段基址3
%endmacro


org 0100h 	;因为我们dos下调试程序，那么0100是可用区域
	jmp PM_BEGIN	;跳入到标号为PM_BEGIN的代码段开始推进
	
	
[SECTION .gdt]
;GDT
;								段基址，段界限，属性
PM_GDT:				Descriptor		0,		0,		0
PM_DESC_CODE32:	Descriptor		0,		SegCode32Len -1,DA_C+DA_32
PM_DESC_DATA:		Descriptor		0,		DATALen-1, DA_DRW	
PM_DESC_STACK:		Descriptor		0,		TopOfStack,	DA_DRWA+DA_32
PM_DESC_TEST:		Descriptor		0200000h,0ffffh,	DA_DRW
PM_DESC_VIDEO:		Descriptor		0B8000h,	0ffffh, DA_DRW


LABEL_DESC_LDT:     Descriptor 0,LDTLen-1,DA_LDT

PM_DESC_CODE_DEST:  Descriptor 0,SegCodeDestLen-1,DA_C+DA_32
PM_CALL_GATE_TEST:  
dw 00000h
dw SelectoerCodeDest
dw 08c00h;表示调用
dw 00000h



;end of definiton gdt
GdtLen equ $ - PM_GDT
GdtPtr dw GdtLen - 1
dd  0 ; GDT 基地址

;GDT 选择子
SelectoerCode32	equ PM_DESC_CODE32 - PM_GDT	
SelectoerDATA	equ PM_DESC_DATA   - PM_GDT
SelectoerSTACK	equ PM_DESC_STACK  - PM_GDT	
SelectoerTEST	equ PM_DESC_TEST   - PM_GDT
SelectoerVideo	equ PM_DESC_VIDEO  - PM_GDT
SelectoerLDT    equ LABEL_DESC_LDT - PM_GDT	

SelectoerCodeDest equ PM_DESC_CODE_DEST     - PM_GDT	
SelectoerCallGateTest equ PM_CALL_GATE_TEST - PM_GDT		
;END of [SECTION .gdt]

[SECTION .data1]
ALIGN 32
[BITS 32]
PM_DATA:
PMMessage : db "Potect Mode", 0;
OffsetPMessage equ PMMessage - $$
DATALen equ $- PM_DATA
;END of [SECTION .data]

;全局的堆栈段
[SECTION .gs]
ALIGN 32
[BITS 32]
PM_STACK:
	times 512 db 0
TopOfStack equ $ - PM_STACK -1
;END of STACK	

[SECTION .s16]
[BITS 16]
PM_BEGIN:
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0100h
	
	;初始化32位的代码段
	xor eax,eax
	mov ax,cs
	shl eax,4
	add eax,PM_SEG_CODE32
	mov word[PM_DESC_CODE32+2],ax
	shr eax,16
	mov byte [PM_DESC_CODE32+4],al
	mov byte [PM_DESC_CODE32+7],ah
	
	
	;初始化32位的数据段
	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,PM_DATA
	mov word[PM_DESC_DATA+2],ax
	shr eax,16
	mov byte [PM_DESC_DATA+4],al
	mov byte [PM_DESC_DATA+7],ah
	
	;初始化32位的stack段
	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,PM_STACK
	mov word[PM_DESC_STACK+2],ax
	shr eax,16
	mov byte [PM_DESC_STACK+4],al
	mov byte [PM_DESC_STACK+7],ah



	;为调用门的运行,我们将代码段跳转
	xor eax,eax
	mov ax,cs
	shl eax,4
	add eax,PM_SEG_CODE_DEST   ;to do
	mov word[PM_DESC_CODE_DEST+2],ax
	shr eax,16
	mov byte [PM_DESC_CODE_DEST+4],al
	mov byte [PM_DESC_CODE_DEST+7],ah

	;初始化32位的ldt段,注册到gdt
	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,LABEL_LDT   ;to do
	mov word[LABEL_DESC_LDT+2],ax
	shr eax,16
	mov byte [LABEL_DESC_LDT+4],al
	mov byte [LABEL_DESC_LDT+7],ah

	;根据gdt,初始化ldt下的注册软件
	xor eax,eax  ;清空eax
	mov ax,ds    ;把代码段的数据读取到ax寄存器
	shl eax,4    ;左移四位
	add eax,LABEL_CODE_A
	mov word [LABEL_LDT_DESC_CODEA +2 ],ax
	shr eax,16
	mov byte [LABEL_LDT_DESC_CODEA+4],al
	mov byte [LABEL_LDT_DESC_CODEA+7],ah
	
	;加载GDTR
	xor eax,eax
	mov ax,ds
	shl eax,4
	add eax,PM_GDT
	mov dword [GdtPtr +2 ],eax
	lgdt [GdtPtr]
	
	;A20
	cli
	
	in al,92h
	or al,00000010b
	out 92h,al
	
	;切换到保护模式
	mov eax,cr0
	or eax,1
	mov cr0,eax
	
	jmp dword SelectoerCode32:0



[SECTION .s32]	;32位的代码段
[BITS 32]
PM_SEG_CODE32 :
	mov ax,SelectoerDATA	;通过数据段的选择子放入ds寄存器，就可以用段+偏移进行寻址
	mov ds,ax
	
	mov ax,SelectoerTEST	;通过测试段的选择子放入es寄存器，就可以用段+偏移进行寻址
	mov es,ax
	
	mov ax,SelectoerVideo
	mov gs,ax
	
	mov ax,SelectoerSTACK
	mov ss,ax
	mov esp,TopOfStack
	
	mov ah,0Ch
	xor esi,esi
	xor edi,edi
	mov esi,OffsetPMessage
	mov edi,(80*10 +0) *2
	cld
	
.1:
	lodsb
	test al,al
	jz .2
	mov [gs:edi],ax
	add edi,2
	jmp .1
	
.2: ;显示完毕

	;测试段的寻址
	; mov ax,SelectoerLDT ;加载ldt
	; lldt ax ;跳到SelectoerLDT
	; jmp SelectoerLDTCodeA:0

	call SelectoerCallGateTest:0

	jmp $
	

SegCode32Len equ $ - PM_SEG_CODE32


;ldt
[SECTION .ldt]
ALIGN 32 ;内存对齐方式32字节
LABEL_LDT:
;                    段基址 ,段界限,属性
LABEL_LDT_DESC_CODEA: Descriptor 0,CodeALen-1,DA_C+DA_32

LDTLen equ $ - LABEL_LDT ;$是当前位置   - 
SelectoerLDTCodeA equ LABEL_LDT_DESC_CODEA - LABEL_LDT+SA_TIL

[SECTION .la]
ALIGN 32
[BITS 32] ;设置指令架构位32位  [bits 64] 就是使用64位的指令集
LABEL_CODE_A:
	mov ax,SelectoerVideo
	mov gs,ax
	mov edi,(80*5+0)*2
	mov ah,0Ch ;大写红色
	mov al,'D';打印大D
	mov [gs:edi],ax

	jmp $
CodeALen equ $ - LABEL_CODE_A
;真正的任务段
; end of 任务段	



[SECTION .sdest]
ALIGN 32
[BITS 32]
PM_SEG_CODE_DEST:
	mov ax,SelectoerVideo
	mov gs,ax
	mov edi,(80*18+0)*2
	mov ah,0ch
	mov al,'G'
	mov [gs:edi],ax
	retf

SegCodeDestLen equ $-PM_SEG_CODE_DEST ;任务代码长度

;end of 调用门