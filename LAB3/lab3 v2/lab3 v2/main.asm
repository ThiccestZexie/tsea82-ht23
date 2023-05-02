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
.def tmp=r18

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
	out DDRA, tmp ; PORTA is where segments will be lit
	out DDRB, tmp ; PORTB is where which display to use will be selected

	; init SP
	ldi tmp,HIGH(RAMEND)
	out SPH,tmp
	ldi tmp,LOW(RAMEND)
	out SPL,tmp

	; reset data variables
	ldi r17, 4 ; do it for every byte in TIME
MAIN_INIT_TIME_RESET:
	ldi XL, LOW(TIME)
	ldi XH, HIGH(TIME)
	ldi tmp, 0x00
	st X, tmp
	dec r17
	brne MAIN_INIT_TIME_RESET

	; should interrupt on rising edge (both ISC0 and ISC1)
	ldi tmp,(1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10) ; THS MIGHT NOT OWORK ON PHYUSOCAL atmega16a
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

MUX_MAIN:
	; tmp loaded with POS variable
	ldi XL, LOW(POS)
	ldi XH, HIGH(POS)
	ld tmp, X
	; use POS to change which display to light up
	out PORTB, tmp

	; load X with TIME + POS
	ldi XL, LOW(TIME)
	ldi XH, HIGH(TIME)
	;ldi r17, 8
	;mul tmp, r17
	add XL, tmp

	; tmp loaded with actual number to display at current pos
	ld tmp, X

	; find how to displ sgemtns
	ldi ZL, LOW(SEGTAB*2)
	ldi ZH, HIGH(SEGTAB*2)
	add ZL, tmp

	; tmp loaded with encoded segment thingy
	lpm tmp, Z

	; light up segments!
	out PORTA, tmp
	
	; increment POS in SRAM memory
	ldi XL, LOW(POS)
	ldi XH, HIGH(POS)
	ld tmp, X 
	inc tmp
	andi tmp, 0b11
	st X, tmp

MUX_EXIT:
	; restore tmp and flags from stack
	pop tmp
	out SREG, tmp
	pop tmp
	reti

BCD:
BCD_INIT:
	; save tmp and flags on stack
	push r17
	push tmp
	in tmp, SREG
	push tmp
	; load start of TIME variable
	ldi XL, LOW(TIME)
	ldi XH, HIGH(TIME)

	ldi r17, 2 ; two passes in loop
BCD_LOOP:
	; load ones
	ld tmp, X
	inc tmp ; increment ones
	st X, tmp
	cpi tmp, 10 
	brne BCD_EXIT ; not 10->EXIT, else continue..
	clr tmp
	st X+, tmp ; reset ones, move to next position
	ld tmp, X ; load tens
	inc tmp ; increment tens
	st X, tmp
	cpi tmp, 6 ; not 6 -> EXIT, else continue
	brne BCD_EXIT
	clr tmp
	st X+, tmp ; reset tens, move to next pos

	dec r17
	brne BCD_LOOP
BCD_EXIT:
	; restore tmp and flags from stack
	pop tmp
	out SREG, tmp
	pop tmp
	pop r17
	reti
