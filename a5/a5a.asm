//file: a5a.asm
//author: Tyler Nguyen
//date: March 28, 2023
//description: to create the functions of hewlett-packard calculator

MAXOP = 20                                                          	//MAXOP constant
NUMBER = '0'                                                         	//NUMBER constant
TOOBIG = '9'                                                   		//TOOBIG constant
MAXVAL = 100								//MAXVAL constant
BUFSIZE = 100								//BUFSIZE constant
define(i_variable,w19)							//define w19 to i variable in getop function
define(c_variable,w20)							//define w20 to c variable in getop function
define(lim_variable,w21)						//define w21 to lim variable in getop function
                     
		        .data                                           //data section
                        .global sp2    					//enables global variable sp2 also known as sp in functions int push, pop and void clear                                                  
                	.global val                                     //enables global variable val in functions int push and pop                    
                        .global bufp                                    //enables global variable bufp in functions int getch and void ungetch                   
                        .global buf                                     //enables global variable buf in functions int getch and void ungetch                   
sp2:                    .word 0                                         //intializes sp2                   
bufp:                   .word 0                                         //intializes bufp                  
val:                    .skip 400                                       //intializes val (MAXVAL * 4)
buf:                    .skip 400                                       //intializes buf (BUFSIZE * 4)             

	                .text                                           //text section                    
full_stack_error:       .string "error: stack full\n"                   //full stack error format string                   
empty_stack_error:      .string "error: stack empty\n"                  //empty stack error format string                  
too_many_char_error:    .string "ungetch: too many characters\n"        //too many characters error format string                   


//int push	
                 	.global push 					//enables global subroutine int push to be seen	                                                    
               		.balign 4                                       //enables 4 bit alignment 

push:              							//push label
			stp fp, lr, [sp, -16]!                          //stores fp and lr                    
                 	mov fp, sp  					//moves sp into fp

        		mov w22, w0                                     //moves int f from int push into w22                    

		    	ldr x9, =sp2					//loads sp2 into x9
                    	ldr w10, [x9]                                   //loads x9 into w10                   

                    	cmp w10, MAXVAL                                	//compares sp2 with MAXVAL                    
			b.ge print_error				//if sp2 >= MAXVAL goto print_errot
		    	ldr x23, =val					//loads val into x23
                    	
			
			str w22, [x23, w10, SXTW 2]                     //val[sp2++] = f                    
             		add w10, w10, 1                                 //sp2 = sp2 + 1 
                    	str w10, [x9]                                   //stores sp                   
                    	b exit                                          //goto exit             

print_error: 								//print_error label		              

	                ldr x0, =full_stack_error			//loads full_stack_error format string
                        bl printf                                       //calls printf

exit:                   						//exit label
			ldp fp, lr, [sp], 16				//deallocates memory
                        ret                                             //leave subroutine 

//int pop
                        .global pop					//enables global subroutine int pop to be seen	
                        .balign 4					//enables 4 bit alignment
pop:                    						//pop label
			stp fp, lr, [sp, -16]!				//stores fp and lr
                        mov fp, sp					//moves sp into fp
                        ldr x9, =sp2					//loads sp2 into x9
                        ldr w11, [x9]					//loads x9 into w11
                        cmp w9, 0					//compares sp2 with 0
                        b.le print_error2				//if sp2 <= 0 goto print_error2
			sub w11, w11, 1					//--sp2
			ldr x22, =val					//loads x22 with val
                        ldr w0, [x22, w11, SXTW 2]			//loads val[--sp2]
                        str w11, [x9]					//store sp2

                        b exit2						//goto exit2

print_error2:								//print_error2 label
                        ldr x0, =empty_stack_error			//load empty_stack_error format string
                        bl printf					//calls printf
                        bl clear					//calls clear

exit2:                  						//exit label
			ldp fp, lr, [sp], 16				//deallocates memory
                        ret						//leaves subroutine

