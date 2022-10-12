BITS 16
org 0x8000

video:
	; start preparing the video memory
	cli
	
	push 0x0A000                ; video memory graphics segment
    	pop es                      ; pop any extar segments from stack
    	xor di,di                   ; set destination index to 0
    	xor ax,ax                   ; set color register to zero
	
	mov ax, 0x13				; jumping to 320x200 & 256 colors
	int 0x10
	
	print:
		; screen = 320x200, half -> 160x100, since we need to print a centered text we will just do some magic operations
		mov ah,0x02
		mov bh,0x00
		mov dh,9          ; y cordinate
		mov dl,4          ; x cordinate
		int 0x10
		
		mov si, text
		
		next:
			; snagged from the same place, the bootldr wwwww
			mov al,[si] ; move the si byte which stores our text to “al”, to later, be compared
			cmp al,0 ; check if the last byte, “or char”, is 0.
			je done ; if that byte compared is 0? we are done, else, continue reading
			call printchar ; call the teletype function to print text
			inc si ; increase the counter “si”, which contains our text bytes
			jmp next ; repeat the operation again, until it checks 0

		printchar: ; the printchar service
			mov ah,0x0e
			mov bl, 0x28 ; red carmesi... (guess why and im following you)
			int 0x10
			ret ; return function
	
	text db "[The punishment for mocking one]",13,10,13,10,"           [of my servants...]",10,13,13,10,13,10,"                IS DEATH",0	

done:
	; some kind of box in the middle
	; preset the color to a dark red
		mov ax,0x04                 ; set color to a dark red
		
		l1: ; first line

		mov dx,0                    ; initialize counter(dx) to 0

		add di,320                  ; add di to 320(next line)
		imul di,10                  ; multiply by 10 to di to set y cordinate from where we need to start drawing

		add di,10                   ; set x cordinate of line from where to be drawn
		
		tl: ; top line

		mov [es:di],ax              ; move value ax to memory location es:di

		inc di                      ; increment di for next pixel
		inc dx                      ; increment our counter
		cmp dx,300                  ; comprae counter value with 300
		jbe tl			    ; if <= 300, again

		; drawing bottm line of window
		xor dx,dx
		xor di,di
		add di,320
		imul di,190         ; set y cordinate for line to be drawn
		add di,10           ; set x cordinate of line to be drawn

		mov ax, 0x28        ; color

	bli: ; bottom line

		mov [es:di],ax

		inc di
		inc dx
		cmp dx,300
		jbe bli

		; drawing left line
		xor dx,dx
		xor di,di
		add di,320
		imul di,10           ; set y cordinate for line to be drawn
		add di,10            ; set x cordinate for line to be drawn

		mov ax,0x28      

	lel: ; left line

		mov [es:di],ax

		inc dx
		add di,320
		cmp dx,180
		jbe lel


		; drawing right line
		xor dx,dx
		xor di,di
		add di,320
		imul di,10           ; set y cordinate for line to be drawn

		add di,311           ; set x cordinate for line to be drawn

		mov ax,0x28          ; orange color

	rl: ; right line

		mov [es:di],ax

		inc dx
		add di,320
		cmp dx,180
		jbe rl

		;drawing line below top line
		xor dx,dx
		xor di,di

		add di,320
		imul di,27           ; set y cordinate for line to be drawn

		add di,11            ; set x cordinate for line to be drawn

		mov ax,0x28	
		jmp endd
	
endd: ; end drawing
	mov ax, 0x00 ; inefficient but it works
	int 0x16
	jmp scene
	
scene:
	; tried to do the chess effect, colors are inspired from one anime i have seen, my favourite
	int 0x10			; set video mode AND draw pixel
	mov ax,cx		; get column in AH
	add ax,di		; offset by framecounter
	xor al,ah		; XOR pattern
	and al, 28		
	or al, 04
	mov ah,0x0C		; set subfunction "set pixel" for int 0x10
	loop scene		; loop the scene
	inc di			; increment framecounter
	jmp scene

times (512 * 5) - ($-$$) db 0 ; remember, if you want to modify the size of the payload, change the bootloader ones too (in %define SECTOR)
; because otherwise it wont work.
	

; AND
;             Operand1: 	0101
;             Operand2: 	0011
;	----------------------------
;	After AND -> Operand1:	0001
;
; OR:
;             Operand1:     0101
;             Operand2:     0011
;	----------------------------
;	After OR -> Operand1:   0111