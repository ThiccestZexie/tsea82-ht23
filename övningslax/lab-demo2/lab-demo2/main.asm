;
; lax-demo1.asm
;
; Created: 2023-05-23 14:08:54
; Author : samak519
;


HW_INIT:
	; init SP
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	; make PD input
	ldi r16, 0x00
	out DDRD, r16
	; make PB output
	ldi r16, 0xFF
	out DDRB, r16

MAIN:
	in r16, PIND


INCREMENT:
	