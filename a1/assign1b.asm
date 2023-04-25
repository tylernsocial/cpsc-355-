//File:		assign1b.asm
//Author:	Tyler Nguyen
//Date:		January 29th, 2023
//Description:	finds the maximum between the range of -10<=x<=4
//		from the equation: y = -2x^3-22x^2+11x+57

define(x_counter, x19)						//represents the x_counter for the range of loop
define(y_value, x20)						//represents the y_value as x_counter increases
define(max_x, x21)						//the x value corresponding to the maximum y_value
define(max_y, x22)						//the maximum y_value corresponding to its x value


define(FPE, x23)						//represents the First Part of Equation, -2x^3
define(SPE, x24)						//represents the Second Part of Equation,-22x^2


define(NEG_2_CONSTS, x26)					//represents -2 in -2x^3
define(NEG_22_CONSTS, x27)					//represents -22 in -22x^2
define(POS_11_CONSTS, x28)					//represents +11 in 11x


fmt:    .string "when x = %li, y = %li\n"
fmt2:   .string "the maximum in the range of -10<=x<=4 is when x = %li, y = %li\n"
								//fmt: stores the string in memory
								//fmt2: stores the string in memory
        .global main						//enables the linker to see main
        .balign 4						//enables the instructions are word aligned


main:   stp     x29, x30, [sp, -16]!				//stores frame pointer fp and lr
        mov     x29, sp						//sets the frame pointer to the stack top

        mov     x_counter, #-10                 		//intializes x value, x_counter = -10
        mov     y_value, #0                     		//intializes y value, y_value = 0
        mov     max_x, #0                       		//intializes max x value, max_x = 0
        mov     max_y, #0                       		//intializes max y value, max_y = 0
                                                
								//set of instructions, intializes ..
                                               			//..each part of y = -2x^3-22x^2+11x+57

        mov     FPE, #0                         		//intializes -2x^3 of the equation, FPE = 0
        mov     SPE, #0                         		//intializes 22x^2 of the equation, SPE = 0
        mov     NEG_2_CONSTS, #-2               		//intializes NEG_2_CONSTS = -2, acts as a constant
        mov     NEG_22_CONSTS, #-22             		//intializes NEG_22_CONSTS = -22, acts as a constant
        mov     POS_11_CONSTS, #11              		//intializes POS_11_CONTS = 11, acts as a constan


        b       test						//goto test

top_loop:                                       		//the top of the loop

	mul	FPE, x_counter, x_counter			//x^2
	mul	FPE, FPE, x_counter				//x^3
	mul	FPE, FPE, NEG_2_CONSTS				//-2x^3
	
	mul 	SPE, x_counter, x_counter			//x^2
	madd 	y_value, SPE, NEG_22_CONSTS, FPE		//y = -2x^3 + (-22*x^2)
	
	madd	y_value, x_counter, POS_11_CONSTS, y_value	//y = y + (11*x)

	add 	y_value, y_value, 57				//y = y+57





        ldr     x0, =fmt                       		 	//the first argument in fmt (learnt ldr from akram tutorial)
        mov     x1, x_counter                   		//the second argument to replace the first "%li" in fmt
        mov     x2, y_value                     		//the thrid argument to replace the sencond "%li" in fmt
        bl      printf                          		//calls printf

        cmp     y_value, max_y                  		//compares y_value to y_max
        b.gt    maximum                         		//if y_value > y_max the goto maximum


        add     x_counter, x_counter, #1        		//increments loop counter

                                                


test:								//loop test
        cmp     x_counter,5					//compares x_counter to 5
        b.lt    top_loop					//if x_counter value < 5 goto top_loop
	
	ldr	x0, =fmt2					//the first agrument in fmt2
	mov 	x1, max_x					//the second argument to replace the frist "%li" in fmt2
	mov 	x2, max_y					//the thrid argument to replace the second "%l" in fmt2
	bl 	printf						//calls printf
	b 	exit						//goto exit
	
maximum:                               		       		//calculates maximum between differnt y values
        mov     max_x, x_counter       		       		//updates the max_x value with the current x_counter value
        mov     max_y, y_value                 			//updates the max_y value with the current y_value 
        add     x_counter, x_counter, #1        		//increments loop counter
        b       test                            		//goto test



exit:								//exits program
        ldp     x29, x30, [sp], 16 				//restores the stack
        mov     x0, 0						//return code
        ret							//return to OS
