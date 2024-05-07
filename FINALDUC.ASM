.model small
.stack 0100h
.data
    SCREEN_WIDTH equ 320
    SCREEN_HEIGHT equ 200
    Hert db 09,09,09,00,00,00,00,00,09,09,09,09,09,09,09,09 ; 16x16 block pattern
        db 09,09,00,00,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,02,02,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,02,02,14,00,09,09,09,09,09,09,09
        db 00,00,06,14,14,02,02,14,00,09,09,09,09,09,09,09
        db 00,06,06,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 06,06,06,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 06,06,06,14,14,14,14,14,00,09,09,09,09,09,09,09 ; Repeat to make a 32x32 pattern
        db 00,00,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,09,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,00,00,09,09,09,09,09,09
        db 09,09,00,14,14,14,14,14,14,14,00,09,09,09,09,09 ; Repeat to make a 32x32 pattern
        db 09,00,14,14,14,14,14,14,14,14,14,00,09,09,09,09
        db 00,14,14,14,14,14,14,14,14,14,14,00,00,09,09,09
        db 00,14,14,14,14,14,14,14,14,14,14,14,14,00,09,09
        db 00,14,14,14,14,14,14,14,14,14,14,14,14,00,00,00
        db 00,14,14,14,14,14,00,14,14,14,14,14,14,00,14,00
        db 00,14,14,14,14,14,00,14,14,14,14,14,00,14,14,00
        db 00,14,14,14,14,14,00,14,14,14,14,00,14,14,14,00
        db 00,14,14,14,14,14,14,00,00,00,00,14,14,14,14,00
        db 00,14,14,14,14,14,14,14,14,14,14,14,14,14,14,00
        db 00,14,14,14,14,14,14,14,14,14,14,14,14,14,00,09
        db 00,14,14,14,14,14,14,14,14,14,14,14,14,00,09,09
        db 00,14,14,14,14,14,14,14,14,14,14,14,00,09,09,09
        db 09,00,14,14,14,14,14,14,14,14,14,00,09,09,09,09
        db 09,09,00,06,06,06,00,00,06,06,06,09,09,09,09,09
        db 09,09,09,06,06,06,09,09,06,06,06,09,09,09,09,09
        db 09,09,09,06,06,06,09,09,06,06,06,09,09,09,09,09

xi dw 0
xf dw 16
yi dw 0
yf dw 16
direction_x dw 1
direction_y dw 1

.code
main proc
    mov ax,@data
    mov ds,ax

    ; Set video mode to 13h (VGA 320x200, 256 colors)
    mov al,13h
    mov ah,00h
    int 10h

    mov direction_x, 1 ; 1 for moving right, -1 for moving left
    mov direction_y, 1 ; 1 for moving down, -1 for moving up

move_duck:
    ; Clear the screen
    mov ah, 06h
    mov al, 0
    mov bh, 0
    mov cx, 0
    mov dx, 184Fh
    int 10h

    ; Draw the shape at the new position
    mov si, offset Hert
    call draw

    ; Update position for next frame
    ; Move horizontally
    mov ax, xi
    add ax, direction_x
    mov xi, ax
    mov ax, xf
    add ax, direction_x
    mov xf, ax

    ; Bounce horizontally if it reaches screen boundaries
    cmp xi, 0
    jl reverse_horizontal
    cmp xf, SCREEN_WIDTH
    jge reverse_horizontal

continue_x:
    ; Move vertically
    mov ax, yi
    add ax, direction_y
    mov yi, ax
    mov ax, yf
    add ax, direction_y
    mov yf, ax

    ; Bounce vertically if it reaches screen boundaries
    cmp yi, 0
    jl reverse_vertical
    cmp yf, SCREEN_HEIGHT
    jge reverse_vertical

continue_y:
    ; Introduce a delay for slower movement
    call delay

    ; Loop the movement
    jmp move_duck

reverse_horizontal:
    neg direction_x
    jmp continue_x

reverse_vertical:
    neg direction_y
    jmp continue_y

    ; Terminate program
    mov ah, 4Ch
    int 21h
main endp

draw proc
    mov ah, 0Ch
    mov dx, yi
y_loop:
    mov cx, xi
x_loop:
    mov al, [si]
    int 10h
    inc si
    inc cx
    cmp cx, xf
    jb x_loop
    inc dx
    cmp dx, yf
    jb y_loop
    ret
draw endp

delay proc
    ; Simple delay loop
    mov cx, 40000
delay_loop:
    loop delay_loop
    ret
delay endp

end main
