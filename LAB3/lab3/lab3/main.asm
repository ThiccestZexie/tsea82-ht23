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

; --- PREPROCESSING
.def tmpL=r18
.def tmpH=r19

; --- SRAM
.dseg
.org SRAM_START
TIME: .byte 4 ; time in BCD-format (BCD increments this)
POS: .byte 1 ; which digit to display (MUX increments/reads this)

; --- TABLES
SEGTAB: 
	.db $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$6F


; --- CODE
.cseg
.org $0000
jmp MAIN ; RESET
.org INT0addr
jmp MUX ; INT0 interr.
.org INT1addr
jmp BCD ; INT1 interr.
.org INT_VECTORS_SIZE

MAIN:
MAIN_INIT:
	; I/O init
	ldi tmpL, $FF
	out DDRA, tmpL ; PORTB is where segments will be lit
	ldi tmpL, $00
	out DDRD, tmpL ; PIND is where INT0 and INT1 will trigger from

	; init SP
	ldi tmpL,HIGH(RAMEND)
	out SPH,tmpL
	ldi tmpL,LOW(RAMEND)
	out SPL,tmpL
	; should interrupt on rising edge (both ISC0 and ISC1)
	ldi tmpL,(1<<ISC01)|(0<<ISC00)|(1<<ISC11)|(0<<ISC10)
	out MCUCR,tmpL
	; enable ISC01 and ISC1
	ldi tmpL,(1<<INT1)|(1<<INT0)
	out GICR,tmpL
	; enable interrupts
	sei
MAIN_WAIT:
	jmp MAIN_WAIT

; interrupt handlers
MUX:
MUX_INIT:
	; save tmpL and flags on stack
	push tmpL
	push tmpH
	in tmpL, SREG
	push tmpL

MUX_LOOP:
	; -- use POS to get current digit
	; load X with TIME+POS
	ldi tmpL, LOW(TIME+POS*8) ;tmpL now contains current digit

	add tmpL, LOW(SEGTAB)

	; -- convert it to hex segments
	; load Z with SEGTAB + tmpL
	; lpm tmpL, Z

	; out tmpL on PORTA

	; incr POS

MUX_EXIT:
	; restore tmpL and flags from stack
	pop tmpL
	out SREG, tmpL
	pop tmpH
	pop tmpL
	reti

BCD:
	; save tmpL and flags on stack
	in tmpL, SREG
	push tmpL
	;.. do something els

	; restore tmpL and flags from stack
	pop tmpL
	out SREG, tmpL
	pop tmpL
	reti
