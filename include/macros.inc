

%ifndef __MACROS_INC__
%define __MACROS_INC__

BUFFER_INPUT_LENGTH equ 0x20
STD_INPUT_HANDLE    equ -10
STD_OUTPUT_HANDLE   equ -11
struc GlobalVars
    .SEH.next       resd    1
    .SEH.handler    resd    1
    .Input.Length   resw    1   ; Length of entered password
endstruc

%macro CREATE_TABLE_NAND 0
    %assign i 0
    %rep 256
        %assign j 0
        %rep 256
            db  ~(j&i)
            %assign j j+1
        %endrep
        %assign i i+1
    %endrep
%endmacro

%macro CREATE_TABLE_COMPARE 0
    %rep 0x1000
        db 0
    %endrep
%endmacro

%macro XOR_LOGIC 0
    %define a byte [Buffer.Input + esi]
    %define b 0xA5
    .xor_loop:
        mov edx, 0
        movzx eax, a
        mov ebx, b
        mov ah, al
        mov al, 0
        movzx eax, byte[eax + ebx + nand_table]

        mov ah, al
        mov al, 0
        movzx edx, byte[eax + ebx + nand_table]

        movzx eax, a
        mov ebx, b
        mov ah, al
        mov al, 0
        movzx eax, byte[eax + ebx + nand_table]

        movzx ebx, a
        mov ah, al
        mov al, 0
        movzx eax, byte[eax + ebx + nand_table]

        mov dh, dl
        mov dl, 0
        movzx eax, byte[eax + edx + nand_table]

        CMP_BYTE_JNZ al, byte [String.Password + esi], .wrong
        sub esi, -1

    CMP_DWORD_JNZ esi, ecx, .xor_loop
%endmacro

%macro CMP_DWORD_JNZ 3
    mov eax, %1
    mov ebx, %2
    mov dword [offset_table + eax*4] , %3
    mov dword [offset_table + ebx*4] , %%.continue
    mov ebx, dword [offset_table + eax*4]
    jmp ebx
    %%.continue:
%endmacro

%macro CMP_DWORD_JZ 3
    mov eax, %1
    mov ebx, %2
    mov dword [offset_table + eax*4] , %%.continue
    mov dword [offset_table + ebx*4] , %3
    mov ebx, dword [offset_table + eax*4]
    jmp ebx
    %%.continue:
%endmacro

%macro CMP_BYTE_JNZ 3
    movzx eax, %1
    movzx ebx, %2
    mov dword [offset_table + eax*4] , %3
    mov dword [offset_table + ebx*4] , %%.continue
    mov ebx, dword [offset_table + eax*4]
    jmp ebx
    %%.continue:
%endmacro

%macro WRITE_MESSAGE 2
	INS_PUSH	STD_OUTPUT_HANDLE
	call	_GetStdHandle@4
	mov	ebx, eax    

	; WriteFile( hstdOut, message, length(message), &bytes, 0);
	INS_PUSH	0	; lpOverlapped
	mov eax, ebp
    sub eax, 4
	INS_PUSH	eax	; Number of bytes written
	mov	eax, %2
	INS_PUSH	eax	; Number of bytes to write
	mov	eax, %1
	INS_PUSH	eax	; buffer
	INS_PUSH	ebx	; file handle
	call	_WriteFile@20
%endmacro

%macro INS_PUSH 1
    sub esp, 4
    mov dword [esp], %1
%endmacro
%endif