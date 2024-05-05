.MODEL SMALL
.STACK 100h

.DATA
    DUCK_SHOOT_MSG DB "DUCK SHOOT$", 0
    GAME_A_MSG DB "GAME A  1 DUCK$", 0
    ENTER_USERNAME_MSG DB 13, 10, "Enter username: $", 0
    username_buffer DB 20 DUP('$')  
    newline DB 13, 10, "$", 0  
    ROUND_1_MSG DB "ROUND 1", 0
    GAME_SCREEN_MSG DB "Game Screen", 0
    score_msg DB "Score: ", 0

.CODE
MAIN PROC
    MOV AX, @DATA          ; Load data segment address into AX
    MOV DS, AX 
    
    mov ah,00h            ; Set DS to point to data segment
    mov al,03h
    int 10h
    
title_page:
    ; Clear screen
    MOV AH, 00h            ; Set video mode (BIOS interrupt)
    MOV AL, 13h            ; Mode 13h (320x200 256-color VGA)
    INT 10h                ; Call video interrupt

    ; Set cursor position for "DUCK SHOOT"
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV BH, 00h            ; Page number
    MOV DH, 8              ; Row = 8 (slightly above the center)
    MOV DL, 14             ; Column = 14 (center)
    INT 10h                ; Call video interrupt

    MOV SI, OFFSET DUCK_SHOOT_MSG  ; SI points to message

    ; Print "DUCK SHOOT" message (first line, "DUCK" in bold)
print_duck_shoot:
    LODSB                  ; Load next character into AL from SI
    CMP AL, ' '            ; Check if space
    JE print_duck_shoot_bold ; If space, jump to printing "SHOOT"
    CMP AL, '$'            ; Check if end of string
    JE print_enter_username_msg  ; If end of string, jump to print_enter_username_msg

    MOV AH, 0Eh            ; BIOS interrupt to print character
    MOV BH, 00h            ; Page number
    MOV BL, 0Ch            ; Attribute (light red on black)
    INT 10h                ; Call video interrupt

    JMP print_duck_shoot   ; Repeat for the next character

print_duck_shoot_bold:
    ; Print "DUCK" in bold font
    MOV AH, 0Eh            ; BIOS interrupt to print character
    MOV BH, 00h            ; Page number
    MOV BL, 0Ch 
    add bl, 08h      ; Attribute (light red on black, bold)
    INT 10h                ; Call video interrupt

    JMP print_duck_shoot   ; Continue printing the rest of the string

print_enter_username_msg:
    ; Set cursor position for "ENTER USERNAME"
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV DH, 12             ; Row = 12
    MOV DL, 14             ; Column = 14 (center)
    INT 10h                ; Call video interrupt

    MOV SI, OFFSET ENTER_USERNAME_MSG  ; SI points to message
    CALL print_string       ; Print "Enter username" message

    ; Set cursor position for user input
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV DH, 14             ; Row = 14
    MOV DL, 20             ; Column = 20
    INT 10h                ; Call video interrupt

    ; Read username from user
    LEA DX, username_buffer  ; DS:DX points to username buffer
    MOV AH, 0Ah            ; BIOS interrupt to read string
    INT 21h                ; Call DOS interrupt

    ; Move to the next page if enter is pressed
    MOV AH, 00h            ; Wait for key press
    INT 16h                ; Call BIOS interrupt

    CMP AL, 0Dh            ; Check if Enter key pressed
    JNE print_enter_username_msg  ; If not, repeat input

menu_page:
    ; Clear screen
    MOV AH, 00h            ; Set video mode (BIOS interrupt)
    MOV AL, 13h            ; Mode 13h (320x200 256-color VGA)
    INT 10h                ; Call video interrupt

    ; Set cursor position for "DUCK SHOOT"
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV BH, 00h            ; Page number
    MOV DH, 8              ; Row = 8 (slightly above the center)
    MOV DL, 14             ; Column = 14 (center)
    INT 10h                ; Call video interrupt

    MOV SI, OFFSET DUCK_SHOOT_MSG  ; SI points to message

    ; Print "DUCK SHOOT" message (second line, "SHOOT" in bold)
print_duck_shoot_menu:
    LODSB                  ; Load next character into AL from SI
    CMP AL, '$'            ; Check if end of string
    JE print_game_a_msg    ; If end of string, jump to print_game_a_msg

    MOV AH, 0Eh            ; BIOS interrupt to print character 
    MOV BH, 00h            ; Page number
    MOV BL, 0Ch            ; Attribute (light red on black)
    INT 10h                ; Call video interrupt

    JMP print_duck_shoot_menu   ; Repeat for the next character

