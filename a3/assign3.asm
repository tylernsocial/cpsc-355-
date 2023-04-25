//File:									assign3.asm
//Author:								Tyler Nguyen
//Date:									February 28th, 2023
//Description:								selection sort program


size = 50								//represents #define SIZE 50
v_s = 16								//represents base address of array 
v_size = size * 4							//represents the size of array in bytes
i_size = 4								//represents the size of index i in bytes
j_size = 4								//represents the size of index j in bytes
min_size = 4								//represents the size of integer min in bytes
temp_size = 4								//represents the size of integer temp in bytes


alloc = -(16 + v_size + i_size + j_size + min_size + temp_size) & -16 	//represents the amount of space to allocate 
dealloc = -alloc							//representrs the ammount of space to deallocate

define(i, w19)								//represents index i 
define(j, w20)								//represents index j
define(min, w21)							//represents integer min 
define(temp, w22)							//represents integer temp
define(v_base, x23)							//represents the array base
define(rand_num_i, w24)							//represents v[i]
define(rand_num_min,w25)						//represents v[min]
define(rand_num_j, w26)							//represents v[j]


fmt:   		.string "v[%d]: %d\n"					//stores the fmt string in memory
fmt2:   	.string "\nSorted array: \n"				//stores the fmt2 string in memory





        	.global main						//enables the linker to see main
        	.balign 4						//enables the instructions are word aligned

main:           stp     x29, x30, [sp ,alloc]!				//stores frame pointer fp and lr
                mov     fp, sp						//sets the frame pointer to the stack top

                add     v_base, fp, v_s					//calculates the array base address

                mov     i, 0						//intializes i to 0
		mov	j, 0						//intializes j to 0
		mov 	min, 0						//intializes min to 0
		mov	temp, 0						//intializes temp to 0
		mov 	rand_num_i, 0					//intializes rand_num_i to 0
		mov 	rand_num_j, 0					//intializes rand_num_j to 0
		mov 	rand_num_min, 0					//intializes rand_num_min to 0
		  
                b       test						//goto test

top_loop:								//represents the top of loop 1
   
                bl      rand						//calls rand()
                and     rand_num_i, w0, 0xFF				//v[i] = rand() & 0xFF
                str     rand_num_i, [v_base,i,SXTW 2]			//stores v[i] into memory

                ldr     x0, =fmt					//the first argument of fmt
                mov     w1, i						//the second argument to replace %d
                mov     w2, rand_num_i					//the third argument to replace %d\n
                bl      printf						//calls printf

                add     i, i, 1						//i++
     



test:									//represents the condition for 1st loop
                cmp     i, size						//compares i to size
                b.lt    top_loop					//goto top_loop if i<size
		
		mov 	i, 0						//reintializes i to 0
		b 	test2						//goto test2

top_loop2:								//represents top of loop 2
		mov 	min, i						//intializes min = i
		add	j,i,1						//j = i + 1 
		b	test3						//goto test3
top_loop3:								//represents top of loop 3
		ldr 	rand_num_j, [v_base,j,SXTW 2]			//loads v[j] from memory
		ldr	rand_num_min, [v_base,min,SXTW 2]		//loads v[min] from memory
		cmp	rand_num_j, rand_num_min			//compares v[j] to v[min]
		b.lt	min_to_j					//goto min_to_j if v[j]<v[min]
		add	j,j,1						//j++
		b	test3						//goto test3
swap:									//represents the swap function
	
		
		ldr	rand_num_min, [v_base,min,SXTW 2]		//loads v[min] from memory
		ldr	rand_num_i, [v_base,i,SXTW 2]			//loads v[i] from memory
		
		mov	temp, rand_num_min				//temp = v[min]
		mov	rand_num_min, rand_num_i			//v[min] = v[i]
		str	rand_num_min, [v_base,min,SXTW 2]		//stores v[min] to memory
		mov 	rand_num_i, temp				//v[i] = temp
		str 	rand_num_i, [v_base,i,SXTW 2]			//stores v[i] to memory
		
		add	i,i,1						//i++
test2:									//represents the condition for 2nd loop
		cmp 	i , #size-1					//compares i to size-1
		b.lt	top_loop2					//goto top_loop2 if i<size-1
		mov	i,0						//reintialize i to 0 
		ldr	x0, =fmt2					//the first argument of fmt2
		bl 	printf						//calls printf
		b	print_test					//goto print_test

test3:									//represents the condition for 3rd loop
		
		cmp	j, size						//compares j to size
		b.lt	top_loop3					//goto top_loop3 if j<size
		b 	swap						//goto swap 
min_to_j:								//represents min = j 
		mov 	min, j						//min = j
		add	j,j,1						//j++
		b 	test3						//goto test3



print_loop:								//reprents the loop to print of sorted array
		ldr	rand_num_i, [v_base,i,SXTW 2]			//loads v[i] from memory
		ldr	x0, =fmt					//the first argument of fmt
		mov	w1, i						//the second argument to replace %d
		mov 	w2, rand_num_i					//the third argument to replace %d\
		bl 	printf						//calls printf
		add	i,i,1						//i++

print_test:								//represents the condition for print loop
		cmp	i,size						//compare i to size
		b.lt	print_loop					//goto print_loop if i<size
		
exit:           							//exits program
		mov w0, 0						//return code
                ldp fp, lr, [sp], dealloc				//restores the stack
                ret							//return to OS


















