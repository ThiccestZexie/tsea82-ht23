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
	ldi tmpL, $FF
	out DDRA, tmpL ; PORTA is where segments will be lit
	;ldi tmpL, $00
	;out DDRD, tmpL ; PIND is where INT0 and INT1 will trigger from

	; init SP
	ldi tmpL,HIGH(RAMEND)
	out SPH,tmpL
	ldi tmpL,LOW(RAMEND)
	out SPL,tmpL

	; should interrupt on rising edge (both ISC0 and ISC1)
	ldi tmpL,(1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10) ; THS MIGHT NOT OWORK ON PHYUSOCAL atmega16a
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
	; tmpL loaded with POS variable
	ldi tmpL, LOW(POS)
	andi tmpL, 0b0011 ; mask away all bits above 2
	; -- use POS to get current digit
	; load X with TIME+POS
	ldi XL, LOW(TIME)
	ldi XH, HIGH(TIME)
	add XL, tmpL

	; tmpL loaded with current digit to display
	ld tmpL, X

	; find how to displ sgemtns
	ldi ZL, LOW(SEGTAB*2)
	ldi ZH, HIGH(SEGTAB*2)
	add ZL, tmpL

	; tmpL loaded with encoded segment thingy
	lpm tmpL, Z

	; light up segments!
	out PORTA, tmpL
	
	; increment POS in SRAM memory
	ldi tmpL, LOW(POS)
	inc tmpL
	sts LOW(POS), tmpL

MUX_EXIT:
	; restore tmpL and flags from stack
	pop tmpL
	out SREG, tmpL
	pop tmpH
	pop tmpL
	reti

BCD:
BCD_INIT:
	; save tmpL and flags on stack
	push tmpL
	in tmpL, SREG
	push tmpL
	; load start of TIME variable
	ldi XL, LOW(TIME)
	ldi XH, HIGH(TIME)
BCD_LOOP:
	ld tmpL, X
	inc tmpL
	st X, tmpL
	cpi tmpL, 10
	brne BCD_EXIT
	clr tmpL
	st X+, tmpL
	ld tmpL, X ; load ten-seconds
	inc tmpL ; incr ten-seonds
	st X, tmpL
	cpi tmpL, 6
	brne BCD_EXIT
	clr tmpL
	st X+, tmpL
	jmp BCD_LOOP
BCD_EXIT:
	; restore tmpL and flags from stack
	pop tmpL
	out SREG, tmpL
	pop tmpL
	reti