print_game_a_msg:
    ; Set cursor position for "GAME A 1 DUCK"
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV DH, 10             ; Row = 10
    MOV DL, 14             ; Column = 14 (center)
    INT 10h                ; Call video interrupt

    MOV SI, OFFSET GAME_A_MSG  ; SI points to message

    ; Print "GAME A 1 DUCK" message
print_game_a_menu:
    LODSB                  ; Load next character into AL from SI
    CMP AL, '$'            ; Check if end of string
    JE check_game_button  ; If end of string, jump to check_game_button

    MOV AH, 0Eh            ; BIOS interrupt to print character
    MOV BH, 00h            ; Page number
    MOV BL, 0Ah            ; Attribute (light green on black)
    INT 10h                ; Call video interrupt

    JMP print_game_a_menu  ; Repeat for the next character

check_game_button:
    ; Check if the user pressed the "GAME A 1 DUCK" button
    MOV AH, 02h            ; Get cursor position (BIOS interrupt)
    INT 10h                ; Call video interrupt
    CMP DH, 10             ; Check if cursor is on row 10 (where "GAME A 1 DUCK" is located)
    JNE print_username_menu  ; If not, continue with the menu loop

    CMP DL, 14             ; Check if cursor is on column 14 (center)
    JNE print_username_menu  ; If not, continue with the menu loop


    MOV AH, 09h            ; Print string (BIOS interrupt)
    MOV DX, OFFSET newline ; Newline characters for formatting
    INT 21h                ; Call DOS interrupt

    MOV DX, OFFSET newline ; Newline characters for formatting
    INT 21h                ; Call DOS interrupt


    MOV AH, 00h            ; Wait for key press
    INT 16h                ; Call BIOS interrupt

    ; After pressing a key, you can proceed to the game page

    JMP game_page          ; Proceed to the game page

game_page:
    ; Clear screen
    MOV AH, 00h            ; Set video mode (BIOS interrupt)
    MOV AL, 13h            ; Mode 13h (320x200 256-color VGA)
    INT 10h                ; Call video interrupt

    ; Print "ROUND 1" in extreme top left
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV DH, 1              ; Row = 1
    MOV DL, 1              ; Column = 1 (extreme top left)
    INT 10h                ; Call video interrupt

    MOV SI, OFFSET ROUND_1_MSG  ; SI points to message
    CALL print_string       ; Print "ROUND 1" message

    ; Print "Game Screen" in the middle
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV DH, 8              ; Row = 8 (slightly above the center)
    MOV DL, 14             ; Column = 14 (center)
    INT 10h                ; Call video interrupt

    MOV SI, OFFSET GAME_SCREEN_MSG  ; SI points to message
    CALL print_string       ; Print "Game Screen" message

    ; Print score in extreme top right
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV DH, 1              ; Row = 1
    MOV DL, 70            ; Column = 70 (extreme top right)
    INT 10h                ; Call video interrupt

    MOV SI, OFFSET score_msg ; SI points to score message
    CALL print_string       ; Print "Score: " message

   
    ; Wait for key press
    MOV AH, 00h            ; Wait for key press
    INT 16h                ; Call BIOS interrupt

    ; After pressing a key, you can proceed to the menu page

    JMP menu_page          ; Repeat menu page loop

print_username_menu:
    ; Print the username
    MOV AH, 02h            ; Set cursor position (BIOS interrupt)
    MOV DH, 12             ; Row = 12
    MOV DL, 14             ; Column = 14 (center)
    INT 10h                ; Call video interrupt

    LEA SI, username_buffer  ; SI points to username buffer
    CALL print_string      ; Print the username

    ; Wait for key press
    MOV AH, 00h            ; Wait for key press
    INT 16h

    ; Check for navigation key press
    MOV AH, 00h            ; Check for key press without waiting
    INT 16h                ; Call BIOS interrupt

    CMP AL, 1Bh            ; Check if ESC key pressed
    JE near_menu_jump      ; If ESC key pressed, jump to near_menu_jump

    JMP menu_page          ; Repeat menu page loop

near_menu_jump:
    JMP title_page    ; Jump to title_page using near jump

print_string PROC
    ; Print a null-terminated string pointed to by SI
    ; Assumes attributes are set and cursor position is correct
    @@print_loop:
        LODSB              ; Load next character into AL from SI
        CMP AL, '$'        ; Check for end of string
        JE @@end_print     ; If end of string, jump to end_print

        MOV AH, 0Eh        ; BIOS interrupt to print character
        MOV BH, 00h        ; Page number
        INT 10h            ; Call video interrupt

        JMP @@print_loop   ; Repeat for the next character

    @@end_print:
    RET
print_string ENDP

MAIN ENDP

END MAIN
