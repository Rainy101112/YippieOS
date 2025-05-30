BITS 16
ORG 0x7C00

mov [drive_number], dl
; Gets the "drive geometry"
mov ah, 8
int 0x13

mov [number_of_heads], dh
and cl, 0x3F
mov [sectors_per_track], cl

mov ax, 1
mov bx, 0x7E00 ; 0x7C00 + 512 * 1
call load_sector

load_all_sectors:
    mov di, [boot_2_sectors_count]
    inc ax

    cmp ax, di 
    jg 0x7E00 + 2 

    add bx, 512
    call load_sector
    jmp load_all_sectors

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
disk_error: db 'Disk error', 0x00

; Expects the character in AL
print:
    mov ah, 0x0E
    cmp al, 0x00
    jne print_char
    ret

print_char:
    int 0x10
    inc al
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

; Expects the sector in AL
; Expects the memory location in BX
load_sector:
    push ax
    push bx
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
    int 0x13
    pop bx
    pop ax
    ret 

times 510-($-$$) db 0
dw 0xAA55

boot_2_sectors_count: 