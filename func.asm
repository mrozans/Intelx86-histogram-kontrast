section .data
lut TIMES 256 DB 0
segment .text
global contrast
contrast:
	push ebp
	mov ebp,esp
	push ebx
	mov ebx,[ebp+20]		; Value of contrast.
	mov edi,255
	shr edi,1			; 255/2 to edi
	mov cl, 0			; value of lut pixel to cl
lutloop:
	xor edx,edx
	xor eax, eax
	mov eax,ebx			; value of contrast assigned to eax.
	mov dl, cl			; current pixel value to edx
	sub edx,edi
	imul eax,edx			; current pixel value multiplied by eax.
	add eax,edi
	cmp eax,10000			; if value < 0
	jna checkupper
	mov al, 0
	jmp doneContr
checkupper:
	cmp eax,255			; if eax value not greater than 255 
	jna doneContr		
	mov al, 255			; set up to maximum value which means 255.
doneContr:
	mov [lut+ecx],al		; result is assigned to current pixel value.
	inc ecx				; address is increased.
	cmp ecx,256			; if ecx == 256 ?
	jne lutloop
set:
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	mov ecx,[ebp+8]			; Pointer of image.
	mov esi,[ebp+12]		; Width of image.
	mov eax,[ebp+16]		; Height of image.
	imul eax,esi			; size = width * height
	imul eax,3			; size*3
	mov esi,eax			; size is assigned to esi
setloop:
	xor eax,eax 			
	mov al, byte[ecx]
	mov al, byte[lut+eax]
	mov byte[ecx], al
	inc ecx				; address is increased.
	dec esi				; size is decreased one by one.
	cmp esi,0			; if size == 0 ?
	jne setloop
exit:
	pop ebx
	mov esp, ebp
	pop ebp
	ret
