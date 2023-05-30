	AREA RESET, DATA, READONLY
		EXPORT __Vectors

__Vectors
	DCD 0x20001000 ; stack pointer value when stack is empty
	DCD Reset_Handler ; reset vector
	ALIGN
		
	AREA FSM, CODE, READONLY
	
	ENTRY
	EXPORT Reset_Handler	
		
Reset_Handler

	; Definición de registros. Estos son mandados en el modulo de red
	.equ GPIO_BASE, 0x20000000      ; Dirección base del registro GPIO
	.equ GPIO_SET_OFFSET, 0x04      ; Final del registro GPIO 

	.equ SENSOR_BASE, 0x00      ; Dirección base del registro de Sensores
	.equ SENSOR_SET_OFFSET, 0x82      ; Final del registro Sensores 
	
	.data
	piso:    .word 3      ; Variable para almacenar el piso disponible
	num_piso:     .word 43      ; Variable para almacenar el número de estacionamiento disponible
	num_total:     .word 129      ; Variable para almacenar el número de estacionamiento disponible

	.text

_start
    ; Configurar los pines de los sensores como entradas y el GPIO como salida
    ldr r0, =GPIO_BASE
	ldr r1, =SENSOR_BASE
	mov r2, #0 ; flag de enviar datos por medio de GPIO_BASE y salir del loop;
	;r3 para calculos
	mov r4, #129       ; Número total de estacionamientos
    mov r5, #0         ; Contador de iteraciones
    mov r6, #0         ; Número de estacionamiento
    mov r7, #0         ; Piso
    ; falta registro de flag para comenzar a buscar
    ldr r8, =
    B preeloop
preloop
	CMP R8, #1
	BEQ loop
	BNE preloop

loop 
    ; Leer el estado de los sensores
	add r1, r1, #1; Desplazar al siguiente sensor
    	ldr r3, r1; Cargar valor de sensor
	BL check_sensors
	add r5, r5, #1;
	CMP r5, #129
	BNE loop
	BEQ sensor_no_ocupado

check_sensors
    tst r3, #1         		; Verificar el bit menos significativo (Sensor de estacionamiento actual)
    beq sensor_no_ocupado       ; Saltar si el bit es 0 (espacio no ocupado)
    BX LR 			;Si no volver al loop

sensor_no_ocupado
    	; Calcular el piso y el número de estacionamiento
    	ldr r3, =43       	; Número de estacionamientos por piso, udiv no puede usar inmediato
    	udiv r7, r5, r3   	; Cálculo del piso (usando división entera)
    	sub r6, r5, r7      ; Número de estacionamiento (comienza desde 0)
	mult r3, r6, r3 ; 
	
	mov r2,#1; Mandar datos y flag para detener loops
	b Send_byte_UART;

Send_byte_UART:	;---cargar a GPIO los datos(Piso y numero)---
	STR r7, [r0, #1] ; carga el piso
	STR r6, [r0, #1] ; carga el número de estacionamiento
	b start
