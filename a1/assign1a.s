//File:		assign1a.s
//Author: 	Tyler Nguyen
//Date:		January 28th, 2023
//Description:	finds the maximum between the range of -10<=x<=4 from the
//		equation: y = -2x^3-22x^2+11x+57

fmt: 	.string "when x = %li, y = %li\n" 
fmt2:	.string "the maximum in the range of -10<=x<=4 is when x = %li, y = %li\n"
					//fmt: stores the string in memory
					//fmt2: stores the string in memory 
	
	.global main			//enables the linker to see main
	.balign 4			//enables the instructions are word aligned


main:	stp	x29, x30, [sp, -16]!	//stores frame pointer fp and lr
	mov	x29, sp			//sets the frame pointer to the stack top
	
	mov	x19, #-10 		//intializes x value, x19 = -10
	mov 	x20, #0 		//intializes y value, x20 = 0
	mov 	x21, #0 		//intializes max x value, x21 = 0
	mov 	x22, #0 		//intializes max y value, x22 = 0
					
					//set of instructions, intializes ..
					//..each part of y = -2x^3-22x^2+11x+57 	
	
	mov	x23, #0 		//intializes -2x^3 of the equation, x23 = 0
	mov	x24, #0			//intializes 22x^2 of the equation, x24 = 0
	mov	x25, #0 		//intializes 11x of the equation, x25 = 0
	mov 	x26, #-2		//intializes x26 = -2, acts as a constant
	mov 	x27, #-22		//intializes x27 = -22, acts as a constant 
	mov	x28, #11 		//intializes x28 = 11, acts as a constan
	 
	
top_loop:				//the top of the loop
	cmp 	x19,4			//compares x19 to 4
	b.gt 	end_loop		//if x19 > 4 then goto end_loop
 	
	mul	x23, x19, x19 		//x^2
	mul 	x23, x23, x19		//x^3
	mul	x23, x23, x26		//-2x^3
	
	mul	x24, x19, x19		//x^2
	mul	x24, x24, x27		//-22x^2

	mul	x25, x19, x28		//11x
	
	add	x20, x23, x24		//y = -2x^3 + (-22x^2)
	add 	x20, x20, x25		//y = -2x^3 + (-22x^2) + 11x
	add 	x20, x20, 57		//y = -2x^3 + (-22x^2) + 11x + 57
	
	ldr 	x0, =fmt		//the first argument in fmt (learnt ldr from akram tutorial)
	mov	x1, x19			//the second argument to replace the first "%li" in fmt
	mov 	x2, x20			//the thrid argument to replace the sencond "%li" in fmt
	bl 	printf			//calls printf
	
	cmp	x20, x22		//compares x20 to x22
	b.gt	maximum			//if x20 > x22 the goto maximum


	add	x19, x19, #1		//increments loop counter
	
	b	top_loop		//goto top_loop
maximum:				//calculates maximum between differnt y values
	mov	x21, x19		//updates the max x value
	mov 	x22, x20		//updates the max y value
	add 	x19, x19, #1		//increments loop counter
	b 	top_loop		//goto top_loop


end_loop:				//the end of the loop
	ldr 	x0, = fmt2		//the first argument in fmt
	mov 	x1, x21			//the second argument to replace the first "%li" in fmt2
	mov	x2, x22			//the third arguement to replace the second "%li" in fmt2
	bl 	printf			//calls printf
	b 	exit			//goto exit
	
exit:					//exits the program
	ldp	x29, x30, [sp], 16      //restores the stack
	mov 	x0, 0			//return code 
	ret				//return to OS
