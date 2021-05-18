nata segment 'code'
assume cs:nata, ds:nata, ss:nata, es:nata
org 100h
begin: jmp main
;------------Для ввода ---------------------
Buf db 7,7 DUP(?)
datev dw 0
mnoj dw ?
ps dw 10,13,'$'
N dw 3 ; количество строк
M dw 3 ; количество столбцов
bait_v_stoke dw ? ; количество байт в одной строке
N_M dw ? ; количество элементов в массиве
;------------Для вывода ---------------------
date dw ?
my_s db '+'
T_Th db ?
Th db ?
Hu db ?
Tens db ?
Ones db ?
;---------------------------------
X dw 9 DUP(?) ; Резервируем память под массив
svX db 10,13,'Enter elements of X array: ',10,13,'$'
svXXX db 10,13,'X array:',10,13,'$'
ssum db 'Bytes with odd number of 1 in even rows = $'
Sum dw 0 ; сумма элементов
K db ? ; номер столбца
K1 db ? ; номер строки
count db 0
;---------------------------------
main proc near
; ******* 1 – Считаем количество элементов в массиве  N_M *****
mov ax, N
mov bx, M
imul bx
mov N_M,ax ; нашли количество элементов в массиве
; считаем сколько байт памяти занимает одна строка bait_v_stoke
mov ax,M
mov bx,2
imul bx
mov bait_v_stoke,ax ; количество байт в одной строке
; ******** 2 – Заполняем массив X ****************
mov cx, N_M ; количество элементов в массиве
lea si,X ; адрес первого элемента
@z1:
push cx

; выводим строку-подсказку
mov ah, 09
lea dx, svX
int 21h
; получаем один элемент
call vvod
; записываем его в массив
mov ax, datev
mov [si], ax
; переходим к следующему элементу, увеличивая индекс на 2
add si, 2
pop cx
loop @z1
; ******* 3 – Вывод массива X *****************
; Выводим строку МАССИВ X
mov ah,09
lea dx,svXXX
int 21h
; Выводим массив X построчно
mov cx,N ; внешний цикл – по количеству строк
mov bx,0 ; сколько байт до начала строки пропустить
; ------ внешний цикл по строкам ------------------------------------
@next_row:
push cx
mov cx, M ; M - количество элементов строки
mov si,0
; ---- внутренний цикл по элементам строки --------------
@next_elem:
mov ax, X[bx][si]
; вывод одного элемента строки
mov date,ax
push cx bx ; сохраняем в стеке нужные регистры
call vivod
pop bx cx
add si,2 ; переход к след. элементу строки
loop @next_elem
; ---- конец внутреннего цикла по элементам строки -----
add bx, bait_v_stoke ; переход к след. строке
mov ah,09 ; перевод строки
lea dx,ps
int 21h
pop cx
loop @next_row
; ------ конец внешнего цикла по строкам --------------
; ******** Конец вывода массива X *********************

;***** 4 – Вызов процедуры подсчета суммы ***************
call raschet
; ***** 5 – Вывод значения суммы ************************
mov ah,09
lea dx,ssum
int 21h
mov ax,sum
mov date,ax
call vivod
; Ожидание нажатия на клавишу
mov ah,08
int 21h
ret
main endp
; ****** 6 – Вывод одного числа на экран *******************
vivod proc near
;--- Число отрицательное ?----------
mov ax,date
and ax,1000000000000000b
mov cl,15
shr ax,cl
cmp ax,1
jne @m1
mov ax,date
neg ax
mov my_s,'-'
jmp @m2
;--- Получаем десятки тысяч ---------------
@m1: mov ax,date
@m2: cwd
mov bx,10000
idiv bx
mov T_Th,al
;------- Получаем тысячи --------------------
mov ax,dx
cwd
mov bx,1000
idiv bx
mov Th,al
;------ Получаем сотни -----------------------
mov ax,dx
mov bl,100
idiv bl
mov Hu,al
;---- Получаем десятки и единицы ---------
mov al,ah
cbw

mov bl,10
idiv bl
mov Tens,al
mov Ones,ah
;--- Выводим знак -----------------------
cmp my_s,'+'
je @m500
mov ah,02h
mov dl,my_s
int 21h
;---------- Выводим цифры -----------------
@m500: cmp T_TH,0 ; проверка на ноль
je @m200
mov ah,02h ; выводим на экран, если не ноль
mov dl,T_Th
add dl,48
int 21h
@m200: cmp T_Th,0
jne @m300
cmp Th,0
je @m400
@m300: mov ah,02h
mov dl,Th
add dl,48
int 21h
@m400: cmp T_TH,0
jne @m600
cmp Th,0
jne @m600
cmp hu,0
je @m700
@m600: mov ah,02h
mov dl,Hu
add dl,48
int 21h
@m700: cmp T_TH,0
jne @m900
cmp Th,0
jne @m900
cmp Hu,0
jne @m900
cmp Tens,0
je @m950
@m900: mov ah,02h
mov dl,Tens
add dl,48
int 21h

@m950: mov ah,02h
mov dl,Ones
add dl,48
int 21h
mov ah,02h
mov dl,' '
int 21h
ret
vivod endp
; ***** 7 – Процедура ввод одного элемента массива *******
vvod proc near
mov datev,0
; ввод числа в виде строки символов
mov ah,10
lea dx,buf
int 21h
mov mnoj,1
; получаем количество введенных символов
mov cl,byte ptr buf+1 ; сколько символов(цифр)
mov ch,0
mov bp,cx
add bp,1 ; адрес последней цифры
@m1000:
; берем одну цифру
mov al,byte ptr buf+bp
sub al,30h
cbw
imul mnoj ; ax=цифра*10 в соответсвующей степени
add datev,ax
; умножаем множитель на 10
mov ax,10
imul mnoj
mov mnoj,ax
sub bp,1
loop @m1000
; перевод строки
mov ah,09
lea dx,ps
int 21h
ret
vvod endp
;***** 8 – Процедура подсчета суммы ***************************
raschet proc near
mov cx, N ; внешний цикл - по количеству строк
mov bx, 0 ; сколько байт до начала строки пропустить
mov k1, 1 ; k1 – номер строки

@next_row1:
push cx
mov cx, N ; N - количество элементов строки
mov si,0
mov k,0 ; k – номер элемента в строке
; ---- внутренний цикл по элементам строки --------------
@next_elem1:
mov ax,X[bx][si] ; берем очередной элемент

push ax
push bx
push cx
push dx

mov dx,ax

test k1,00000001b ; проверяем строку на четность
jnz @dalhe

xor al,al
@repeat:
mov ah,dl
and ah,1
add al,ah
shr dx,1
jnz @repeat

and al,01h
jz @dalhe
inc sum

; переход к следующему элементу строки
@dalhe: add si,2 ; адрес след. элемента
add k,1 ; наращиваем номер элемента в строке

pop dx
pop cx
pop bx
pop ax

loop @next_elem1
add k1,1 ; наращиваем номер строки
; ---- конец внутреннего цикла по элементам строки -----
add bx,bait_v_stoke ; переход к след. строке
pop cx
loop @next_row1

ret
raschet endp
;***************************************************************
nata ends
end begin