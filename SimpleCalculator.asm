title SIMPLE_CALCULATOR
; James-Andrew R. Sarmiento
; 2012-26531

.model small 
.data
	MSG1 db 10,13, "Enter first number: ", '$'
	MSG2 db 10,13, "Enter second number: ", '$'
	MSGSUM db 10,13, "SUM: ", '$'
	MSGDIFF db 10,13, "DIFFERENCE: ", '$'
	MSGDIFF2 db 10,13, "DIFFERENCE: -", '$'
	MSGPROD db 10,13, "PRODUCT: ", '$'
	MSGQUOT db 10,13, "QUOTIENT: ", '$'
	MSGMOD db 10,13, "MODULO: ", '$'
	MSGMAX db 10,13, "MAX: ", '$'
	MSGMIN db 10,13, "MIN: ", '$'
	MSGAVE db 10,13, "AVERAGE: ", '$'
	POINTFIVE db ".5", '$'
	MSGUNDEF db "Undefined", '$'
	
	num1 db 0 
	num2 db 0
	sum db 0
	diff db 0
	max db 0
	min db 0
	negativeTrigger db 0
	pointFiveTrigger db 0
	product dw 0
	quotient db 0
	modulo db 0
	ave db 0
	count db 0
	
.stack 100h
.code

	inputFunction proc
		xor ax, ax
		xor bx, bx
		xor cx, cx
		xor dx, dx
		
		getUserInput:
			inc count							  
			mov ah, 01h 						;GET INPUT FROM USER
			int 21h
				
				cmp al, 13
				je exitLoop
				
			sub al, 48
			xor cx, cx
			mov cl, al
			mov al, dl							;MOV AL, NUM1
			mov bl, 10
			mul bl
			mov dl, al							;MOV NUM1, AL
			add dl, cl
					
			cmp count, 2
			jl getUserInput
		
		exitLoop:
			ret
		inputFunction endp

	adder proc
		mov al, num1
		mov cl, num2
		add al, cl
		mov sum, al
		ret
		adder endp
	
	minus proc
		mov al, max
		mov cl, min
		sub al, cl
		mov diff, al
		ret
		minus endp
	
	whichIsLarger proc
		mov al, num1
		mov cl, num2
		cmp al, cl
		jge greater
			mov max, cl
			mov min, al
			add negativeTrigger, 1
			jmp done
		greater:
			mov max, al
			mov min, cl
		done:
		whichIsLarger endp
	
	multiply proc
		mov bx, 0
		mov al, num1
		mov bl, num2
		mul bl
		mov product, ax
		ret 
		multiply endp
	
	divide proc
		xor ax, ax
		xor cx, cx
		mov al, num1
		mov cl, num2
		div cl
			mov quotient, al
			mov modulo, ah
			ret
			divide endp
	
	average proc
	xor cx, cx
	xor ax, ax
		mov al, sum
		mov cl, 2 
		div cl
			mov ave, al
			cmp ah, 1
			je putPTF
				jmp exitAve
			putPTF:
				add pointFiveTrigger, 1 
			exitAve:
			ret
			average endp
			
		
	; function adapted from http://pastebin.com/mk8vn071		
	display proc				;Procedure TO DISPLAY
			mov bx, 10			;initializes divisor
			mov dx, 0000h			;clears dx
			mov cx, 0000h			;clears cx
				
							;Splitting process starts here
	dloop1:	mov dx, 0000h			;clears dx during jump
				div bx				;divides ax by bx
				push dx				;pushes dx(remainder) to stack
				inc cx				;increments counter to track the number of digits
				cmp ax, 0			;checks if there is still something in ax to divide
				jne dloop1			;jumps if ax is not zero
					
	dloop2:	pop dx				;pops from stack to dx
				add dx, 30h			;converts to it's ascii equivalent
				mov ah, 02h				
				int 21h				;calls dos to display character
				loop dloop2			;loops till cx equals zero
				ret				;returns control
			display endp
	
	;MAIN FUNCTION STARTS HERE
	main proc
	
	mov ax, @data
	mov ds,ax
	
	lea dx, MSG1				;DISPLAYS INPUT MESSAGE FOR NUM1									
    mov ah, 09h
    int 21h
	
	call inputFunction			;CALLS FUNCTION FOR RECEIVING THE INPUT OF THE USERAND MAKING IT DECIMAL
	mov num1, dl				;STORES THE DECIMAL TO VARIABLE NUM1
	
	xor ax, ax					;CLEARS CONTENT OF REGISTERS USED
	xor bx, bx
	xor cx, cx
	xor dx, dx
	mov count, 0
	
	lea dx, MSG2				;DISPLAYS INPUT MESSAGE FOR NUM2
    mov ah, 09h
    int 21h
	
	call inputFunction			;CALLS FUNCTION FOR RECEIVING THE INPUT OF THE USERAND MAKING IT DECIMAL
	mov num2, dl				;STORES THE DECIMAL TO VARIABLE NUM2
	
	xor ax, ax					;CLEARS CONTENT OF REGISTERS USED
	xor bx, bx
	xor cx, cx
	xor dx, dx

	call whichIsLarger			;CALLS FUNCTION FOR GETTING THE BIGGER NUMBER AMONG INPUTS
		lea dx, MSGMAX			;DISPLAYS "MAX: "			
		mov ah, 09h	
		int 21h
		xor ax, ax				;CLEARS AX REGISTER
		mov al, max				;COPIES CONTENT OF MAX TO AL
		call display			;DISPLAYS THE DECIMAL CONTENT ON SCREEN
				
		lea dx, MSGMIN					
		mov ah, 09h
		int 21h
		xor ax, ax				;CLEARS AX REGISTER
		mov al, min				;COPIES CONTENT OF MIN TO AL
		call display			;DISPLAYS THE DECIMAL CONTENT ON SCREEN
		
	call adder					;CALLS FUNCTION THAT ADDS NUM1 AND NUM2
		lea dx, MSGSUM					
		mov ah, 09h
		int 21h
		xor ax, ax
		mov al, sum
		call display
		
	call minus					;CALLS SUBTRACTION FUNCTION OF MAX AND MINIMUM, MAX - MINIMUM SO THAT THERE IS NO NEGATIVE
		cmp negativeTrigger, 1	;LOOKS IF THERE IS A NEGATIVE ANSWER IF NUM2 IS GREATER THAN NUM1. THIS IS MANIPULATED IN THE WHICHISLARGER FUNCTION
		jne positive
			lea dx, MSGDIFF2	;PRINTS MSG WITH NEGATIVE SIGN		
			mov ah, 09h
			int 21h
			jmp printMinus
		
		positive:
		lea dx, MSGDIFF			;PRINTS MSG WITHOUT NEGATIVE SIGN			
		mov ah, 09h
		int 21h
		printMinus:				;DISPLAYS VALUE OF THE DIFFERENCE
		xor ax, ax
		mov al, diff
		call display
		
	call multiply				;CALL MULTIPLY FNC
		lea dx, MSGPROD					;
		mov ah, 09h
		int 21h
		mov ax, product			;MOVES PRODUCT TO AX REGISTER FOR DISPLAY
		call display
		xor ax, ax
	
	lea dx, MSGQUOT				;PRINTS "QUOTIENT: " MSG		
	mov ah, 09h
	int 21h
	
	cmp num2, 0 				;IF NUM2 IS NOT ZERO AUTOMATICALLY JUMPS TO VALID LABEL AND COMPUTES FOR QUOTIENT, OTHERWISE DISPLAYS UNDEFINED
	jne valid
		lea dx, MSGUNDEF			
		mov ah, 09h
		int 21h
		jmp undefDiv
		
	valid: 
	call divide					;CALLS DIVIDE FNC
		xor ax, ax
		mov al, quotient
		call display
		
		lea dx, MSGMOD					
		mov ah, 09h
		int 21h
		xor ax, ax
		mov al, modulo
		call display
	
	undefDiv:
	call average				;CALLS AVERAGE FNC
		lea dx, MSGAVE					
		mov ah, 09h
		int 21h
		
		xor ax, ax
		mov al, ave
		call display			;DISPLAYS AVERAGE
		
		cmp pointFiveTrigger, 1	;CONCATENATES .5 IF MODULO IS 1
		je ptF
			jmp msDOS
		
		ptF:
			lea dx, POINTFIVE					
			mov ah, 09h
			int 21h
		
	msDOS:	
	mov ax, 4c00h				;RETURNS TO MS-DOS
	int 21h
	main endp
	end main
				