//File:											assign2c.asm
//Author:										Tyler Nguyen
//Date:											February 8th, 2023
//Description:										integer multiplication prorgram

define(Multiplier, w21)									//represents the multipler variable
define(Multiplicand, w22)                                                               //represents the multiplicand variable
define(Product, w23)                                                                    //represents the product variable
define(negative, w24)                                                                   //represents the negative variable
define(bitwise_result,w28)                                                              //holds the result of the bitwise operation
define(i,w29)                                                                           //represents the counter for the for loop



define(Result, x25)                                                                     //represents the result variable after calculations
define(temp1, x26)                                                                      //represents the first temporary variable
define(temp2, x27)                                                                      //represents the second temporary variable

define(FALSE, w19)                                                                      //represents as the FALSE constant
define(TRUE, w20)                                                                       //represents as the TRUE constant

fmt:            .string "multiplier = 0x%08x (%d) multiplicand = 0x%08x (%d)\n\n"       //stores the fmt string in memory
fmt2:           .string "product = 0x%08x multiplier = 0x%08x\n"                        //stores the fmt2 string in memory
fmt3:           .string "64-bit result = 0x%016lx (%ld)\n"                              //stores the fmt3 string in memory


                .global main                                                            //enables the linker to see main
                .balign 4                                                               //enables the instructions are word aligned


main:           stp     x29, x30, [sp, -16]!                                            //stores frame pointer fp and lr
                mov     x29, sp                                                         //sets the frame pointer to the stack top

                mov     FALSE,#0                                                        //intializes the constant false to 0
                mov     TRUE, #1                                                        //intializes the constant true to 1

                mov     Multiplicand, #-252645136                                       //intializes the multiplicand to -252645136
                mov     Multiplier, #-256                                               //intializes the multiplier to -256
                mov     Product, #0                                                     //intializes the product to 0
                mov     i, #0                                                           //intializes i to 0

                ldr     x0, =fmt                                                        //the first argument in fmt(learnt from akram tutorial)
                mov     w1, Multiplier                                                  //the second argument to replace the first"%08x"
                mov     w2, Multiplier                                                  //the third argument to replace the first "%d"
                mov     w3, Multiplicand                                                //the fourth argument to replace the second"%08x"
                mov     w4, Multiplicand                                                //the fifth argument to replace the second"%d"
                bl      printf                                                          //calls printf

                cmp     Multiplier, 0                                                   //compares Multiplier to 0
                b.lt    is_negative                                                     //if Multiplier value is < 0 goto is_negative

                mov     negative, #0                                                    //intialize negative to 0
                b       test                                                            //goto to test

top_loop:                                                                               //top of loop
                and     bitwise_result, Multiplier, 0x1                                 //bitwise_result = Multiplier & 0x1
                cmp     bitwise_result, 1                                               //compares bitwise_result to 1

                b.eq    product_add                                                     //if bitwise_result == 1 goto product_add

body_loop:                                                                              //body of the loop

                asr     Multiplier, Multiplier, 1                                       //Multiplier = Multiplier >> 1
                and     bitwise_result, Product, 0x1                                    //bitwise_result = Product & 0x1
                cmp     bitwise_result, 1                                               //compares bitwise_result to 1

                b.eq    multiplier_or                                                   //if bitwise_result == 1 goto multiplier_or
                and     Multiplier, Multiplier, 0x7FFFFFFF                              //Multiplier = Multiplier & 0x7FFFFFFF

body_loop2:                                                                             //second body of the loop
                asr     Product, Product, 1                                             //Product = Product >> 1
                add     i, i, 1                                                         //i++ increments loop counter


test:                                                                                   //loop test
                cmp     i, 32                                                           //compares i to 32
                b.lt    top_loop                                                        //if i < 32 goto top_loop
                cmp     negative, 1                                                     //compares negative to 1
                b.eq    product_sub                                                     //if negative == 1  goto product_sub

main2:                                                                                  //second part of main
                ldr     x0, =fmt2                                                       //the first argument in fmt2
                mov     w1, Product                                                     //the second argument to replace the first"%08x"
                mov     w2, Multiplier                                                  //the third argument to replace the second"%08x"
                bl      printf                                                          //calls printf

                sxtw    x23, Product                                                    //converts int Product into a long int
                and     temp1, x23, 0xFFFFFFFF                                          //temp1 = x23(Product) & 0xFFFFFFFF
                lsl     temp1, temp1, 32                                                //temp1 = temp1 << 32

                sxtw    x21, Multiplier                                                 //converts int Multiplier into a long int
                and     temp2, x21, 0xFFFFFFFF                                          //temp2 = x21(Multiplier) & 0xFFFFFFFF
                add     Result, temp1, temp2                                            //Result = temp1 + temp2

                ldr     x0, =fmt3                                                       //the first argument of fmt3
                mov     x1, Result                                                      //the second argument to replace "%0x016lx"
                mov     x2, Result                                                      //the third argument to replace "%ld"
                bl      printf                                                          //calls printf
                b       exit                                                            //goto exit

product_add:                                                                            //product addition
                add     Product, Product, Multiplicand                                  //Product = Product + Multiplicand
                b       body_loop                                                       //goto body_loop

multiplier_or:                                                                          //multiplier or calculation
                orr     Multiplier, Multiplier, 0x80000000                              //Multiplier = Multiplier | 0x80000000
                b       body_loop2                                                      //goto body_loop2

is_negative:                                                                            //if Multiplier is negative
                mov     negative, #1                                                    //intializes negative to 1
                b       test                                                            //goto test

product_sub:                                                                            //product subtraction
                sub     Product, Product, Multiplicand                                  //Product = Product - Multiplicand
                b       main2                                                           //goto main2

exit:                                                                                   //exits program
                ldp     x29, x30, [sp], 16                                              //restores the stack
                mov     x0, 0                                                           //return code
                ret                                                                     //return to OS
