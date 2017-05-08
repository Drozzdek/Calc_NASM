%include 'io.mac'
%include 'Macros.asm'

.DATA
msg_Inicio		db		'Ingrese una expresion: ',0
msg_Final		db		'La respuesta es: ',0
msg_Post		db		'la expresion en postfijo es: ',0
msg_Error		db		'Error. Caracter invalido.',0
msg_Ov			db		'Ocurrio un overflow',0
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
	je	PostFijo
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
	cmp byte[A_evaluar],0
	je	Error
	XOR ESI,ESI
	mov ESI,EDI
	dec ESI
	cmp byte[A_evaluar+ESI],'0'
	jb	Error
	cmp byte[A_evaluar+ESI],'1'
	ja	Error
	jmp cicloOperando
Hex:
	cmp byte[A_evaluar],0		;¿No hay ningun numero?
	je	Error					;Da error porque tiene que haber un numero entre 0 y 9 o una letra entre A y F antes del caracter de 'h'
	mov ESI,EDI					;Se usa ESi para poder moverme por la variable A_evaluar sin perder la posicion por la que voy
	dec ESI						;Se reduce para ver el carcater anterior a la posicion a la que estoy.
	cmp byte[A_evaluar+ESI],'F'	;Pregunto si el caracter anterior es un F
	ja	Error					;Si es mayor que una F, entonces hay un error en la expresion ingresada.
	je	cicloOperando
	cmp byte[A_evaluar+ESI],'0'	;Pregunto si el caracter anterior es un 0
	jb	Error					;Si es menor que 0, entonces hay un error de sintaxis en la expresion ingresada.
	cmp byte[A_evaluar+ESI],'A'	;Pregunto si el caracter anterior es un A
	je	cicloOperando			;Si es igual que una F, es un carcater valido.
	cmp byte[A_evaluar+ESI],'B'	;Pregunto si el caracter anterior es un B
	je	cicloOperando			;Si es igual que una F, es un carcater valido.
	cmp byte[A_evaluar+ESI],'C'	;Pregunto si el caracter anterior es un C
	je	cicloOperando			;Si es igual que una F, es un carcater valido.
	cmp byte[A_evaluar+ESI],'D'	;Pregunto si el caracter anterior es un D
	je	cicloOperando			;Si es igual que una F, es un carcater valido.
	cmp byte[A_evaluar+ESI],'E'	;Pregunto si el caracter anterior es un E
	je	cicloOperando			;Si es igual que una F, es un carcater valido.
	cmp byte[A_evaluar+ESI],'9'	;Pregunto si es un caracter de 9
	ja	Error					;Si es mayor que 9 pero ninguno de los anteriores, entonces es un error de sintaxis.
	jmp cicloOperando
Oct:
	cmp byte[A_evaluar],0
	je	Error
	XOR ESI,ESI
	mov ESI,EDI
	dec ESI
	cmp byte[A_evaluar+ESI],'0'
	jb	Error
	cmp byte[A_evaluar+ESI],'7'
	ja	Error
	jmp cicloOperando
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
	je	PostFijo
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
	cmp byte[EBX],'/'
	jae	Valido
	cmp byte[EBX],'-'
	je	Valido
	cmp byte[EBX],'+'
	je	Valido
	cmp byte[EBX],'*'
	je	Valido
	cmp byte[EBX],'('
	je	Parentesis
	cmp byte[EBX],')'
	je	Parentesis2
;#############################################################################################################
Valido:
	XOR	EDX,EDX					;EDX = 0. Para limpiar el registro de basura
	mov DL,byte[EBX]			;Se mueve el caracter a evaluar a memoria.
	XOR ESI,ESI					;ESI = 0. Para limpiar el registro de basura.
	jmp Prioridad					;Se llama a el proc para que en el ESI, me quede la prioridad de la operacion
JValido:
	XOR ECX,ECX					;ECX = 0. Para limpiar el registro de basura.
	mov [nueva_prec],ESI		;Se mueve a la variable la prioriodad de la nueva operacion
	mov CX,[nueva_prec]			;Se mueve a memoria dicha prioridad
;#############################################################################################################
cicloPrioridad:
	XOR ESI,ESI					;ESI = 0. Para limpiar el registro de basura.
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura.
	pop AX						;Se saca el tope de la pila
	push AX						;pero no lo elimino aun.
	jmp Prioridad_Pila				;Se llama a el proc para que en el ESI, me quede la prioridad de la operacion
