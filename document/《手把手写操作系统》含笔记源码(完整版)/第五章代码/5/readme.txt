nasm -o testPM.bin LDTDemo.asm 
这是用来生成0x9000的pm程序，然后需要将它烧入到seek=20的位置
dd if=testPM.bin of=e:\d123.vhd bs=512 count=100 seek=20
同时，需要重新编译kernel，将它烧入seek=9的位置
dd if=kernel.bin of=e:\d123.vhd bs=512 count=100 seek=9