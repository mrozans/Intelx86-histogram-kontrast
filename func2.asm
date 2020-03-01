section .data
lut1 TIMES 256 DB 0
lut2 TIMES 256 DB 0
lut3 TIMES 256 DB 0
segment .text
global histogram
%define bluemax [ebp-4]
%define greenmax [ebp-8]
%define redmax [ebp-12]
%define bluemin [ebp-16]
%define greenmin [ebp-20]
%define redmin [ebp-24]
histogram:
	push ebp
	mov ebp, esp
	sub esp, 24
	push ebx
	mov ecx, [ebp+8]			; Pointer of image.
	mov esi, [ebp+12]		; Width of image.
	mov eax, [ebp+16]		; Height of image.
	mov ebx, 0
	mov bluemax, ebx
	mov greenmax, ebx
	mov redmax, ebx
	mov ebx, 255
	mov bluemin, ebx
	mov greenmin, ebx
	mov redmin, ebx
	imul eax, esi			; size = width * height
	imul eax, 3			; size*3
	mov esi, eax			; size is assigned to esi
	xor eax, eax 			; eax = 0
bmin:
	mov al, byte[ecx]
	inc ecx
	cmp bluemin, eax
	jle bmax
	mov bluemin, eax
bmax:
	cmp bluemax, eax
	jge gmin
	mov bluemax, eax
gmin:
	mov al, byte[ecx]
	inc ecx
	cmp greenmin, eax
	jle gmax
	mov greenmin, eax
gmax:
	cmp greenmax, eax
	jge rmin
	mov greenmax, eax
rmin:
	mov al, byte[ecx]
	inc ecx
	cmp redmin, eax
	jle rmax
	mov redmin, eax
rmax:
	cmp redmax, eax
	jge checkloop
	mov redmax, eax
checkloop:
	sub esi, 3
	cmp esi, 0
	jne bmin
lutprepare:
	xor eax, eax
	mov eax, bluemin
	sub bluemax, eax
	xor ebx, ebx
	xor eax, eax
	mov ah, 255
	mov ebx, bluemax
	xor edx, edx
	idiv ebx
	mov bluemax,eax
	xor eax, eax
	mov eax, greenmin
	sub greenmax, eax
	xor ebx, ebx
	xor eax, eax
	mov ah, 255
	mov ebx, greenmax
	xor edx, edx
	idiv ebx
	mov greenmax, eax
	xor eax, eax
	mov eax, redmin
	sub redmax, eax
	xor ebx, ebx
	xor eax, eax
	mov ah, 255
	mov ebx, redmax
	xor edx, edx
	idiv ebx
	mov redmax, eax
	xor ecx, ecx
	xor edx, edx
	mov cl, 0
lutloop:
	xor eax, eax
	mov al, cl
	xor ebx, ebx
	mov ebx, bluemin
	sub eax, ebx
	xor ebx, ebx
	mov ebx, bluemax
	imul eax, ebx
	mov [lut1+ecx], ah
	xor eax, eax
	mov al, cl
	xor ebx, ebx
	mov ebx, greenmin
	sub eax, ebx
	xor ebx, ebx
	mov ebx, greenmax
	imul eax, ebx
	mov [lut2+ecx], ah
	xor eax, eax
	mov al, cl
	xor ebx, ebx
	mov ebx, redmin
	sub eax, ebx
	xor ebx, ebx
	mov ebx, redmax
	imul eax, ebx
	mov [lut3+ecx], ah
	xor eax, eax
	inc ecx				; address is increased.
	cmp ecx,256			; if ecx == 256 ?
	jne lutloop
set:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	mov ecx, [ebp+8]		; Pointer of image.
	mov esi, [ebp+12]		; Width of image.
	mov eax, [ebp+16]		; Height of image.
	imul eax, esi			; size = width * height
	imul eax, 3			; size*3
	mov esi, eax			; size is assigned to esi
	xor eax, eax
setloop:
	mov al, byte[ecx]
	mov al, byte[lut1+eax]
	mov byte[ecx], al
	inc ecx
	mov al, byte[ecx]
	mov al, byte[lut2+eax]
	mov byte[ecx], al
	inc ecx
	mov al, byte[ecx]
	mov al, byte[lut3+eax]
	mov byte[ecx], al
	inc ecx
	sub esi, 3
	cmp esi, 0
	jne setloop
exit:
	pop ebx
	mov esp, ebp
	pop ebp
	ret
