model small
.data
.code
start:
mov ah,02h
mov dl,47h
dec dl ;dl - 1
int 21h

mov ax,4c00h
int 21h






end start