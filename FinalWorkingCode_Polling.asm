LIST P=16F877A
#include <P16F877A.inc>

__CONFIG _CP_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC & _LVP_OFF


CBLOCK 0x20		
	delay1
	delay2

	tempPortB

	; ---- Direction Vars
	forward_both
	
	HR_R
	HR_L

	SR_R
	SR_L

	HL_R
	HL_L
	
	SL_R
	SL_L
	
	lastAction

ENDC

ORG 0x00
	GOTO MAIN


MAIN:	;=====================MAIN
	;=======BANK1 Select
	
	BCF STATUS, RP1
	BSF STATUS, RP0
	
	;------------TRIS
	CLRF TRISC
	CLRF TRISD			;for testing

	MOVLW 0xFF
	MOVWF TRISB	
	
	;------------ADCON (set as digital)
	MOVLW 0x07
	MOVWF ADCON1
	

	;---------------RB4 to 6 
	BCF OPTION_REG, 7		;enable pullup bit 7 = 0


	; -------------------PWM INIT
	MOVLW 165	; PR2 = [Fosc /(4 * F_PWM * prescale)] - 1
	MOVWF PR2	; PR2 = [  8M /(4 * 3k    * (1 4 or 16)] - 1



	;=======BANK0 Select
	BCF STATUS, RP0

	;-----------PORTs
	CLRF PORTB
	CLRF PORTC
	
	;-------------------PWM
	CLRF CCPR1L 	; 8 MSBs of duty cycle
	CLRF CCPR2L

	MOVLW 0x06	
	MOVWF T2CON

	MOVLW 0x0C
	MOVWF CCP1CON
	MOVWF CCP2CON

	; ------------- define direction variables
	MOVLW 30							; EDIT_THIS
	MOVWF forward_both
	
	MOVLW 0							; EDIT THIS
	MOVWF HR_R
	MOVLW 190							; EDIT THIS
	MOVWF HR_L

	MOVLW 30							; EDIT THIS
	MOVWF SR_R 
	MOVLW 90							; EDIT THIS
	MOVWF SR_L

	MOVLW 190							; EDIT THIS
	MOVWF HL_R
	MOVLW 0							; EDIT THIS
	MOVWF HL_L	
	
	MOVLW 90							; EDIT THIS
	MOVWF SL_R
	MOVLW 30							; EDIT THIS
	MOVWF SL_L

	CLRF tempPortB
	CLRF lastAction
	

LOOP:	;=================================LOOP
	MOVF PORTB, W
	MOVWF tempPortB
	MOVLW 0x8F 		;1000 1111
	IORWF tempPortB, F
	

	; --------------- 3 IR sensor Checker
	; W B W bit 6 5 4		1 means black
	MOVLW 0xAF	;X010 XXXX
	XORWF tempPortB, W
	BTFSC STATUS, Z
	CALL FORWARD_Wheels
	
	
	; w W B
	MOVLW 0x9F	;X001 XXXX
	XORWF tempPortB, W
	BTFSC STATUS, Z
	CALL HARD_RIGHT	
	
	; WBB
	MOVLW 0xBF	;X011 XXXX
	XORWF tempPortB, W
	BTFSC STATUS, Z
	CALL SOFT_RIGHT	

	;BWW
	MOVLW 0xCF	;X100 XXXX
	XORWF tempPortB, W
	BTFSC STATUS, Z
	CALL HARD_LEFT	

	;BBW
	MOVLW 0xEF	;X110 XXXX
	XORWF tempPortB, W
	BTFSC STATUS, Z
	CALL SOFT_LEFT	

	;BBB
	MOVLW 0xFF	;X111 XXXX
	XORWF tempPortB, W
	BTFSC STATUS, Z
	CALL CHECK_DIR

	;WWW
	MOVLW 0x8F	;X000 XXXX
	XORWF tempPortB, W
	BTFSC STATUS, Z
	CALL CHECK_90
	GOTO LOOP

;==================FUNCTIONS

;--------- Let CCPR1L be right, CCPR2L be left 
FORWARD_Wheels:
	MOVLW 0x35
	MOVWF CCPR1L
	MOVWF CCPR2L
	
	MOVLW 0x01
	MOVWF lastAction

	RETURN

HARD_RIGHT:
	MOVLW 0x00
	MOVWF CCPR1L

	MOVLW 0xFF
	MOVWF CCPR2L
	
	MOVLW 0x02
	MOVWF lastAction

	RETURN

SOFT_RIGHT:
	MOVLW 0x00
	MOVWF CCPR1L

	MOVLW 0xA0
	MOVWF CCPR2L

	MOVLW 0x04
	MOVWF lastAction

	RETURN

HARD_LEFT:
	MOVLW 0xFF
	MOVWF CCPR1L

	MOVLW 0x00
	MOVWF CCPR2L

	MOVLW 0x08
	MOVWF lastAction

	RETURN

SOFT_LEFT:
	MOVLW 0xA0
	MOVWF CCPR1L

	MOVLW 0x00
	MOVWF CCPR2L

	MOVLW 0x10
	MOVWF lastAction

	RETURN

STOP:	
	CLRF CCPR1L
	CLRF CCPR2L
	RETURN

CHECK_DIR:
	; bit number
	; lastAction = 0	| forward
	; lastAction = 1	| HR
	; lastAction = 2	| SR
	; lastAction = 3	| HL
	; lastAction = 4	| SL
	
	BTFSC lastAction, 0
	CALL FORWARD_Wheels
	
	BTFSC lastAction, 1
	CALL HARD_RIGHT

	BTFSC lastAction, 2
	CALL SOFT_RIGHT

	BTFSC lastAction, 3
	CALL HARD_LEFT

	BTFSC lastAction, 4
	CALL SOFT_LEFT		
	RETURN
	

CHECK_90:
	BTFSC lastAction, 1
	CALL HARD_RIGHT

	BTFSC lastAction, 2
	CALL HARD_RIGHT

	BTFSC lastAction, 3
	CALL HARD_LEFT

	BTFSC lastAction, 4
	CALL HARD_LEFT
	RETURN
	


;----------------DELAY
DELAY:
	MOVLW 0xFF
	MOVWF delay2

OUTER_DELAY:
	MOVLW 0xFF
	MOVWF delay1
INNER_DELAY:
	DECFSZ delay1
	GOTO INNER_DELAY

	DECFSZ delay2
	GOTO OUTER_DELAY	
	RETURN

END
