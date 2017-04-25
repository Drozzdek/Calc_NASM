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
	mov byte [A_evaluar+EDI], '%'
	inc edi
	
cicloOperando:
	mov al, byte[EBX]
	mov byte [A_evaluar+EDI], AL
	inc EBX
	cmp byte[EBX], '0'
	jb  operador
	cmp byte[EBX], '9'
	ja	Error
	
	
operador:		
	mov ESI, operadores			;Consigue el inicio de operadores. ESI porque es uno de los registros que permiten buscar dentro de la memoria.

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
	inc EBX
	jmp Ciclo

Done:
	PutStr	msg_Final
	
fin:
	nwln
	.EXIT
