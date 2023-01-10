//file header
    .arch armv6     //armv6 architecture
    .arm            //arm 32-bit IS
    .fpu vfp        //floating point co-processor
    .syntax unified //modern syntax

//definitions applying to the entire source file
    //.equ EXAMPLE_DEF, 0xff

    //.data         //uncomment if needed

    .text           //start of text segment

    .global fpconvert               //make fpconvert global for linking to
    .type   fpconvert, %function    //define fpconvert to be a function
    .equ 	FP_OFF, 32 	            //fp offset distance from sp (# of saved regs - 1) * 4

fpconvert:	
// function prologue - do not edit this part
    push    {r4-r10, fp, lr}    // save registers to stack
    add     fp, sp, FP_OFF      // set frame pointer to frame base


// ==========================================================================
// ==========================================================================

    lsr r1, r0, #13                 // r1 = r0 >> 13  //r1 stores the sigbit
    and r2, r0, #0x1f80             // extract only exponent
    lsr r2, r2, #7                  // store the value of exponent in r2
    and r3, r0, #0x7f               // extract mantissa, store in r3

    cmp r2, #0x3f                   // if (exponent == 111111)
    bne .LnotInfinite
    bl convert_infinity             //     convert_infinity();
    bl .Lfin                        //     return;

.LnotInfinite:
    cmp r2, #0                      // if (exponent != 000000) // normal case
    beq .Ldenormal
    sub r2, r2, #31                 // r2 = r2 - 31     //remove bias 31
    add r2, r2, #127                // r2 = r2 + 127    //add new bias 127
    lsl r1, r1, #31                 // r1 = r1 << 31
    lsl r2, r2, #23                 // r2 = r2 << 23
    lsl r3, r3, #16                 // r3 = r3 << 16
    and r0, r0, #0                  // erase r0
    orr r0, r0, r1                  // set sigbit
    orr r0, r0, r2                  // set exponent
    orr r0, r0, r3                  // set mantissa
    b .Lfin

.Ldenormal:
    mov r2, #97                     //set exponent = -30 + bias
    cmp r3, #0                      //if (mantissa != 0)
    beq .Lzero                      //
    cmp r3, #0x40                   //while (mantissa < 0x40)
    bge .LendWhile
.Lwhile:
    lsl r3, r3, #1                  //r3 = r3 << 1
    sub r2, r2, #1                  //r2--
    cmp r3, #0x40
    blt .Lwhile

.LendWhile:
    lsl r3, r3, #1
    sub r2, r2, #1

    lsl r1, r1, #31                 // r1 = r1 << 31
    lsl r2, r2, #23                 // r2 = r2 << 23
    lsl r3, r3, #16                 // r3 = r3 << 16
    and r0, r0, #0                  // erase r0
    orr r0, r0, r1                  // set sigbit
    orr r0, r0, r2                  // set exponent
    lsl r3, r3, #9                  // r3 = r3 << 9
    lsr r3, r3, #9                  // r3 = r3 >> 9 // get rid of the bit out of matissa bounds
    orr r0, r0, r3                  // set mantissa
    b .Lfin

.Lzero:
    lsl r0, r1, #31
.Lfin:



    






// ==========================================================================
// function epilogue
    sub	sp, fp, FP_OFF
    pop     {r4-r10, fp, lr}     // MUST MATCH LIST IN PROLOG'S PUSH
    bx      lr                   // return

// function footer
    .size fpconvert, (. - fpconvert) // set size for function

// ==========================================================================

    .global convert_infinity
    .type   convert_infinity, %function
    .equ    FP_OFF, 32
// make a 32-bit IEEE +Inf or -Inf
convert_infinity:	
// function prologue (do not edit)
    push    {r4-r10, fp, lr}    // save regs
    add     fp, sp, FP_OFF
// r4-r10 are local to this function
// changes to these values will not be reflected
// in the main function.

// ==========================================================================
// ==========================================================================
    lsl r1, r1, #31             //r1 = r1 << 31
    mov r2, #255                 //r2 = 0b1111_1111
    lsl r2, r2, #23             //r2 = r2 << 2
    orr r0, r1, r2

// ==========================================================================
// function epilogue
    sub	sp, fp, FP_OFF
    pop     {r4-r10, fp, lr}    // restore regs
    bx      lr                  // return
// function footer
    .size convert_infinity, (. - convert_infinity)

//file footer
    .section .note.GNU-stack,"",%progbits // stack/data non-exec (linker)
.end
