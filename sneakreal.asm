IDEAL
MODEL small
STACK 100h
DATASEG

SIZE_OF_HISTORY_POS equ 460 
position_history dw SIZE_OF_HISTORY_POS dup(50)
snake2_position_history dw SIZE_OF_HISTORY_POS dup(100)


saveKey db 0

BLACK equ 0000b
WHITE equ 1111b
GREEN equ 0010b
RED	equ 0100b
YELLOW equ 1110b
CAYEN equ 1011b
MAGNETA equ 1101b
BLUE equ 1001b

W_KEYBOARD equ 17
S_KEYBOARD equ 31
A_KEYBOARD equ 30
D_KEYBOARD equ 32

RIGHT_KEYBOARD equ 04Dh
LEFT_KEYBOARD equ 04Bh
UP_KEYBOARD equ 048h
DOWN_KEYBOARD equ 050h



NUMBER_OF_START_SQUARE equ 5
num_of_square db NUMBER_OF_START_SQUARE




next_square_color db BLACK

is_lost db FALSE

is_want_2_players db 0

music_sounds dw 11EDh,0FE8h,0E2Bh,0D5Bh,0BE4h,0A98h,96Fh,8E5h

apple_color dw red
apple_counter db 0

right_direction_on_key_board db D_KEYBOARD
left_direction_on_key_board db A_KEYBOARD

SQUARE_LINE_LENGTH equ 5
SQUARE_HEIGHT equ 5

highet dw SQUARE_HEIGHT
line_length dw SQUARE_LINE_LENGTH

REGULAR_SLEEP_TIME equ 0df00h
FAST_SLEEP_TIME equ 05f00h
START_SLEEP_TIME equ 0ffffh

random_x dw 0
random_y dw 0

POINT_OBJECT_SIZE equ 4
next_place_in_pos_history dw POINT_OBJECT_SIZE
snake2_next_place_in_pos_history dw POINT_OBJECT_SIZE

sleep_time dw REGULAR_SLEEP_TIME

UP_DIRECTION equ 0
DOWN_DIRECTION equ 1
LEFT_DIRECTION equ 2
RIGHT_DIRECTION equ 3

start_message db "Welcome to sneak game by Fight Ohm Few$"
how_many_players_are_playing db  "Enter how many players are playing? (1/2)$"

special_apples db "********************SPECIAL APPLES********************$"
STRING_REGULAR_APPLE db "Red apple - Regular Apple$"
STRING_FAST_APPLE db "Yellow apple - Change the speed of your snake$"
STRING_TRIPPLE_APPLE db "Cayen apple - Tripple score apple$"
STRING_CONFUSE_APPLE db "Pink apple - Switch betwen left and right$"

movment db "********************MOVMENT********************$"
first_player_movment db "First player move with w - up, s - down, a - left, d - right.$"
second_player_movment db "Second player move with the arrows.$"

rules db "********************RULES********************$"
dont_touch_lines db "You can't touch the lines.$"
dont_touch_snake db "You can't touch snakes (yourself or the other player).$"
eat_apple_rule db "When you eat an apple you get bigger.$"
two_players_rule db "Two playres mode - Play together, you are a part of a team! $"


LEN_REGULAR_APPLE_STRING equ 25
LEN_TRIPPLE_APPLE_STRING equ 33
LEN_CONFUSE_APPLE_STRING equ 41
LEN_FAST_APPLE_STRING equ 45

end_massage db "Your sneak,  score is $"
credit 		db "ASM Sec2 Project prepared by$"
credit_one	db "Pattaraphol Weingkham 170-9$"
credit_two	db "Gidtipong Capangnoi 147-7$"
credit_three db "Kittipas Krapong 149-3$"

FALSE equ 0
TRUE equ 1

current_direction dw RIGHT_DIRECTION
snake2_current_direction dw RIGHT_DIRECTION

left_onKeyboard db LEFT_KEYBOARD
right_onKeyboard db RIGHT_KEYBOARD


CODESEG

proc print_dot
	; arguments: x, y, color
	x equ [bp+8]
	y equ [bp+6]
	color equ [bp+4]
	
	push bp
	mov bp, sp
	
	push cx
	
	mov bh,0h
	mov cx,x
	mov dx,y
	mov al,color
	mov ah,0ch
	int 10h
	
	pop cx
	pop bp
	ret 6
endp print_dot

