section .data
    ; Text messages and prompts
    welcome_msg    db "BITMASTER - Bit Manipulation Tool", 13, 10
                  db "==================================", 13, 10, 0
    prompt_num     db "Enter a number (0-255): ", 0
    prompt_bit     db "Enter bit position (0-7): ", 0
    prompt_choice  db 13, 10, "Choose operation:", 13, 10
                  db "1. Set bit", 13, 10
                  db "2. Clear bit", 13, 10
                  db "3. Toggle bit", 13, 10
                  db "Your choice (1-3): ", 0
    result_msg     db 13, 10, "Operation Result:", 13, 10
                  db "================", 13, 10, 0
    original_msg   db "Original number: ", 0
    binary_msg     db "Binary: ", 0
    operation_msg  db "Operation: ", 0
    set_msg        db "SET bit ", 0
    clear_msg      db "CLEAR bit ", 0
    toggle_msg     db "TOGGLE bit ", 0
    newline        db 13, 10, 0
    separator      db "----------------", 13, 10, 0
    
    ; Error messages
    error_range    db "Error: Number must be 0-255!", 13, 10, 0
    error_bit      db "Error: Bit position must be 0-7!", 13, 10, 0
    error_choice   db "Error: Choice must be 1-3!", 13, 10, 0

section .bss
    number         resb 1
    bit_pos        resb 1
    operation      resb 1
    input_buffer   resb 10
    temp_buffer    resb 10

section .text
    global _start

_start:
    ; Display welcome message
    mov ecx, welcome_msg
    call print_string
    
main_loop:
    ; Get number from user
    call get_number
    mov [number], al
    
    ; Get bit position from user  
    call get_bit_position
    mov [bit_pos], al
    
    ; Get operation choice
    call get_operation
    mov [operation], al
    
    ; Perform the operation and display results
    call perform_operation
    call display_results
    
    ; Ask if user wants to continue
    call ask_continue
    cmp al, 'y'
    je main_loop
    
    ; Exit program
    mov eax, 1
    mov ebx, 0
    int 0x80

; ============ SUBROUTINES ============

; Get number from user (0-255)
get_number:
    mov ecx, prompt_num
    call print_string
    call read_input
    call string_to_number
    cmp eax, 255
    jg .error
    ret
.error:
    mov ecx, error_range
    call print_string
    jmp get_number

; Get bit position from user (0-7)
get_bit_position:
    mov ecx, prompt_bit
    call print_string
    call read_input
    call string_to_number
    cmp eax, 7
    jg .error
    ret
.error:
    mov ecx, error_bit
    call print_string
    jmp get_bit_position

; Get operation choice from user (1-3)
get_operation:
    mov ecx, prompt_choice
    call print_string
    call read_input
    call string_to_number
    cmp eax, 1
    jl .error
    cmp eax, 3
    jg .error
    ret
.error:
    mov ecx, error_choice
    call print_string
    jmp get_operation

; Perform the selected bit operation
perform_operation:
    mov al, [number]
    mov cl, [bit_pos]
    mov bl, 1
    shl bl, cl      ; Create bit mask
    
    cmp byte [operation], 1
    je .set_bit
    cmp byte [operation], 2
    je .clear_bit
    cmp byte [operation], 3
    je .toggle_bit
    
.set_bit:
    or al, bl       ; Set the bit
    jmp .done
.clear_bit:
    not bl          ; Invert mask
    and al, bl      ; Clear the bit
    jmp .done
.toggle_bit:
    xor al, bl      ; Toggle the bit
.done:
    mov [number], al ; Store result back
    ret

; Display operation results
display_results:
    mov ecx, result_msg
    call print_string
    
    ; Display original number
    mov ecx, original_msg
    call print_string
    mov al, [number]
    call print_number
    mov ecx, newline
    call print_string
    
    ; Display operation performed
    mov ecx, operation_msg
    call print_string
    
    cmp byte [operation], 1
    je .show_set
    cmp byte [operation], 2
    je .show_clear
    cmp byte [operation], 3
    je .show_toggle
    
.show_set:
    mov ecx, set_msg
    call print_string
    jmp .show_bit_pos
.show_clear:
    mov ecx, clear_msg
    call print_string
    jmp .show_bit_pos
.show_toggle:
    mov ecx, toggle_msg
    call print_string
    
.show_bit_pos:
    mov al, [bit_pos]
    call print_number
    mov ecx, newline
    call print_string
    
    ; Display binary representation
    mov ecx, binary_msg
    call print_string
    mov al, [number]
    call print_binary
    mov ecx, newline
    call print_string
    
    mov ecx, separator
    call print_string
    ret

; Ask user if they want to continue
ask_continue:
    mov ecx, newline
    call print_string
    mov ecx, .prompt
    call print_string
    call read_input
    cmp byte [input_buffer], 'y'
    je .yes
    cmp byte [input_buffer], 'Y'
    je .yes
    mov al, 'n'
    ret
.yes:
    mov al, 'y'
    ret
.prompt db "Continue? (y/n): ", 0

; ============ UTILITY FUNCTIONS ============

; Print string (address in ecx)
print_string:
    push eax
    push ebx
    push edx
    mov edx, 0
.length_loop:
    cmp byte [ecx + edx], 0
    je .print
    inc edx
    jmp .length_loop
.print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop edx
    pop ebx
    pop eax
    ret

; Read input into input_buffer
read_input:
    push eax
    push ebx
    push ecx
    push edx
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buffer
    mov edx, 10
    int 0x80
    ; Null terminate the string
    mov byte [ecx + eax - 1], 0
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Convert string to number (result in eax)
string_to_number:
    push ebx
    push ecx
    push edx
    mov esi, input_buffer
    xor eax, eax
    xor ebx, ebx
.convert_loop:
    mov bl, [esi]
    cmp bl, 0
    je .done
    sub bl, '0'
    imul eax, 10
    add eax, ebx
    inc esi
    jmp .convert_loop
.done:
    pop edx
    pop ecx
    pop ebx
    ret

; Print number in decimal (value in al)
print_number:
    push eax
    push ebx
    push ecx
    push edx
    movzx eax, al
    mov ebx, 10
    mov ecx, 0
.divide_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    push edx
    inc ecx
    test eax, eax
    jnz .divide_loop
.print_loop:
    pop eax
    mov [temp_buffer], al
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, temp_buffer
    mov edx, 1
    int 0x80
    pop ecx
    loop .print_loop
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

; Print number in binary (value in al)
print_binary:
    push eax
    push ebx
    push ecx
    push edx
    mov ecx, 8
.binary_loop:
    rol al, 1
    jc .one
.zero:
    mov byte [temp_buffer], '0'
    jmp .print_bit
.one:
    mov byte [temp_buffer], '1'
.print_bit:
    push eax
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, temp_buffer
    mov edx, 1
    int 0x80
    pop ecx
    pop eax
    loop .binary_loop
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

