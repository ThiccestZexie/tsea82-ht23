	
	; --- lab4spel.asm
; PA0 - joy X-led
; PA1 - joy Y-led


	.equ	VMEM_SZ     = 5		; #rows on display
	.equ	AD_CHAN_X   = 0		; ADC0=PA0, PORTA bit 0 X-led
	.equ	AD_CHAN_Y   = 1		; ADC1=PA1, PORTA bit 1 Y-led
	.equ	GAME_SPEED  = 70	; inter-run delay (millisecs)
	.equ	PRESCALE    = 7		; AD-prescaler value
	.equ	BEEP_PITCH  = 20	; Victory beep pitch
	.equ	BEEP_LENGTH = 100	; Victory beep length
	
	; ---------------------------------------
	; --- Memory layout in SRAM
	.dseg
	.org	SRAM_START
POSX:	.byte	1		; Own position
POSY:	.byte 	1
TPOSX:	.byte	1		; Target position
TPOSY:	.byte	1
LINE:	.byte	1		; Current line	
VMEM:	.byte	VMEM_SZ ; Video MEMory
SEED:	.byte	1		; Seed for Random

	; ---------------------------------------
	; --- Macros for inc/dec-rementing
	; --- a byte in SRAM
	.macro INCSRAM	; inc byte in SRAM
		lds	r16,@0
		inc	r16
		sts	@0,r16
	.endmacro

	.macro DECSRAM	; dec byte in SRAM
		lds	r16,@0
		dec	r16
		sts	@0,r16
	.endmacro

 
	; ---------------------------------------
	; --- Code
	.cseg
	.org $0
	jmp	START
	.org INT0addr
	jmp	MUX

START:
	; init SP
	ldi r16, HIGH(RAMEND)
	out SPH, r16
	ldi r16, LOW(RAMEND)
	out SPL, r16

	ldi r16, 0
	sts LINE, r16 ; clear current line

	call	HW_INIT	
	call	WARM
RUN:
	call	JOYSTICK
	call	ERASE_VMEM
	call	UPDATE
	call DELAY
	call CHECK_HIT ; Sätter Z om HIT!
	brne	NO_HIT	
	ldi		r16,BEEP_LENGTH
	call	BEEP
	call	WARM
NO_HIT:
	jmp		RUN

	; ---------------------------------------
	; --- Multiplex display
MUX:	
;;*** 	skriv rutin som handhar multiplexningen och ;***
;;*** 	utskriften till diodmatrisen. Öka SEED.		;***
	push r16
	in r16, SREG
	push r16

	ldi XL, LOW(VMEM)
	ldi XH, HIGH(VMEM)
	lds r16, LINE
	out PORTC, r16 
	add XL, r16 ; index VMEM using line
	; X now points to correct VMEM line in SRAM
	ld r16, X
	out PORTB, r16 ; ASSUMES PORTB IS OUT 

	incsram SEED

	pop r16
	out SREG, r16
	pop r16
	reti
		
	; ---------------------------------------
	; --- JOYSTICK Sense stick and update POSX, POSY
	; --- Uses r16
JOYSTICK:
    push r16
	;x-axis	
	cpi r17, 0b00000000
	breq JOYSTICK_MOVE_RIGHT
	cpi r17, 0b11000000
	breq JOYSTICK_MOVE_LEFT
	;y-axis
	JOYSTICK_Y:
	cpi r18, 0b11000000
	breq JOYSTICK_MOVE_UP
	cpi r18, 0b00000000
	breq JOYSTICK_MOVE_DOWN
	JOYSTICK_EXIT:
	pop r16
	ret
;*** 	skriv kod som ökar eller minskar POSX beroende 	;***
;*** 	på insignalen från A/D-omvandlaren i X-led...	;***

;*** 	...och samma för Y-led 				;***
JOYSTICK_MOVE_RIGHT:
	lds r16, POSX
	dec r16
	sts POSX, r16
	jmp JOYSTICK_Y
JOYSTICK_MOVE_LEFT:
	lds r16, POSX
	inc r16
	sts POSX, r16
	jmp JOYSTICK_Y
JOYSTICK_MOVE_UP:
	lds r16, POSY
	inc r16
	sts POSY, r16
	jmp JOYSTICK_EXITS
JOYSTICK_MOVE_DOWN:
	lds r16, POSY
	dec r16
	sts POSY, r16
	jmp JOYSTICK_EXIT
JOY_LIM:
	call	LIMITS		; don't fall off world!
	ret

	; ---------------------------------------
	; --- LIMITS Limit POSX,POSY coordinates	
	; --- Uses r16,r17
LIMITS:
	lds		r16,POSX	; variable
	ldi		r17,7		; upper limit+1
	call	POS_LIM		; actual work
	sts		POSX,r16
	lds		r16,POSY	; variable
	ldi		r17,5		; upper limit+1
	call	POS_LIM		; actual work
	sts		POSY,r16
	ret

POS_LIM:
	ori		r16,0		; negative?
	brmi	POS_LESS	; POSX neg => add 1
	cp		r16,r17		; past edge
	brne	POS_OK
	subi	r16,2
POS_LESS:
	inc		r16	
POS_OK:
	ret

	; ---------------------------------------
	; --- UPDATE VMEM
	; --- with POSX/Y, TPOSX/Y
	; --- Uses r16, r17
UPDATE:	
	clr		ZH 
	ldi		ZL,LOW(POSX)
	call 	SETPOS
	clr		ZH
	ldi		ZL,LOW(TPOSX)
	call	SETPOS
	ret

	; --- SETPOS Set bit pattern of r16 into *Z
	; --- Uses r16, r17
	; --- 1st call Z points to POSX at entry and POSY at exit
	; --- 2nd call Z points to TPOSX at entry and TPOSY at exit
