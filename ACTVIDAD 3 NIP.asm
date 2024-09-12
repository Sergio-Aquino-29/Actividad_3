;Gonzalez Aquino Serigio
; Actividad 3 NIP de seguridad
;Microprocesadores


.org 0000h
    ld a,89h          ; Configuración de puertos
    out (CW),a        ; Escribir en el puerto de control
    ld SP,27ffh       ; Inicializar el puntero de pila

    ld hl,text1       ; Mostrar el mensaje "Ingrese clave"
    call disp_text
    call solicitar_clave

halt_loop:
    halt              ; Detener el sistema si se bloquea
    jp halt_loop      ; Ciclo infinito si se bloquea

; Subrutinas

; Solicitar clave de 4 dígitos
solicitar_clave:
    ld b,3            ; Contador de intentos (3 intentos permitidos)

intento_nuevo:
    ld hl,passw       ; Apuntar a donde se almacenará la clave
    ld c,4            ; Contador de 4 dígitos

read_digit:
    in a,(KEYB)       ; Leer un dígito del teclado
    cp 30h            ; Comprobar si es menor que '0' (30h)
    jp c,error_input
    cp 3Ah            ; Comprobar si es mayor que '9' (39h + 1)
    jp nc,error_input

    ld (hl),a         ; Guardar el dígito válido
    ld a,'*'          ; Mostrar un asterisco en la pantalla
    out (LCD),a       ; Escribir el asterisco en la pantalla LCD
    inc hl            ; Mover al siguiente espacio para el próximo dígito
    dec c             ; Disminuir el contador de dígitos
    jp nz,read_digit  ; Si faltan dígitos, continuar leyendo

    ; Verificar clave
    ld hl,passw       ; Apuntar al primer dígito ingresado
    ld de,pattern     ; Apuntar a la clave patrón
    call verificar_clave
    jp z,clave_correcta  ; Si las claves coinciden, saltar a clave_correcta

    ; Clave incorrecta
    ld hl,text_incorrecta
    call disp_text
    dec b              ; Disminuir intentos
    jp nz,intento_nuevo  ; Intentar de nuevo si no se han acabado los intentos

    ; Bloquear el sistema
    ld hl,text_bloqueado
    call disp_text
    jp halt_loop

; Mostrar mensaje de clave correcta
clave_correcta:
    ld hl,text_correcta
    call disp_text
    ret

; Manejo de entrada no válida
error_input:
    ld hl,text_error
    call disp_text
    jp solicitar_clave

; Verificar si la clave es correcta
verificar_clave:
    ld c,4            ; Comparar 4 dígitos
ver_loop:
    ld a,(hl)         ; Cargar dígito de la clave ingresada
    ld e,a            ; Cargar dígito en E
    ld a,(de)         ; Cargar dígito de la clave patrón
    cp e              ; Comparar los valores
    jp nz,verificar_fail ; Si no coinciden, salir con error
    inc hl
    inc de
    dec c
    jp nz,ver_loop    ; Si faltan dígitos, continuar verificando
    ret               ; Retornar con éxito

verificar_fail:
    ret               ; Retornar con error

; Subrutina para mostrar un texto en la pantalla
disp_text:
repeat1:
    ld a,(hl)
    cp "&"
    jp z,end_sub1
    out (LCD),a
    inc hl
    jp repeat1
end_sub1:
    ret

; Datos
.org 2000h
text1:          .db "Ingrese clave: &"
text_error:     .db "Error: Solo se permiten numeros&"
text_correcta:  .db "Clave correcta, acceso concedido&"
text_incorrecta:.db "Clave incorrecta, intente de nuevo&"
text_bloqueado: .db "Acceso bloqueado. No puede ingresar mas claves&"
pattern:        .db "1234"
passw:          .db 00h,00h,00h,00h  ; Espacio para los 4 dígitos ingresados

; Constantes
LCD:    .equ 00h
KEYB:   .equ 01h
CW:     .equ 03h

.end