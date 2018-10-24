#=========================================================================
# Spell checker 
#=========================================================================
# Marks misspelled words in a sentence according to a dictionary
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
dictionary_file_name:   .asciiz  "dictionary.txt"  

#-------------------------------------------------------------------------
# Global variables in memory
#-------------------------------------------------------------------------
# 
content:                .space 2049     # Maximun size of input_file + NULL
.align 4                                # The next field will be aligned
dictionary:             .space 200001   # Maximum number of words in dictionary *
                                        # maximum size of each word + NULL

# You can add your data here!
tokens:                  .space 411849
max_word_size:           .word 201 
max_input_size:          .word 2049 

dict2d:                  .space 210000
max_dictionary_words:    .word 10000
max_d_size:                 .word 21


a:                 .byte 'a'
z:                 .byte 'z'
A:                 .byte 'A'
Z:                 .byte 'Z'
comma:             .byte ','
period:            .byte '.'
exclamation:       .byte '!'
space:             .byte ' ' 
qmark:             .byte '?'
underscore:        .byte '_'

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
        sb   $0,  content($t0)          # content[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(input_file)


        # opening file for reading

        li   $v0, 13                    # system call for open file
        la   $a0, dictionary_file_name  # input file name
        li   $a1, 0                     # flag for reading
        li   $a2, 0                     # mode is ignored
        syscall                         # fopen(dictionary_file, "r")
        
        move $s0, $v0                   # save the file descriptor 

        # reading from file just opened

        move $t0, $0                    # idx = 0

READ_LOOP2:                             # do {
        li   $v0, 14                    # system call for reading from file
        move $a0, $s0                   # file descriptor
                                        # dictionary[idx] = c_input
        la   $a1, dictionary($t0)       # address of buffer from which to read
        li   $a2,  1                    # read 1 char
        syscall                         # c_input = fgetc(dictionary_file);
        blez $v0, END_LOOP2             # if(feof(dictionary_file)) { break }
        lb   $t1, dictionary($t0)               
        lb   $t1, dictionary($t0)               
        beq  $t1, $0,  END_LOOP2        # if(c_input == '\n')
        addi $t0, $t0, 1                # idx += 1
        j    READ_LOOP2
END_LOOP2:
        sb   $0,  dictionary($t0)       # dictionary[idx] = '\0'

        # Close the file 

        li   $v0, 16                    # system call for close file
        move $a0, $s0                   # file descriptor to close
        syscall                         # fclose(dictionary_file)
#------------------------------------------------------------------
# End of reading file block.
#------------------------------------------------------------------




# You can add your code here!
# addr = baseAddr + (rowIndex * colSize + colIndex) * dataSize
# row number * row length + column number
# rowIndex = $t0, tokens_number
# colSize = $a1, max_word_length
# colIndex = $t2, tokens_c_idx


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
        beq $t0, $0, dictionaryloop # if (c == '\0') then the token ended, proceed to tokenizing the dictionary

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
        
        addi $t2, $t2, 1 # token_c_idx += 1
        addi $t3, $t3, 1 # c_idx += 1
        
        lb $t0, content($t3) # c = content[c_idx]
        beq $t0, $0, dictionaryloop #  if (c == '\0') then the token ended, proceed to tokenizing the dictionary

        bgt $t0, $s0, isalpha # if the character is still an alphabet, repeat
        
        j print_new # if the character is NOT an alphabet, go to print_new

isspace:
        
        mul $t7, $t4, $t6
        add $t7, $t7, $t2
        
        sb $t0, tokens($t7) # tokens[tokens_number][token_c_idx] = c  

        addi $t2, $t2, 1 # token_c_idx += 1
        addi $t3, $t3, 1 # c_idx += 1
        lb $t0, content($t3) # c = content[c_idx]
        #beq $t0, $0, output_tokens # if (c == '\0') { break; }
        beq $t0, $0, dictionaryloop #  if (c == '\0') then the token ended, proceed to tokenizing the dictionary

        beq $t0, $s5, isspace # if the character is still a space, repeat
                
        j print_new # if the character is NOT a space, go to print_new

ispunct: 

        mul $t7, $t4, $t6
        add $t7, $t7, $t2

        sb $t0, tokens($t7) # tokens[tokens_number][token_c_idx] = c  
    
        addi $t2, $t2, 1 # token_c_idx += 1
        addi $t3, $t3, 1 # c_idx += 1
        lb $t0, content($t3) # c = content[c_idx]
        
        beq $t0, $0, dictionaryloop # if (c == '\0') then the token ended, proceed to tokenizing the dictionary

        beq $t0, $s2, ispunct # if the character is a comma, it is a punctuation mark, repeat
        beq $t0, $s3, ispunct # if the character is a period, it is a punctuation mark, repeat
        beq $t0, $s4, ispunct # if the character is an exclamation mark, it is a punctuation mark, repeat
        beq $t0, $s6, ispunct # if the character is a question mark, it is a punctuation mark, repeat
        
        j print_new # if the character is NOT a punctuation, go to print_new