SETPOS:
	ld		r17,Z+  	; r17=POSX
	call	SETBIT		; r16=bitpattern for VMEM+POSY
	ld		r17,Z		; r17=POSY Z to POSY
	ldi		ZL,LOW(VMEM)
	add		ZL,r17		; *(VMEM+T/POSY) ZL=VMEM+0..4
	ld		r17,Z		; current line in VMEM
	or		r17,r16		; OR on place
	st		Z,r17		; put back into VMEM
	ret
	
	; --- SETBIT Set bit r17 on r16
	; --- Uses r16, r17
SETBIT:
	ldi		r16,$01		; bit to shift
SETBIT_LOOP:
	dec 	r17			
	brmi 	SETBIT_END	; til done
	lsl 	r16		; shift
	jmp 	SETBIT_LOOP
SETBIT_END:
	ret

	; ---------------------------------------
	; --- Hardware init
	; --- Uses r16
HW_INIT:

;*** 	Konfigurera hårdvara och MUX-avbrott enligt ;***
;*** 	ditt elektriska schema. Konfigurera 		;***
;*** 	flanktriggat avbrott på INT0 (PD2).			;***

	; should interrupt on rising edge (both ISC0 and ISC1)
	ldi r16,(1<<ISC01)|(1<<ISC00)|(1<<ISC11)|(1<<ISC10)
	out MCUCR,r16

	; enable ISC01 and ISC1
	ldi r16,(1<<INT1)|(1<<INT0)
	out GICR, r16
	; enable interrupts
	sei		
	ret

	; ---------------------------------------
	; --- WARM start. Set up a new game
WARM:
	push r16

	; -- Init POSX, POSY = (0,2)
	ldi r16, 0
	sts POSX, r16 ; gör POSX=0
	ldi r16, 2
	sts POSY, r16 ; gör POSY=2

	; -- Init TPOSX, TPOSY to random
	push	r0		
	push	r0		
	call	RANDOM ; RANDOM returns x,y on stack
	pop r16 
	sts TPOSX, r16 ; random TPOSX stored in SRAM!
	pop r16
	sts TPOSY, r16 ; random TPOSY stored in SRAM! 

	call	ERASE_VMEM
WARM_EXIT:
	pop r16
	ret

	; ---------------------------------------
	; --- RANDOM generate TPOSX, TPOSY
	; --- in variables passed on stack.
	; --- Usage as:
	; ---	push r0 
	; ---	push r0 
	; ---	call RANDOM
	; ---	pop TPOSX 
	; ---	pop TPOSY
	; --- Uses r16
RANDOM:
	; Z same as stackpointer
	in		r16,SPH
	mov		ZH,r16
	in		r16,SPL
	mov		ZL,r16
	lds		r16,SEED
	
;*** 	Använd SEED för att beräkna TPOSX		;***
;*** 	Använd SEED för att beräkna TPOSY		;***

	;***		; store TPOSX	2..6
	;***		; store TPOSY   0..4
	ret


	; ---------------------------------------
	; --- Erase Videomemory bytes
	; --- Clears VMEM..VMEM+4
	
ERASE_VMEM:
	push r16
	ldi XL, LOW(VMEM) ; X pointing to 0th byte in VMEM
	ldi XH, HIGH(VMEM)
	ldi r16, VMEM_SZ ; loop 5 times
ERASE_VMEM_LOOP:
	ldi r16, 0
	st X+, r16 ; clear byte
	dec r16
	brne ERASE_VMEM_LOOP
ERASE_VMEM_EXIT:
	pop r16
	ret

	; ---------------------------------------
	; --- BEEP(r16) r16 half cycles of BEEP-PITCH
CHECK_HIT:
	push r16
	push r17
	lds r16, TPOSX
	lds r17, POSX
	cp r16,r17
	brne CHECK_EXIT
	lds r16, TPOSY
	lds r17, POSY
	cp r16, r17
	brne CHECK_EXIT
	; win
	sez
CHECK_EXIT:	
	pop r17
	pop r16
	ret

; r16 holds the length
BEEP:
	push r17
	push r18
	ldi r18, BEEP_LENGTH
BEEP_LOOP:
	ldi r17, 0x01
	out PORTC, r17
	call DELAY
	ldi r17, 0x00
	out PORTC, r17
	call DELAY
	dec r18
	brne BEEP_LOOP
BEEP_DONE:
	pop r18
	pop r17
	ret
		
; delays for r16 milliseconds	
DELAY:
	push r17
	push r16
    sbi PORTB,7
    ;ldi r16,10 ; antal 
delayYttreLoop:
    ldi r17, 0x1F
delayInreLoop:
    dec r17
    brne delayInreLoop
    dec r16
    brne delayYttreLoop
    cbi PORTB,7
	pop r16
	pop r17
    ret

; AD found in r16 after this
ADC8:
	ldi r16, (1<<REFS0)|(1<<ADLAR)
	out ADMUX, r16
	ldi r16, (1<<ADEN)
	ori r16, (1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
	out ADCSRA, r16
ADC8_CONVERT:
	in r16, ADCSRA
	ori r16, (1<<ADSC)
	out ADCSRA,r16
ADC8_WAIT:
	in r16, ADCSRA
	sbrc r16, ADSC
	rjmp ADC8_WAIT
	in r16, ADCH
	mov r17, r16
	andi r17, 0xC0 ; WORRY about it later 
	swap r17