proc print_line
	; arguments: x, y, color
	x equ [bp+8]
	y equ [bp+6]
	color equ [bp+4]
	push bp
	mov bp,sp
	
	push cx
	
	mov cx,[line_length]
	
	next_dot:
		push x
		push y
		push color
		call print_dot
		
		mov ax,x
		inc ax
		mov x,ax
		loop next_dot
	pop cx
	pop bp
	ret 6
endp print_line

proc print_square
	; arguments: x, y, color
	x equ [bp+8]
	y equ [bp+6]
	color equ [bp+4]
	
	push bp
	mov bp,sp

	mov cx,[highet]
	
	next_line:
		push x
		push y
		push color
		call print_line
		
		mov ax,y
		inc ax
		mov y,ax
		
		loop next_line
	pop bp
	ret 6
endp print_square


proc sleep
	;arguments sleep_time (in microseconds)
	sleep_time_arg equ [bp+4]
	push bp
	mov bp,sp
	mov cx,0
	mov dx,sleep_time_arg
	;--------- calling wait int
	mov ah, 86h
	int 15h
	pop bp
	ret 2
endp sleep


proc move_snake
	;arguments: direction,offset position_history,place_in_arr,offset of place_in_arr
	color equ [bp+12]
	offset_of_place_in_arr equ [bp+10]
	direction equ [bp+8]
	place_in_arr equ [bp+4]
	position_history_arg equ [bp+6]
	next_x equ [bp-4]
	next_y equ [bp-2]
	push bp
	mov bp,sp
	sub sp,4
	
	; extract current x, y.
	mov bx,position_history_arg
	mov si,place_in_arr
	mov ax,[bx+si- 4]
	mov next_x, ax
	mov ax,[bx+si- 2]
	mov next_y, ax
	
	
	mov ax,direction
	cmp ax,LEFT_DIRECTION
	je snake_left				;j if eq
	cmp ax,RIGHT_DIRECTION
	je snake_right
	cmp ax,UP_DIRECTION
	je snake_up
	cmp ax,DOWN_DIRECTION
	je snake_down
	
	snake_left:
		mov ax,SQUARE_LINE_LENGTH
		sub next_x,ax
		jmp  end_direction
	snake_right:
		mov ax,SQUARE_LINE_LENGTH
		add next_x,ax
		jmp end_direction
	snake_up:
		mov ax,SQUARE_HEIGHT
		sub next_y,ax
		jmp end_direction
	snake_down:
		mov ax,SQUARE_HEIGHT
		add next_y,ax
	end_direction:
	push next_x
	push next_y
	call set_next_square_color
	
	push next_x
	push next_y
	push color
	call print_square
	
	push position_history_arg
	push offset_of_place_in_arr
	push next_x
	push next_y
	call add_new_snake_position
	 
	
	
	
	add sp,4
	pop bp
	ret 10
endp move_snake


proc generate_apple

	mov dl, 13
	mov ah,2
	int 21h

	mov dx, offset end_massage
	mov ah, 9H
	int 21H 
	mov al,1
		
	mov al, [num_of_square]
	
	;print num_of_square minus NUMBER_OF_START_SQUARE
	sub al, NUMBER_OF_START_SQUARE
	mov ah,0
	mov cl,10
	div cl
	mov dl ,al
	;print tens digit 
	push ax
	add dl,30h
	mov ah, 2h
	int 21h
	;print units digit
	pop ax
	mov dl ,ah
	add dl,30h
	mov ah, 2h
	int 21h

	call random_x_pos
	call random_y_pos
	mov [apple_color],RED

	cmp [apple_counter],7
	je tripple_sqare
	cmp [apple_counter],5
	je confuse_apple
	cmp [apple_counter],10
	je fast_apple
	jmp skip_change_color
	tripple_sqare:
	mov [apple_color],CAYEN
	jmp skip_change_color
	confuse_apple:
	mov [apple_color],MAGNETA
	jmp skip_change_color
	fast_apple:
	mov [apple_color],YELLOW
	mov [apple_counter],0

	skip_change_color:
	call check_x_and_random_y
	push [random_x]
	push [random_y]
	push [apple_color]
	call print_square

inc [apple_counter]

ret
endp generate_apple


proc random_x_pos
	mov ah, 00
	INT 1Ah
	mov dh,0
	mov ax,dx
	mov cx,SQUARE_LINE_LENGTH
	div cl
	sub dl,ah
	mov dh,0
	add dx,50

	mov [random_x],dx
	end_proc_random_x_pos:
	;return random num in random_x var

