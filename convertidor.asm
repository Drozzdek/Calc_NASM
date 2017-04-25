
 %include "io.mac"
 
.DATA
	prueba times 8 db 0

.CODE
imprimirAxBases:
;Imprime a la salida estándar un número que supone que estar en el ax. Recibe la base en la que quiere desplegarlo en el bx. Supone que es un número positivo y natural en 16 bits
    push ax;primero preserva los registros metiéndolos a la pila
    push bx
    push cx
    push dx

    xor cx, cx;limpia el cx
conseguirDigitos:
	xor dx, dx;limpia el dx
    div bx ;divide entre lo que esté en el bx, que es la base que entró como parámetro
    push dx;ahora guarda el dígito en la pila, esto para darle la vuelta
    inc cx ;incrementa la cantidad de dígitos guardados en 1, esto es para saber cuántos dígitos imprimir
    cmp ax, 0;averigua si hay que conseguir más dígitos
    jne conseguirDigitos ;hay que conseguir más dígitos

imprimirDigitos:
	pop dx;saca el dígito más significativo hacia los menos significativos de la pila
    cmp dl, 9;compara lo que retira con un 9
    ja letra ;si es mayor, significa que es una letra, por lo que hay que convertirla a letra
    add dl, 30h ;no es una letra, por lo que hay que imprimir un número, para esto tiene que convertir el número en un caracter
    jmp imprime ;salta a imprimir
letra:
	add dl, 37h ;agrega lo necesario para que el número sea una letra
imprime:
	PutCh dl
    loop imprimirDigitos ;mientras falte un dígito por imprimir
	jmp comparaciones

imprimirBinario:
	mov dl, 'b'
	int 21h
	jmp salidaImprimirAXBases

imprimirOctal:
	mov dl, 'o'
	int 21h
	jmp salidaImprimirAXBases

imprimirHexadecimal:
	mov dl, 'h'
	int 21h
	jmp salidaImprimirAXBases

comparaciones:
	cmp bx, 2
	je imprimirBinario
	cmp bx, 8
	je imprimirOctal
	cmp bx, 16
	je imprimirHexadecimal

salidaImprimirAXBases:
    pop dx;ahora restaura los registros antes de salir
    pop cx
    pop bx
    pop ax
    ret ;regresa
	
convertidor:
	;este proc revisa un string cuya dirección estará en el bx y estará delimitado por los registros de índice si y di, donde el si dice el inicio del string y el di el final
	;Lo que hará será que leerá el string de derecha a izquierda y lo dejará como un byte en "decimal" en el ax
	push ebx;preservo los registros en la pila
	push ecx
	push edx
	push esi
	push edi
	;el ax no lo inserto ahora mismo dado que no necesito restaurarlo luego de la llamada

	xor ecx,ecx;aquí limpio el cx para que reinicio el conteo de dígitos
	xor eax,eax;aquí limpio el ax para que limpie lo que sea que haya estado en el ax
	push ax;ahora sí lo inserto, dado que necesito tener el valor actual del número metido en el tope de la pila

	mov al, byte [edi];muevo el supuesto último character del string al "al" para poder compararlo con una de las posibles bases
	cbw;esto es para que complete el ax con el signo del número, o sea con 0's si es positivo o 1's si es negativo
	cmp ax, 58;esto es para averiguar si el string está supuestamente en decimal o en cualquier otra base
	jb decimal;significa que lo que leyó es un número, lo que significa que no tenía identificador de base, lo que indica que está en decimal, lo que hace que no requiera conversión
	cmp ax, 62h;averigua si está en binario
	je binario;significa que leyó una 'b' expresando que está en binario
	cmp ax, 6Fh;averigua si está en octal
	je octal;significa que leyó una 'o' expresando que está en octal
	cmp ax, 68h;averigua si está en hexadecimal
	je hexadecimal;significa que leyó una 'h' expresando que está en hexadecimal
	jmp errorDetectado

decimal:
	;significa que el valor está representado en la base decimal
	mov dx, 10;muevo el 10 al dx para que sepa en qué base debe convertir
	jmp cicloConvertidor;esto es para que vaya al ciclo en donde se convertirá el número

