//File:	assign4.asm
//Author: Tyler Nguyen
//Date: March 15th, 2023
//Description: draw a sphere and change its size program

print_sphere:		.string /*"Sphere %s*/ "origin = (%d, %d, %d) radius = %d\n" 	//format string 1
print_initial:		.string "\nInitial sphere values:\n" 				//format string 2
print_change:		.string "\nChanged sphere values:\n"				//format string 3
print_first:		.string "first "						//format string 4
print_second:		.string "second "						//format string 5


fp .req x29										//equates to name x29 to fp
lr .req x30										//equates to name x30 to lr

define(result_r, w19)									//define w19 to result_r
define(factor_r, w20)									//define w20 to factor_r
define(s_r, x19)									//define x19 to s_r
define(first_r, x21)									//define x21 to first_r
define(second_r, x22)									//define x22 to second_r

x_offset = 0										//offset for x
y_offset = 4										//offset for y
z_offset = 8										//offset for z

origin_offset = 12 									//offset for origin
radius_offset = 16									//offset for radius
result_offset = 20									//offset for result
		
s_size = 32										//size of s
first_size = 32										//first size
second_size = 32									//second size

first_s = 16										//offset for first_s 
second_s = 40										//offset for second_s

result_size = 4										//size of result
factor_size = 4										//size of factor

alloc = -(16 + first_size + second_size) & -16						//main memory allocation
dealloc = -alloc									//main memory deallocation

			.balign 4							//aligns bits by 4
			.global main							//make main visible 
main:			stp fp, lr, [sp, alloc]!					//store x29 and x30 
			mov fp, sp							//mov sp to fp
			
			add first_r, fp, first_s					//calculating base address of first
			mov x8, first_r							//move first_r into x8 for calculations
			bl newSphere 							//goto newSphere
			
			add second_r, fp, second_s					//calculating base address for second_r
			mov x8, second_r						//move second_r into x8 for calculations
			bl newSphere							//goto newSphere
			
			ldr x0, =print_initial						//loads print_initial to x0
			bl printf							//calls printf
			
			ldr x0, =print_first						//loads print_first to x0
			bl printf							//calls printf
			mov x8, first_r							//moves first_r to x8
			bl printSphere							//goto printSphere
	
			ldr x0, =print_second						//load print_second to x0
			bl printf							//calls printf
			mov x8, second_r						//move second_r to x8
			bl printSphere							//goto printSphere


			bl equal							//goto equal
			ldr result_r,[fp, result_offset]				//loads result_r 
			cmp result_r, 1							//compare result_r with 1
			b.ne false							//if not equal goto false
				
			mov x8, first_r							//move first_r into x8
			mov w1, #-5 							//mov -5 to w1
			mov w2, #3							//mov 3 to w2
			mov w3, #2							//mov 2 to w3
			bl move								//goto move
			

			mov x8, second_r						//mov x9 to second_r
			mov w1, #8							//mov 8 tp w1
			bl expand							//goto expand
false:											//false label
			ldr x0, =print_change						//load print_change to x0
			bl printf							//calls printf
			
			ldr x0, =print_first						//load print_first to x0
			bl printf							//calls printf
			mov x8, print_first						//move print_first to x8
			bl printSphere							//goto printSphere
			
			ldr x0, =print_second						//load print_second to x0
			bl printf							//calls printf
			mov x8, print_second						//mov print_second to x8
			bl printSphere							//goto printSphere
			
exit:			mov x0,0							//exit label and move 0 to x0
			ldp fp, lr, [sp], dealloc					//loads fp and lr 
			ret								//return to os


//struct sphere newSphere()

newSphere_alloc = -(16 + s_size) & -16							//memory allocation for newSphere
newSphere_dealloc = -newSphere_alloc							//memory deallocation for newSphere

newSphere:		stp fp,lr, [sp, newSphere_alloc]!				//stores fp and lr
			mov fp,sp							//move sp to fp
			
			mov s_r,x8							//move x8 to s_r
			str wzr,[s_r,origin_offset + x_offset]				//s.origin.x = 0
			str wzr,[s_r,origin_offset + y_offset]				//s.origin.y = 0
			str wzr,[s_r,origin_offset + z_offset]				//s.origin.z = 0
			
			mov x23, #1							//move 1 into x23
			str x23,[s_r,radius_offset]					//s.radius = 1

			ldp fp, lr,[sp], newSphere_dealloc				//loads fp and lr
			ret								//returns to main

