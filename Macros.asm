;----------------------------------------
Pow:
	mov EAX, 1		;Respuesta minima para cualquier exponente
	jcxz SalirPow
cicloPow:
	;DX => Base
	;CX => Exponente
	;AX => Respuesta
	cmp CL,0
	je	SalirPow
	mul DL
	dec CX
	jmp cicloPow
SalirPow:
	ret
;----------------------------------------
Overflow:
	PutStr msg_Ov
	nwln
	ret

