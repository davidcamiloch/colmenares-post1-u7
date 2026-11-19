; post2e.asm - INT 16h/AH=02h: estado de Shift/Ctrl reflejado en B800h
; Compilar: nasm -f bin post2e.asm -o post2e.com
ORG 100h
section .data
  etiqSh  db "SHIFT:"
  etiqCt  db "CTRL:"
section .text
start:
  mov ax, 0B800h
  mov es, ax
  cld
  ; Etiquetas fijas en la fila 0
  xor di, di             ; columna 0
  mov si, etiqSh
  mov cx, 6              ; "SHIFT:" ocupa las columnas 0-5
.etq1:
  lodsb
  mov ah, 0Fh
  stosw
  loop .etq1
  mov si, etiqCt
  mov di, 16             ; columna 8: (0*80 + 8) * 2 = 16
  mov cx, 5              ; "CTRL:" ocupa las columnas 8-12
.etq2:
  lodsb
  mov ah, 0Fh
  stosw
  loop .etq2
.bucle:
  mov ah, 02h            ; byte de estado de 0040h:0017h, no bloqueante
  int 16h
  mov bl, al
  ; Bits 0-1: Shift derecho o izquierdo
  mov cl, "0"
  test bl, 03h
  jz  .shift_listo
  mov cl, "1"
.shift_listo:
  mov di, 12             ; columna 6: (0*80 + 6) * 2 = 12
  mov byte [es:di],   cl
  mov byte [es:di+1], 0Ah
  ; Bit 2: Ctrl
  mov cl, "0"
  test bl, 04h
  jz  .ctrl_listo
  mov cl, "1"
.ctrl_listo:
  mov di, 26             ; columna 13: (0*80 + 13) * 2 = 26
  mov byte [es:di],   cl
  mov byte [es:di+1], 0Ch
  mov ah, 01h            ; hay tecla en el buffer?
  int 16h
  jz  .bucle             ; ZF = 1: no hay tecla
  mov ah, 00h            ; consumir la tecla
  int 16h
  cmp ah, 01h            ; Escape
  jne .bucle
  mov ah, 4Ch
  xor al, al
  int 21h
