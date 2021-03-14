
section .data
    delim db " ", 0
    aux db 0, 0

section .bss
    root resd 1
    length resb 4
    reserve resb 1

section .text

extern check_atoi
extern print_tree_inorder
extern print_tree_preorder
extern evaluate_tree
extern strdup
extern calloc

global create_tree
global iocla_atoi

get_length: ; determinam lungimea unui sir
	push ebp
	mov ebp, esp

	xor edx, edx
	xor eax, eax

	mov edx, [ebp + 8]

moving_through: ; ne oprim cand ajungem la caracterul nul
	inc eax
	cmp byte [edx + eax], 0
	jne moving_through

	mov esp, ebp
	pop ebp

	ret

iocla_atoi:
	push ebp
	mov ebp, esp

	xor ebx, ebx
	mov ebx, [ebp + 8]

	push ebx
	call get_length ; determinam lungimea sirului
	pop ebx

	xor ecx, ecx
	mov [length], eax

	xor eax, eax
	xor edx, edx

check_bytes:
	mov byte al, [ebx + ecx]
	cmp al, 48  ; cazul in care avem minus
	jl dont ; se sare peste adaugarea in numar
	imul edx, 10
	sub byte al, 48
	add edx, eax
dont: 
	inc ecx

	cmp ecx, [length]
	jne check_bytes

	xor ecx, ecx

	cmp byte [ebx], 45
	jne finish
	imul edx, -1

finish:
	mov eax, edx

	mov esp, ebp
	pop ebp

	ret


create_tree:
    push ebp
    mov ebp, esp

    push ebx
    push ecx
    push edx
    push esi
    push edi
    ; avem deja sirul pe stiva
    xor ecx, ecx
    mov ecx, [ebp + 8]
    push ecx
    xor esi, esi ; vom folosi registrul esi pentru a parcurge sirul
    call worker
    add esp, 4

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    leave
    ret

worker: 
	push ebp
	mov ebp, esp

	;sirul este in ecx
	mov ecx, [ebp + 8]

	xor edx, edx ; folosit pentru transfer
	mov byte [aux], 0 ; in el transferam elementul
	mov byte [reserve], 0
	xor edi, edi ; il folosim pe post de index

extraction: ; preluam elementul
	cmp byte [ecx + esi], 0
	je over
	cmp byte [ecx + esi], 10
	je over
	mov dl, [ecx + esi]
	mov [aux + edi], dl
	inc edi
	inc esi
	cmp byte [ecx + esi], " "
	jne extraction

over:
	inc esi ; sarim peste spatiu
	
	; dupa ce am extras elementul, ii punem caracterul nul in coada
	mov byte [aux + edi], 0

	; copiem sirul

	push ecx
	push eax
	push ebx
	push edx
	push esi
	push edi
	push aux
	call strdup
	add esp, 4
	pop edi
	pop esi
	pop edx
	pop ebx
	add esp, 4
	pop ecx

	; mutam copia
	mov [reserve], eax

	; vedem daca elementul este un operator sau un operand
	cmp byte [aux], 48
	jl label1
	jmp label2

	; cazul operator
	; punem valoarea sa pe [edx], pentru [edx + 4] si [edx + 8] apelam iar worker
label1:
	cmp byte [aux + 1], 48 ; cazul in care am dat peste un numar negativ
	jg label2

	; alocam memoria 
	push ecx
	push esi
	push 1
	push 12
	call calloc
	add esp, 8
	pop esi
	pop ecx
	xor edx, edx
	mov edx, eax

	xor eax, eax

	mov eax, [reserve]
	mov [edx], eax

	;ramura stanga
	push edx
	push ecx

	call worker

	pop ecx
	pop edx

	mov [edx + 4], eax

	; ramura dreapta
	push edx
	push ecx

	call worker

	pop ecx
	pop edx
	mov [edx + 8], eax
	mov eax, edx

	jmp point_end

	; cazul operand
label2:
	; alocam memoria necesara
	push ecx
	push esi
	push 1
	push 12
	call calloc
	add esp, 8
	pop esi
	pop ecx

	xor edx, edx
	mov edx, eax

	; punem valoarea operandului
	
	mov eax, [reserve]
	mov [edx], eax
	
	; cei doi pointeri sunt nuli
	mov dword [edx + 4], 0
	mov dword [edx + 8], 0

	mov eax, edx

point_end:

	mov esp, ebp
	pop ebp
	ret
