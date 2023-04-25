//file: a5b.asm
//author: Tyler Nguyen
//date:	March 23, 2023
//description: create a program that accepts command line arguments that represent the date in the format mm dd yyyy




define(amt_argument, w19)                  															//amount if arguments                                             
define(in_argument, x20)                                                             										//input argument array

define(month, w21)                                                                    										//input for months
define(day, w22)                                                                      										//input for day
define(year, x23)																		//input for year
	
define(bam_array_r, x24)                                                               										//(B)ase (A)ddress (M)onth array
define(bas_array_r, x25)                                                              										//(B)ase (A)ddress (S)uffix array
	
		    	.text																	//.text read-only location
error_msg:	    	.string "usage: a5b mm dd yyyy\n"                                             								//error message format string
fmt:	    	    	.string "%s %d%s, %d\n"   														//format string for output
	
jan:		    	.string "January"                    							                                         	//january
feb:		    	.string "February"                                                            								//february
mar:		    	.string "March"                                                               								//march
apr:		   	.string "April"                                                               								//april
may:		    	.string "May"                                                               								//may
jun:		  	.string "June"                                                                								//june
jul:		   	.string "July"                                                                								//july
aug:	    		.string "August"                                                              								//august
sep:	    		.string "September"                                                           								//september
oct:	  		.string "October"                                                             								//october
nov:	   		.string "November"                                                            								//november
dec:	    		.string "December"                                                            								//december

st: 			.string "st"																//st suffix
nd:			.string "nd"																//nd suffix
rd:			.string "rd"																//rd suffix
th:             	.string "th"                                        											//th suffix

m_array_m:		.dword jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec									//creation of month array
		
s_array_m:		.dword st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st       //creation of suffix array for 31 days                                        		
		
                                      		

			.balign 4                                                                 								//align bits by 4
			.global main                                                             								//enables main to be visible 

main:	     																			//main label
			stp x29, x30, [sp, -16]!                                                  								//stores fp and lr 
			mov x29, sp                                                               								//sets frame pointer to the stack top 
		
			mov amt_argument, w0                                                            							//move w0 to amt_argument
			mov in_argument, x1                                                            								//move x1 to in_argument
			mov w26, 1																//move first user input
			mov w27, 2																//move second user input
			mov w28, 3																//move thrid user input
		
			cmp amt_argument, 4                                                             							//compares amount of ammount arguments to 4
			b.lt write_error                                                              		       						//goto write_error if amt_argument < 4
	
			
			ldr x0, [in_argument, w26, SXTW 3]                                        								//load first argument into x0
			bl atoi                                          											//calls atoi
			mov month, w0     															//move result of atoi into month
       		 
			
			ldr x0, [in_argument, w27, SXTW 3]               											//load second argument into x0
			bl atoi                                          											//calls atoi
			mov day, w0                                    												//move result of atoi into day

	
			ldr x0, [in_argument, w28, SXTW 3] 													//load third argument into x0
			bl atoi																	//calls atoi
			mov year, x0																//move result of atoi into year
	  
		        cmp month, 0																//compare month to 0
			b.le write_error															//goto write_error if month < 0
			cmp month, 12																//compare month to 12
			b.gt write_error															//goto write_error if month > 12
			cmp day, 0																//compare day to 0
			b.le write_error															//goto write_error if day < 0
			cmp day, 31																//compare day to 31
			b.gt write_error															//goto write_error if day > 31 
			cmp year, 0																//compare year to 0
			b.le write_error                                         										//goto write_error if year < 0
	
		
			ldr bam_array_r, =m_array_m														//get month from month array based from input
			sub month, month, 1															//month = month - 1 to get correct month
	
			ldr bas_array_r, =s_array_m      													//get suffix from suffix array based from input             					
	
			ldr x0, =fmt																//load format string
			ldr x1, [bam_array_r, month, SXTW 3]          												//load month for the format string
	
			mov w2, day                                    												//mov day into w2
			sub day, day, 1																//day = day - 1 to get correct day
			ldr x3, [bas_array_r, day, SXTW 3]        												//load day for the format string
	
			mov x4, year																//mov year into x4
	
			bl printf 																//call printf                                      	
end:	      																			//end label
			ldp x29, x30, [sp], 16                           											//deallocate memory
			ret    																	//return to os

write_error:																			//write_error label
			ldr x0, =error_msg															//load error_msg format string 
			bl printf																//call printf
			b end                                          												//goto end
