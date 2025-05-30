BITS 16
ORG 0x7E00
boot_2_start:

boot_2_sectors_count: dw (boot_2_end - boot_2_start + 511)/512

boot_2:
    mov sp, stack_end
    
    mov al, 0x69
    call print_byte

loop_2:
    hlt
    jmp loop_2

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

resb 4096
stack_end:

boot_2_end: