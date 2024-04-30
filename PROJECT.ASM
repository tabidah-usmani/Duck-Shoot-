.MODEL SMALL
.STACK 100h

.DATA
    DUCK_SHOOT_MSG DB "DUCK SHOOT$"
    GAME_A_MSG DB "GAME A  1 DUCK$"
    ENTER_USERNAME_MSG DB 13, 10, "Enter username: $"
    username_buffer DB 20 DUP('$')  ; Buffer to store the username
    newline DB 13, 10, "$"  ; New line characters for formatting
    GAME_BACKGROUND DB 320*200 DUP (0)  ; Game background buffer (assuming Mode 13h)

.CODE
MAIN PROC
    MOV AX, @DATA          ; Load data segment address into AX
    MOV DS, AX             ; Set DS to point to data segment

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

    ; Print "DUCK SHOOT" message
print_duck_shoot:
    LODSB                  ; Load next character into AL from SI
    CMP AL, '$'            ; Check if end of string
    JE print_enter_username_msg  ; If end of string, jump to print_enter_username_msg

    MOV AH, 0Eh            ; BIOS interrupt to print character
    MOV BH, 00h            ; Page number
    MOV BL, 07h            ; Attribute (white on black)
    INT 10h                ; Call video interrupt

    JMP print_duck_shoot   ; Repeat for the next character

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

    ; Print "DUCK SHOOT" message
print_duck_shoot_menu:
    LODSB                  ; Load next character into AL from SI
    CMP AL, '$'            ; Check if end of string
    JE print_game_a_msg    ; If end of string, jump to print_game_a_msg

    MOV AH, 0Eh            ; BIOS interrupt to print character
    MOV BH, 00h            ; Page number
    MOV BL, 07h            ; Attribute (white on black)
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
    JE print_username_menu      ; If end of string, jump to print_username_menu

    MOV AH, 0Eh            ; BIOS interrupt to print character
    MOV BH, 00h            ; Page number
    MOV BL, 07h            ; Attribute (white on black)
    INT 10h                ; Call video interrupt

    JMP print_game_a_menu  ; Repeat for the next character

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

    CMP AL, 08h            ; Check if Backspace key pressed
    JE near_title_jump     ; If Backspace key pressed, jump to near_title_jump

    JMP menu_page          ; Repeat menu page loop

near_title_jump:
    JMP title_page         ; Jump to title_page

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
