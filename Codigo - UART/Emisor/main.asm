;-------------------------------------------------------------------------------
;   
;   Archivo: main.asm
;   Fecha de creacion/modificacion: 17 Mayo 2022
;   Author: Bottini, Franco Nicolas y Robledo, Valentin
;   Dispositivo: PIC16F887
;   Descripción: Emisor TP FINAL
;   Hardware: Simulacion y Implementacion
;
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Librerías incluidas
;-------------------------------------------------------------------------------

PROCESSOR 16F887
LIST P = 16F887
#include <p16f887.inc>
    
;-------------------------------------------------------------------------------
; Palabras de configuración
;-------------------------------------------------------------------------------

 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_ON & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_ON & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF

;-------------------------------------------------------------------------------
; Macros
;-------------------------------------------------------------------------------
    
#define FIRST 0x30
#define LAST  0x40
 
cblock 0x70
    W_Temp
    Status_Temp
    
    BufferFlag
    BufferPointer
    
    Data_Temp
    
    Row
    Column
endc

;-------------------------------------------------------------------------------
; Variables
;-------------------------------------------------------------------------------
    
;-------------------------------------------------------------------------------
; Vector de Reset
;-------------------------------------------------------------------------------
    
ORG 0x0000
resetVector:
    goto main

;-------------------------------------------------------------------------------
; Loop principal
;-------------------------------------------------------------------------------
ORG 0x0004
    movwf W_Temp
    swapf STATUS, W
    movwf Status_Temp
    
    btfsc INTCON, RBIF
    call Keypad
    
    swapf Status_Temp, W
    movwf STATUS
    swapf W_Temp, F
    swapf W_Temp, W
    
    retfie
    
ORG 0x0030
main:    
    bsf STATUS, RP1
    
    movlw 0x61
    movwf OSCCON
    
    bsf STATUS, RP0
    
    clrf BAUDCTL
    
    clrf ANSEL			
    clrf ANSELH
    
    bcf STATUS, RP1
    
    movlw 0x20
    movwf TXSTA
    
    movlw 0x19
    movwf SPBRG
    
    movlw 0x0F
    movwf TRISB
    movwf IOCB
    
    movlw 0x83
    movwf OPTION_REG
    
    bcf STATUS, RP0
    
    movlw FIRST
    movwf BufferPointer
    
    bsf BufferFlag, 0
    
    movlw 0xF0
    movwf PORTB
    
    movlw 0x80
    movwf RCSTA
    
    movlw 0x88
    movwf INTCON
Loop:
    btfsc BufferFlag, 0
    goto Loop
    
    call SendRegister
    goto Loop
    
;-------------------------------------------------------------------------------
; Subrutinas
;-------------------------------------------------------------------------------

;--------------------------------------------------------------
SendRegister
    bcf INTCON, RBIE

    call PollBuffer
    
    movwf TXREG
    
    bsf STATUS, RP0
    
    btfss TXSTA, TRMT
    goto $-1   
    
    bcf STATUS, RP0
    
    bsf INTCON, RBIE
    
    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
Keypad
    call Debounce    
    call ScanRows
    
    btfsc Column, 2
    return
    
    bcf STATUS, C
    rlf Row, F
    rlf Row, F
    
    movf Column, W
    addwf Row, F
    movlw 0xD0
    addwf Row, W

    call PutBuffer
    
    movlw 0xF0
    movwf PORTB
    
    call SendRegister
    
    btfsc PORTB, RB0
    goto $-1
    btfsc PORTB, RB1
    goto $-1
    btfsc PORTB, RB2
    goto $-1
    btfsc PORTB, RB3
    goto $-1

    bcf INTCON, RBIF
    
    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
ScanColumns
    movlw 0x00
    movwf Column
    btfsc PORTB, 0
    return
    
    incf Column, F
    btfsc PORTB, 1
    return
    
    incf Column, F 
    btfsc PORTB, 2
    return
    
    incf Column, F  
    btfsc PORTB, 3
    return
    
    movlw 0x04
    movwf Column

    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
ScanRows
    movlw 0x00
    movwf Row
    movlw 0x10
    movwf PORTB  
    call ScanColumns   
    btfss Column, 2
    return

    rlf PORTB, F
    incf Row, F  
    call ScanColumns
    btfss Column, 2
    return
    
    rlf PORTB, F
    incf Row, F
    call ScanColumns
    btfss Column, 2
    return
    
    rlf PORTB, F
    incf Row, F
    call ScanColumns
    btfss Column, 2
    return      
    
    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
PutBuffer
    movwf Data_Temp
    
    movlw LAST
    subwf BufferPointer, W
    btfsc STATUS, Z
    goto Full
    goto Add
    
Full:
    movlw FIRST
    movwf BufferPointer

Add:
    movf BufferPointer, W
    movwf FSR
    
    movf Data_Temp, W
    movwf INDF
    
    incf BufferPointer, F
    
    bcf BufferFlag, 0
    
    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
PollBuffer
    decf BufferPointer, F
    
    movf BufferPointer, W
    movwf FSR
    
    movlw FIRST
    subwf BufferPointer, W
    btfsc STATUS, Z
    bsf BufferFlag, 0

    movf INDF, W
    
    return
;--------------------------------------------------------------
  
;--------------------------------------------------------------
Debounce ;4 ms aprox   
    bcf INTCON, T0IF
    
    clrf TMR0
    
    btfss INTCON, T0IF
    goto $-1
    
    return
;--------------------------------------------------------------
    
END