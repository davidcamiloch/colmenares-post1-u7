; post2c.asm - Limpiar pantalla con REP STOSW en B800h
; Compilar: nasm -f bin post2c.asm -o post2c.com
ORG 100h
section .text
start:
  mov ax, 0B800h
  mov es, ax
  mov ax, 1720h      ; AH = 17h (fondo azul, texto gris), AL = 20h (espacio)
  xor di, di         ; offset 0: esquina superior izquierda
  mov cx, 2000       ; 80 x 25 = 2 000 celdas
  cld                ; DF = 0: DI avanza
  rep stosw          ; ES:DI = AX; DI += 2; CX -= 1 hasta CX = 0
  ; Mensaje en fila 12, columna 30: (12*80 + 30) * 2 = 1980
  mov di, 1980
  mov si, titulo
.bucle:
  lodsb              ; AL = [DS:SI]; SI += 1
  or al, al          ; fin de cadena (byte 0)
  jz  .fin
  mov ah, 1Fh        ; blanco brillante sobre el mismo fondo azul
  stosw
  jmp .bucle
.fin:
  mov ah, 07h
  int 21h
  mov ah, 4Ch
  xor al, al
  int 21h
titulo: db "HOLA DESDE B800h", 0
