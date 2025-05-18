BITS 16
ORG 0x7C00

mov [drive_number], dl
mov ah, 8
int 0x13

mov [number_of_heads], dh
and cl, 0x3F
mov [sectors_per_track], cl

init:   
    mov al, 1
    mov cx, [sectors_per_track]
    xor dx, dx
    div cx

    inc dl
    mov [sector], dl
    
    mov cx, [number_of_heads]
    xor dx, dx
    div cx
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

jmp boot_2

loop:
    hlt
    jmp loop

drive_number: db 0
number_of_heads: dw 0
sectors_per_track: dw 0
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

boot_2:
    mov al, 0x16
    call print_byte

loop_2:
    hlt
    jmp loop_2
