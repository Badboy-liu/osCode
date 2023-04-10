;代码段放在什么地方
; ./dd if=loader.bin of=dingst.vhd bs=512 count=1 seek=2  第二扇区  bs是byteSize   count=条数  seek
LOCAER_BASE_ADDR equ 0x900
section loader vstart=LOCAER_BASE_ADDR

mov ax,0xb800
mov es,ax
mov byte [es:0x00],'O'
mov byte [es:0x01],0x07
mov byte [es:0x02],'K'
mov byte [es:0x03],0x06

jmp $ ;停止住
