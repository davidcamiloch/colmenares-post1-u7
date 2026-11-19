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

## Parte 2: INT 16h y acceso directo a B800h

| Programa | Servicio | Qué hace |
|----------|----------|----------|
| `post2a.asm` | INT 16h/00h | Muestra el scan code y el ASCII de cada tecla en hexadecimal hasta pulsar Esc (scan 01h); las teclas extendidas devuelven ASCII 00 |
| `post2b.asm` | Escritura en B800h | Escribe H, O, L y A en las filas 10 a 13, columna 35, cada una con su atributo |
| `post2c.asm` | `REP STOSW` | Rellena las 2 000 celdas con 1720h y escribe "HOLA DESDE B800h" en la fila 12 |
| `post2d.asm` | INT 16h/00h + B800h | Editor de una línea en la fila 12; Enter termina |
| `post2e.asm` | INT 16h/02h y 01h + B800h | Refleja en la fila 0 el estado de Shift y Ctrl sin bloquearse; Esc termina |

En modo texto 80×25 cada celda ocupa 2 bytes en el segmento B800h: el carácter en el desplazamiento par y el atributo en el impar. El desplazamiento de una celda es (fila × 80 + columna) × 2. Para la fila 10 y la columna 35 da (800 + 35) × 2 = 1 670, que es el valor que `post2b.asm` carga en DI. La pantalla completa ocupa 80 × 25 × 2 = 4 000 bytes, por eso `post2c.asm` repite `STOSW` 2 000 veces con AX = 1720h: AL = 20h es el espacio y AH = 17h es fondo azul con texto gris.

### Desviaciones respecto a la guía

- `post2d.asm`: la guía volvía a llamar INT 16h después de calcular el desplazamiento para recuperar el carácter que `mov ax, fila` había destruido. El editor exigía pulsar cada tecla dos veces y escribía solo la segunda. El carácter ahora se guarda en CL inmediatamente; el desplazamiento se calcula con instrucciones del 8086 y `fila * 80` lo resuelve el ensamblador.
- `post2c.asm`: el mensaje usa el atributo 1Fh en lugar de 0Fh. Con 0Fh el texto quedaba sobre fondo negro y el checkpoint pide blanco brillante sobre azul.
- `post2a.asm` y `post2e.asm`: `nibbleToChar` compara sin signo (`jbe`) y `post2e.asm` usa `TEST` en lugar de `AND` seguido de `OR`; el resultado es el mismo con menos instrucciones.

### Decisión técnica 3: INT 16h bloqueante o puerto 60h

AH=00h no sirve dentro del bucle de `post2e.asm`. Esa función espera a que haya una tecla en el buffer; mientras el usuario solo mantiene Shift o Ctrl no entra ningún carácter, el bucle queda detenido en la interrupción y los dígitos de la fila 0 dejan de actualizarse. AH=02h devuelve al instante el byte de estado de 0040h:0017h y AH=01h solo consulta si hay tecla, así que el bucle sigue girando. Leer el puerto 60h del 8042 con `IN AL, 60h` sería más rápido y daría control total: el programa vería cada make code y cada break code en el momento en que el controlador los entrega, sin pasar por la interrupción del BIOS. El precio es alto. El programa debe instalar su propio manejador de IRQ1, enviar el EOI al 8259 por el puerto 20h, distinguir make de break por el bit 7, seguir los prefijos E0h de las teclas extendidas y traducir el scan code al carácter según la distribución del teclado. INT 16h ya resuelve todo eso y deja el buffer listo. Para un laboratorio de aplicaciones en DOSBox, INT 16h es la opción adecuada porque el BIOS existe y es confiable. El acceso al puerto 60h se vuelve necesario en un sistema operativo propio o en un controlador de teclado, donde no hay BIOS que haga ese trabajo. La regla es usar el BIOS mientras exista y bajar al puerto solo cuando no hay intermediario.

### Decisión técnica 4: byte de estado de AH=02h o seguimiento manual

AH=02h es más simple y más correcto que llevar la cuenta de los make y break codes. El manejador de INT 09h del BIOS actualiza el byte de 0040h:0017h en cada interrupción de teclado, incluso cuando el programa está ocupado en otra cosa; `post2e.asm` solo lo lee y prueba dos bits. El seguimiento manual exigiría capturar 2Ah y AAh para Shift izquierdo, 36h y B6h para el derecho, 1Dh y 9Dh para Ctrl, mantener variables propias y además no perder ningún evento. Ese es el error típico. Si el programa no consulta el buffer con suficiente frecuencia, o si el código de liberación nunca llega como tecla al buffer, la variable queda en "presionado" y el modificador se queda atascado hasta la siguiente pulsación; el byte del BIOS no sufre ese problema porque se recalcula en la propia interrupción. AH=02h también distingue los dos Shift: el bit 0 corresponde al derecho y el bit 1 al izquierdo, así que basta probar `test bl, 01h` o `test bl, 02h`. Interceptar los scan codes crudos solo compensa cuando se necesitan los eventos de transición, el instante exacto de presionar o soltar, por ejemplo para medir cuánto tiempo se mantuvo una tecla; el byte de estado solo informa el estado actual. La regla es leer el estado con AH=02h y capturar scan codes solo cuando importa el momento del cambio.

## Capturas

| Captura | Contenido |
|---------|-----------|
| `capturas/p1-cp1-compilacion.png` y `p1-cp1-post1.png` | Ensamblado y salida de `post1.com` |
| `capturas/p1-cp2-post1b.png` | "A" amarilla sobre azul y "U7" en rojo claro |
| `capturas/p1-cp3-post1c.png` | Título verde en la fila 5 |
| `capturas/p1-cp4-post1d.png` | Modo 03h confirmado y relectura correcta |
| `capturas/p2-cp1-post2a.png` | Scan codes de letras, flechas y F1 |
| `capturas/p2-cp2-post2b.png` | HOLA en cuatro colores |
| `capturas/p2-cp3-post2c.png` | Pantalla azul con el mensaje |
| `capturas/p2-cp4-post2d.png` | Texto tecleado en la fila 12 |
| `capturas/p2-cp5-post2e.png` | SHIFT:1 y CTRL:1 mientras se mantienen pulsadas |

## Referencias

- NASM Development Team. (s.f.). *NASM — The Netwide Assembler: documentación*. https://www.nasm.us/doc/
- INT 10H. (s.f.). En *Wikipedia*. https://en.wikipedia.org/wiki/INT_10H
- BIOS interrupt call. (s.f.). En *Wikipedia*. https://en.wikipedia.org/wiki/BIOS_interrupt_call
