; post2b.asm - Escritura directa en B800h
; Compilar: nasm -f bin post2b.asm -o post2b.com
ORG 100h
section .text
start:
  mov ax, 0B800h     ; ES = segmento de video en modo texto
  mov es, ax
  ; fila 10, col 35: (10*80 + 35) * 2 = 1670
  mov di, 1670
  mov byte [es:di],   48h  ; "H"
  mov byte [es:di+1], 0Fh  ; blanco brillante sobre negro
  ; fila 11, col 35: (11*80 + 35) * 2 = 1830
  mov di, 1830
  mov byte [es:di],   4Fh  ; "O"
  mov byte [es:di+1], 0Eh  ; amarillo sobre negro
  ; fila 12, col 35: (12*80 + 35) * 2 = 1990
  mov di, 1990
  mov byte [es:di],   4Ch  ; "L"
  mov byte [es:di+1], 0Ah  ; verde claro sobre negro
  ; fila 13, col 35: (13*80 + 35) * 2 = 2150
  mov di, 2150
  mov byte [es:di],   41h  ; "A"
  mov byte [es:di+1], 0Ch  ; rojo claro sobre negro
  mov ah, 07h        ; esperar tecla y salir
  int 21h
  mov ah, 4Ch
  xor al, al
  int 21h
