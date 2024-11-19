section .bss
    input resb 5        ; Buffer for user input (uninitialized)
    result resd 1       ; Space to store the factorial result
    res_str resb 10     ; Buffer for the result string (uninitialized)

section .data
    prompt db "Enter a number: ", 0 ; Input prompt
    result_msg db "Factorial: ", 0  ; Output prefix
    newline db 10, 0                ; Newline character

section .text
    global _start

_start:
    ; Print prompt
    mov eax, 4                      ; System call number (write)
    mov ebx, 1                      ; File descriptor (stdout)
    mov ecx, prompt                 ; Message to print
    mov edx, 17                     ; Length of message
    int 0x80                        ; System call

    ; Read input
    mov eax, 3                      ; System call number (read)
    mov ebx, 0                      ; File descriptor (stdin)
    mov ecx, input                  ; Buffer to store input
    mov edx, 5                      ; Max number of bytes to read
    int 0x80                        ; System call

    ; Convert input (ASCII to integer)
    mov eax, 0                      ; Clear eax (accumulator for the number)
    mov esi, input                  ; Pointer to the input buffer
convert_loop:
    movzx ebx, byte [esi]           ; Load one byte from input
    cmp bl, 10                      ; Check for newline (ASCII 10)
    je compute_factorial            ; Jump if newline
    sub bl, '0'                     ; Convert ASCII to numeric value
    imul eax, eax, 10               ; Multiply accumulator by 10
    add eax, ebx                    ; Add numeric value to accumulator
    inc esi                         ; Move to next character
    jmp convert_loop                ; Repeat loop

compute_factorial:
    push eax                        ; Push number to stack
    call factorial                  ; Call factorial subroutine
    mov [result], eax               ; Store result in memory

    ; Convert result to string
    mov eax, [result]               ; Load result into eax
    mov edi, res_str + 9            ; Point to the end of the buffer
    mov byte [edi], 0               ; Null-terminate string
convert_result:
    xor edx, edx                    ; Clear edx for division
    mov ebx, 10                     ; Divisor (base 10)
    div ebx                         ; eax = eax / 10, edx = remainder
    add dl, '0'                     ; Convert remainder to ASCII
    dec edi                         ; Move buffer pointer backwards
    mov [edi], dl                   ; Store ASCII character
    test eax, eax                   ; Check if quotient is zero
    jnz convert_result              ; Repeat if not zero

    ; Print result message
    mov eax, 4                      ; System call number (write)
    mov ebx, 1                      ; File descriptor (stdout)
    mov ecx, result_msg             ; Message to print
    mov edx, 10                     ; Length of message
    int 0x80                        ; System call

       ; Print result
    mov eax, 4                 ; System call number (write)
    mov ebx, 1                 ; File descriptor (stdout)
    mov ecx, edi               ; Pointer to the result string
    lea esi, res_str + 9       ; Load address of res_str + 9 into ESI
    sub esi, edi               ; Calculate length of the result string
    mov edx, esi               ; Move length into EDX
    int 0x80                   ; System call

    ; Print newline
    mov eax, 4                      ; System call number (write)
    mov ebx, 1                      ; File descriptor (stdout)
    mov ecx, newline                ; Newline character
    mov edx, 1                      ; Length of newline
    int 0x80                        ; System call

    ; Exit program
    mov eax, 1                      ; System call number (exit)
    xor ebx, ebx                    ; Exit status 0
    int 0x80                        ; System call

factorial:
    ; Calculate factorial
    pop ecx                         ; Load input number into ecx
    mov eax, 1                      ; Initialize result

factorial_loop:
    cmp ecx, 0                      ; Check if counter is 0
    je factorial_end                ; End loop if done
    mul ecx                         ; Multiply eax by ecx
    dec ecx                         ; Decrement counter
    jmp factorial_loop              ; Repeat loop

factorial_end:
    ret