ret
endp random_x_pos

proc random_y_pos
	mov ah, 00
	INT 1Ah
	mov dh,0
	mov ax,dx
	mov cl,SQUARE_HEIGHT
	div cl
	sub dl,ah
	mov dh,0
	mov [random_y],dx
	add [random_y], 25
	;return random num in random_y var
ret
endp random_y_pos

proc check_x_and_random_y
	x_or_y_isnt_vaild:
		;cmp [random_x],0
		;jg skip_x_to_low
		;call random_x_pos
		;jmp x_or_y_isnt_vaild
		
		skip_x_to_low:
		cmp [random_x],315
		jl skip_x_to_high
		add [random_x], 100
		jmp x_or_y_isnt_vaild
		
		skip_x_to_high:
		;cmp [random_y],20
		;jg skip_y_to_low
		;call random_y_pos
		;jmp x_or_y_isnt_vaild
		
		skip_y_to_low:
		cmp [random_y],195
		jl skip_y_to_high
		sub [random_y], 100
		jmp x_or_y_isnt_vaild

		skip_y_to_high:
ret
endp check_x_and_random_y


proc add_new_snake_position
	;arguments: x,y,offset_next_place_in_pos_history,history_pos_offset
	history_pos_offset equ [bp+10]
	offset_next_place_in_pos_history equ [bp+8]
	x equ [bp+6]
	y equ [bp+4]
	push bp
	mov bp,sp
	
	mov bx, offset_next_place_in_pos_history
	cmp [bx],SIZE_OF_HISTORY_POS
	jne skip_set_next_place_in_pos_history
	mov [bx],0
	skip_set_next_place_in_pos_history:
		mov si,[bx]
		mov ax,x
		mov bx,history_pos_offset
		mov [bx+si],ax
		add si, 2
		mov ax,y
		mov [bx+si],ax
		add si, 2
		mov bx,offset_next_place_in_pos_history
		mov [bx],si
	pop bp
	ret 8
endp add_new_snake_position

proc set_next_square_color
	; arguments: x,y
	x equ [bp+6]
	y equ [bp+4]
	push bp
	mov bp,sp
	
	mov bh,0
	mov cx,x
	mov dx,y
	add cx,2
	add dx,2
	mov ah,0Dh
	int 10h
	mov [next_square_color],al
	pop bp
	ret 4
endp set_next_square_color

proc erase_square
	; arguments: x, y
	x equ [bp+6]
	y equ [bp+4]
	push bp
	mov bp,sp
	
	push x
	push y
	push BLACK
	call print_square
	
	pop bp
	ret 4
endp erase_square


proc make_lines
	push [line_length]
	;----------- print horizental up line
	mov [line_length],320

	push 0
	push 20
	push WHITE

	call print_square
	;----------- print horizental down line
	push 0
	mov ax,200
	sub ax,SQUARE_HEIGHT
	push ax
	push WHITE

	call print_square

	pop [line_length]
	;----------- print vertical right line
	push [highet]

	mov ax,320
	sub ax,SQUARE_LINE_LENGTH
	push ax
	push 20
	mov [highet],180
	push WHITE
	call print_square
	;----------- print vertical left line
	push 0
	push 20
	push WHITE
	call print_square

	pop [highet]
	ret
endp make_lines

proc check_next_square_color
;arguments: next_square_color
	next_square_color_arg equ [bp+4]
	push bp
	mov bp, sp
	mov al,next_square_color_arg
	
	cmp al,BLACK
	je end_proc_check_next_square_color
	
	cmp al,RED
	je eat_apple
	
	cmp al,WHITE
	je loosing
	
	cmp al,GREEN
	je loosing
	
	cmp al,YELLOW
	je set_fast_apple
	
	cmp al,CAYEN
	je tripple_sqare_apple
	
	cmp al,MAGNETA
	je set_confuse_apple
	
	cmp al,BLUE
	je loosing
	
	jmp end_proc_check_next_square_color
	
	eat_apple:
	call eat_regular_apple
	jmp end_proc_check_next_square_color

	set_confuse_apple:
	call eat_confuse_apple
	jmp end_proc_check_next_square_color

	set_fast_apple:
	call eat_fast_apple
	jmp end_proc_check_next_square_color

	tripple_sqare_apple:
	call eat_tripple_sqare_apple
	jmp end_proc_check_next_square_color

	loosing:
	mov [is_lost],TRUE
	end_proc_check_next_square_color:
	
	pop bp
	ret 2
