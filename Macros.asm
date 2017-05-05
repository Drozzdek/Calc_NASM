;----------------------------------------
%macro Pow 0
	mov EAX, 1		;Respuesta minima para cualquier exponente
	jcxz SalirPow
cicloPow:
	;DX => Base
	;CX => Exponente
	;AX => Respuesta
	mul DL
	loop cicloPow
SalirPow:
%endmacro
;----------------------------------------
%macro	Complete	0
cicloComplete:
		XOR EBX,EBX
		pop BX
		cmp BL,0
		je	Completa
		mov byte[A_evaluar+EDI],'@'
		inc EDI
		mov byte[A_evaluar+EDI],BL
		inc EDI
		jmp cicloComplete
Completa:
%endmacro
;----------------------------------------
%macro	Imprimir 0
		XOR EBX,EBX
		mov EBX,A_evaluar
cicloImprime:
		cmp BL,0
		je	salirImprime
		PutCh BL
		inc EBX
		jmp cicloImprime
salirImprime:
%endmacro
;----------------------------------------
%macro	Suma	0
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
%endmacro
;----------------------------------------
%macro	Resta	0
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
%endmacro
;----------------------------------------
%macro	Multi	0
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
%endmacro
;----------------------------------------
%macro	Divis	0
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
%endmacro
;----------------------------------------
%macro	Prioridad	0
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
	ret
Dos:
	mov ESI,2
	ret
%endmacro
;----------------------------------------
%macro	Prioridad_Pila	0
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
	ret
%endmacro
;----------------------------------------
%macro	conv_Binario 0
	XOR EDI,EDI
	pop	DI
	sub DI,'0'
	push CX
	XOR ECX,ECX
	mov CX,[cont]
	mov DX,2
	Pow
	XOR EDX,EDX
	mov DX,DI
	mul DL
	pop CX
	add CX,AX
%endmacro
;----------------------------------------
%macro	conv_Octal 0
	XOR EDI,EDI
	pop	DI
	sub DI,'0'
	push CX
	XOR ECX,ECX
	mov CX,[cont]
	mov DX,8
	Pow
	XOR EDX,EDX
	mov DX,DI
	mul DL
	pop CX
	add CX,AX
%endmacro
;----------------------------------------
%macro	conv_Decimal 0
	XOR EDI,EDI
	pop	DI
	sub DI,'0'
	push CX
	XOR ECX,ECX
	mov CX,[cont]
	mov DX,10
	Pow
	XOR EDX,EDX
	mov DX,DI
	mul DL
	pop CX
	add CX,AX
%endmacro
;----------------------------------------
%macro	conv_Hexadecimal 0
	XOR EDI,EDI
	pop	DI
	cmp DI,'0'
	jb	ErroS
	cmp DI,'9'
	ja	N_Hex
	sub DI,'0'
	push CX
N_Hex:
	cmp	DI,'A'
	je	HexA
	cmp	DI,'B'
	je	HexB
	cmp	DI,'C'
	je	HexC
	cmp	DI,'D'
	je	HexD
	cmp	DI,'E'
	je	HexE
	cmp	DI,'F'
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
	XOR ECX,ECX
	mov CX,[cont]
	mov DX,16
	Pow
	XOR EDX,EDX
	mov DX,DI
	mul DL
	pop CX
	add CX,AX
%endmacro
;----------------------------------------
