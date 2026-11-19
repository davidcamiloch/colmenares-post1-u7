; post2a.asm - INT 16h: leer scan codes
; Compilar: nasm -f bin post2a.asm -o post2a.com
ORG 100h
section .data
  prompt   db "Pulse una tecla (ESC para salir): ", 0Dh, 0Ah, "$"
  msgScan  db "  Scan: $"
  msgAscii db "  ASCII: $"
  crlf     db 0Dh, 0Ah, "$"
section .text
start:
  mov ah, 09h
  mov dx, prompt
  int 21h
.leer:
  mov ah, 00h        ; esperar tecla
  int 16h            ; AH = scan code, AL = ASCII
  mov bl, ah         ; scan code en BL
  mov bh, al         ; ASCII en BH
  cmp bl, 01h        ; Escape
  je  .fin
  mov ah, 09h
  mov dx, msgScan
  int 21h
  mov al, bl
  call impHex
  mov ah, 09h
  mov dx, msgAscii
  int 21h
  mov al, bh
  call impHex
  mov ah, 09h
  mov dx, crlf
  int 21h
  jmp .leer
.fin:
  mov ah, 4Ch
  xor al, al
  int 21h

; Subrutina: imprime AL como 2 digitos hexadecimales con INT 21h/02h
impHex:
  push ax
  shr al, 4          ; nibble alto
  call nibbleToChar
  mov dl, al
  mov ah, 02h
  int 21h
  pop ax
  and al, 0Fh        ; nibble bajo
  call nibbleToChar
  mov dl, al
  mov ah, 02h
  int 21h
  ret

nibbleToChar:
  cmp al, 9
  jbe .digito
  add al, 37h        ; A-F: 0Ah + 37h = 41h ("A")
  ret
.digito:
  add al, 30h        ; 0-9
  ret
