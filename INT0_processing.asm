;1. Dalybos is nulio (int 0) apdorojimo procedura. Si procedura turi i ekrana isvesti informacija apie pertraukimas sukelusia operacij: adresa, koda, mnemonika, operandu reiksmes.
; Uztenka, kad komanda atpazintu tik komanda DIV
; PVZ.: I ekrana isvedama informacija galetu atrodyti taip: Dalyba is nulio! 0000:0128 F7F3 DIV BX ; ax = 2532 dx=0001

.model small

.stack 100h

.data
	pranesimas db "Dalyba is nulio! $"
	erroras db "Klaida!", 10, 13, "$"
	dalyba db "DIV $"
	enteris db 10, 13 , "$"
	
	papildomas dw ?
	
	w_registrai db "AX", "CX", "DX", "BX", "SP", "BP", "SI", "DI"
	b_registrai db "AL", "CL", "DL", "BL", "AH", "CH", "DH", "BH"
	
	print_bxsi db "[BX+SI+poslinkis]$"
	print_bxdi db "[BX+DI+poslinkis]$"
	print_bpsi db "[BP+SI+poslinkis]$"
	print_bpdi db "[BP+DI+poslinkis]$"
	print_si   db "[SI+poslinkis]$"
	print_di   db "[DI+poslinkis]$"
	print_bp   db "[BP+poslinkis]$"
	print_bxpos db "[BX+poslinkis]$"
	print_adres db "[t.adres]$"
	
	print_ax db "AX=$"
	print_al db "AL=$"
	print_ah db "AH=$"
	print_dx db "DX=$"
	
	reiksmeAX dw ?
	reiksmeDX dw ?
	
	
.code
trecia:
	mov ax, @data
	mov ds, ax
		
	mov ax, 0
	mov es, ax

	push es:[0]
	push es:[2]

; PERTRAUKIMO PERIIMIMAS

	mov word ptr es:[0], offset pertraukimas
	mov es:[2], @code

; TESTUOJAME INT 0
    
    mov ax, 0000h
	div bx
	mov bx, 0000h
	div di
	xor dx, dx
	div dx
	xor cx, cx
	div cx
	mov bp, 0000h
	div bp
	 
; PABAIGA
	 
	pop es:[2]
	pop es:[0]	
	
	mov ah, 4Ch
	mov al, 0h
	int 21h

; INT 0 apdorojimas

pertraukimas proc
    
    pop si
    pop di
    push di
	add si, 0002h
    push si
	sub si, 0002h
	
	mov reiksmeAX, ax
	push ax
	push bx
	push cx
	mov reiksmeDX, dx
	push dx
	push bp
	push es
	push ds
	
	mov ax, @data
	mov ds, ax    
	
; OPK i AL 
	
	mov bx, cs:[si]
	
; DIV nustatymas
   
    	mov ah, 09h
	mov dx, offset pranesimas
	int 21h
	
	;Spausdinam CS:IP
	mov ax, di
	call print
	
	mov ah, 02h
	mov dl, ":"
	int 21h
	
	mov ax, si
	call print
	
	call printTarpas   ;spausdinam tarpa
	
	;SPAUSDINAM MASININI KODA
	mov ah, bl
	mov al, bh
    call print
    
    call printTarpas
    
    mov ah, 02h
    mov dl, 3Bh
    int 21h
    
    call printTarpas
    
    ;TIKRINAM IR SPAUSDINAM MNEMONIKA
     
    mov ah, 09h
    mov dx, offset dalyba
    int 21h
    
    mov al, bh
    mov cl, 04h
    shr al, cl
             
    cmp al, 03h
    je mod_00
    cmp al, 07h
    je mod_00
    cmp al, 0Bh
    je mod_00
    cmp al, 0Fh
    jne neatpazinta
    mod_11:
        xor ax, ax
        xor si, si
        mov al, bh
        shl al, cl
        shr al, cl
        xor cx, cx
        
        rm_tikrinimas:
        cmp al, ch
        je rm_rastas
        inc ch
        jmp rm_tikrinimas
            rm_rastas:
                mov al, ch
                mov dh, 02h
                mul dh
                mov si, ax
                cmp bl, 0F6h
                je w_nulis
                cmp bl, 0F7h
                jne neatpazinta
                w_vienas:
                    mov ah, 02h
                    mov dl, byte ptr[byte ptr w_registrai[si]]
                    int 21h
                    
                    mov ah, 02h
                    mov dl, byte ptr[byte ptr w_registrai[si]+1]
                    int 21h
                    call w_1
                    jmp pertraukimo_pabaiga
                w_nulis:
                    mov ah, 02h
                    mov dl, byte ptr[byte ptr b_registrai[si]]
                    int 21h
                    
                    mov ah, 02h
                    mov dl, byte ptr[byte ptr b_registrai[si]+1]
                    int 21h
                    call w_0
                    jmp pertraukimo_pabaiga    