//void clear								
			.global clear					//enables global subroutine void clear to be seen
			.balign 4					//enables 4 bit alignment
clear:									//clear label
			stp fp, lr, [sp,-16]!				//stores fp and lr
			mov fp, sp					//moves sp into fp
			ldr x10, =sp2					//loads sp2 into x0
			ldr w9, [x10]					//loads x0 into w9
			mov w9, 0					//move 0 into w9
			str w9, [x10]					//stores w9 into x0
			ldp fp, lr, [sp], 16				//deallocates memory
			ret						//leaves subroutine 

//int getop		
                    	s_array_size = 8     				//array s size	    
                    	s_loc_m = 16            			//array s locatiom
                    	getop_alloc = -(16 + s_array_size) & -16    	//getop memory allocation
                    	getop_dealloc = -getop_alloc   			//getop memory deallocation
                    	.global getop                 			//enables global subroutine int getop to be seen
                    	.balign 4					//enables 4 bit alignment
getop:             							//getop label 	
			stp fp, lr, [sp, getop_alloc]!			//stores fp and lr
                    	mov fp, sp					//moves sp into fp				
                   	add x9, fp, s_loc_m             		//calculates base address and move it into x9                                      
                    	mov x22, x0                                     //move *s into x22 
                    	mov lim_variable, w1                            //move w1 into lim_variable                  
                    	str x22, [x9]                                   //stores address of *s into x22                    

get_next:               						//get_next label
			bl getch                                        //calls getch 
                    	mov c_variable, w0                             	//c = getch()                  
                    	cmp c_variable, ' '                             //compare c and ' '                   
                    	b.eq get_next                                   //if  c = ' ' goto get_next                      
                    	cmp c_variable, '\t'                           	//compare c and '\t'                           
                    	b.eq get_next                   		//if c = '\t\ goto get_next                                     
                    	cmp c_variable, '\n'                            //compare c and '\n'
                    	b.eq get_next                                   //if c = '\n' goto get_next                      
                    	cmp c_variable, '0'                            	//compare c and '0'                     
                    	b.lt return_c                                   //if c < 0 goto return_c                     
                    	cmp c_variable, '9'                             //compare c amd '9'                   
                    	b.gt return_c                                   //if c > 9 goto return_c                     

                    	b cont                                          //goto cont

return_c:              							//return_c label
			mov w0, c_variable                              //move c into w0                   
                    	b exit3                                         //goto exit3                

cont:               							//cont label
			add x9, fp, s_loc_m                             //calculating base address                   
                    	ldr x22, [x9]                                   //load x22 with base address of s                   
                    	str c_variable, [x22]                           //stores the value of c into s[0]
			mov i_variable, 1                               //intialize i to 1         
                    	b test                                          //goto test

                    
loop:               							//loop label
                    	cmp i_variable, lim_variable                    //compare i and lim                   
                    	b.ge exit_loop                                  //i >= lim                   
                    	add x9, fp, s_loc_m                             //get base address of s again                       
                    	ldr x22, [x9]                                   //load address into x22                   
                    	str c_variable, [x22, i_variable, SXTW 2]       //stores the value of c into s[i]                

exit_loop:         							//exit_loop label
			add i_variable, i_variable, 1                   //i++                    

test:               							//test label
			bl getchar                                      //call getchar            	       
                    	mov c_variable, w0                              //move result of getchar into c                  
                    	cmp c_variable, '0'                             //compare c and '0'                  
                    	b.lt failed                                     //if c < '0' goto failed
                    	cmp c_variable, '9'                             //compare c and '9'                    
                    	b.le loop                                       //if c < '9' goto loop                  