print_new: 
       
        mul $t7, $t4, $t6
        add $t7, $t7, $t2
        
        sb $0, tokens($t7) # tokens[tokens_number][token_c_idx] = '\0'
        addi $t6, $t6, 1 # tokens_number += 1

        move $t2, $0 # int token_c_idx = 0; 

        j check # return to checking

########################## END OF TOKENIZER ########################## 
                                        
dictionaryloop:
        
        # set the previously used t registers to null
        move $t0, $0
        move $t1, $0
        move $t2, $0
        move $t3, $0
        move $t4, $0
        move $t5, $0
        move $t7, $0
        move $t8, $0
        
        li $s0, 64
        li $s1, 10 # load newline ('\n') to $s1
        
        lw $t4, max_d_size
        lw $t5, max_dictionary_words


check2:

        move $t2, $0 # int dict_index = 0;
        
        lb $t0, dictionary($t3) # int i = 0. d = dictionary[i]. d is in $t0.
        beq $t0, $0, clear # if (d == '\0') {break;} -> go to spellchecking

        bne $t0, $s1, isalpha2 # if (isalpha(d)) (or if (d != '\n')
        j print_new2 # else { ... }

isalpha2:

        # $t0 has dictionary[dict_index]
        # I want to store dictionary[dict_index] in dict_array[d_words][dict_index]
        # to access the address of dict_array[d_words][dict_index]
        # address = ((rowlength * array_row) + array_column)) 
        # $t4 has max_d_size (maximum word length) = rowlength
        # $t2 has dict_index = array_column
        # $t8 has d_words = array_row

        mul $t7, $t4, $t8
        add $t7, $t7, $t2
        
        sb $t0, dict2d($t7) # dict_array[d_words][dict_index] = d 
        
        addi $t2, $t2, 1 # dict_index += 1
        addi $t3, $t3, 1 # i += 1
        
        lb $t0, dictionary($t3) # d = dictionary[i]
        beq $t0, $0, clear # if (d == '\0') {break;}
        
        bne $t0, $s1, isalpha2 # if (d != '\n'), continue looping and storing

        j print_new2 # else { ... }


print_new2: 

        mul $t7, $t4, $t8
        add $t7, $t7, $t2

        sb $0, dict2d($t7) # dict_array[d_words][dict_index] = '\0'
        addi $t8, $t8, 1 # d_words += 1

        move $t2, $0 # int dict_index = 0; 
        addi $t3, $t3, 1 # i += 1
              
        j check2 # return to check
        
        
########################## END OF DICTIONARY TOKENIZER ########################## 
        

###########################################################################################################################################################
###########################################################################################################################################################
###########################################################################################################################################################
         
clear:
        
        # Set all the used registers to null
        
        move $t0, $0
        move $t1, $0
        move $t2, $0
        move $t3, $0
        move $t4, $0
        move $t5, $0
        move $t7, $0
        move $t9, $0
        
        move $s0, $0
        move $s1, $0
        move $s2, $0
        move $s3, $0
        move $s4, $0
        move $s5, $0
        move $s6, $0
        move $s7, $0
        
        lw $s0, max_word_size
        
        lw $s2, max_d_size
        
        move $s4, $t6 # move the content of $t6 which contains tokens_number to $s4
        addi $s4, $s4, 1 # tokens_number + 1
        move $s5, $t8 # move the content of $t8 which contains d_words to $s5
        addi $s5, $s5, 1 # d_words + 1
        
        li $s6, 64 
        
        move $t6, $0
        move $t8, $0
        

spellchecker:
        
        beq $t0, $s4, main_end # when current tokens number = real tokens number, end the program (reached the end of the tokens)
        
        # $t0 = tokens_number 
        # $t1 = token_c_idx
        
        mul $t2, $s0, $t0
        add $t2, $t2, $t1
        
        # load the contents of tokens[tokens_number][token_c_idx] to $t3
        lb $t3, tokens($t2)
        
        # $t4 = d_words
        # $t5 = dict_index
        
        mul $t6, $s2, $t4
        add $t6, $t6, $t5
        
        # load the contents of dict_array[d_words][dict_index] to $t7
        lb $t7, dict2d($t6)
        
        # if the value in $t3 has an ASCII value of less than or equal to 64, it is NOT an alphabet        
        ble $t3, $s6, print # so print anyway

        jal strcmp # go to a function where you compare the strings
        # result from compare strings is stored in $s7.
        beqz $s7, printwrong # if $s7 = 0, then the token is not in the dictionary
        j print # if $s7 = 1, then the token is in the dictionary
        