JValido2:
	XOR EDX,EDX					;EDX = 0. Para limpiar el registro de basura.
	
	mov [pila_prec],ESI		;
	XOR DX,DX
	mov DX,[pila_prec]
	
	cmp CX,DX					;Se compara la prioridad de la nueva operacion contra la del tope de la pila.
	jg	Mayor					;Salta si la nueva prioridad es mayor.
	jle MenorIgual				;Salta si la prioridad de la pila es mayor.
;#############################################################################################################
Mayor:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura.
	mov AX,[EBX]				;Se mueve al AX el carcater que se evaluo anteriormente
	push AX						;Se guarda en pila el nuevo caracter de operacion.
	inc EBX						;Se incrementa el EBX para que se mueva al siguiente caracter a evaluar.
	jmp cicloParser				;Salta al ciclo del parser para evaluar el siguiente caracter.
	
MenorIgual:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura.
	pop AX						;Se saca el tope de la pila
	mov byte[A_evaluar+EDI],'@'	;Se agrega a la variable en postfijo un nuevo separador.
	inc EDI						;Se incrementa el EDI para que se mueva a la siguiente posicion a insertar.
	mov byte[A_evaluar+EDI],AL	;Se agrega a la variable a postfijo el caracter de operacion del tope de la pila.
	inc EDI						;Se incrementa el EDI para que se mueva a la siguiente posicion a insertar.
	jmp cicloPrioridad			;Repite el ciclo con el nuevo caracter.
