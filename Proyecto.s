; Definici�n de registros. Estos son mandados en el modulo de red
.equ GPIO_BASE, 0x20000000      ; Direcci�n base del registro GPIO
.equ GPIO_SET_OFFSET, 0x04      ; Final del registro GPIO 

.equ SENSOR_BASE, 0x00      ; Direcci�n base del registro de Sensores
.equ SENSOR_SET_OFFSET, 0x82      ; Final del registro Sensores 

.data
piso:    .word 3      ; Variable para almacenar el piso disponible
num_piso:     .word 43      ; Variable para almacenar el n�mero de estacionamiento disponible
num_total:     .word 129      ; Variable para almacenar el n�mero de estacionamiento disponible

.text
.global _start

_start:
    ; Configurar los pines de los sensores como entradas y el GPIO como salida
    ldr r0, =GPIO_BASE
	ldr r1, =SENSOR_BASE
	mov r2, #0 ; flag de enviar datos por medio de GPIO_BASE y salir del loop;
	;r3 para calculos
	mov r4, #129       ; N�mero total de estacionamientos
    mov r5, #0         ; Contador de iteraciones
    mov r6, #0         ; N�mero de estacionamiento
    mov r7, #0         ; Piso

loop:;---Falta Agregar salida del loop---
    ; Leer el estado de los sensores
	add r1, r1, #1; Desplazar al siguiente sensor
    ldr r3, r1; Cargar valor de sensor
	b check_sensors
	add r4, r4, #1;
	b loop

check_sensors:
    tst r3, #1         ; Verificar el bit menos significativo (Sensor de estacionamiento actual)
    beq sensor_no_ocupado       ; Saltar si el bit es 0 (espacio no ocupado)
	b loop ;Si no volver al loop

sensor_no_ocupado:
    ; Calcular el piso y el n�mero de estacionamiento
    ldr r3, =43       ; N�mero de estacionamientos por piso, udiv no puede usar inmediato
    udiv r7, r5, r3   ; C�lculo del piso (usando divisi�n entera)
    add r6, r5, r7      ; N�mero de estacionamiento (comienza desde 0)

	mov r2,#1; Mandar datos y flag para detener loops
	b Send_byte_UART;

Send_byte_UART:	;---cargar a GPIO los datos(Piso y numero)---
	b loop
