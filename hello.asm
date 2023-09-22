model small
.data
    msg1 db 'Left',10,13,'$'
    msg2 db 'Right',10,13,'$'
.code
start:

    mov ax,@data
    mov ds,ax
loop_game:
    mov ah,08h
    int 21h

    cmp al,61h
    je show_left
    cmp al,64h
    je show_right
    jmp show_end
    ; mov dx,offset msg1
    ; mov ah,09h
    ; int 21h

    ; mov ah, 02h
    ; mov dl,al
    ; int 21h
    
    ; jmp test1

    ; mov dl,'B'
    ; int 21h

show_left:
    mov dx,offset msg1
    mov ah,09h
    int 21h
    jmp loop_game
show_right:
    mov dx,offset msg2
    mov ah,09h
    int 21h
    jmp loop_game
show_end:
    jmp loop_game

end start