;Macro เรียกค่ามาใช้ได้ตลอด
ConvertDecimal MACRO  decimal, printableDecimal ; แปลงค่า 
	mov al,decimal ; ย้ายค่าไปเก็บไว้ al
	xor ah, ah  ; รับค่า 
	mov cl, 10 ; กำหนด cl เก็บ 10
	div cl ; หาร al เป็นตัวตั้ง
	add ax, 3030h ; ผลลัพธ์จาก al/cl
	mov printableDecimal,ax ; นำ ax ส่งไป printableDecimal
ENDM ConvertDecimal  ; จบ line คำสั่งแปลงฐาน

Print MACRO row, column, color 
   push ax ; push เข้า stack
   push bx
   push cx
   push dx   
   
   mov Ah, 02h ;จองข้อมูลหน้าจอ
   mov Bh, 0h ;เซ้ทหน้าจอ
   mov Dh, row ;ผลลัพธ์เก็บไว้ที่ Dh
   mov Dl, column 
   INT 10h ; intเกี่ยวกับจอแสดงผล

   mov Ah, 09 ; เซ็ทค่าพิมขึ้นจอ
   mov Al, ' ' ; แสดงข้อความ
   mov Bl, color ; ใช้ Bl กำหนดสีหน้าจอ
   mov Cx, 1h
   INT 10h  
   
   pop dx ;เอา stack ออก
   pop cx
   pop bx
   pop ax
ENDM Print     

PrintShooter MACRO column
   push ax
   push bx
   push cx
   push dx   
   
   mov Ah, 02h
   mov Bh, 0h
   mov Dh, 24
   mov Dl, column
   INT 10h 

   mov Ah, 09
   mov Al, 127  ; แหลมลูกศร
   mov Bl, 02h
   mov Cx, 1h
   INT 10h   
   
   pop dx
   pop cx
   pop bx
   pop ax

ENDM PrintShooter    

PrintShot MACRO row, column
   push ax
   push bx
   push cx
   push dx   
   
   mov Ah, 02h
   mov Bh, 0h
   mov Dh, row
   mov Dl, column
   INT 10h 

   mov Ah, 09   ; สีกระสุนปืน
   mov Al, 254
   mov Bl, 0Ch 
   mov Cx, 1h
   INT 10h   
   
   pop dx
   pop cx
   pop bx
   pop ax

ENDM PrintShot  

PrintText Macro row , column , text
   push ax
   push bx
   push cx
   push dx   
   
   mov ah,2
   mov bh,0
   mov dl,column
   mov dh,row
   int 10h

   mov ah, 9
   mov dx, offset text
   int 21h
   
   pop dx
   pop cx
   pop bx
   pop ax

ENDM PrintText

Delete Macro row, column
   mov Ah, 02h
   mov Bh, 0h
   mov Dh, row
   mov Dl, column
   int 10h 

   mov Ah, 09
   mov Al, ' '
   mov Bl, 0h
   mov Cx, 1h
   int 10h 

ENDM Delete

Delay  Macro Seconds, MilliSeconds
    push ax
    push bx
    push cx
    push dx 
    push ds

    mov cx, Seconds		;Cx,Dx : number of microseconds to wait
    mov dx, MilliSeconds
    mov ah, 86h
    int 15h
	
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
ENDM Delay 


ClearScreen MACRO
        
    mov ax, 0600h  ;al=0 => Clear
    mov bh, 07     ;bh=07 => Normal Attributes              
    mov cx, 0      ;From (cl=column, ch=row)
    mov dl, 80     ;To dl=column
    mov dh, 25     ;To dh=row
    int 10h    
    
    ;ขยับเม้า
    mov ax, 0
    mov ah, 2
    mov dx, 0
    int 10h   
    
