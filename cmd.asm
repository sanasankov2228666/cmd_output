.model tiny
.code
org 100h


start: jmp main


; ==========================  output_cmd  ==========================
;                       
;	entery:    bx  -  string adres
;		   	   cl  -  atribut for symbols
; 		       si  -  VRAM adres
;	exit:      ---                                    
;	expected:  si = 0, es = VRAM segment
;	destr:     ax, si, bx
;
; ==================================================================

output_cmd:

			mov bx, 80h
			mov al, [bx]	
			
			cmp al, 0
			je if_empty

			call find_size
			call print_frame
			call print_words
			
			ret

			if_empty:
			mov bx, offset empty
			mov cx, 140

			call str_output
			jmp end_program


; _______________________________________________________________________________________________________________________________________



; ==========================  str_output (bx, cl, si)  =====================
;
;	entery:    bx  -  string adres
;		   	   cl  -  atribut for symbols
; 		       si  -  VRAM adres
;	exit:      ---                                    
;	expected:  si = 0, es = VRAM segment
;	destr:     ax, si, bx
;
; ==========================================================================


str_output:

			xor si, si
	
			loop_str_output:
	
			cmp byte ptr [bx], 0
			je end_loop
		
			mov al, [bx]
			mov es:[si], al
			mov es:[si + 1], cl
	
			inc bx
			add si, 2
		
			jmp loop_str_output
			
			end_loop:
			ret

; _______________________________________________________________________________________________________________________________________



; ==========================  print_words (bx, cx)  ===================
;
;	entery:    bx  -  leight 
;		   	   cl  -  height
;
;	exit:      ---                                   
;	expected:  si = 0, es = VRAM segment
;	destr:     ax, si, bx
;
; ==========================================================================


print_words:
			; ===== save registers =====
			
			push ax
			push bx
			push cx
			push dx
			push si
			push di

			; ===== find right up corner x y ======
		
			push ax			

			xor ax, ax
			mov ax, 80

			sub ax, bx
			shr ax, 1
			mov dh, al	     ; dy - x lt

			mov ax, 25

			sub ax, cx
			shr ax, 1
			mov dl, al           ; dl  - y lt
			
			call get_offset	
			
			pop ax
	
			; ===== begin loop =====

			mov si, 81h

			words_loop:

			cmp ax, 0
			je end_words_loop

			dec ax

			mov bl, [si]
			inc si

			cmp bl, 35
			je new_line_symbol

			mov bh, 30
				
			mov es:[di], bx
			add di, 2

			jmp words_loop

			new_line_symbol:

			inc dl
			call get_offset			

			jmp words_loop
			

			; ===== end loop =====			

			end_words_loop:
	
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			
			ret


; _______________________________________________________________________________________________________________________________________
;						
;					         =========== FRAME FUNCS ==========
; _______________________________________________________________________________________________________________________________________



; ==========================  print_frame (bx, cx)  =========================
;
;	entery:    bx - lenght
;              cx - height
;	exit:      ---                                
;	expected:  es = VRAM segment
;	destr:     bx, cx
;	
; ===========================================================================


print_frame:		
			; ===== save registers =====			

			push ax
			push bx
			push cx
			push dx
			push si
			push di

			; ===== find right up corner x y ======
			
			add bx, 4
			add cx, 4

			xor ax, ax
			mov ax, 80

			sub ax, bx
			shr ax, 1
			mov dh, al	     ; dy - x lt

			mov ax, 25

			sub ax, cx
			shr ax, 1
			mov dl, al           ; dl  - y lt
			
			call get_offset				
			
			; ==== top-left corner ====

			mov al, 201
			mov ah, 27
			mov es:[di], ax
			
			; ==== line ====

			call print_x_line	
			
			mov ax, 7099
			mov es:[di], ax
			
			inc dl					; y++
			sub cx, 2

			; ==== begin of the loop ====

			loop_horizontal:
			
			cmp cx, 0
			je end_loop_horizontal
			
			dec cx
			push cx
			call print_in_line
			pop  cx
			inc dl
			
			jmp loop_horizontal

			; ===== end of the loop =====

			end_loop_horizontal:

			call get_offset
		
			mov ax, 7112
			mov es:[di], ax

			call print_x_line	

			mov ax, 7100
			mov es:[di], ax

			; ==== end of func =====
			
			pop di
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
			
			ret


; _______________________________________________________________________________________________________________________________________			


		
; ===========================  print_in_line (void)  =========================
;
;	entry:    void
;	exit:     di - video memory offset
;	expected: es = VRAM segment, bx - leight, dh - x, dl - y
;	destr:    ax, bx, di, cx
;	
; ============================================================================


