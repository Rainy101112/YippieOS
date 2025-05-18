BITS 16
ORG 0x7C00

mov [drive_number], dl
mov ah, 8
int 0x13

mov [number_of_heads], dh
and cl, 0x3F
mov [sectors_per_track], cl

init:   
    mov al, 2
    mov cl, [sectors_per_track]
    xor dl, dl
    div cl

    inc dl
    mov [sector], dl
    
    mov cl, [number_of_heads]
    xor dl, dl
    div cl
    mov [head], dl 
    mov [cylinder], al

mov ah, 2
mov al, 1
mov ch, [cylinder]
mov cl, [sector]
mov dh, [head]
mov dl, [drive_number]
mov bx, 0x7C00 + 512
int 0x13

; Debugging
mov al, [cylinder]
call print_byte
mov bx, newline
call print

mov al, [sector]
call print_byte
mov bx, newline
call print

mov al, [head]
call print_byte
mov bx, newline
call print

mov al, [test_magic]
call print_byte

jmp boot_2

loop:
    hlt
    jmp loop

number_of_heads: db 0
drive_number: db 0
sectors_per_track: db 0
sector: db 0
head: db 0
cylinder: db 0
newline: db 0x0A, 0x0D, 0x00

print:
    mov ah, 0x0E
    mov al, [bx]
    cmp al, 0x00
    jne print_char
    ret

print_char:
    int 0x10
    inc bx
    jmp print
    
; We expect digit in AL
print_digit:
    mov ah, 0x0E
    mov cl, '0'
    mov dx, 'A' - 10
    cmp al, 10
    cmovge cx, dx
    add al, cl
    int 0x10
    ret

; We expect the integer in AL 
print_byte:
    ; 1010 1001
    mov bl, al
    ; 0000 1010
    shr al, 4
    call print_digit

    ; 1010 1001
    mov al, bl
    ; 1010 1001 and 0000 1111
    and al, 0b00001111

    call print_digit
    ret

; We expect the integer in AX
print_integer:
    ; 1010 0011 AH 
    ; 0001 0101 AL
    mov si, ax 
    mov al, ah
    call print_byte

    mov ax, si
    call print_byte
    ret

times 510-($-$$) db 0
dw 0xAA55

test_magic: db 0x49

boot_2:
    mov al, 0x16
    call print_byte

loop_2:
    hlt
    jmp loop_2


; Comments and stuff

; mov ah, 0x0E
; mov bx, msg
; call print
; mov bx, msg1
; call print

; mov ah, 8
; mov dl, 0x80
; int 0x13
; mov ah, 0x0
; mov al, dh