failed:                							//failed label
                    	cmp i_variable, lim_variable                    //compare i and lim                    
                    	b.ge loop2                                      //if i >= lim goto loop2               
                    	mov w0, c_variable                              //mov c into w0                 
                    	bl ungetch                                      //call ungetch                
                    	mov w10, '\0'                                   //move '\0' into w11                     
                    	add x9, fp, s_loc_m                             //recalculate base address s                      
                    	ldr x22, [x9]                                   //load address into x22                   
                    	str w10, [x22, i_variable, SXTW 2]              //store '\0' into s[i]                 
                    	mov w0, NUMBER                                  //move number into w0                    
                    	b exit3                                         //goto exit3                 

loop2:            							//loop2 label
                    	cmp c_variable, '\n'                            //compare c and '\n'                   
                    	b.eq cont2                                      //if c = '\n' goto cont2                     
                    	cmp c_variable, -1                              //compare c and -1                   
                    	b.eq cont2                                      //if c = -1 goto cont2                     
                    	bl getchar                                      //call getchar                   
                    	mov c_variable, w0                              //move result of getchar into c                 
                    	b loop2                                         //goto loop2                

cont2:               							//cont2 label
			mov w11, '\0'                                   //move '\0' into w11                   
                    	add x9, fp, s_loc_m                             //recalculate base address of s                        
                    	ldr x22, [x9]                                   //load x9 into x22                     	
			str w10, [x22, lim_variable, SXTW 2]	        //store '\0' into s[lim-1]			        
                    	sub lim_variable, lim_variable, 1               //lim = lim - 1
			mov w0, TOOBIG                                  //mov TOOBIG into w0                    

exit3:             							//exit3 label
			ldp fp, lr, [sp], getop_dealloc			//deallocates memory
                    	ret                                             //leaves subroutine                     

//int getch
                   	.global getch  					//enables global subroutine int getch to be seen     
			.balign 4					//enables 4 bit alignment
getch:              							//getch label
			stp fp, lr, [sp, -16]!				//stores fp and lr
                    	mov fp, sp					//moves sp into fp
			ldr x9, =bufp					//loads bufp into x9
                    	ldr w10, [x9]                                   //loads bufp into w10                   
                    	cmp w10, 0                                      //compare bufp and 0                    
                    	b.le get_next2                                  //if bufp <= 0 goto get_next2                      
                    	sub w10, w10, 1                                 //bufp = bufp - 1 
		    	ldr x22, =buf					//loading base address of buf
		   	ldr w0, [x22, w10, SXTW 2]                      //loads w0 with buf[--bufp]         
                    	str w10, [x9]                                   //store w10 into x9                  

                    	b exit4                                         //goto exit4                 

get_next2:            							//get_next2
			bl getchar                                      //call getchar                  

exit4:             							//exit 4 label
			ldp fp, lr, [sp], 16				//deallocate memory
                    	ret                                             //leave subroutine                  
//void ungetch
                    	.global ungetch                                 //enables global subroutine void ungetch to be seen                  
                    	.balign 4					//enables 4 bit alignment
ungetch:            							//ungetch label
			stp fp, lr, [sp, -16]!				//stores fp and lr
                    	mov fp, sp					//moves sp into fp
                    	mov w22, w0  					//move int c into w22                                                   
                        ldr x9, =bufp					//load bufp into x9
			ldr w10, [x9]                                   //loads bufp into w10                  
                    	cmp w10, BUFSIZE                                //compares bufp and BUFSIZE                  
                    	b.le cont3                                      //if bufp <= BUFSIZE goto cont3                 
                   	ldr x0, =too_many_char_error			//load too_many_char_error format string
			bl printf                                      	//printf                     

                    	b exit5                                         //goto exit5       

cont3:             							//cont3 label
                	ldr x23, =buf   				//load buf into x23
			str w22, [x23, w10, SXTW 2]                   	//stores c into buf[bufp++]   
                   	add w10, w10, 1					//bufp = bufp + 1
			str w10, [x9]                                   //stores bufp               

exit5:               							//exit5 label
			ldp fp, lr, [sp], 16				//deallocates memory
                    	ret                                             //leaves subroutine
                
