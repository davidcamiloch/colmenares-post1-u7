; post1c.asm - Cadena en posicion exacta con color
; Compilar: nasm -f bin post1c.asm -o post1c.com
ORG 100h
section .data
  titulo  db "UNIDAD 7 - PANTALLA Y TECLADO", "$"
  filaT   equ 5
  colT    equ 25          ; (80 - 29) / 2 = 25: titulo centrado
section .text
start:
  ; Limpiar pantalla
  mov ah, 06h
  xor al, al
  xor cx, cx
  mov dx, 184Fh
  mov bh, 07h
  int 10h
  ; Dibujar el titulo caracter a caracter
  mov si, titulo     ; SI apunta al inicio de la cadena
  mov dl, colT       ; columna inicial
  mov dh, filaT      ; fila fija
.bucle:
  mov al, [si]       ; siguiente caracter
  cmp al, "$"        ; fin de cadena
  je  .fin
  mov ah, 02h        ; posicionar cursor en DH, DL
  xor bh, bh
  int 10h
  mov ah, 09h        ; escribir AL con atributo verde claro (0Ah)
  xor bh, bh
  mov bl, 0Ah
  mov cx, 1
  int 10h
  inc si             ; siguiente caracter
  inc dl             ; siguiente columna
  jmp .bucle
.fin:
  mov ah, 07h
  int 21h
  mov ah, 4Ch
  xor al, al
  int 21h
