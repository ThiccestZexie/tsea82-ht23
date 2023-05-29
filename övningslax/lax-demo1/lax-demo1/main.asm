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

	; make PA input
	ldi r16, 0x00
	out DDRA, r16
	; make PB output
	ldi r16, 0xFF
	out DDRB, r16

MAIN:
	sbis PINA, 4
	jmp MAIN ; no strobe, keep polling

READNUM:
	in r16, PINA
	andi r16, 0x0F ; mask away higher nibble

SEPARATE:
	; try to subtract 9 from r16
	; 
	; if it succedds, set r16 bit 4.
	; the result is 10s in higher r16, and ones in r16
	cpi r16, 10
	brcs DISPLAY
	subi r16, 10
	ori r16, (1<<4)

DISPLAY:
	out PORTB, r16
	jmp MAIN