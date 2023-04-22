; Ett stoppur som visar tiden passerad i minuter och sekunder.
; ---
; IN:
;	PD3 : 1Hz clk
;	PD2 : önskad muxfrekv clk
; ---
; OUT: 
;	PA0 : segm A
;	PA1 : segm B
;	...
;	PA6 : segm G
;	PA7 : segm DP
;
;	PB0 : pos A
;	PB1 : pos B
; ---

; --- SRAM
.dseg
.org SRAM_START
TIME: .byte 4 ; time in BCD-format
POS: .byte 1 ; 7-seg position?

; --- CODE
.cseg
.org $0000
jmp MAIN ; RESET
.org INT0addr
jmp MUX ; INT0 interr.
.org INT1addr
jmp BCD ; INT1 interr.
.org INT_VECTORS_SIZE

; --- TABLES
SEGTAB: 
	.db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F

MAIN:
MAIN_INIT:
	; I/O init
	ldi r16, $FF
	out DDRA, r16 ; PORTB is where segments will be lit
	ldi r16, $00
	out DDRD, r16 ; PIND is where INT0 and INT1 will trigger from

	; init SP
	ldi r16,HIGH(RAMEND)
	out SPH,r16
	ldi r16,LOW(RAMEND)
	out SPL,r16
	; should interrupt on rising edge (both ISC0 and ISC1)
	ldi r16,(1<<ISC01)|(0<<ISC00)|(1<<ISC11)|(0<<ISC10)
	out MCUCR,r16
	; enable ISC01 and ISC1
	ldi r16,(1<<INT1)|(1<<INT0)
	out GICR,r16
	; enable interrupts
	sei
MAIN_WAIT:
	jmp MAIN_WAIT

; interrupt handlers
MUX:
	; save r16 and flags on stack
	push r16
	in r16, SREG
	push r16

	; get current number
	ldi r16, TIME

	; convert it to hex segments

	; out on PORTA

	; inc POS

	; restore r16 and flags from stack
	pop r16
	out SREG, r16
	pop r16
	reti
BCD:
	; save r16 and flags on stack
	in r16, SREG
	push r16
	;.. do something els

	; restore r16 and flags from stack
	pop r16
	out SREG, r16
	pop r16
	reti
