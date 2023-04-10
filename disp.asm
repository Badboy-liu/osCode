mov ax,0xb800 ;指向文本模式的显示缓冲区
mov es,ax ;把文本模式传给扩展寄存器

mov byte [es:0x00],'I'
mov byte [es:0x01],0x07
mov byte [es:0x02],'l'
mov byte [es:0x03],0x06
mov byte [es:0x04],'i'
mov byte [es:0x05],0x06
mov byte [es:0x06],'k'
mov byte [es:0x07],0x06
mov byte [es:0x08],'e'
mov byte [es:0x09],0x06
mov byte [es:0x0a],'y'
mov byte [es:0x0b],0x05
mov byte [es:0x0c],'o'
mov byte [es:0x0d],0x05
mov byte [es:0x0e],'u'
mov byte [es:0x0f],0x05
jmp $ ;停止住
times 510-($-$$) db 0  ;填充完512个字节   db就是定义字符串
;db 0x55,0xaa
dw 0xaa55