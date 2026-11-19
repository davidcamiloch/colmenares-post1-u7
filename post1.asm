; post1.asm - INT 21h: salida de texto basica
; Compilar: nasm -f bin post1.asm -o post1.com
; Ejecutar: post1.com
ORG 100h
section .data
  msg1  db "Arquitectura de Computadores", 0Dh, 0Ah, "$"
  msg2  db "Unidad 7: Pantalla y Teclado", 0Dh, 0Ah, "$"
  msg3  db "Laboratorio POST-1", 0Dh, 0Ah, "$"
section .text
start:
  mov ah, 09h        ; INT 21h/09h: imprimir cadena terminada en "$"
  mov dx, msg1
  int 21h
  mov ah, 09h        ; se recarga AH: DOS puede devolver AL modificado
  mov dx, msg2
  int 21h
  mov ah, 09h
  mov dx, msg3
  int 21h
  mov ah, 4Ch        ; terminar con codigo 0
  xor al, al
  int 21h
