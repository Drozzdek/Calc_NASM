%include 'io.mac'

.DATA
msg_Inicio		db		'Ingrese una expresion: ',0
msg_Final		db		'La respuesta es: ',0
msg_Error		db		'Error. Caracter invalido.',0
nueva_prec		db		0
pila_prec		db		0
cont 			db		0
largo			db		0

.UDATA
expresion		resb	64
A_evaluar		resb	128

.CODE
	.STARTUP
	push EBP
	mov EBP,ESP
	PutStr msg_Inicio
	GetStr expresion
	mov EBX, expresion
	XOR EDI,EDI
;#############################################################################################################
cicloParser:
	XOR EAX,EAX
	XOR ECX,ECX
	XOR EDX,EDX
	XOR ESI,ESI
	cmp byte[EBX],0
	je	Respuesta
	cmp byte[EBX],'('
	jb	Error
	cmp byte[EBX],'b'
	je	Bin
	cmp byte[EBX],'h'
	je	Hex
	cmp byte[EBX],'o'
	je	Oct
	cmp byte[EBX],'F'
	ja	Error
	cmp byte[EBX],'0'
	jb	Operador
	cmp byte[EBX],'9'
	ja	N_Hex
	jmp N_Val
N_Hex:
	cmp byte[EBX],'A'
	je N_Val
	cmp byte[EBX],'B'
	je N_Val
	cmp byte[EBX],'C'
	je N_Val
	cmp byte[EBX],'D'
	je N_Val
	cmp byte[EBX],'E'
	je N_Val
	cmp byte[EBX],'F'
	je N_Val
	jmp Error
;#############################################################################################################
Bin:
	inc EBX
	jmp cicloParser
Hex:
	inc EBX
	jmp cicloParser
Oct:
	inc EBX
	jmp cicloParser
;#############################################################################################################
N_Val:
	mov byte[A_evaluar+EDI],'@'		;Se agrega un @ para que funcione como separador.
	inc EDI							;Se incrementa el EDI porque es el que uso para moverme por la variable.
cicloOperando:
	XOR EAX,EAX						;EAX = 0. Limpia el registro de basura.
	mov AL,byte[EBX]
	mov byte[A_evaluar+EDI],AL
	inc EDI
	inc EBX
	cmp byte[EBX],0
	je	Respuesta
	cmp byte[EBX],'0'
	jb	Operador
	cmp byte[EBX],'b'
	je	Bin
	cmp byte[EBX],'h'
	je	Hex
	cmp byte[EBX],'o'
	je	Oct
	cmp byte[EBX],'F'
	ja	Error
	cmp byte[EBX],'9'
	jle	cicloOperando
	ja	N_Hex2
N_Hex2:
	cmp byte[EBX],'A'
	je cicloOperando
	cmp byte[EBX],'B'
	je cicloOperando
	cmp byte[EBX],'C'
	je cicloOperando
	cmp byte[EBX],'D'
	je cicloOperando
	cmp byte[EBX],'E'
	je cicloOperando
	cmp byte[EBX],'F'
	je cicloOperando
	jmp Error
;#############################################################################################################
Operador:
	inc EBX
	jmp cicloParser

Respuesta:
	PutStr	msg_Final
	XOR EAX,EAX
	pop EAX
	PutLInt EAX
	jmp Fin
Error:
	PutStr	msg_Error
Fin:
	nwln
	.EXIT
