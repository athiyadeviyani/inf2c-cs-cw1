/***********************************************************************
* File       : <spell_checker.c>
*
* Author     : <Siavash Katebzadeh>
*
* Description: 
*
* Date       : 08/10/18
*
***********************************************************************/
// ==========================================================================
// Spell checker 
// ==========================================================================
// Marks misspelled words in a sentence according to a dictionary

// Inf2C-CS Coursework 1. Task B/C 
// PROVIDED file, to be used as a skeleton.

// Instructor: Boris Grot
// TA: Siavash Katebzadeh
// 08 Oct 2018

#include <stdio.h>

// maximum size of input file
#define MAX_INPUT_SIZE 2048
// maximum number of words in dictionary file
#define MAX_DICTIONARY_WORDS 10000
// maximum size of each word in the dictionary
#define MAX_WORD_SIZE 20

int read_char() { return getchar(); }
int read_int()
{
    int i;
    scanf("%i", &i);
    return i;
}
void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(int c)     { putchar(c); }   
void print_int(int i)      { printf("%i", i); }
void print_string(char* s) { printf("%s", s); }
void output(char *string)  { print_string(string); }

// dictionary file name
char dictionary_file_name[] = "dictionary.txt";
// input file name
char input_file_name[] = "input.txt";
// content of input file
char content[MAX_INPUT_SIZE + 1];
// valid punctuation marks
char punctuations[] = ",.!?";
// tokens of input file
char tokens[MAX_INPUT_SIZE + 1][MAX_INPUT_SIZE + 1];
// number of tokens in input file
int tokens_number = 0;
// content of dictionary file
char dictionary[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE + 1];

///////////////////////////////////////////////////////////////////////////////
/////////////// Do not modify anything above
///////////////////////////////////////////////////////////////////////////////

// You can define your global variables here!
//char dict_array[MAX_DICTIONARY_WORDS * MAX_WORD_SIZE][MAX_DICTIONARY_WORDS * MAX_WORD_SIZE];
//int dict_number = 0;
int d_words = 0;

char dict_array[MAX_DICTIONARY_WORDS + 1][MAX_WORD_SIZE + 1];

int indexes[MAX_INPUT_SIZE + 1];

// code