//void move()
move_alloc = -(16 + alloc) & -16							//memory allocation for move
move_dealloc = -move_alloc								//memory deallocation for move

move:			stp fp, lr, [sp, move_alloc]!					//store fp and lr
			mov fp, sp							//move sp to fp
			
			ldr w25, [x8,origin_offset + x_offset]				//loads s->origin.x
			add w25, w25, w1						//s->origin.x+=deltaX
			str w25, [x8,origin_offset + x_offset]				//stores s->origin.x
			 
			ldr w25, [x8,origin_offset + y_offset]				//loads s->origin.y
                        add w25, w25, w2						//s->origin.y+=deltaY
                        str w25, [x8,origin_offset + y_offset]				//stores s->origin.y

			ldr w25, [x8,origin_offset + z_offset]				//loads s->origin.z
                        add w25, w25, w3						//s->origin.z+=deltaZ
                        str w25, [x8,origin_offset + z_offset]				//stores s->origin.z
				
			ldp fp, lr,[sp], move_dealloc					//loads fp and lr
			ret								//return to main
//void expand()
expand_alloc = -(16 + s_size + factor_size) & -16					//memory allocation for expand
expand_dealloc = -expand_alloc								//memory deallocation fo expand

expand:			stp fp, lr, [sp, expand_alloc]!					//store fp and lr
			mov fp, sp							//move sp tp fp
			
			ldr w11, [x8, radius_offset]					//loads s->radius
			mul w11, w11, w1						//s->radius*=factor
			str w11, [x8, radius_offset]					//store s->radius

			ldp fp, lr,[sp], expand_dealloc					//loads fp and lr
			ret								//return to main

//int equal()
equal_alloc = -(16 + alloc + result_size) & -16						//memory allocation for equal
equal_dealloc = -equal_alloc								//memory deallocation for equal

equal:			stp fp, lr, [sp, equal_alloc]!					//store fp and lr
			mov fp, sp							//move sp to fp
			mov result_r, 0 						//move 0 to result_r

			ldr w24, [first_r, x_offset + origin_offset]			//load s1->origin.x
			ldr w25, [second_r, x_offset + origin_offset]			//load s2->origin.x
			cmp w24, w25							//compares s1->origin.x to s2->origin.x
			b.ne store							//goto store if not equal
			
			ldr w24, [first_r, y_offset + origin_offset]			//loads s1->origin.y
                        ldr w25, [second_r, y_offset + origin_offset]			//loads s2->origin.y
                        cmp w24, w25							//compare s1->origin.y to s2->origin.y
                        b.ne store							//goto store if not equal
			
			ldr w24, [first_r, z_offset + origin_offset]			//loads s1->origin.z
                        ldr w25, [second_r, z_offset + origin_offset]			//loads s2->origin.z
                        cmp w24, w25							//compare s1->origin.z to s2->origin.z
                        b.ne store							//goto store if not equal
	
			ldr w24, [first_r, result_offset]				//loads s1->radius
                        ldr w25, [second_r, result_offset]				//loads s2->radius
                        cmp w24, w25							//compare s1->radius to s2->radius
                        b.ne store							//goto store if not equal 
			
			mov result_r, 1							//move 1 to result_r

store:			str result_r, [fp, result_offset]				//stores result_r
			
			ldp fp, lr, [sp], equal_dealloc					//loads fp and lr
			ret								//return to main
//void printSphere
printS_alloc = -(16 + s_size) & -16							//memory allocation for printSphere
printS_dealloc = -printS_alloc								//memory deallocation for printSphere

printSphere: 		stp fp, lr, [sp, printS_alloc]!					//store fp and lr
			mov fp, sp							//move sp to fp
			
			ldr x0, =print_sphere						//load print_sphere to x0
			ldr w1,[x8, x_offset + origin_offset] 				//loads s->origin.x
			ldr w2,[x8, y_offset + origin_offset]				//loads s->origin.y
			ldr w3,[x8, z_offset + origin_offset]				//loads s->origin.z
			ldr w4,[x8, radius_offset]					//loads s->radius
			
			bl printf							//calls printf
			
			mov x0,0							//move 0 to xo
			ldp fp, lr, [sp], printS_dealloc				//loads fp and lr
			ret								//return to main
			