print:
        move $t1, $zero # set token_c_idx = 0 to print from first character of the token
        
        mul $t2, $s0, $t0
        add $t2, $t2, $t1

        lb $t3, tokens($t2)
        
        j printright
        
        printright:
                add $a0, $t3, $zero # copy the value stored in $t0 to $a0
                li $v0, 11 # system call for print character
                syscall # print the character in register $a0
        
                addi $t1, $t1, 1 # token_c_idx += 1
        
                mul $t2, $s0, $t0
                add $t2, $t2, $t1
        
                lb $t3, tokens($t2)
                
                beq $t3, $0, printdone # if the end of the token is reached, move to the next token
                j printright # else { continue printing }

         
printwrong:

        move $t1, $zero # set token_c_idx = 0 to print from first character of the token
        
        mul $t2, $s0, $t0
        add $t2, $t2, $t1
        
        lb $t3, tokens($t2)
        
        # print the first underscore
        li $a0, 95
        li $v0, 11
        syscall 
        
        printloop:
        
                add $a0, $t3, $zero # copy the value stored in $t0 to $a0 
                li $v0, 11 # system call for print character
                syscall # print the character in register $a0
        
                addi $t1, $t1, 1 # token_c_idx += 1
        
                mul $t2, $s0, $t0
                add $t2, $t2, $t1
        
                lb $t3, tokens($t2)

                beq $t3, $0, print_underscore2 # if the end of the token is reached, print the enclosing underscore
                j printloop # else { continue printing }
        
        # print the enclosing underscore
        print_underscore2:
        
        li $a0, 95
        li $v0, 11
        syscall 
               
        j printdone

printdone:

        addi $t0, $t0, 1 # tokens_number += 1
        move $t1, $0 # token_c_index = 0
        move $t5, $0 # dict_index = 0
        move $t4, $0 # d_words = 0
        j spellchecker
                

strcmp:
        loop:
        
                mul $t2, $s0, $t0
                add $t2, $t2, $t1

        
                lb $t3, tokens($t2)

                mul $t6, $s2, $t4
                add $t6, $t6, $t5

                lb $t7, dict2d($t6)
        
                # check if the character is null
                beqz $t3, checkstr1
                beqz $t7, different
                
                # IF NEITHER OF THEM ARE NULL
                beq $t3, $t7, same
                bne $t3, $t7, checkstr2 # check if lowercased
        
        checkstr1:
                bnez $t7, differentlength # if you've reached the end of the token but not the dictionary word, then it's not the same word
                j same # int empty = (a == NULL) || (b == NULL);
        
        # check if the lowercase version of the token is the same as the dictionary word
        checkstr2:
                addi $t8, $t3, 32
                beq $t8, $t7, same # (((a[i])+32) == (b[i])) == 1
                j different
                
        different:
                li $s7, 0 
                beq $t4, $s5, endfunction # if d_words = real dict number, then end (reached the end of the dictionary)
                # however if d_words < real dict number
                addi $t4, $t4, 1 # d_words += 1 (move to the next dictionary word)
                move $t5, $0 # dict_index = 0 (start comparing from the first character of the dictionary word)
                move $t1, $0 # token_c_idx = 0 (start comparing from the first character of the token)
                j loop
                

        same:
                li $s7, 1 # $s7 acts as a flag. if the characters are the same, mark 1.
                beqz $t3, checkstr3 # if you've reached the end of the token, you want to check if you reached the end of the dictionary word
                addi $t1, $t1, 1 # tokens_c_idx += 1 
                addi $t5, $t5, 1 # dict_index += 1
                j loop # move to the next character in the token and compare it to the next character in the dictionary word
        
        checkstr3:
                beqz $t7, endfunction # if the dictionary word reached null as well and $s7 remains 1, then they are the same word
                j differentlength # else, they are of different length
                
        differentlength:
                li $s7, 0 # if they are different in length, they are obviously different words
                beq $t4, $s5, endfunction # if d_words = real dict number, then end (reached the end of the dictionary)
                addi $t4, $t4, 1 # d_words += 1 (move to the next dictionary word)
                move $t5, $0 # dict_index = 0 (start comparing from the first character of the dictionary word)
                move $t1, $0 # token_c_idx = 0 (start comparing from the first character of the token)
                j loop
                 
                
        endfunction:
                jr $ra
                # if the characters are different until end of dict, $s4 will be 0 
                # if the characters are the same until end of dict, $s4 will be 1
                # it will go back to where we placed jal strcmp, and process the result of $s4

        
#------------------------------------------------------------------
# Exit, DO NOT MODIFY THIS BLOCK
#------------------------------------------------------------------
main_end:      
        li   $v0, 10          # exit()
        syscall

#----------------------------------------------------------------
# END OF CODE
#----------------------------------------------------------------
