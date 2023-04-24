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

; --- DEF
.def tmp=r16

; --- SRAM
.dseg
.org SRAM_START
TIME: .byte 4 ; time in BCD-format (BCD increments this)
POS: .byte 1 ; which digit to display (MUX increments/reads this)

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
	ldi tmp, $FF
	out DDRA, tmp ; PORTB is where segments will be lit
	ldi tmp, $00
	out DDRD, tmp ; PIND is where INT0 and INT1 will trigger from

	; init SP
	ldi tmp,HIGH(RAMEND)
	out SPH,tmp
	ldi tmp,LOW(RAMEND)
	out SPL,tmp
	; should interrupt on rising edge (both ISC0 and ISC1)
	ldi tmp,(1<<ISC01)|(0<<ISC00)|(1<<ISC11)|(0<<ISC10)
	out MCUCR,tmp
	; enable ISC01 and ISC1
	ldi tmp,(1<<INT1)|(1<<INT0)
	out GICR,tmp
	; enable interrupts
	sei
MAIN_WAIT:
	jmp MAIN_WAIT

; interrupt handlers
MUX:
MUX_INIT:
	; save tmp and flags on stack
	push tmp
	in tmp, SREG
	push tmp

MUX_LOOP:
	; -- use POS to get current digit
	; load X with TIME+POS
	ld 

	; current digit = ld X -> store in tmp for temp

	; -- convert it to hex segments
	; load Z with SEGTAB + tmp
	; lpm tmp, Z

	; out tmp on PORTA

	; incr POS

MUX_EXIT:
	; restore tmp and flags from stack
	pop tmp
	out SREG, tmp
	pop tmp
	reti

BCD:
	; save tmp and flags on stack
	in tmp, SREG
	push tmp
	;.. do something els

	; restore tmp and flags from stack
	pop tmp
	out SREG, tmp
	pop tmp
	reti
