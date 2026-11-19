; post1b.asm - INT 10h: cursor y color
; Compilar: nasm -f bin post1b.asm -o post1b.com
ORG 100h
section .text
start:
  ; Limpiar pantalla con scroll (INT 10h/06h)
  mov ah, 06h        ; scroll hacia arriba
  xor al, al         ; 0 = limpiar toda la ventana
  xor cx, cx         ; esquina superior izquierda: fila 0, columna 0
  mov dx, 184Fh      ; esquina inferior derecha: fila 24, columna 79
  mov bh, 07h        ; relleno blanco sobre negro
  int 10h
  ; Cursor en fila 2, columna 10
  mov ah, 02h
  xor bh, bh         ; pagina 0
  mov dh, 02h
  mov dl, 0Ah
  int 10h
  ; "A" amarillo (Eh) sobre azul (1h) = 1Eh
  mov ah, 09h
  mov al, "A"
  xor bh, bh
  mov bl, 1Eh
  mov cx, 1
  int 10h
  ; Cursor en fila 3, columna 10
  mov ah, 02h
  xor bh, bh
  mov dh, 03h
  mov dl, 0Ah
  int 10h
  ; "U" rojo claro (Ch) sobre negro = 0Ch
  mov ah, 09h
  mov al, "U"
  xor bh, bh
  mov bl, 0Ch
  mov cx, 1
  int 10h
  ; AH=09h no avanza el cursor: se mueve a la columna 11
  mov ah, 02h
  xor bh, bh
  mov dh, 03h
  mov dl, 0Bh
  int 10h
  mov ah, 09h
  mov al, "7"
  xor bh, bh
  mov bl, 0Ch
  mov cx, 1
  int 10h
  ; Esperar tecla y salir
  mov ah, 07h
  int 21h
  mov ah, 4Ch
  xor al, al
  int 21h