endp check_next_square_color

proc eat_regular_apple
	;cancel confuse apple
	mov [right_direction_on_key_board],D_KEYBOARD
	mov [left_direction_on_key_board],A_KEYBOARD
	mov [right_onKeyboard],RIGHT_KEYBOARD
	mov [left_onKeyboard],LEFT_KEYBOARD
	
	;cancel fast apple
	mov [sleep_time],REGULAR_SLEEP_TIME
	
	inc [num_of_square]
	push 0
	call play_music_sounds
	call generate_apple
	ret
endp eat_regular_apple

proc eat_fast_apple
	mov [sleep_time],FAST_SLEEP_TIME
	inc [num_of_square]
	push 1
	call play_music_sounds
	call generate_apple
	ret
endp eat_fast_apple

proc eat_tripple_sqare_apple
	add [num_of_square],3
	push 2
	call play_music_sounds
	call generate_apple
	ret
endp eat_tripple_sqare_apple

proc eat_confuse_apple
	mov [right_direction_on_key_board],A_KEYBOARD
	mov [left_direction_on_key_board], D_KEYBOARD
	mov [right_onKeyboard],LEFT_KEYBOARD
	mov [left_onKeyboard],RIGHT_KEYBOARD
	inc [num_of_square]
	push 3
	call play_music_sounds
	call generate_apple
	ret
endp eat_confuse_apple

proc  play_music_sounds ;--- arguments offset of music_sounds
	offset_of_music_sound equ [bp+4]
	push bp
	mov bp,sp
	mov bx, offset_of_music_sound
	mov ax, [offset music_sounds + bx]	
	out 42h,al
	mov al,ah
	out 42h,al				; send I/O output
	mov al,61h
	mov al,11b
	out 61h,al
	
	;calling sleep otherwise you cant hear sound
	push REGULAR_SLEEP_TIME
	call sleep
	call stop_playing_nusic
	pop bp
	ret 2
endp play_music_sounds


proc stop_playing_nusic
	mov al,61h				
	out 61h,al
	ret
endp stop_playing_nusic

proc erase_last_square
	;arguments: position_history,place_in_arr
	position_history_arg equ [bp+6]
	place_in_arr equ [bp+4]
	push bp
	mov bp,sp

	mov cx,place_in_arr
	mov al,POINT_OBJECT_SIZE
	mov bl,[num_of_square]
	mul bl
	cmp ax,cx
	jg num_of_square_bigger_then_next_place_in_pos_history ;jump is greater
	sub cx,ax

	jmp skip_num_of_square_bigger_then_next_place_in_pos_history
	num_of_square_bigger_then_next_place_in_pos_history:
		sub ax,cx
		mov cx,SIZE_OF_HISTORY_POS
		sub cx,ax

	skip_num_of_square_bigger_then_next_place_in_pos_history:	
	mov si,cx
	mov bx,position_history_arg
	mov ax,[bx+si]
	push ax
	mov ax,[bx+si+2]
	push ax
	call erase_square

	
	pop bp
	ret 4
endp erase_last_square

proc snake1
	push offset position_history
	push [next_place_in_pos_history]
	call erase_last_square
	
	push GREEN
	push offset next_place_in_pos_history
	push [current_direction]
	push offset position_history
	push [next_place_in_pos_history]
	call move_snake
	
	mov al,[next_square_color]
	push ax
	call check_next_square_color
	ret
endp snake1

proc snake2
	push offset snake2_position_history
	push [snake2_next_place_in_pos_history]
	call erase_last_square
	
	push BLUE
	push offset snake2_next_place_in_pos_history
	push [snake2_current_direction]
	push offset snake2_position_history
	push [snake2_next_place_in_pos_history]
	call move_snake
	
	mov al,[next_square_color]
	push ax
	call check_next_square_color
	ret
endp

