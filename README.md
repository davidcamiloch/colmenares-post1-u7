# colmenares-post1-u7

Laboratorio del Post-contenido de la Unidad 7 (Manejo de Pantalla y Teclado) de Arquitectura de Computadores, UFPS. Autor: David Camilo Colmenares Hernández.

La Parte 1 trabaja la salida de texto con INT 21h y el control de pantalla con INT 10h. La Parte 2 lee el teclado con INT 16h y escribe directamente en la memoria de video B800h. Todos los programas son .COM de NASM y se ejecutan en DOSBox.

## Entorno

- DOSBox 0.74-3 con la carpeta del laboratorio montada como C:.
- NASM 3.02 para DOS con CWSDPMI como servidor DPMI (`cwsdpmi -p` antes de ensamblar).

```
C:\> nasm -f bin post1.asm -o post1.com
C:\> post1.com
```

