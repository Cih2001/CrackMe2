%include "include\macros.inc"	; Contains general purpose macros

SECTION	.text
    extern	_GetStdHandle@4
	extern	_WriteFile@20
	extern	_ExitProcess@4
	extern	_ReadFile@20
	extern	_GetLastError@0

    global	_main	; PE Entry

bits 32
_main:
    pusha   
	mov ebp, esp
	sub esp, 4

    mov eax, dword [fs:0]
    mov dword [Variables + GlobalVars.SEH.next], eax
    mov dword [Variables + GlobalVars.SEH.handler], .res
    mov dword [fs:0], Variables + GlobalVars.SEH.next
    mov eax, dword [fs:0]
    mov dword [0],0
    .res:

	WRITE_MESSAGE String.EnterPassword, String.EnterPassword.Length

    INS_PUSH	STD_INPUT_HANDLE
	call	_GetStdHandle@4
	mov	ebx, eax

    INS_PUSH	0	; lpOverlapped
	mov eax, ebp
    sub eax, 4
	INS_PUSH	eax	; lpNumberOfBytesRead
	INS_PUSH	BUFFER_INPUT_LENGTH ; nNumberOfBytesToRead
	INS_PUSH	Buffer.Input	; lpBuffer
	INS_PUSH	ebx	; hFile
	call	_ReadFile@20
	CMP_DWORD_JNZ eax, eax, .error

    mov ecx, [ebp-4]
    CMP_DWORD_JNZ ecx, String.Password.Length + 2, .wrong

    mov ecx, String.Password.Length
    mov esi, 0
    XOR_LOGIC

	WRITE_MESSAGE	String.Correct, String.Correct.Length
	jmp	.exit

    .error:
		call	_GetLastError@0
		jmp	.exit
	.wrong:
		WRITE_MESSAGE	String.Wrong, String.Wrong.Length
	.exit:
		mov	esp, ebp
		popa
		INS_PUSH	0
		call	_ExitProcess@4

SECTION .data
    Buffer.Input:	times	BUFFER_INPUT_LENGTH	db	0
    Variables:
	istruc	GlobalVars
        at  GlobalVars.SEH.next,        dd 0
        at  GlobalVars.SEH.handler,     dd 0
		at	GlobalVars.Input.Length,	dw	0	; Length of enterd password
	iend
    String.Password:                db  'XOR_can_be_great' , 0
    String.Password.Length:         equ	$-String.Password-1
    String.EnterPassword:			db	'Enter Password:', '$', 0
    String.EnterPassword.Length:	equ	$-String.EnterPassword-2
    String.Wrong:					db	'Hmm, Not exactly! Try harder.', 0xD, 0xA, '$', 0
    String.Wrong.Length:			equ	$-String.Wrong-2
    String.Correct:					db	'Congratulations, You are a winner!', 0xD, 0xA, '$', 0
    String.Correct.Length:			equ	$-String.Correct-2
    offset_table:
    CREATE_TABLE_COMPARE
    nand_table:
    CREATE_TABLE_NAND