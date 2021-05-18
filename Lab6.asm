;7. Y = (1+x*x)*arctg(x)/2

nata segment 'code'
assume cs:nata, ds:nata, ss:nata, es:nata
org 100h
begin: jmp main
;******************************************************************************
	result 		dd ?
	floatpart	dd ?
	tmp 		dd ?
	intpart		dd ?
	numb 		dw ?
	lenintpart 	dw 5
	lenfloatpart	dw 5
	tmpint		dw ?
	d 		dd 10.0
	print_str 	db 20 dup('$')
	separator 	db '.'
	sign		db ' '

;******************************************************************************
;---------------------------------
x dd 3.0
y dd ?
odin dd 1.0
dwa dd 2.0
temp dd ?
;---------------------------------------------------------
main proc near
FINIT
FLD x
FLD x
FMUL
FADD odin
FLD dwa
FDIV
FSTP temp
FLD x
FPATAN
FSTP x
FSTP y
FLD x
FLD temp
FMUL

FSTP result
call Out_DD_float

ret
main endp

;-----------------------------------------------------------
Out_DD_float proc near
;--------------------------------------
fld result
lea si,result
add si,3
mov al,[si]
test al,80h
jz @positiv
	fchs
	mov sign,'-'
@positiv:
	fst tmp
	fld1
	fld tmp
	fprem
	fsub st(2),st
	mov cx,lenfloatpart
	mov lenfloatpart,cx
@floatpart_mul_10:
	fmul d
loop @floatpart_mul_10
	frndint
	fstp floatpart
	fstp tmp
	fstp intpart
;---------------------------------§ ЇЁбм жЁда ў бва®Єг
mov cx,2
lea si,print_str
add si,lenintpart
add si,lenfloatpart
lea di,separator
lea bx,lenfloatpart
fld floatpart
@print_to_str:
	fst y
	push cx
	mov cx,[bx]
	@repeate_out_char:
		fld d
		fld y
		fprem
		fist numb
		fsub st(2),st
		fstp tmp
		fdiv
		fist tmpint
		fst y
		mov dx,numb
		mov ax,tmpint
		add dl,48
		mov [si],dl
		dec si
		cmp ax,0
	loopne @repeate_out_char
	fstp tmp
	mov al,[di]
	mov [si],al
	inc di
	dec si
	sub bx,2
	fld intpart
	pop cx
loop @print_to_str
fstp tmp
;------------------------------------‚лў®¤ бва®ЄЁ ­  нЄа ­
inc si
mov dx,si
mov ah,09h
int 21h
ret
;--------------------------------------
Out_DD_float endp

nata ends
end begin