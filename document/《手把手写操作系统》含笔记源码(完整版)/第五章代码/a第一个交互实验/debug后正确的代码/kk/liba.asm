BITS 16
[global printInPos]	;为了将来可以在光标处打印内容
[global putchar]	;输出一个字符
[global getch]		;获得键盘的输入

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