binario:
	;significa que el valor está representado en la base binaria
	mov dx, 2;muevo el 2 al dx para que sepa en qué base debe convertir
	dec di;esto es para que el final del string esté en el último dígito, y que no intente convertir la letra
	jmp cicloConvertidor;esto es para que vaya al ciclo en donde se convertirá el número

octal:
	;significa que el valor está representado en la base octal
	mov dx, 8;muevo el 8 al dx para que sepa en qué base debe convertir
	dec di;esto es para que el final del string esté en el último dígito, y que no intente convertir la letra
	jmp cicloConvertidor;esto es para que vaya al ciclo en donde se convertirá el número

hexadecimal:
	;significa que el valor está representado en la base hexadecimal
	mov dx, 16;muevo el 16 al dx para que sepa en qué base debe convertir
	dec di;esto es para que el final del string esté en el último dígito, y que no intente convertir la letra
	jmp cicloConvertidor;esto es para que vaya al ciclo en donde se convertirá el número

cicloConvertidor:;en este ciclo agarro todos los dígitos desde el menos significativo y lo convierto a la base que supuestamente estará en el dx
	;primero que todo debo tener listo la base elevada a la cantidad de dígitos actual
	call potenciador;este proc agarrará la base en la que está el número dejada en el dx y la elevará a la cantidad de dígitos que estará en el dx, al iniciar está en 0, y se incrementa al final del ciclo
	cmp byte [edi],58;averigua si es una letra
	ja convertirLetra
	sub byte [edi],48;convierte el dígito a número
	jmp multiplicacionCicloConvertidor

convertirLetra:
	sub byte [edi],37h
	jmp multiplicacionCicloConvertidor

multiplicacionCicloConvertidor:
	mul byte [edi];agarro el número sobre el cual está la "cabeza lectora", y lo multiplico con la base elevada a la supuesta cantidad de dígitos que ya estaba en el al
	jo saltoOverflow
	xchg esp,ebp;intercambio el sp con el bp para poder usar el bp para apuntar al tope de la pila
	add word [ebp],ax;le agrego al último word de la pila el dígito
	jo saltoOverflow
	xchg esp,ebp;intercambio el sp con el bp de nuevo para restaurarlos y que la pila no estalle en dos
	inc cx;incremento el cx, dado que ya hay un dígito más
	dec di;decremento el di para que lea el siguiente caracter a la izquierda
	cmp di,si;el di se va a ir acercando al si, dado que se convierte de izquierda a derecha, si el di es menor al si, significa que ya terminó de convertir el string
	jge cicloConvertidor;si es mayor, todavía faltan dígitos por convertir
	jmp retorno;esto es para que se salte la zona en la salta debido a que encontró un overflow

saltoOverflow: jmp errorDetectado

retorno:
	pop ax;restauro el valor encontrado en el string
	pop di ;recupero el resto de los registros de la pila
	pop si
	pop dx
	pop cx
	pop bx
	ret ;regresa

potenciador:
	;este proc lo que hace es potenciar un número que está en el dx a la cantidad de veces que estará en el cx (o específicamente el dl)
	;lo retorna en el ax
	push ecx;preservo los registros en la pila
	push ebp
	push edx

	mov eax,1;le muevo al ax un 1, que será el valor mínimo para todas las potencias
	jcxz salidaPotenciar
	mov ebp, esp;esto es para poder buscar el valor que introduje a la pila de último, que fue el dx, y dado que sólo puedo indexar mediante un registro de índice, entonces lo tomo de aquí

potenciar:
	mul byte [ebp];multiplico el ax por el valor que quedó en la pila, antes conocido como dx, que es la base por la que se debe multiplicar
	loop potenciar;que lo haga mientras quede un valor en el cx

salidaPotenciar:
	pop edx;recupero los registros de la pila
	pop ebp
	pop ecx
	ret ;regresa

.STARTUP
	GetStr prueba,7
	mov edi, prueba
	mov esi, edi
	add edi, 7
	call convertidor
	PutLInt eax
	jmp fin

errorDetectado:

fin:
.EXIT
