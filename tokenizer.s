#=========================================================================
# Tokenizer
#=========================================================================
# Split a string into alphabetic, punctuation and space tokens
# 
# Inf2C Computer Systems
# 
# Siavash Katebzadeh
# 8 Oct 2018
# 
#
#=========================================================================
# DATA SEGMENT
#=========================================================================
.data

#-------------------------------------------------------------------------
# Constant strings
#-------------------------------------------------------------------------

input_file_name:        .asciiz  "input.txt"   
newline:                .asciiz  "\n"

#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned


# You can add your data here!
tokens:                  .space 411849
max_word_size:           .word 201 
max_input_size:          .word 2049 



a: 		.byte 'a'
z: 		.byte 'z'
A: 		.byte 'A'
Z: 		.byte 'Z'
comma: 		.byte ','
period: 	.byte '.'
exclamation: 	.byte '!'
space:		.byte ' ' 
qmark:	 	.byte '?'
        
#=========================================================================
# TEXT SEGMENT  
#=========================================================================
.text

#-------------------------------------------------------------------------
# MAIN code block
#-------------------------------------------------------------------------

.globl main                     # Declare main label to be globally visible.
                                # Needed for correct operation with MARS
main:
        
#-------------------------------------------------------------------------
# Reading file block. DO NOT MODIFY THIS BLOCK
#-------------------------------------------------------------------------

# opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, input_file_name       # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # open a file
        
        move $s0, $v0                   # save the file descriptor 

# reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP:                              # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # content[idx] = c_input
        la   $a1, content($t0)          # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(input_file);
        
        
        blez $v0, END_LOOP              # if(feof(input_file)) { break }
        lb   $t1, content($t0)  
        
        
        addi $v0, $0, 10                # newline \n
        beq  $t1, $v0, END_LOOP         # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP
                
        
END_LOOP:

        sb   $0,  content($t0)
         
        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------


tokenizerloop:

        li $s0, 64
        li $s1, 32
        
        lw $t4, max_word_size
        lw $t5, max_input_size
        
        lb $s2, comma
        lb $s3, period
        lb $s4, exclamation
        lb $s5, space
        lb $s6, qmark
        lb $s7, newline 
        

check:
        move $t2, $0 # int token_c_idx = 0; 
        
        lb $t0, content($t3) # int c_idx = 0. c = content[c_idx]. c is in $t0.
        beq $t0, $0, main_end # if (c == '\0') {break;}

        bgt $t0, $s0, isalpha # if(c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') { ... }
        beq $t0, $s2, ispunct # i the character is a comma, it is a punctuation mark
        beq $t0, $s3, ispunct # if the character is a period, it is a punctuation mark
        beq $t0, $s4, ispunct # if the character is an exclamation mark, it is a punctuation mark
        beq $t0, $s6, ispunct # if the character is a question mark, it is a punctuation mark 
        beq $t0, $s5, isspace # if the character is a space, go to isspace

isalpha:
   
        # t0 has content[c_idx]
        # t3 has c_idx
        # tokens[tokens_number][token_c_idx] = c    
        # address = ((rowlength * array_row) + array_column)) 
        # rowlength = max_word_size, in $t4
        # array_row = tokens_number = $t6
        # array_column = token_c_index = $t2
        # store the address in $t7
        
        mul $t7, $t4, $t6
        add $t7, $t7, $t2
        
        sb $t0, tokens($t7) # tokens[tokens_number][token_c_idx] = c  
        
        add $a0, $t0, $zero # copy the value stored in $t0 to $a0 
        li $v0, 11 # system call for print character
        syscall # print the character in register $a0
        
        addi $t2, $t2, 1 # token_c_idx += 1
        addi $t3, $t3, 1 # c_idx += 1
        
        lb $t0, content($t3) # c = content[c_idx]
        beq $t0, $0, main_end # if (c == '\0') {break;}

        bgt $t0, $s0, isalpha # if the character is still an alphabet, repeat
        
        j print_new # if the character is NOT an alphabet, go to print_new

isspace:
        
        mul $t7, $t4, $t6
        add $t7, $t7, $t2
        
        sb $t0, tokens($t7) # tokens[tokens_number][token_c_idx] = c  
        
        add $a0, $t0, $zero # copy the value stored in $t0 to $a0 
        li $v0, 11 # system call for print character
        syscall # print the character in register $a0
        
        addi $t2, $t2, 1 # token_c_idx += 1
        addi $t3, $t3, 1 # c_idx += 1
        lb $t0, content($t3) # c = content[c_idx]
        #beq $t0, $0, output_tokens # if (c == '\0') { break; }
        beq $t0, $0, main_end # if (c == '\0') {break;}

        beq $t0, $s5, isspace # if the character is still a space, repeat
                
        j print_new # if the character is NOT a space, go to print_new

ispunct: 

        mul $t7, $t4, $t6
        add $t7, $t7, $t2

        sb $t0, tokens($t7) # tokens[tokens_number][token_c_idx] = c  
        
        add $a0, $t0, $zero # copy the value stored in $t0 to $a0 
        li $v0, 11 # system call for print character
        syscall # print the character in register $a0
        
        addi $t2, $t2, 1 # token_c_idx += 1
        addi $t3, $t3, 1 # c_idx += 1
        lb $t0, content($t3) # c = content[c_idx]
        
        beq $t0, $0, main_end # if (c == '\0') {break;}

        beq $t0, $s2, ispunct # if the character is a comma, it is a punctuation mark, repeat
        beq $t0, $s3, ispunct # if the character is a period, it is a punctuation mark, repeat
        beq $t0, $s4, ispunct # if the character is an exclamation mark, it is a punctuation mark, repeat
        beq $t0, $s6, ispunct # if the character is a question mark, it is a punctuation mark, repeat
        
        j print_new # if the character is NOT a punctuation, go to print_new

print_new: 

        la $a0, newline # print a new line "\n"
        li $v0, 11 # system call for print character
        syscall # print the character in register $a0#
        
        mul $t7, $t4, $t6
        add $t7, $t7, $t2
        
        sb $0, tokens($t7) # tokens[tokens_number][token_c_idx] = '\0'
        addi $t6, $t6, 1 # tokens_number += 1

        move $t2, $0 # int token_c_idx = 0; 

        j check # return to the tokenizerloop
             
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