ENDM ClearScreen
;=========================================
.MODEL SMALL
.STACK 64    
.DATA
    StartScreen      db '              ====================================================',0ah,0dh
                     db '             ||                                                  ||',0ah,0dh
                     db '             ||         >>  Shooting rockets Game  <<            ||',0ah,0dh
                     db '             ||__________________________________________________||',0ah,0dh
                     db '             ||                                                  ||',0ah,0dh
                     db '             ||     Use left and right key to move gunshooter    ||',0ah,0dh
                     db '             ||          and space button to shoot bullet        ||',0ah,0dh
                     db '             ||                                                  ||',0ah,0dh
                     db '             ||              You begin with 6 lifes              ||',0ah,0dh
                     db '             ||  Score the highest you can score before you die  ||',0ah,0dh
                     db '             ||        Scoring points increase your lifes        ||',0ah,0dh
                     db '             ||                                                  ||',0ah,0dh
                     db '             ||            Press Enter to start playing          ||',0ah,0dh
                     db '             ||            Press ESC to Exit                     ||',0ah,0dh
                     db '              ====================================================',0ah,0dh
                     db '$',0ah,0dh
    GameoverScreen   db '          __________________________________________________',0ah,0dh
                     db '             ||                                                  ||',0ah,0dh
                     db '             ||               >> GAMEOVER <<                     ||',0ah,0dh
                     db '             ||__________________________________________________||',0ah,0dh
                     db '$',0ah,0dh
    RocketColLeft    db ?
    RocketColRight   db ?
    RocketColCenter  db ?


    RocketRow        db 15
    RocketColor      db 0d0h                                                                             ; สียานศัตรู


    ShooterCol       db 40
   
    ShotRow          db ?
    ShotCol          db ?
    ShotStatus       db 0                                                                                ;สถานะกระสุน

    lifes            db 6
    Misses           db 0
    Hits             db 0                                                                                ;คะแนน
    PlayerName       db 15, ?,  15 dup('$')                                                              ;กำหนดชื่อได้ไม่เกิน 15
    AskPlayerName    db 'Enter your name: ','$'
    Disp_Hits        db 'Score: ??','$'
    Disp_lifes       db 'lifes: ?','$'
    GameTitle        db ' >>  Shooting rockets Game  >> ','$'
    FinalScoreString db 'Your final score is: ??','$'
    RocketDirection  db 0                                                                                ;0=ซ้าย, 1=ขวา
    EasyMode         db 'Easy Mode','$'
    HardMode         db 'Hard Mode','$'
    ExtremeMode      db 'Extreme Mode','$'
    Instruction      db 'Press ESC to exit - Space to fire - Right/Left arrows to move','$'
    separate         db '>>','$'
    ;==================================================

.CODE
ResetGame PROC
    ; รีเซ็ทค่าทั้งหมด
                             mov            RocketColLeft, 0                          ; รีเซ็ท column
                             mov            RocketColCenter, 1
                             mov            RocketColRight, 2
                             mov            RocketRow, 15
                             mov            RocketColor, 0d0h
                             mov            ShooterCol, 40
                             mov            ShotRow, 0
                             mov            ShotCol, 0
                             mov            ShotStatus, 0
                             mov            lifes, 6
                             mov            Misses, 0
                             mov            Hits, 0
                             ret
ResetGame ENDP

MAIN PROC FAR
                             mov            ax, @DATA
                             mov            ds, ax
    
                             ClearScreen
                             call           StartMenu
                             ClearScreen
                             call           DrawInterface
                             call           ResetRocket
                             PrintShooter   40
                             call           UpdateStrings
  
    MainLoop:                
                             cmp            RocketDirection, 1
                             jz             moveRocketRight                           ; j=0
                             call           RocketMoveLeft
                             jmp            AfterRocketMove
   
    moveRocketRight:         
                             call           RocketMoveRight
   
    AfterRocketMove:         
                             cmp            ShotStatus, 1
                             jnz            NoShotExist                               ; j!=0
                             call           CheckShotStatus                           ;เช็คกระสุน
   
                             cmp            ShotStatus, 1
                             jnz            NoShotExist
                             call           MoveShot
                             PrintShooter   ShooterCol                                ;ยิงแล้วยานจะขยับไม่ได้
   
    NoShotExist:             
                             mov            ah,1h
                             int            16h                                       ;ZF=1 when a key is pressed
                             jz             NokeyPress
                             call           KeyisPressed
   
    NokeyPress:              
                             call           Difficulty
   
    EndOfMainLoop:           
                             jmp            MainLoop
                             hlt                                                      ; รอการสั่งคำสั่งถัดไป
