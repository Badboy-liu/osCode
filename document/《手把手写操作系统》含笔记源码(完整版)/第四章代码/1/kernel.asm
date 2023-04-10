KERNEL_BASE_ADDR equ 0x1500
section loader vstart=KERNEL_BASE_ADDR
mov ax,0xb800
mov es,ax

mov byte [es:0x00],'D'
mov byte [es:0x01],0x07
mov byte [es:0x02],'X'
mov byte [es:0x03],0x06

jmp $