proc game_loop
WaitForKey:

	mov al,[is_lost]
	cmp al,TRUE
	je ending

	push [sleep_time]
	call sleep
	
	;---------- snake1
	call snake1
	;--------------snake2
	cmp [is_want_2_players],FALSE
	je skip_mov_snake_2
	call snake2
	skip_mov_snake_2:
	
	;check if there is a a new key in buffer
	in al, 64h
	cmp al, 10b
	; If there isn't a new key, jump to start.
	je WaitForKey
	in al, 60h	
	cmp al, [saveKey]  ;check if the key is same as already pressed
	je WaitForKey
	mov [saveKey], al  ;new key - store it
	
	
	cmp al,6
	je pressed_add_square
	
	;------end
	cmp al,1
	je ending
	
	call change_snake1_direction
		
	cmp [is_want_2_players],FALSE
	je skip_change_direction_snake_2

	call change_snake2_direction
	
	skip_change_direction_snake_2:
	
	jmp WaitForKey

	pressed_add_square:
		inc [num_of_square]
		call generate_apple
		jmp WaitForKey
ending:
ret
endp game_loop

proc change_snake1_direction
	cmp al,[right_direction_on_key_board]
	je pressed_right
	
	cmp al,[left_direction_on_key_board]
	je pressed_left
	
	cmp al,S_KEYBOARD
	je pressed_down

	cmp al,W_KEYBOARD
	je pressed_up
	
	jmp end_proc_change_snake1_direction
	
	pressed_up:
		cmp [current_direction],DOWN_DIRECTION
		je end_proc_change_snake1_direction
		mov [current_direction],UP_DIRECTION
		jmp end_proc_change_snake1_direction
	
	pressed_down:
		cmp [current_direction],UP_DIRECTION
		je end_proc_change_snake1_direction
		mov [current_direction],DOWN_DIRECTION
		jmp end_proc_change_snake1_direction
	
	pressed_left:
		cmp [current_direction],RIGHT_DIRECTION
		je end_proc_change_snake1_direction
		mov [current_direction],LEFT_DIRECTION
		jmp end_proc_change_snake1_direction
	
	pressed_right:
		cmp [current_direction],LEFT_DIRECTION
		je end_proc_change_snake1_direction
		mov [current_direction],RIGHT_DIRECTION
	end_proc_change_snake1_direction:
	ret
endp change_snake1_direction


proc change_snake2_direction

	cmp al,[right_onKeyboard]
	je snake2_pressed_right
	
	cmp al,[left_onKeyboard]
	je snake2_pressed_left
	
	cmp al,DOWN_KEYBOARD
	je snake2_pressed_down

	cmp al,UP_KEYBOARD
	je snake2_pressed_up
	
	jmp end_proc_change_snake1_direction
	
	snake2_pressed_up:
		cmp [snake2_current_direction],DOWN_DIRECTION
		je end_proc_change_snake2_direction
		mov [snake2_current_direction],UP_DIRECTION
		jmp end_proc_change_snake2_direction
	
	snake2_pressed_down:
		cmp [snake2_current_direction],UP_DIRECTION
		je end_proc_change_snake2_direction
		mov [snake2_current_direction],DOWN_DIRECTION
		jmp end_proc_change_snake2_direction
	
	snake2_pressed_left:
		cmp [snake2_current_direction],RIGHT_DIRECTION
		je end_proc_change_snake2_direction
		mov [snake2_current_direction],LEFT_DIRECTION
		jmp end_proc_change_snake2_direction
	
	snake2_pressed_right:
		cmp [snake2_current_direction],LEFT_DIRECTION
		je end_proc_change_snake2_direction
		mov [snake2_current_direction],RIGHT_DIRECTION
	end_proc_change_snake2_direction:
	ret
endp change_snake2_direction

proc new_line
	;carriage return
	mov dl, 10
	mov ah,2
	int 21h
	;new line
	mov dl, 13
	mov ah,2
	int 21h
	ret
endp new_line

