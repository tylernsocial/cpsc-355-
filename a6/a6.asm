//file: a6.asm
//author: Tyler Nguyen
//date: april  6, 2023
//description: create a program that takes an input file from the command line, and using those inputs
//	       generate the their ln(x) output


			.data								//data section
STOPPING_LIMIT:  	.double 0r1.0e-13						//initializing the limit for the term/series calculation to stop to 1.0e-13
ZERO: 			.double 0r0.0							//initializing ZERO to 0.0 for later use
ONE:    		.double 0r1.0							//initializing ONE to 1.0 for later use

			.text								//text section
opening_error_msg:  	.string "could not open file, error, terminating\n"		//format string for opening error message
print_IO:  		.string "|   %.10f\t|\t%.10f   |\n"				//format string for printing the (I)nput, (O)utput
input_file_error: 	.string "incorrect file type, please type another file name\n"  //format string for incorrect input file
top_of_table:   	.string "|   x value\t        |       Ln(x)          |\n"	//format string for the top of the table/header
underline: 		.string "================================================\n"	//format string for underlining the table/header
EOF_closed_file_msg: 	.string " end of file reached, closed file\n"			//format string for end of file and closed file message
file_opened_msg: 	.string "file open successfully\n"				//fomrat string for opening the file successfully message


define(arg_amt, w20)									//amount of command argument
define(arg_val, x21)									//argument value, array of strings 
define(fd_r, w22)									//file descriptor
define(input_x, d8)									//the value of the input x
define(series_sum, d9)									//the sum of given ln(x) series until the limit is reached
define(nth_val, d10)									//the nth term of the series
define(curr_term, d11)									//current term being calculated in the series
define(one_r, d12)									//variable that will hold 1.0
define(divsor, d13)									//the divsor of each term
define(first_term, d14)									//the value of the first term (x-1)/x
define(numer, d15)									//numerator (x-1)
define(exp, d16)									//the value nth-1 term so that it can raised the nth exponent for current term
define(stop_limit, d17)									//the stopping limit for the term/series calculation 1.0e-13
buf_size = 8										//buffer size for bytes that will be read
buf_loc = 16										//buffer location in the stack
alloc= -(16 + buf_size) & -16								//allocating memory
dealloc = -alloc									//deallocating memory


        		.balign 4							//enables 4 bit alignment
        		.global main							//enables main to be seen

main:  											//main label
			stp     x29, x30, [sp, alloc]!					//stores fp and lr
       			mov     x29, sp							//sets fp to sp

		        mov     arg_amt, w0						//storing amount of values from argument
      			mov     arg_val, x1						//storing command line arguement values

  		      	cmp     arg_amt, 2						//comparing arg_amt to 2, 
        		b.ne    IFE_print						//if != 2 arguements goto IFE_print

        		mov     w0, -100						//w0 = -100 to find file 
		        ldr     x1, [arg_val, 8]					//assigning the name of the file from command line
    			mov     w2, 0							//w2 = 0
         		mov     w3, 0							//w3 = 0
        		mov     x8, 56							//x8 = 56 openat IO request/service call/request
        		svc     0							//call system function
        		mov     fd_r, w0						//fd_r = w0

        		cmp     fd_r, 0							//comparing fd to 0, to see if file was opened correctly
        		b.ge    table_setup						//if successful goto table_setup

        		ldr x0,=opening_error_msg					//load format string opening_error_msg
        		bl      printf							//calls printf
        		b       end							//goto end

table_setup: 										//table_setup label
        		ldr     x0,= file_opened_msg					//load format string file_opened_msg
        		bl      printf							//calls printf
        		ldr     x0,= underline						//load format string underline
        		bl      printf							//calls printf
        		ldr     x0,= top_of_table					//load format string top_of_table 
        		bl      printf							//calls printf
        		ldr     x0,= underline						//load format string underline
       	 		bl      printf							//calls printf

ln_calc_setup:										//ln_calc_setup label
        		ldr     x19, =ZERO						//loads x19 with ZERO address data
        		ldr     series_sum, [x19]					//loads series_sum with x19
        		ldr     x19,=ONE						//loads x19 with ONE address data
        		ldr     one_r, [x19]						//loads one_r with x19
        		ldr     x19, =STOPPING_LIMIT					//loads x19 with STOPPING_LIMIT address data	
        		ldr     stop_limit, [x19]					//loads stop_limit with x19

        		fmov    nth_val, 1.0						//nth_val = 1.0
        		mov     w0, fd_r						//w0 = fd_r 
        		add     x1, x29, buf_loc					//pointer to buffer
        		mov     x2, buf_size						//x2 = buf_size get number of bytes 
        		mov     x8, 63							//write I/O request
        		svc     0							//call system function

        		cmp     w0, buf_size						//compares w0 to 0 (long n_read >= 0)
        		b.lt    close_file						//if w0 < 0 goto close_file

        		ldr     input_x, [x29, buf_loc]					//load input x into input_x
        		fsub    numer, input_x, one_r					//calculating x-1
        		fdiv    first_term, numer, input_x				//calculating (x-1)/x
        		fmov    curr_term, first_term					//value of first term of series (x-1)/x
        		fmov    exp, first_term						//value of ((x-1/x)^n)
        		fadd    series_sum, series_sum, curr_term			//calculating series sum = 0.0 + (x-1)/x
        		b       term_test						//goto term_test

next_term_calc: 									//next_term_calc label
			fadd    nth_val, nth_val, one_r					//incrementing nth value by 1 n++
        		fdiv    divsor, one_r, nth_val					//setting up divsor 1.0/nth_value
        		fmul    exp, exp, first_term					//calculating nth exponent of (x-1)/x, ((x-1)/x)^n)^n
        		fmul    curr_term, divsor, exp					//1/n(x-1/n)^n
        		fadd    series_sum, series_sum, curr_term			//calculating series sum = (x-1)/x + 1/n(x-1/n)^n ....
        		b       term_test						//goto term_test

close_file:  										//close_file label
			mov     w0, fd_r						//w0 = fd_r 
        		mov     x8, 57							//close file code
        		svc     0							//call system function
        		ldr     x0, =underline						//load format string underline
        		bl      printf							//calls printf
        		ldr     x0, =EOF_closed_file_msg				//load format string EOF_closed_file_msg
        		bl      printf							//calls printf

end:    										//end label				
			ldp     x29, x30, [sp], dealloc					//deallocating memory
        		ret								//return to os

IFE_print:										//IFE_print label (I)nput (F)ile (E)rror
			ldr     x0,= input_file_error					//load format string input_file_error
        		bl      printf							//calls printf
        		b       end							//goto end
	
IO_print:										//IO_print label (I)nput (O)utput
       			ldr     x0,=print_IO						//loads format string print_IO
        		fmov    d0, input_x						//moves input_x into d0
        		fmov    d1, series_sum						//moves ln(x) into d1
        		bl      printf							//calls printf
        		b       ln_calc_setup						//goto ln_calc_setup

term_test:										//term_test label

        		fabs    stop_limit, stop_limit					//absolute value of stop_limit
        		fabs    d19, curr_term						//absolute value of current term
       	 		fcmp    d19, stop_limit						//compares abs(current term) to abs(stop_limit)
        		b.ge    next_term_calc						//if greater than calculate next term in series
        		b       IO_print						//else go to IO_print