int isalpha(char c) {
  return (c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
}

int isword(char string[]) {
  int i;
  for (i = 0; 1; i++) {
    if (string[i] == '\0') {
      break;
    }
    if (((string[i] >= 'a' && string[i] <= 'z') || (string[i] >= 'A' && string[i] <= 'Z')) && (string[i] != ' ')) {
      continue;
    } else { 
        return 0; 
      }
  }
  return 1;
} 


int compare(char a[], char b[]) {
  int i;

  int empty = (a == NULL) || (b == NULL);

  if (empty) {
    return 0;
  }
  
  i = 0;
  
  while (((a[i]) != '\0') && ((b[i]) != '\0') && ( (((a[i]) == (b[i])) == 1) || (((a[i])+32) == (b[i]) == 1) ) ) {
    i++;
  }

  int finalresult = (((a[i]) == (b[i])) == 1) || (((a[i])+32) == (b[i]) == 1) ;
  return (finalresult);
}

void convert_dict() {
  char d;
  
  int i = 0;
  d = dictionary[i];

  do { 

    int dict_index = 0;

    if (d == '\0') {
      break;
    }

    if (isalpha(d)) {

      do {
        dict_array[d_words][dict_index] = d;
        dict_index += 1;
        i += 1;

        d = dictionary[i];
      } while (isalpha(d));
      dict_array[d_words][dict_index] = '\0';
      d_words += 1;
    } 
      if (d == '\n') {
        do {
          dict_array[d_words][dict_index] = '\0';
          dict_index += 1;
          i += 1;
          d = dictionary[i];
        } while (d == '\n');
      }
    } while(1);
  }

void spell_checker() {

// GLOBAL VARIABLE = int indexes[MAX_INPUT_SIZE + 1];
        int i;
        int j;

        for (i = 0; i < MAX_INPUT_SIZE + 1; i++) {

                int flag = 0;

                if (isword(tokens[i])) {
                        for (j = 0; j < MAX_DICTIONARY_WORDS + 1; j++) {
                                if (compare(tokens[i], dict_array[j]) == 1) {
                                        flag = 1;
                                        break;
                                }
                        }

                        if (flag == 0) {   
        indexes[i] = 1;
                        }
                }

        }

}

void output_tokens() {
  int i; 

  for (i = 0; i < MAX_INPUT_SIZE + 1; i++) {  
                if (indexes[i] != 0) {
                        printf("_%s_", tokens[i]);
                } else {
                        printf(tokens[i]);
                }
        }
  return;
}

// void print_dictionary() {
//   int i, j;
//   for (i = 0; i < MAX_DICTIONARY_WORDS; i++) {
//     for (j = 0; j < MAX_WORD_SIZE; j++) {
//       print_char(dict_array[i][j]);
//     }
//   }
// }

// void print_tokens() {
//   int i = 0; 
//   int j = 0;
//   int count = 0;
//   for (i = 0; i < tokens_number; i++) {
//     for (j = 0; j < tokens_number; j++) {
//       print_char(tokens[i][j]);
      
//     }
//     count++;
//     print_char('/');
//   }
//   print_int(count);
// }

//---------------------------------------------------------------------------
// Tokenizer function
// Split content into tokens
//---------------------------------------------------------------------------
void tokenizer() {
        char c;

        // index of content 
        int c_idx = 0;
        c = content[c_idx];
        do {

                // end of content
                if (c == '\0'){
                        break;
                }

                // if the token starts with an alphabetic character
                if (c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z') {

                        int token_c_idx = 0;
                        // copy till see any non-alphabetic character
                        do {
                                tokens[tokens_number][token_c_idx] = c;

                                token_c_idx += 1;
                                c_idx += 1;

                                c = content[c_idx];
                        } while (c >= 'A' && c <= 'Z' || c >= 'a' && c <= 'z');
                        tokens[tokens_number][token_c_idx] = '\0';
                        tokens_number += 1;

                        // if the token starts with one of punctuation marks
                }
                else if (c == ',' || c == '.' || c == '!' || c == '?') {

                        int token_c_idx = 0;
                        // copy till see any non-punctuation mark character
                        do {
                                tokens[tokens_number][token_c_idx] = c;

                                token_c_idx += 1;
                                c_idx += 1;

                                c = content[c_idx];
                        } while (c == ',' || c == '.' || c == '!' || c == '?');
                        tokens[tokens_number][token_c_idx] = '\0';
                        tokens_number += 1;

                        // if the token starts with space
                }
                else if (c == ' ') {

                        int token_c_idx = 0;
                        // copy till see any non-space character
                        do {
                                tokens[tokens_number][token_c_idx] = c;

                                token_c_idx += 1;
                                c_idx += 1;

                                c = content[c_idx];
                        } while (c == ' ');
                        tokens[tokens_number][token_c_idx] = '\0';
                        tokens_number += 1;
                }
        } while (1);
}
//---------------------------------------------------------------------------
// MAIN function
//---------------------------------------------------------------------------

int main(void)
{

        /////////////Reading dictionary and input files//////////////
        ///////////////Please DO NOT touch this part/////////////////
        int c_input;
        int idx = 0;

        // open input file 
        FILE *input_file = fopen(input_file_name, "r");
        // open dictionary file
        FILE *dictionary_file = fopen(dictionary_file_name, "r");

        // if opening the input file failed
        if (input_file == NULL){
                print_string("Error in opening input file.\n");
                return -1;
        }

        // if opening the dictionary file failed
        if (dictionary_file == NULL){
                print_string("Error in opening dictionary file.\n");
                return -1;
        }

        // reading the input file
        do {
                c_input = fgetc(input_file);
                // indicates the the of file
                if (feof(input_file)) {
                        content[idx] = '\0';
                        break;
                }

                content[idx] = c_input;

                if (c_input == '\n'){
                        content[idx] = '\0';
                }

                idx += 1;

        } while (1);

        // closing the input file
        fclose(input_file);

        idx = 0;

        // reading the dictionary file
        do {
                c_input = fgetc(dictionary_file);
                // indicates the end of file
                if (feof(dictionary_file)) {
                        dictionary[idx] = '\0';
                        break;
                }

                dictionary[idx] = c_input;
                idx += 1;
        } while (1);

        // closing the dictionary file
        fclose(dictionary_file);
        //////////////////////////End of reading////////////////////////
        ////////////////////////////////////////////////////////////////
        tokenizer();
        convert_dict();

        spell_checker();
  output_tokens();

        return 0;
}
