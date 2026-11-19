; post2d.asm - Mini editor: INT 16h + B800h
; Compilar: nasm -f bin post2d.asm -o post2d.com
; Correccion respecto a la guia: el caracter se guarda en CL justo despues de INT 16h.
; La guia volvia a llamar INT 16h para recuperarlo, lo que obligaba a pulsar cada
; tecla dos veces; ademas el offset se calcula con instrucciones del 8086.
ORG 100h
fila     equ 12          ; fila fija de edicion
col_ini  equ 0           ; columna inicial
atributo equ 0Fh         ; blanco brillante sobre negro
section .text
start:
  mov ax, 0B800h
  mov es, ax
  mov dl, col_ini        ; DL = columna actual
.leer:
  mov ah, 00h
  int 16h                ; AH = scan code, AL = ASCII
  cmp al, 0Dh            ; Enter termina
  je  .fin
  or  al, al
  jz  .leer              ; tecla extendida: se ignora
  mov cl, al             ; guardar el caracter antes de usar AX
  ; offset = (fila * 80 + columna) * 2
  mov ax, fila * 80      ; constante resuelta por el ensamblador: 960
  xor bh, bh
  mov bl, dl
  add ax, bx
  shl ax, 1
  mov di, ax
  mov byte [es:di],   cl
  mov byte [es:di+1], atributo
  inc dl
  cmp dl, 80
  jb  .leer
  mov dl, col_ini        ; volver al inicio al llegar al borde
  jmp .leer
.fin:
  mov ah, 4Ch
  xor al, al
  int 21h
