	.def	key = r18


; Exempelkod Föreläsning 2
	jmp		AV28

AV23:
; Avsnitt 2.3 16-bitars register

	lds		r16,$102		; ladda r16 från SRAM adress $102
	com		r16				; komplementera (invertera) r16
	sts		$102,r16		; spara på adress $102 innehållet i r16

	ldi		ZH,HIGH($102)	; ladda höga delen av $102 till ZH (r31)
	ldi		ZL,LOW($102)	; ladda loga delen av $102 till ZL (r30)
	ld		r16,Z			; ladda r16 från det som Z pekar på
	com		r16				; komplementera (invertera) r16
	st		Z,r16			; spara på adress som Z pekar på, innehållet i r16
	nop


AV24:
; Avsnitt 2.4 Aritmetiska operationer
	
	add		r16,r20			; ingen ingående carry
	adc		r17,r21			; med carry
	nop

AV25:
; Avsnitt 2.5 Logiska operationer

	lds		r16,$120		; ladda r16 från adress $120
	andi	r16,$07			; maska bort allt utom bit 2,1,0
	nop

AV26:
; Avsnitt 2.6 Skiftinstruktioner

	asr		r16				; arithmetic shift right

	lsr		r16				; logic shift right

	lsl		r16				; logic shift left, samma som
							; arithmetic shift left, dvs 
							; det finns ingen instruktion som heter asl
	nop


AV27:
; Avsnitt 2.7 Hoppinstruktioner
	
	; Ovillkorligt hopp
A:	
	nop						; no operation
	nop
	jmp		B				; ovillkorligt hopp till symbolisk adress (label) B
	nop						
	nop

B:
	nop


	; Villkorligt hopp
	lds		r16,$9E			; ladda ena talet från adress $9E
	lds		r17,$9F			; ladda andra talet från adress $9F
	cp		r16,r17			; (r16-r17), N-flaggan uppdateras
	brmi	R17BIG			; hopp om negativt (N==1), dvs r17 störst
	mov		r17,r16			; annars, r16 störst
R17BIG:
	sts		$A0,r17			; spara största talet i adress $A0
	nop


	; BRACKET
BRACKET:
	clz						; clear Z (zero) flag
	cpi		r16,0			; r16 - 0
	brcs	BRACKET_DONE	; C=1, Z=0 om r16 < '0'
							; C=0, Z=1 om r16 = '0'
							; C=0, Z=0 om r16 > '0'
	; was at least 0
	cpi		r16,9			; r16 - 9
	brcc	BRACKET_DONE	; C=1, Z=0 om r16 < '9'
							; C=0, Z=1 om r16 = '9'
							; C=0, Z=0 om r16 > '9'
	; and at most 9
	sez						; set Z (zero) flag
BRACKET_DONE:
	nop						

AV27_SUM:
	; Beräkna summan 1+2+3+ ... + 255
	clr		r22				; sum = 0
	clr		r21
	ldi		r20,255			; index
AGAIN:
	add		r21,r20			; sum += index
	brcc	NOCARRY
	inc		r22
NOCARRY:
	dec		r20				; minska index med 1
	brne	AGAIN
	sts		$2D2,r21		; store sum
	sts		$2D3,r22
	nop


AV28:
; Avsnitt 2.8 I/O-instruktioner
	ldi		r16,$F0			; $F0 = 0b11110000
	out		DDRB,r16		; ooooiiii (o=out, i=in)
	in		r16,PINB		; read from PIN
	andi	r16,$0F			; mask bits
	lsl		r16				; shift 1 step left
	lsl		r16				; shift 1 step left
	lsl		r16				; shift 1 step left
	lsl		r16				; shift 1 step left
	out		PORTB,r16		; write to PORT
	nop

AV28_skip:
	; skip-instruktionen
GET_KEY:
	clr		key		
	sbic	PINA,3			; skip next instruction if PA3=0
	dec		key				; key = $FF
	nop


AV28_cpse:
	; compare and skip if equal
	ldi		r17,200
	clr		r16
LOOP:
	subi	r16,-1			; r16 = r16 - (-1)
	cpse	r16,r17
	rjmp	LOOP
	nop