MAIN ENDP

    ;==================================================
UpdateStrings Proc
                             push           ax
	 
                             ConvertDecimal Hits, ax
                             mov            Disp_Hits[8], ah
                             mov            FinalScoreString[22], ah
                             mov            Disp_Hits[7], al
                             mov            FinalScoreString[21], al
		
                             mov            ah,lifes
                             add            ah, 30h
                             mov            Disp_lifes[7], ah
	
                             PrintText      1 , 56 , Disp_Hits
                             PrintText      1 , 70 , Disp_lifes

                             pop            ax
                             ret
UpdateStrings ENDP

    ;==================================================
RocketMoveLeft Proc
                             dec            RocketColLeft
                             Print          RocketRow ,RocketColLeft, RocketColor
                             Delete         RocketRow, RocketColRight
                             dec            RocketColRight
                             dec            RocketColCenter
	
                             cmp            RocketColLeft ,0
                             Jnz            endOfRocketMoveLeft
                             call           DeleteRocket
                             call           ResetRocket
    endOfRocketMoveLeft:     ret
RocketMoveLeft ENDP

    ;==================================================
RocketMoveRight Proc
                             inc            RocketColRight
                             Print          RocketRow ,RocketColRight, RocketColor
                             Delete         RocketRow, RocketColLeft
                             inc            RocketColleft
                             inc            RocketColCenter
	
                             cmp            RocketColRight ,80
                             Jnz            endOfRocketMoveRight
                             call           DeleteRocket
                             call           ResetRocket
    endOfRocketMoveRight:    ret
RocketMoveRight ENDP

    ;==================================================
KeyisPressed Proc
                             mov            ah,0
                             int            16h

                             cmp            ah,4bh                                    ;ขยับยานตัวตัวเองกดลูกศรซ้าย
                             jnz            NotLeftKey
                             call           MoveShooterLeft
                             jmp            EndofKeyisPressed
	
    NotLeftKey:              
                             cmp            ah,4dh
                             jnz            NotRightKey                               ;ขยับไปทางขวาถ้ากดปุ่มลูกศรขวา
                             call           MoveShooterRight
                             jmp            EndofKeyisPressed
	
    NotRightKey:             
                             cmp            ah,1H                                     ;esc ออก

                             Jnz            NotESCKey
                             call           Gameover
		
    NotESCKey:               
                             cmp            ah,39h                                    ;กดปุ่ม spacebar

                             jnz            EndofKeyisPressed
                             cmp            ShotStatus, 1
                             jz             EndofKeyisPressed
                             mov            al,1                                      ;พร้อมยิงอีกครั้ง
                             mov            ShotStatus,1
                             mov            al, ShooterCol
                             mov            ShotCol, al
                             mov            al, 24                                    ;จะถูกส่งไปที่ Mainloop
                             mov            ShotRow,al
			
    EndofKeyisPressed:       
                             ret
KeyisPressed ENDP

    ;==================================================
MoveShooterLeft Proc
                             cmp            ShooterCol, 0
                             JZ             NoMoveLeft
                             dec            ShooterCol                                ; ลดค่าไป 1
                             PrintShooter   ShooterCol
                             mov            al, ShooterCol
                             inc            al                                        ; เพิ่มค่ามา1
                             delete         24, al
    NoMoveLeft:              
                             ret
MoveShooterLeft ENDP

    ;==================================================
MoveShooterRight Proc
                             cmp            ShooterCol, 79
                             JZ             NoMoveRight
                             inc            ShooterCol
                             PrintShooter   ShooterCol
                             mov            al, ShooterCol
                             dec            al
                             delete         24, al
    NoMoveRight:             
                             ret
MoveShooterRight ENDP

    ;==================================================
MoveShot Proc
                             dec            ShotRow
                             PrintShot      ShotRow,ShotCol
                             mov            al, ShotRow
                             inc            al
                             delete         al, ShotCol
                             ret