;#############################################################################################################
Parentesis:
	XOR EDX,EDX					;EDX = 0. Para limpiar el registro de basura.
	mov DX,[EBX]			;Se mueve al DX el carcater de (
	push DX						;y se guarda en la pila.
	inc EBX						;Se incrementa el EBX para que se mueva al siguiente caracter a evaluar.
	jmp	cicloParser				;Repite el ciclo desde el inicio con el nuevo caracter.
	
Parentesis2:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura.
	pop AX						;Obtiene el carcater en el tope de la pila.
	cmp AL,'('					;Es el tope de la pila un caracter de (
	je	Siguiente				;Si es un carcater (, salte a siguiente.
	cmp AX,0					;¿Llegue al final de la expresion?
	je	Siguiente				;Si llegue al final de la expresion, salte a siguiente.
	mov byte[A_evaluar+EDI],'@'	;Se agrega a la variable en postfijo un nuevo separador.
	inc EDI						;Se incrementa el EDI para que se mueva a la siguiente posicion a insertar.
	mov byte[A_evaluar+EDI],AL	;Se agrega a la variable a postfijo el caracter de operacion del tope de la pila.
	inc EDI						;Se incrementa el EDI para que se mueva a la siguiente posicion a insertar.
	jmp Parentesis2				;Se repite el ciclo con el siguiente carcater de la pila.
Siguiente:
	inc EBX						;Se incrementa el EBX para que se mueva al siguiente caracter a evaluar.
	jmp cicloParser				;Repite el ciclo desde el inicio con el nuevo caracter.
;#############################################################################################################
Evaluar:
	nwln						;Se borran todos los registros
	XOR EAX,EAX
	XOR EBX,EBX
	XOR ECX,ECX
	XOR EDX,EDX
	XOR ESI,ESI
	XOR EDI,EDI
	
	mov EBX,A_evaluar			;Se mueve al EBX la variable en postfijo
cicloEvalua:
	cmp byte[EBX],0					;¿llegue al final de la expresion?
	je	Respuesta				;Salte al final del programa si ya llegue al final de la expresion. Da la respuesta
	cmp byte[EBX],'@'					;Pregunto si es un caracter de separador.
	je	Separador				;Salte si es un separador.
	cmp byte[EBX],'0'					;Pregunta si es un caracter de 0
	jb	Operacion				;Si es menor que '0', es una operacion
Num:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura
	mov AX,[EBX]				;AX = caracter a evaluar
	push AX						;Se guarda el caracter en pila.
								
								;Incrementa la variable largo al hacer
	mov ESI,[largo]				;ESI = largo
	inc ESI						;ESI++
	mov [largo],ESI				;largo = ESI
	
	inc EBX						;Se incrementa el EBX para que se mueva al siguiente caracter a evaluar.
	jmp cicloEvalua				;Repite el ciclo con el nuevo caracter a evaluar.
;#############################################################################################################
Separador:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura
	mov AX,[largo]				;AX = largo del numero
	cmp AX,0					;¿El largo es 0?
	je Siguiente2				;Si es 0, salga del ciclo del separador
	XOR EDX,EDX					;EDX = 0. Para limpiar el registro de basura.
	pop DX						;DX = caracter en el tope de la pila
	
	cmp DL,'b'					;¿Es un numero binario?
	je	Bin2
	cmp DL,'o'					;¿Es un numero binario?
	je	Oct2
	cmp DL,'h'					;¿Es un numero binario?
	je	Hex2
	push DX
	jmp conv_Dec				;Conviertalo a decimal

Bin2:
	;Decrementa largo
	mov ESI,[largo]
	dec ESI
	mov [largo],ESI
	jmp	conv_Bin				;Conviertalo a decimal
	
Oct2:
	;Decrementa largo
	mov ESI,[largo]
	dec ESI
	mov [largo],ESI
	jmp	conv_Oc					;Conviertalo a decimal
	
Hex2:
	;Decrementa largo
	mov ESI,[largo]
	dec ESI
	mov [largo],ESI
	jmp	conv_Hex				;Conviertalo a decimal
;#############################################################################################################
conv_Bin:
	
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura
	mov AX,[largo]				;AX = largo del numero
	cmp AX,0					;¿El largo es 0?
	je Siguiente2				;Si es 0, salga del ciclo del separador
	
	jmp conv_Binario
JCBin:
	;Incrementa contador
	mov ESI,[cont]
	inc ESI
	mov [cont],ESI
	
	;Decrementa largo
	mov ESI,[largo]
	dec ESI
	mov [largo],ESI
	jmp conv_Bin
;#############################################################################################################
conv_Oc:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura
	mov AX,[largo]				;AX = largo del numero
	cmp AX,0					;¿El largo es 0?
	je Siguiente2				;Si es 0, salga del ciclo del separador
	
	jmp conv_Octal
JCOct:
	;Incrementa contador
	mov ESI,[cont]
	inc ESI
	mov [cont],ESI
	
	;Decrementa largo
	mov ESI,[largo]
	dec ESI
	mov [largo],ESI
	jmp conv_Oc
;#############################################################################################################
conv_Dec:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura
	mov AX,[largo]				;AX = largo del numero
	cmp AX,0					;¿El largo es 0?
	je Siguiente2				;Si es 0, salga del ciclo del separador
	jmp conv_Decimal
JCDec:
	;Incrementa contador
	mov ESI,[cont]
	inc ESI
	mov [cont],ESI
	
	;Decrementa largo
	mov ESI,[largo]
	dec ESI
	mov [largo],ESI
	jmp conv_Dec
;#############################################################################################################
conv_Hex:
	XOR EAX,EAX					;EAX = 0. Para limpiar el registro de basura
	mov AX,[largo]				;AX = largo del numero
	cmp AX,0					;¿El largo es 0?
	je Siguiente2				;Si es 0, salga del ciclo del separador
	
	jmp conv_Hexadecimal
JCHex:
	;Incrementa contador
	mov ESI,[cont]
	inc ESI
	mov [cont],ESI
	
	;Decrementa largo
	mov ESI,[largo]
	dec ESI
	mov [largo],ESI
	jmp conv_Hex
;#############################################################################################################
Siguiente2:
	push CX
	XOR CX,CX
	inc EBX
	mov ESI,0
	mov [largo],ESI
	mov ESI,0
	mov [cont],ESI
	jmp cicloEvalua
;#############################################################################################################
Operacion:
	cmp byte[EBX],'+'
	je  Suma
	cmp byte[EBX],'-'
	je  Resta
	cmp byte[EBX],'*'
	je  Multiplicacion
	cmp byte[EBX],'/'
	je  Division
;#############################################################################################################
Suma:
	XOR AX,AX
	XOR CX,CX
	XOR DX,DX
	pop CX
	pop AX
	add AX,CX
	push AX
	inc EBX
	inc EBX
	XOR EAX,EAX
	XOR ECX,ECX
	XOR EDX,EDX
	XOR ESI,ESI
	XOR EDI,EDI
	jmp cicloEvalua
;#############################################################################################################
Resta:
	XOR AX,AX
	XOR CX,CX
	XOR DX,DX
	pop CX
	pop AX
	sub AX,CX
	push AX
	inc EBX
	inc EBX
	XOR EAX,EAX
	XOR ECX,ECX
	XOR EDX,EDX
	XOR ESI,ESI
	XOR EDI,EDI
	jmp cicloEvalua
;#############################################################################################################
Multiplicacion:
	XOR AX,AX
	XOR CX,CX
	XOR DX,DX
	pop CX
	pop AX
	mul CX
	push AX
	inc EBX
	inc EBX
	XOR EAX,EAX
	XOR ECX,ECX
	XOR EDX,EDX
	XOR ESI,ESI
	XOR EDI,EDI
	jmp cicloEvalua
;#############################################################################################################
Division:
	XOR AX,AX
	XOR CX,CX
	XOR DX,DX
	pop CX
	pop AX
	div CX
	push AX
	inc EBX
	inc EBX
	XOR EAX,EAX
	XOR ECX,ECX
	XOR EDX,EDX
	XOR ESI,ESI
	XOR EDI,EDI
	jmp cicloEvalua
;#############################################################################################################
Complete:
		XOR EBX,EBX
		pop BX
		cmp BX,0
		je	Completa
		mov byte[A_evaluar+EDI],'@'
		inc EDI
		mov byte[A_evaluar+EDI],BL
		inc EDI
		jmp Complete
Completa:
	call Imprimir
	jmp JPost
;----------------------------------------
Imprimir:
		XOR EBX,EBX
		mov EBX,A_evaluar
cicloImprime:
		cmp byte[EBX],0
		je	salirImprime
		PutCh byte[EBX]
		inc EBX
		jmp cicloImprime
salirImprime:
	ret
;----------------------------------------
Prioridad:
	cmp DL,'+'
	je	Uno
	cmp DL,'-'
	je	Uno
	cmp DL,'*'
	je	Dos
	cmp DL,'/'
	je	Dos
Uno:
	mov ESI,1
	jmp Sal
Dos:
	mov ESI,2
	jmp Sal
Sal:
	jmp JValido
;----------------------------------------
Prioridad_Pila:
	cmp AL,0
	je	Vacia
	cmp AL,'('
	je	Vacia
	cmp AL,'+'
	je	Uno
	cmp AL,'-'
	je	Uno
	cmp AL,'*'
	je	Dos
	cmp AL,'/'
	je	Dos
Vacia:
	mov ESI,0
	jmp SalPP
SalPP:
	jmp JValido2
;----------------------------------------
conv_Binario:
	XOR EDI,EDI
	pop	DI
	sub DI,'0'
	push CX
	XOR ECX,ECX
	mov CX,[cont]
	mov DX,2
	call Pow
	XOR EDX,EDX
	mov DX,DI
	mul DL
	jo  Ov1
NoOv1:
	pop CX
	add CX,AX
	jmp JCBin
Ov1:
	call Overflow
	jmp NoOv1
;----------------------------------------
conv_Octal:
	XOR EDI,EDI
	pop	DI
	sub DI,'0'
	push CX
	XOR ECX,ECX
	mov CX,[cont]
	mov DX,8
	call Pow
	XOR EDX,EDX
	mov DX,DI
	mul DL
	jo  Ov2
NoOv2:
	pop CX
	add CX,AX
	jmp JCOct
Ov2:
	call Overflow
	jmp NoOv2
;----------------------------------------
conv_Decimal:
	pop DX
	sub DL,'0'
	push CX
	XOR ECX,ECX
	mov CX,[cont]
	push DX
	XOR DX,DX
	mov DX,10
	call Pow
	XOR EDX,EDX
	pop DX
	mul DL
	jo  Ov3
NoOv3:
	pop CX
	add CX,AX
	jmp JCDec
Ov3:
	call Overflow
	nwln
	jmp NoOv3
;----------------------------------------
conv_Hexadecimal:
	XOR EDX,EDX
	pop	DX
	cmp DL,'0'
	jb	Error
	cmp DL,'9'
	ja	N_Hex3
	mov DI,DX
	sub DI,'0'
	jmp Conv
N_Hex3:
	cmp	DL,'A'
	je	HexA
	cmp	DL,'B'
	je	HexB
	cmp	DL,'C'
	je	HexC
	cmp	DL,'D'
	je	HexD
	cmp	DL,'E'
	je	HexE
	cmp	DL,'F'
	je	HexF
HexA:
	mov DI,10
	jmp Conv
HexB:
	mov DI,11
	jmp Conv
HexC:
	mov DI,12
	jmp Conv
HexD:
	mov DI,13
	jmp Conv
HexE:
	mov DI,14
	jmp Conv
HexF:
	mov DI,15
	jmp Conv
Conv:
	push CX
	XOR ECX,ECX
	mov CX,[cont]
	XOR EDX,EDX
	mov DX,16
	call Pow
	XOR EDX,EDX
	mov DX,DI
	mul DL
	jo  Ov4
NoOv4:
	pop CX
	add CX,AX
	jmp JCHex
Ov4:
	call Overflow
	jmp	NoOv4
;----------------------------------------
;#############################################################################################################
PostFijo:
	PutStr	msg_Post
	jmp Complete
JPost:
	jmp	Evaluar
	nwln
Respuesta:
	PutStr	msg_Final
	XOR ECX,ECX
	pop CX
	PutInt CX
	nwln
	jmp Fin
Error:
	PutStr	msg_Error
Fin:
	nwln
	.EXIT