proc open_screen
	call new_line
	
	mov ax, offset start_message
	mov bl, CAYEN
	mov cx,38
	call print_with_color
	call new_line
	
	call new_line
	
	mov ax, offset rules
	mov bl,GREEN
	mov cx,45
	call print_with_color
	call new_line
	
	call new_line
	
	mov dx, offset eat_apple_rule
	mov ah, 9H
	int 21H 
	mov al,1
	call new_line
	
	mov dx, offset dont_touch_snake
	mov ah, 9H
	int 21H 
	mov al,1
	call new_line
	
	mov dx, offset dont_touch_lines
	mov ah, 9H
	int 21H 
	mov al,1
	call new_line
	
	mov dx, offset two_players_rule
	mov ah, 9H
	int 21H
	mov al, 1
	call new_line
	
	call new_line
	
	mov ax, offset movment
	mov bl,GREEN
	mov cx,47
	call print_with_color
	call new_line
	
	call new_line
	
	mov dx, offset first_player_movment
	mov ah, 9H
	int 21H 
	mov al,1
	call new_line
	
	mov dx, offset second_player_movment
	mov ah, 9H
	int 21H 
	mov al,1
	call new_line
	
	call new_line
	
	mov ax, offset special_apples
	mov bl,GREEN
	mov cx, 54
	call print_with_color
	call new_line
	
	call new_line
	
	mov ax,offset STRING_REGULAR_APPLE
	mov bl,RED
	mov cx,LEN_REGULAR_APPLE_STRING
	call print_with_color
	call new_line

	mov ax,offset STRING_FAST_APPLE
	mov bl,YELLOW
	mov cx,LEN_FAST_APPLE_STRING
	call print_with_color
	call new_line

	mov ax,offset STRING_TRIPPLE_APPLE
	mov bl,CAYEN
	mov cx,LEN_TRIPPLE_APPLE_STRING
	call print_with_color
	call new_line

	mov ax,offset STRING_CONFUSE_APPLE
	mov bl,MAGNETA
	mov cx,LEN_CONFUSE_APPLE_STRING
	call print_with_color
	call new_line
	
	call new_line

	;get input from user to know how many players are playing
	how_much_players_input_loop:
		mov dx, offset how_many_players_are_playing
		mov ah, 9h
		Int 21h

		call new_line
		
		; getting user input.
		mov ah, 1h
		int 21h
		sub al,31h
		
		push ax
		call new_line
		pop ax
		
		;Check if input is valid (1/2)
		cmp al,TRUE
		jg how_much_players_input_loop
		cmp al,FALSE
		jl how_much_players_input_loop
		
	mov [is_want_2_players],al
	ret
endp open_screen


proc return_to_text_mode
	mov ah, 0
	mov al, 2
	int 10h
	ret
endp return_to_text_mode


proc print_with_color
	;ax <--- offset of the String
	;bl <--- color 
	;cx <--- number of chars
	mov dx,ax
	mov ah, 9

	int 10h

	int 21H
	ret 
endp print_with_color




 proc SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp SetGraphic

proc end_screen
	push 4
	call play_music_sounds
	call return_to_text_mode
	mov al,0
	; call mov_to_the_middle_of_the_screen
	mov dx, offset end_massage
	mov ah, 9H
	int 21H 
	mov al,1
	
	; call mov_to_the_middle_of_the_screen
	
	;print num_of_square minus NUMBER_OF_START_SQUARE
	sub [num_of_square],NUMBER_OF_START_SQUARE
	mov ah,0
	mov al,[num_of_square]
	mov cl,10
	div cl
	mov dl ,al
	;print tens digit
	push ax
	add dl,30h
	mov ah, 2h
	int 21h
	;print units digit
	pop ax
	mov dl ,ah
	add dl,30h
	mov ah, 2h
	int 21h
	
	call new_line

	mov ax, offset credit
	mov bl, YELLOW
	mov cx,28
	call print_with_color
	call new_line
	call new_line

	mov ax, offset credit_one
	mov bl, CAYEN
	mov cx,27
	call print_with_color
	call new_line
	call new_line

	mov ax, offset credit_two
	mov bl, GREEN
	mov cx,25
	call print_with_color
	call new_line
	call new_line

	mov ax, offset credit_three
	mov bl, MAGNETA
	mov cx,22
	call print_with_color
	call new_line
	call new_line
	
	ret
endp end_screen


proc mov_to_the_middle_of_the_screen;----al is parmater wiche line to you want
; Set cursor location to (11, 33)
	 MOV BH, 0
	 MOV DH, 11
	 add dh,al
	 MOV DL, 33
	 MOV AH, 2H
	 INT 10H 
	 ret
 endp mov_to_the_middle_of_the_screen


start:
	mov ax, @data
	mov ds, ax
	call open_screen
	call SetGraphic
	call make_lines
	call new_line

	call generate_apple
	cmp [is_want_2_players],TRUE
	jne skip_2_apples
	; otherwise two apples generate in the same place
	mov cx,5
	sleep_for_apples_gap:
		push cx
		
		push START_SLEEP_TIME
		call sleep
		
		pop cx
		loop sleep_for_apples_gap
		
	
	call generate_apple
	skip_2_apples:
	call game_loop
	call end_screen
	
	exit:
	mov ax, 4c00h
	int 21h
END start