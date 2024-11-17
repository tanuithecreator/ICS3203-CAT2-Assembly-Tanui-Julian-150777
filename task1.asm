section .data
    prompt db "Enter a number: ", 0      ; Prompt for user input
    positive_msg db "The number is POSITIVE.", 0
    negative_msg db "The number is NEGATIVE.", 0
    zero_msg db "The number is ZERO.", 0

section .bss
    input resb 10                        ; Reserve space for user input

section .text
    global _start                        ; Entry point for the program

_start:
    ; Prompt user for input
    mov eax, 4                          ; syscall: sys_write
    mov ebx, 1                          ; file descriptor: stdout
    mov ecx, prompt                     ; address of the prompt message
    mov edx, 17            ; length of the prompt
    int 0x80                            ; call kernel

    ; Read user input
    mov eax, 3                          ; syscall: sys_read
    mov ebx, 0                          ; file descriptor: stdin
    mov ecx, input                      ; address of input buffer
    mov edx, 10                         ; maximum input length
    int 0x80                            ; call kernel

    ; Convert string input to integer
    mov eax, 0                          ; clear eax
    mov esi, input                      ; pointer to input buffer

convert_to_int:
    movzx ecx, byte [esi]               ; load a character
    cmp ecx, 10                         ; check for newline (ASCII 10)
    je classify_number                  ; if newline, input complete
    sub ecx, '0'                        ; convert ASCII to integer
    imul eax, eax, 10                   ; shift previous value left
    add eax, ecx                        ; add current digit
    inc esi                             ; move to the next character
    jmp convert_to_int                  ; repeat

classify_number:
    cmp eax, 0                          ; compare the number with 0
    je is_zero                          ; jump if number is zero
    jl is_negative                      ; jump if number is less than zero

is_positive:
    ; Print "POSITIVE" message
    mov eax, 4                          ; syscall: sys_write
    mov ebx, 1                          ; file descriptor: stdout
    mov ecx, positive_msg               ; address of the message
    mov edx, 26         ; length of the message
    int 0x80                            ; call kernel
    jmp exit                            ; exit the program

is_negative:
    ; Print "NEGATIVE" message
    mov eax, 4                          ; syscall: sys_write
    mov ebx, 1                          ; file descriptor: stdout
    mov ecx, negative_msg               ; address of the message
    mov edx, 26           ; length of the message
    int 0x80                            ; call kernel
    jmp exit                            ; exit the program

is_zero:
    ; Print "ZERO" message
    mov eax, 4                          ; syscall: sys_write
    mov ebx, 1                          ; file descriptor: stdout
    mov ecx, zero_msg                   ; address of the message
    mov edx, 22             ; length of the message
    int 0x80                            ; call kernel

exit:
    ; Exit the program
    mov eax, 1                          ; syscall: sys_exit
    xor ebx, ebx                        ; return code: 0
    int 0x80                            ; call kernel


