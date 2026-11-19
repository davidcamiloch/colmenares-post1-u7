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

## Parte 1: INT 21h e INT 10h

| Programa | Servicio | Qué hace |
|----------|----------|----------|
| `post1.asm` | INT 21h/09h y 4Ch | Imprime tres cadenas terminadas en `$` y termina con código 0 |
| `post1b.asm` | INT 10h/06h, 02h y 09h | Limpia la pantalla; escribe "A" con atributo 1Eh en la fila 2 y "U7" con 0Ch en la fila 3 |
| `post1c.asm` | INT 10h/02h y 09h en bucle | Dibuja "UNIDAD 7 - PANTALLA Y TECLADO" en la fila 5 desde la columna 25 con atributo 0Ah |
| `post1d.asm` | INT 10h/0Fh y 08h | Comprueba que el modo activo es 03h; escribe "Z" con 2Fh en la fila 8, columna 10 y relee la celda |

El byte de atributo reparte sus 8 bits en fondo (bits 7-4) y texto (bits 3-0). 1Eh es 0001 1110b: fondo azul (1h) y texto amarillo (Eh). 2Fh es 0010 1111b: fondo verde (2h) y texto blanco brillante (Fh). INT 10h/09h escribe el carácter y su atributo en la posición del cursor pero no lo avanza; por eso `post1b.asm` reposiciona el cursor antes del "7" y `post1c.asm` incrementa DL en cada vuelta. El título de `post1c.asm` mide 29 caracteres y queda centrado porque (80 − 29) / 2 ≈ 25.

### Desviaciones respecto a la guía

- `post1d.asm`: la guía guardaba el modo de video en DL y la instrucción siguiente, `mov dx, msgModo`, lo sobrescribía antes de `cmp dl, 03h`. La comparación usaba el byte bajo de la dirección del mensaje y el programa siempre informaba un modo inesperado. El modo ahora se guarda en CL, que INT 21h/09h no modifica, y el mensaje muestra el valor 03h.
- `post1.asm`: AH se recarga con 09h antes de cada llamada. INT 21h/09h devuelve AL = 24h en MS-DOS, de modo que no conviene suponer que AX queda intacto entre llamadas.

### Decisión técnica 1: INT 21h o INT 10h para la salida de texto

INT 21h/09h es la opción correcta cuando el texto no necesita color ni posición fija. `post1.asm` imprime su encabezado con una sola llamada por cadena: DS:DX apunta al texto, DOS lo recorre hasta el `$`, avanza el cursor, interpreta 0Dh y 0Ah y respeta la redirección de la salida estándar. Programar lo mismo con INT 10h, como hace `post1c.asm`, exige un bucle que carga cada carácter, compara con el terminador, posiciona el cursor con AH=02h, escribe con AH=09h e incrementa SI y DL; son seis instrucciones y dos interrupciones por carácter frente a una sola llamada para toda la cadena. INT 10h se vuelve obligatoria cuando el resultado depende del atributo o de la celda exacta: la "A" amarilla sobre azul de `post1b.asm`, el título verde centrado de `post1c.asm` y la "Z" con atributo 2Fh que `post1d.asm` debe releer. INT 21h/09h no admite atributo, así que ninguno de esos tres resultados es posible con ella. Por la misma razón solo la ruta INT 10h depende del modo de video: el atributo tiene sentido únicamente en un modo de texto con color, y por eso `post1d.asm` lo verifica con AH=0Fh. INT 21h escribe caracteres sin atributo y funciona igual en cualquier modo. La regla es usar INT 21h para texto plano e INT 10h cuando importan el color o la posición.

### Decisión técnica 2: verificar el modo y releer la celda

`post1b.asm` y `post1c.asm` asumen que la pantalla está en modo 03h. Si un programa anterior la dejó en modo gráfico 13h, el mismo byte de atributo se interpreta como índice de paleta y el carácter se dibuja con la fuente gráfica del BIOS en otra posición; en un modo monocromo 07h los colores se convierten en subrayado o vídeo inverso. El programa no recibe ningún error, simplemente produce otra pantalla. INT 10h/0Fh devuelve en AL el modo activo, en AH las columnas y en BH la página, así que `post1d.asm` puede comprobar la suposición en lugar de codificarla. Releer la celda con AH=08h confirma que el carácter y el atributo que quedaron en la página son los que se escribieron. En un editor de pantalla esa comprobación detecta que otro proceso, por ejemplo un TSR con ventana emergente, modificó la celda, y evita guardar o mostrar un estado que ya no coincide con el buffer interno. AH=08h y la lectura directa de B800h de la Parte 2 se complementan. El BIOS conoce el modo y la página activa y devuelve el par correcto sin que el programa calcule segmento ni desplazamiento; el acceso directo es mucho más rápido pero exige saber de antemano que el modo es texto 80×25 y que cada celda ocupa 2 bytes. La regla es verificar con el BIOS lo que se asume y usar B800h solo cuando el modo está confirmado.

