;
; lab1.asm
;
; Created: 2023-04-11 13:48:32
; Author : thest
;


; Replace with your application code
.equ T_HALF=5
.equ BITS=4

;ldi r20, 5
ldi r18, 0x00
out DDRA, r18
ldi r18, 0xFF
out DDRB, r18

ldi r18, HIGH(RAMEND)
out SPH, r18
ldi r18, LOW(RAMEND)
out SPL, r18

STARTBIT:
	sbic PINA, 0
	jmp CHECK_VALID_START
	jmp STARTBIT

CHECK_VALID_START:
	call DELAY ; T/2 delay
	sbis PINA, 0
	jmp STARTBIT
	
BIT_INIT:
	clr r18 ; used to store incoming bits
	clr r19 ; iteration index
BIT:
	call DELAY
	call DELAY ; T delay
	sbic PINA, 0
	sbr r18, 0b10000
	lsr r18
	inc r19
	cpi r19, BITS
	brne BIT
	jmp DISPLAY

DISPLAY: ; OUTPUT r18 on PORTB lower
	out PORTB, r18
	call DELAY
	call DELAY
	jmp STARTBIT

DELAY:
	sbi PORTB,7
	ldi r16,T_HALF ; Decimal bas
delayYttreLoop:
	ldi r17, 0x1F
delayInreLoop:
	dec r17
	brne delayInreLoop
	dec r16
	brne delayYttreLoop
	cbi PORTB,7
	ret
