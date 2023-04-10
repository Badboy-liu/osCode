
;----------------------------------------------------------------------------
DA_DR		EQU	90h	; ���ڵ�ֻ�����ݶ�����ֵ
DA_DRW		EQU	92h	; ���ڵĿɶ�д���ݶ�����ֵ
DA_DRWA		EQU	93h	; ���ڵ��ѷ��ʿɶ�д���ݶ�����ֵ
DA_C		EQU	98h	; ���ڵ�ִֻ�д��������ֵ
DA_CR		EQU	9Ah	; ���ڵĿ�ִ�пɶ����������ֵ
DA_CCO		EQU	9Ch	; ���ڵ�ִֻ��һ�´��������ֵ
DA_CCOR		EQU	9Eh	; ���ڵĿ�ִ�пɶ�һ�´��������ֵ
;----------------------------------------------------------------------------
DA_32		EQU	4000h	; 32 λ��

DA_DPL0		EQU	  00h	; DPL = 0
DA_DPL1		EQU	  20h	; DPL = 1
DA_DPL2		EQU	  40h	; DPL = 2
DA_DPL3		EQU	  60h	; DPL = 3
;----------------------------------------------------------------------------
%macro Descriptor 3
	dw	%2 & 0FFFFh				; �ν��� 1				(2 �ֽ�)
	dw	%1 & 0FFFFh				; �λ�ַ 1				(2 �ֽ�)
	db	(%1 >> 16) & 0FFh			; �λ�ַ 2				(1 �ֽ�)
	dw	((%2 >> 8) & 0F00h) | (%3 & 0F0FFh)	; ���� 1 + �ν��� 2 + ���� 2		(2 �ֽ�)
	db	(%1 >> 24) & 0FFh			; �λ�ַ 3				(1 �ֽ�)
%endmacro ;

org 07c00h
	jmp	LABEL_BEGIN

[SECTION .gdt]
; GDT
;                                         �λ�ַ,      �ν���     , ����
LABEL_GDT:		Descriptor	       0,                0, 0     		; ��������
LABEL_DESC_CODE32:	Descriptor	       0, SegCode32Len - 1, DA_C + DA_32	; ��һ�´����, 32
LABEL_DESC_VIDEO:	Descriptor	 0B8000h,           0ffffh, DA_DRW		; �Դ��׵�ַ
; GDT ����

GdtLen		equ	$ - LABEL_GDT	; GDT����
GdtPtr		dw	GdtLen - 1	; GDT����
		dd	0		; GDT����ַ

; GDT ѡ����
SelectorCode32		equ	LABEL_DESC_CODE32	- LABEL_GDT
SelectorVideo		equ	LABEL_DESC_VIDEO	- LABEL_GDT
; END of [SECTION .gdt]

[SECTION .s16]
[BITS	16]
LABEL_BEGIN:
	mov	ax, cs
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, 0100h

	; ��ʼ�� 32 λ�����������
	xor	eax, eax  
	mov	ax, cs
	shl	eax, 4
	add	eax, LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32 + 2], ax
	shr	eax, 16
	mov	byte [LABEL_DESC_CODE32 + 4], al
	mov	byte [LABEL_DESC_CODE32 + 7], ah

	; Ϊ���� GDTR ��׼��
	xor	eax, eax
	mov	ax, ds
	shl	eax, 4
	add	eax, LABEL_GDT		; eax <- gdt ����ַ
	mov	dword [GdtPtr + 2], eax	; [GdtPtr + 2] <- gdt ����ַ

	; ���� GDTR
	lgdt	[GdtPtr]

	; ���ж�
	cli

	; �򿪵�ַ��A20
	in	al, 92h
	or	al, 00000010b
	out	92h, al

	; ׼���л�������ģʽ
	mov	eax, cr0
	or	eax, 1
	mov	cr0, eax

	; �������뱣��ģʽ
	jmp	dword SelectorCode32:0	; ִ����һ���� SelectorCode32 װ�� cs, ����ת�� Code32Selector:0  ��
; END of [SECTION .s16]


[SECTION .s32]; 32 λ�����. ��ʵģʽ����.
[BITS	32]

LABEL_SEG_CODE32:
	mov	ax, SelectorVideo
	mov	gs, ax			; ��Ƶ��ѡ����(Ŀ��)

	mov	edi, (80 * 3 + 0) * 2	; ��Ļ�� 3 ��, �� 0 �С�
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'D'
	mov	[gs:edi], ax

	; ����ֹͣ
	jmp	$

SegCode32Len	equ	$ - LABEL_SEG_CODE32
; END of [SECTION .s32]
times 361	db 0
dw 0xaa55

