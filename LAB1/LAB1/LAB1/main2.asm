;
; lab1.asm
;
; Created: 2023-04-11 13:48:32
; Author : thest
;


; Replace with your application code
.equ T=10
.equ BITS=4

ldi r24, 0x00
out DDRA, r24
ldi r24, 0xFF
out DDRB, r24

ldi r24, HIGH(RAMEND)
out SPH, r24
ldi r24, LOW(RAMEND)
out SPL, r24

MAIN:
	call STARTBIT
	jmp VALID_START
MAIN_VALID:
	call BIT_INIT

STARTBIT:
	sbic PINA, 0
	ret
	jmp STARTBIT

VALID_START:
	call DELAY ; T/2 Dealy
	sbic PINA, 0
	jmp MAIN_VALID
	jmp MAIN

BIT_INIT:
	clr r16
	clr r17
BIT_LOOP:
	call DELAY
	call DELAY
	sbic PINA, 0
	sbr r16, 0b10000
	lsr r16
	inc r17
	cpi r17, BITS
	brne BIT_LOOP
DISPLAY:
	out PORTB, r16
	jmp MAIN

DELAY:
	push r16
	push r17
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
	pop r17
	pop r16
	ret
