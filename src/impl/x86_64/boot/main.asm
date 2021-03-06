global start

section .text
bits 32
start:
    mov esp, stack_top

    call check_multiboot
    call check_cpuid
    call check_long_mode

    call setup_page_tables
    

    ; print 'ok'
    mov dword [0xb8000], 0x2f4b2f4f
    hlt 

check_multiboot:
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret
.no_multiboot:
    mov al, "M"
    jmp error

check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eac, 1<<21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    cmp eax, ecx
    je .no_cpuid
    ret
.no_cpuid:
    mov al, "C"
    jmp error

check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode

    mov eax, 0x80000001
    cpuid
    test edx, 1<<29
    jb .no_long_mode

    ret
.no_long_mode:
    move al, "L"
    jmp error

error:
    ;print "ERR: X" where X is the error code
    mov dword [0xb8000], 0x4f52f45
    mov dword [0xb8004], 0x4f3af52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt
section .bss
stack_bottom:
    resb 4096 * 4
stack_top: