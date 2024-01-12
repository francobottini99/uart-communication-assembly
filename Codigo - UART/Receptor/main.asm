;-------------------------------------------------------------------------------
;   
;   Archivo: main.asm
;   Fecha de creacion/modificacion: 17 Mayo 2022
;   Author: Lencina, Aquiles Benjamin y Quinteros del Castillo, Santiago
;   Dispositivo: PIC16F887
;   Descripción: Receptor TP FINAL
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
    
#define RX_FIRST    0x30
#define RX_LAST     0x35
#define DISP_FIRST  0x36
#define DISP_LAST   0x3A
 
cblock 0x70
    W_Temp
    Status_Temp
    
    Data_Temp
    Code_Temp
    
    BufferFlag
    BufferPointer
    
    AuxPort  
    DispShowPointer
    DispWritePointer
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
    
    btfsc INTCON, T0IF
    call Multiplex
    
    btfsc PIR1, RCIF 
    call RecibeRegister
    
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
    
    movlw 0x19
    movwf SPBRG
    
    movlw 0x80
    movwf TRISD
    
    movlw 0xF0
    movwf TRISA
    
    movlw 0x40
    movwf PIE1
    
    movlw 0x84
    movwf OPTION_REG
    
    bcf STATUS, RP0
    
    movlw DISP_FIRST
    movwf DispShowPointer
    
    movlw RX_FIRST
    movwf BufferPointer
    
    movlw 0x01
    movwf AuxPort
    
    call Clear
    
    bsf BufferFlag, 0

    movlw 0x90
    movwf RCSTA
    
    movlw 0xE4
    movwf INTCON

Main_Loop:    
    btfss BufferFlag, 0
    call Refresh
    
    goto Main_Loop
    
;-------------------------------------------------------------------------------
; Subrutinas
;-------------------------------------------------------------------------------
    
;--------------------------------------------------------------
RecibeRegister
    btfsc RCSTA, OERR
    goto ResetUART
    goto Recibe
    
ResetUART:
    bcf RCSTA, CREN
    bsf RCSTA, CREN
    
Recibe:
    movf RCREG, W
    
    call PutBuffer
    
    bcf PIR1, RCIF
    
    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
Multiplex
    clrf PORTA
    
    movf DispShowPointer, W
    movwf FSR
    movf INDF, W
    movwf PORTD

    movf AuxPort, W
    movwf PORTA
     
    bcf STATUS, C
    rlf AuxPort, F
    
    incf DispShowPointer, F
    
    movlw DISP_LAST
    subwf DispShowPointer, W
    btfss STATUS, C
    goto Finish
    goto Init

Init:
    movlw 0x01
    movwf AuxPort
    
    movlw DISP_FIRST
    movwf DispShowPointer
    
Finish:
    bcf INTCON, T0IF
    
    movlw 0x64
    movwf TMR0
    
    return
;--------------------------------------------------------------

;--------------------------------------------------------------
Refresh
    call PollBuffer
    movwf Data_Temp
    
    movlw 0xF0
    andwf Data_Temp, W
    movwf Code_Temp
    movlw 0x0F
    andwf Data_Temp, F
    
    movlw 0xD0
    subwf Code_Temp, W
    btfsc STATUS, Z
    call DisplayData
    
    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
DisplayData
    movf Data_Temp, W
    call DecodeDisplay
    movwf Data_Temp
    
    movlw 0x00
    subwf Data_Temp, W
    btfsc STATUS, Z
    goto Clean
    
    movlw 0xFF
    subwf Data_Temp, W
    btfsc STATUS, Z
    goto Delete
    
    goto Save
    
Delete:
    call Backspace
    
    movf DispWritePointer, W
    movwf FSR
    movf Data_Temp, W
    movwf INDF
    
    goto Done
    
Save:
    movlw DISP_LAST
    subwf DispWritePointer, W
    btfsc STATUS, C
    call Clear
    
    movf DispWritePointer, W
    movwf FSR
    movf Data_Temp, W
    movwf INDF
    
    incf DispWritePointer, F    

    goto Done

Clean:
    call Clear
    
Done: 
    bcf INTCON, RBIF    
    
    return
;--------------------------------------------------------------
    
;--------------------------------------------------------------
Backspace
    movlw DISP_FIRST
    subwf DispWritePointer, W
    btfsc STATUS, Z
    return
    
    decf DispWritePointer, F
       
    return
;--------------------------------------------------------------

;--------------------------------------------------------------
Clear
    movlw DISP_FIRST
    movwf FSR
    
RegClrf: 
    movlw 0xFF
    movwf INDF
    
    incf FSR, F
    
    movlw DISP_LAST
    subwf FSR, W
    btfss STATUS, C
    goto RegClrf
    
    movlw DISP_FIRST
    movwf DispWritePointer
    
    return
;--------------------------------------------------------------

;--------------------------------------------------------------
PutBuffer
    movwf Data_Temp
    
    movlw RX_LAST
    subwf BufferPointer, W
    btfsc STATUS, Z
    goto Full
    goto Add
    
Full:
    movlw RX_FIRST
    movwf BufferPointer

Add:
    movf BufferPointer, W
    movwf FSR
    
    movf  Data_Temp, W
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
    
    movlw RX_FIRST
    subwf BufferPointer, W
    btfsc STATUS, Z
    bsf BufferFlag, 0

    movf INDF, W
    
    return
;--------------------------------------------------------------

;--------------------------------------------------------------
DecodeDisplay addwf PCL, F 
    retlw 0x00 ;clear
    retlw 0x40 ;0
    retlw 0xFF ;backspace
    retlw 0x21 ;d
    retlw 0xF8 ;7
    retlw 0x80 ;8
    retlw 0x98 ;9
    retlw 0xC6 ;C
    retlw 0x99 ;4
    retlw 0x92 ;5
    retlw 0x82 ;6
    retlw 0x83 ;b
    retlw 0xF9 ;1
    retlw 0x24 ;2
    retlw 0x30 ;3
    retlw 0x88 ;A
;--------------------------------------------------------------
    
END