MoveShot ENDP

    ;==================================================
CheckShotStatus Proc
                             push           ax
	
                             mov            ah,RocketRow
                             inc            ah                                        ;ตรวจสอบหากถูกยิง
                             cmp            ah, ShotRow
                             JNZ            CheckEndRange
    ;เช็คเมื่อยิงโดน
                             mov            al,ShotCol
                             cmp            al, RocketColLeft
                             JZ             Hit
                             cmp            al, RocketColCenter
                             JZ             Hit
                             cmp            al, RocketColRight
                             JZ             Hit
                             cmp            RocketDirection, 0
                             jnz            RightDirection
                             mov            ah, RocketColLeft
                             dec            ah
                             cmp            al, ah
                             JZ             Hit
                             jmp            CheckEndRange
    RightDirection:          
                             mov            ah, RocketColRight
                             inc            ah
                             cmp            al, ah
                             JZ             Hit
		
    ;==================================================
    CheckEndRange:           
                             cmp            ShotRow, 2                                ;จะหยุดเมื่อถึงRow
                             jnz            noChange
                             dec            Lifes
                             cmp            lifes, 0
                             jnz            ResetTheShot
                             call           Gameover
	 
    Hit:                     inc            Hits
                             inc            lifes
                             call           DeleteRocket
                             call           ResetRocket
    ResetTheShot:            
                             call           ResetShot
                             call           UpdateStrings
    noChange:                
	 
                             pop            ax
                             ret
CheckShotStatus ENDP

    ;==================================================
Difficulty Proc
	
                             cmp            Hits, 5
                             jle            EasyGame
                             cmp            Hits, 10
                             jle            HardGame
                             Delay          0,10000
                             PrintText      0, 67, ExtremeMode                        ;Extreme Mode เมื่อ <10
                             jmp            EndDifficulty
	
    HardGame:                Delay          0,20000                                   ;Hard Mode เมื่อยิง => 10 & > 5
                             PrintText      0, 70, HardMode
                             jmp            EndDifficulty
	
    EasyGame:                Delay          1,0                                       ;Easy Mode ยิงโดนต่ำกว่า 5
    EndDifficulty:           
                             ret
Difficulty ENDP
    ;==================================================
DeleteRocket Proc
                             Delete         RocketRow, RocketColLeft
                             Delete         RocketRow, RocketColCenter
                             Delete         RocketRow, RocketColRight
                             ret
DeleteRocket ENDP

    ;==================================================
RandomiseRocketRow Proc
                             push           ax
                             push           bx
                             push           cx
                             push           dx
   
    ; Range of row= [5,24]
                             mov            ah, 2ch
                             int            21h                                       ;รับค่าเวลา DH = second   Dl=MilliSeconds
                             xor            ax, ax
                             mov            al, dl
                             mov            bl, 20                                    ; หาค่า[0-19]
                             div            bl
                             add            ah, 3                                     ;ผลลัพธ์จะอยู่ช่วง 3-22
                             mov            RocketRow, ah
   
    ;Change the color of rocket
    NotBlack:                
                             add            RocketColor ,10h                          ;ตรวจสอบสียาน
                             mov            ah, RocketColor
                             and            ah, 10h
                             cmp            ah ,00h
                             jz             NotBlack
        
                             pop            dx
                             pop            cx
                             pop            bx
                             pop            ax
                             ret
RandomiseRocketRow ENDP

    ;==================================================
ResetRocket Proc
                             call           RandomiseRocketDirection
                             call           RandomiseRocketRow
	
                             cmp            RocketDirection, 1
                             jnz            movementLeft
                             mov            RocketColLeft, 0
                             mov            RocketColCenter, 1
                             mov            RocketColRight, 2
                             jmp            EndOfResetRocket
	
    movementLeft:            
                             mov            RocketColLeft, 78
                             mov            RocketColCenter, 79
                             mov            RocketColRight, 80
    
    EndOfResetRocket:        
                             ret
ResetRocket ENDP

    ;==================================================