neatpazinta:

     mov ah, 09h
     mov dx, offset erroras
     int 21h
     jmp pertraukimo_pabaiga
         
    mod_00:
        mov al, bh
        shl al, cl
        shr al, cl
        
        cmp al, 00h
        je rm_00
        cmp al, 01h
        je rm_01 
        cmp al, 02h
        je rm_02 
        cmp al, 03h
        je rm_03 
        cmp al, 04h
        je rm_04 
        cmp al, 05h
        je rm_05 
        cmp al, 06h
        je rm_06
        cmp al, 07h
        jne neatpazinta
            rm_07:
            lea dx, print_bxpos
            jmp mod_pab
            rm_00:
            lea dx, print_bxsi
            jmp mod_pab
            rm_01:
            lea dx, print_bxdi
            jmp mod_pab
            rm_02:
            lea dx, print_bpsi
            jmp mod_pab
            rm_03:
            lea dx, print_bpdi
            jmp mod_pab
            rm_04:
            lea dx, print_si
            jmp mod_pab
            rm_05:
            lea dx, print_di
            jmp mod_pab
            rm_06:
            mov al, bh
            shr al, cl
            cmp al, 03h
            jne ne_00
            lea dx, print_adres
            jmp mod_pab
            ne_00:
                lea dx, print_bp
        mod_pab:
            mov ah, 09h
            int 21h
            cmp bl, 0F6h
            je w_nulis2
            cmp bl, 0F7h
            jne neatpazinta
            call w_1
            w_nulis2:
                call w_0
                jmp pertraukimo_pabaiga    
                    
                                     

pertraukimo_pabaiga:

    mov ah, 09h
    mov dx, offset enteris
    int 21h
    
	pop ds
	pop es
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	IRET

pertraukimas endp


; PAGALBINES SPAUSDINIMO IR KITOS PROCEDUROS
w_1 proc
    push ax
    push dx
    
    call printTarpas
    
    mov ah, 09h
    mov dx, offset print_ax
    int 21h
    
    mov ax, reiksmeAX
    call print
    
    call printTarpas
    
    mov ah, 09h
    mov dx, offset print_dx
    int 21h
    
    mov ax, reiksmeDX
    call print
    
    pop dx
    pop ax
    ret
w_1 endp

w_0 proc
    push ax
    push dx
    
    call printTarpas
    
    mov ah, 09h
    mov dx, offset print_ah
    int 21h
   
    mov ax, reiksmeAX
    mov al, ah
    call print_low
    
    call printTarpas
    
    mov ah, 09h
    mov dx, offset print_al
    int 21h
   
    mov ax, reiksmeAX
    call print_low
    
    pop dx
    pop ax
    ret
w_0 endp

printTarpas proc
    
    push ax
    push dx
    
    mov ah, 02h
    mov dl, 20h
    int 21h
    
    pop dx
    pop ax
    ret
    
printTarpas endp    

print proc
    
    push ax
    mov al, ah
    call print_low
    pop ax
    call print_low
	ret
	
print endp

print_low proc
    push ax
    push cx
    
    push ax
    mov cl, 04h
    shr al, cl
    call printH
    pop ax
    call printH
    
    pop cx
    pop ax 
    ret
print_low endp

printH proc
    
    push ax
    push dx
    
    and al, 0Fh
    cmp al, 09h
    jbe printSkaic
    jmp printSymbol
    
    printSymbol:
        sub al, 10
        add al, 41h
        mov dl, al
        mov ah, 2
        int 21h
        jmp printH_grizti
        
    printSkaic:
        mov dl, al
        add dl, 30h
        mov ah, 2
        int 21h
        jmp printH_grizti 
        
    printH_grizti:
        pop dx
        pop ax
    ret
        
printH endp        
        
end trecia