print_in_line:

			push bx
			push di		

			sub bx, 2	
			
			call get_offset

			; ==== print ( ║ ) begin ====			

			mov cx, 7098
			mov es:[di], cx			; print ( ║ )	blue background, light blue symbol 	

			add di, 2

			loop_line_in_print: 
			
			cmp bx, 0
			je end_loop_line_in_print

			dec bx
			
			mov cx, 4128 
			mov es:[di], cx       ; blue
				
			add di, 2		

			jmp loop_line_in_print

			end_loop_line_in_print:

			; ==== print ( ║ ) end ====

			mov cx, 7098
			mov es:[di], cx			; print ( ║ )	blue background, light blue symbol 	

			pop di
			pop bx
			ret

	
; _______________________________________________________________________________________________________________________________________			

			
		
; ===========================  print_x_line (void)  ===========================
;
;	entry:    void
;	exit:     di - video memory offset
;	expected: es = VRAM segment, bx - leight, dh - x, dl - y
;	destr:    ax, bx, di, cx
;	
; ============================================================================


print_x_line:
			push bx
			push cx		

			sub bx, 2 			
			
			call get_offset
			add di, 2

			loop_line_x_print: 
			
			cmp bx, 0
			je end_loop_line_x_print

			dec bx
			
			mov cx, 5069
			mov es:[di], cx       ; 201 ansi ( ═ ) blue background, light blue symbol 
				
			add di, 2		

			jmp loop_line_x_print

			end_loop_line_x_print:

			pop cx
			pop bx
			ret
			


; _______________________________________________________________________________________________________________________________________			

			
		
; ===========================  get_offset  =================================
;
;	entry:    dh - x, dl - y
;	exit:     di - video memory offset
;	destr:    ax, bx
;	
; ==========================================================================

get_offset:
			push ax
			push bx
	
			xor ax, ax
			xor bx, bx			

			mov al, dl
			mov bl, 160
			mul bl					; ax = row * 160
			
			mov bl, dh
			shl bx, 1				; bx = column * 2
			
			add ax, bx
			mov di, ax
			
			pop bx
			pop ax
			ret			
			
			


; _______________________________________________________________________________________________________________________________________



;; ============================  find_size (ax)  ==========================
;
;	entry:    ax - size of cmd
;	exit:     bx - width
;  		  	  cx - height                                
;	expected: es = VRAM segment
;	destr:    ax, bx, si, di, cx, dx
;
; ==========================================================================


find_size:
			push ax
			push dx
			push di
			push si

			xor bx, bx          
			xor cx, cx          
			xor dx, dx          
			mov di, 81h

			mov di, 81h
		
			; ===== loop begin =====
			
			loop_find_size:
		
			cmp ax, 0
			je end_loop_find_size
		
			dec ax
			
			cmp byte ptr [di], 35
			je new_line
	
			inc di

			; ===== if new letter =====

			cmp bx, 56
			je bad_size
		
			inc bx
			jmp loop_find_size
		

			; ===== if new line =====

			new_line:
	
			inc di

			cmp cx, 13
			je bad_size
	
			inc cx

			cmp bx, dx
			ja max_line
			xor bx, bx
			jmp loop_find_size
			
			; ===== max str leight =====
			max_line:
			mov dx, bx
			xor bx, bx
			jmp loop_find_size		


			; ===== end of loop ======
			end_loop_find_size:

			cmp bx, dx
			ja last_max
			jmp exit_find_size

			last_max:
			mov dx, bx

			exit_find_size:
			mov bx, dx
			inc cx

			pop si
			pop di
			pop dx
			pop ax

			ret
				

			; ===== if bad size =====

			bad_size:

			mov bx, offset cmd_bad
			mov cx, 140h
			call str_output
			jmp end_program

; _______________________________________________________________________________________________________________________________________




		
; ==================================================================
;                                 main
; ==================================================================

main:	
			xor bx, bx
			xor cx, cx
			xor dx, dx
			xor di, di
			xor si, si
			
			mov ax, 0b800h			; es = VRAM segment
			mov es, ax			; 

			xor ax, ax

			call output_cmd	
			
			end_program:
			mov ax, 4c00h
			int 21h                       


; _______________________________________________________________________________________________________________________________________



; ======================================================================
; 	      		 	    data
; ======================================================================

	
empty db 'cmd is empty', 0
cmd_bad  db 'bad size', 0


end start