;Jokubas Savodnikas 4grp 2pogr 2UZD

.model small

.stack 100h
 
.data

    fname  db 256 dup(?)  ;input failo vardas
    foutname db 256 dup(?)
    buf   db 256 dup(?) ;bufferis
    outbuf db 256 dup(?)
    ferror db "Nepavyko atverti failo", 10, 13, "$"
    fmes db "Sekmingai atvertas failas", 10, 13, "$"
    ferrorclose db "Nepavyko uzverti failu", 10, 13, "$"
    fmesclose db "Sekmingai uzverti failai", 10, 13, "$"
    zodziai db "Zodziu arba simboliu kratinio ilgiai: $" 
    input dw 0000h
    output dw 0000h 
    output_count db 0
    
.code
 
Programa:  
    mov ax,@data
    mov ds,ax
    
    call getFileName

    push OFFSET fname
    call openFileRead
    call fileError

    push OFFSET foutname
    call openFileWrite
    call fileError
     
    
    call readFile
    call count 


    call Exit
    
getFileName proc
         
    mov bx, 0082h
    lea si, fname; bus naudojamas kaip skaitliukas
   
    getname1:
   
    mov dl, byte ptr es:[bx]
    cmp dl, 20h
    je pridedamNuli
    mov byte ptr[si], dl
   
    inc si
    inc bx
   
    jmp getname1
   
    pridedamNuli:
    inc si
    mov byte ptr[si], 0;
    lea si, foutname
    inc bx
 
   
    getname2:
    mov dl, byte ptr es:[bx]
    cmp dl, 13
    je pridedamNuli2
    mov byte ptr[si], dl
 
    inc bx
    inc si
    jmp getname2
   
    pridedamNuli2:
   
    inc si
    mov byte ptr[si], 0
    ret
                  
getFileName endp 

openFileRead proc
        
    pop si
    mov ax, 3D00h
    pop dx
    int 21h
    mov input, ax
    push si
    ret
       
openFileRead endp

openFileWrite proc 
    
	pop si
	mov ah, 3Ch
	xor cx, cx
	pop dx
	int 21h
	push dx
	
	mov ax, 3D01h
	pop dx
	int 21h
	mov output, ax
	push si
	ret
	
openFileWrite endp

readFile proc
    
    MOV dx, offset buf
    mov ax, 3F00h
    mov bx, input
    mov cx, 256
    int 21h
    ret
        
readFile endp

count proc
    
    xor bx, bx
    xor cx, cx
    lea si, buf
    xor di,di
    linelength:
    inc si
    inc cx
    cmp byte ptr[si], 13
    jne linelength
    
    lea si, buf 
    ciklas:
        cmp byte ptr[si], 20h
        je tiesa
        cmp byte ptr[si], 10
        je tiesa
    netiesa:
        inc si
        inc bx
    loop ciklas
    tiesa:
        mov ax, bx
        
        mov bx, 0Ah
        xor dx, dx
        push cx
        xor cx, cx
    
    kiekskc:
        xor dx, dx
        div bx
        push dx
        inc cx
        cmp ax, 00h
        jne kiekskc
    isvedimas:
        pop dx
        add dx, 30h
	mov byte ptr [outbuf+di],dl
	inc di
	inc byte ptr [output_count]
        ;mov ah, 02h
        ;int 21h
        loop isvedimas
        
        xor bx, bx
    tarpas:
        mov dl, 20h
	mov byte ptr [outbuf+di],dl
	inc di
	inc byte ptr [output_count]
	;mov ah, 02h
        ;int 21h
        
        cmp byte ptr[si], 10
        je exit
        
        inc si
        pop cx
    loop ciklas
        ret
count endp

writeMessage proc
      
	xor ch,ch
	mov ah, 40h
	mov bx, output
	mov cl, byte ptr [output_count] 
	lea dx, outbuf
	int 21h
	mov byte ptr [output_count], 0
	ret
	
writeMessage endp

closeFile proc
	
	mov ah, 3Eh
	mov bx, output
	int 21h

	mov bx, input
	int 21h
	ret

closeFile endp

fileError proc
	jc showerror					
	skiperror:
		mov dx, OFFSET fmes	
		mov ah, 09h					
		int 21h							
		ret
	showerror:
		mov dx, OFFSET ferror	
		mov ah, 09h					
		int 21h						
		call Exit					
fileError endp

closeError proc
	jc showerrorclose					
	skiperrorclose:
		mov dx, OFFSET fmesclose	
		mov ah, 09h					
		int 21h							
		ret
	showerrorclose:
		mov dx, OFFSET ferrorclose	
		mov ah, 09h					
		int 21h						
		call Exit
closeError endp

Exit proc
 
    call writeMessage
    call closeFile
    call closeError
    mov ah, 4Ch
    mov al, 0
    int 21h
    ret

Exit endp

END Programa 
