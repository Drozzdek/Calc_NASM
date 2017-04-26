%include 'io.mac'

.DATA
msg_Inicio		db		'Ingrese una expresion: ', 0
msg_Error		db		'Error', 0
msg_Final		db		'Todo Funciona!', 0
largo			db		0
operadores 		db		'+-*/'

.UDATA
expresion		resb	32
A_evaluar		resb	42

.CODE
	.STARTUP
	PutStr	msg_Inicio
	GetStr  expresion
	
	mov EBX, expresion			;
	xor EDI,EDI					;Vacia el registro
	xor ESI,ESI					;Vacia el registro
	
Ciclo:
	cmp byte[EBX], 0
	je  Done
	;Error si es mayor que z minuscula
	;Error si esta en el hueco entre z minuscula y a mayuscula
	;Error si esta entre 9 y a mayuscula, Pero verificar que no sea un igual
	;Error si es menor a 0 y diferente de un operador valido
	;+-*/()
	cmp byte[EBX], 'b'
	je NoError
	cmp byte[EBX], 'd'
	je NoError
	cmp byte[EBX], 'h'
	je NoError
	cmp byte[EBX], 'o'
	je NoError
	cmp byte[EBX], '9'
	jb Pos_Error
	cmp byte[EBX], 'z'
	ja Error
	cmp byte[EBX], 'a'
	jb Pos_Error
	cmp byte[EBX], 'A'
	jb Pos_Error
	;es un operando
	;ciclo, hasta encontrar operador
	mov byte [A_evaluar+EDI], '@'
	inc EDI
	
cicloOperando:
	mov AL, byte[EBX]
	mov byte [A_evaluar+EDI], AL
	inc EBX
	cmp byte[EBX], '0'
	jb  operador
	cmp byte[EBX], '9'
	ja	Error
	
operador:		
	mov ESI, operadores			;Consigue el inicio de operadores. ESI porque es uno de los registros que permiten buscar dentro de la memoria.
	call Prioridad

Error:
	PutStr msg_Error
	nwln
	mov eax, 1
	mov ebx, 1
	int 0x80

Pos_Error:
	cmp byte[EBX], 'Z'
	ja Error
	cmp byte[EBX], '='
	je NoError
	cmp byte[EBX], '9'
	ja Error
	cmp byte[EBX], '/'
	jae NoError
	cmp byte[EBX], '-'
	je NoError
	cmp byte[EBX], '+'
	je NoError
	cmp byte[EBX], '*'
	je NoError
	cmp byte[EBX], '('
	je NoError
	cmp byte[EBX], ')'
	je NoError
	jmp Error

NoError:
Num_Letra:
	mov BL, byte[EBX]
	mov A_evaluar, BL
	inc EBX
	jmp Ciclo
Simb:
	mov A_evaluar, '@'
	mov BL, byte[EBX]
	mov A_evaluar, BL			;Aqui deberia pedir por la prioridad de operaciones y resolver de acuerdo a eso
	inc EBX
	jmp Ciclo

Done:
	PutStr	msg_Final
	
fin:
	nwln
	.EXIT

;Esta funcion me da la prioridad para la pila y decision de operadores
Prioridad:
	cmp AL, [operadores+ESI]		;El SI es el que tiene la prioridad del operador y va de 0 hasta donde la posicion donde la encontre.
	jne Siguiente					;Si no lo a encontrado, salte al siguiente
	ret								;De lo contrario, retorne a donde lo encontro
Siguiente:
	inc ESI
	jmp Prioridad

;Decide de acuerdo al algoritmo de postfijo que hacer con el operador conseguido
;Meto a la pila si es mayor
;Si es menor, lo saco, lo agrego a la expresion
;Lo vuelvo a comparar
;En postfijo hay que tener en cuenta los parenesis que en la expresion final no aparecen
Ev_Operador:
	