RandomiseRocketDirection Proc
                             push           ax
                             push           bx
                             push           cx
                             push           dx                                        ;รักษาค่าคงที่ของstackเอาไว้

                             mov            ah, 2ch                                   ;โหลดระบบค่าเวลา เข้า ah
                             int            21h                                       ; DH = second   Dl=MilliSeconds
                             xor            ax, ax
                             mov            al, dl
                             mov            bl, 2                                     ;ผลลัพธ์เลขคู่ 0=ซ้าย คี่ 1=ขวา โดยนำไปหาร 2
                             div            bl
                             mov            RocketDirection,ah

                             pop            dx
                             pop            cx
                             pop            bx
                             pop            ax
                             ret
                             ret
RandomiseRocketDirection ENDP

    ;==================================================
ResetShot Proc
                             delete         ShotRow, ShotCol
                             mov            al,0
                             mov            ShotStatus,al
                             ret
ResetShot ENDP
    ;==================================================
StartMenu Proc
    
                             push           ax
                             push           bx
                             push           cx
                             push           dx
                             push           ds

                             ClearScreen
    LoopOnName:              
                             PrintText      8,8,AskPlayerName

    ;รับค่าชื่อผู้เล่น
                             mov            ah, 0Ah
                             mov            dx, offset PlayerName
                             int            21h

                             cmp            PlayerName[1], 0                          ;เช็คว่าได้ใส่ชื่อหรือไม่
                             jz             LoopOnName

    ;เช็คตัวอักษรตัวเล็กตัวใหญ่
                             cmp            PlayerName[2], 40h
                             jbe            LoopOnName
                             cmp            PlayerName[2], 7Bh
                             jae            LoopOnName
                             cmp            PlayerName[2], 60h
                             jbe            anotherCheck
                             ja             ExitLoopOnName
    anotherCheck:            
                             cmp            PlayerName[2], 5Ah
                             ja             LoopOnName

    ExitLoopOnName:          
                             ClearScreen
                             PrintText      1,1,StartScreen

    ;ซ่อนเม้าส์
                             mov            ah,01h
                             mov            cx,2607h
                             int            10h

    checkforinput:           
                             mov            AH,0
                             int            16H

                             cmp            al,13                                     ;Enter to Start Game
                             JE             StartTheGame

                             cmp            ah,1H                                     ;Esc to exit the game
                             JE             ExitMenu
                             JNE            checkforinput

    ExitMenu:                
                             mov            ah,4CH
                             int            21H

    StartTheGame:            
                             pop            ds
                             pop            dx
                             pop            cx
                             pop            bx
                             pop            ax
                             RET
StartMenu ENDP
    ;==================================================


Gameover Proc
                             ClearScreen
                             
                             PrintText      1, 30, PlayerName
                             PrintText      3, 25,FinalScoreString
                             PrintText      5, 5 ,GameoverScreen
                             mov            AH,0
                             int            16H

                             cmp            al,13
                             call           ResetGame
                             call           MAIN

                             mov            ah,4CH
                             int            21H
                             ret
                        
Gameover ENDP
    ;==================================================
DrawInterface Proc
	
                             push           ax
                             push           cx
                             push           dx
	
    ;กลับไปโค้ดด้านบน
	
                             mov            al, 0
                             mov            cx, 80
    DrawLineloop1:           
                             Print          1, al, 30h
                             inc            al
                             loop           DrawLineloop1
	
                             mov            al,0
                             mov            cx, 65
    DrawLineloop2:           
                             Print          0, al, 70h
                             inc            al
                             loop           DrawLineloop2
	
                             mov            al,' '
                             mov            PlayerName[0],al
                             mov            PlayerName[1],al
                             PrintText      1 , 0 , PlayerName
                             PrintText      1 , 56 , Disp_Hits
                             PrintText      1 , 70 , Disp_lifes
                             PrintText      1 , 24 , GameTitle
                             PrintText      0, 70, EasyMode
                             PrintText      0, 2, Instruction
                             PrintText      1, 67,separate
                             pop            dx
                             pop            cx
                             pop            ax
                             RET
DrawInterface ENDP

    ;==================================================
END MAIN    