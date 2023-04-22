;
; lab2.asm
;
; Created: 2023-04-17 14:57:02
; Author : thest
;
.org 0x00

HW_INIT:
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

MSG:
	.db "DATORTEKNIK", 0
MORSE:
	.db $60,$88,$A8,$90,$40,$28,$D0,$08,$20,$78,$B0,$48,$E0,$A0,$F0,$68,$D8,$50,$10,$C0,$30,$18,$70,$98,$B8,$C8
	ldi ZH, HIGH(MSG*2)
	ldi ZL, LOW(MSG*2)

MAIN:
MAIN_LOOP:
	call GET_CHAR
	call LOOKUP	
	call SEND
	call NOBEEP_2
	brne MAIN
	jmp MAIN_END

NOBEEP:
	call DELAY
	ret
	
NOBEEP_2:
	call DELAY
	call DELAY
	ret

GET_CHAR:
	lpm r16, Z+
	ret

LOOKUP:
	; Save context
	push ZH
	push ZL

	; compare character in r16 with 'A', giving us index to use in MORSE table
	subi r16, 'A'
	ldi ZH, HIGH(MSG*2)
	ldi ZL, LOW(MSG*2)

	; point to where morse code of char
	add ZL, r16

	; load morse code for char
	lpm r16, Z

	; Restore context
	pop ZL
	pop ZH

	ret

SEND:
SEND_LOOP:
	lsl r16
	call BEEP
	brne SEND_LOOP
SEND_END:
	ret

BEEP:
	brcs BEEP_3
	jmp BEEP_1
BEEP_1:
	push r16
	ldi r16, 0x01
	out PINA, r16
	call DELAY
	ldi r16, 0x00
	out PINA, r16
	pop r16
	jmp BEEP_DONE
BEEP_3:
	push r16
	ldi r16, 0x01
	out PINA, r16
	call DELAY
	call DELAY
	call DELAY
	ldi r16, 0x00
	out PINA, r16
	pop r16
	jmp BEEP_DONE
BEEP_DONE:
	ret

DELAY:
    sbi PORTB,7
    ldi r16,10 ; Decimal bas
delayYttreLoop:
    ldi r17, 0x1F
delayInreLoop:
    dec r17
    brne delayInreLoop
    dec r16
    brne delayYttreLoop
    cbi PORTB,7
    ret

MAIN_END:
