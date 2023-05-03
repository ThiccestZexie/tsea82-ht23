; Exempelkod F�rel�sning 1

; Avsnitt 2.1 Grupp 1 - Flytta data

	ldi		r16,23		; Load immediate

	mov		r13,r16		; Move direct (copy)
						; move Rd,Rr
						; Rd - destination (vart)
						; Rr - source (k�lla, varifr�n)


; Avsnitt 2.2 8-bitars register

	ldi		r22,$30		; Ladda r22 med $30 (ASCII f�r 0)
	add		r22,r16		; addera siffran i r16 till r22

	mov		r22,r16		; kopiera r16 (siffran) till r22
	ori		r22,$30		; or:a in 1:or ($30 = 0b00110000)


; Avsnitt 2.3 16-bitars register

	adiw	r24,1		; �ka registerparet r25:r24 med 1
						; adiw fungerar bara med r25:r24, r27:r26, r29:r28, r31:r30

	inc		r16			; �ka r16 med 1, p�verkar Z med inte C
	brne	DONE		; om resultatet skiljt fr�n 0, hoppa till DONE
	inc		r17			; �ka annars �ven r17 med 1
DONE:
	nop


; Exempel ld/lds/st/sts

	ldi		ZH,HIGH($0102)	; ZH(r31)=01
	ldi		ZL,LOW($0102)	; ZL(r30)=02
	ld		r16,Z			; r16=Mem(Z)
	com		r16				; complement r16
	st		Z,r16			; Mem(Z)=r16


	lds		r16,$0102		; r16=Mem($0102)
	com		r16				; complement r16
	sts		$0102,r16		; Mem($0102)=r16


FO2:
	lds		r16,$102	; ladda r16 fr�n SRAM adress $102
	com		r16			; komplementera (invertera) r16
	sts		$102,r16	; spara p� adress $102 inneh�llet i r16

	ldi		ZH,HIGH($102)	; ladda h�ga delen av $102 till ZH (r31)
	ldi		ZL,LOW($102)	; ladda loga delen av $102 till ZL (r30)
	ld		r16,Z			; ladda r16 fr�n det som Z pekar p�
	com		r16				; komplementera (invertera) r16
	st		Z,r16			; spara p� adress som Z pekar p�, inneh�llet i r16
	nop

