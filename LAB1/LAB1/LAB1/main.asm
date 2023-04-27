;
; lab1.asm
;
; Created: 2023-04-11 13:48:32
; Author : thest
;


; Replace with your application code
.equ T=10
.equ BITS=4

ldi r20, 5
ldi r24, 0x00
out DDRA, r24
ldi r24, 0xFF
out DDRB, r24

ldi r24, HIGH(RAMEND)
out SPH, r24
ldi r24, LOW(RAMEND)
out SPL, r24

MAIN:
	jmp STARTBIT

STARTBIT:
	sbic PINA, 0
	call CHECK_VALID_START
	jmp STARTBIT

CHECK_VALID_START:
	call DELAY ; T/2 delay
	sbis PINA, 0
	ret
	jmp BIT_INIT
	
BIT_INIT:
	clr r18
BIT:
	; T delay
	call DELAY
	call DELAY
	sbic PINA, 0
	sbr r18, 0b10000
	lsr r18
	inc r19
	cpi r19, BITS
	brne BIT
	jmp DISPLAY

DISPLAY: ; OUTPUT r18 on PORTB lower (dont touch PORTB.7!)
	out PORTB, r18
	jmp MAIN

DELAY:
	sbi PORTB,7
	ldi r16,T ; Decimal bas
delayYttreLoop:
	ldi r17, 0x1F
delayInreLoop:
	dec r17
	brne delayInreLoop
	dec r16
	brne delayYttreLoop
	cbi PORTB,7
	ret
