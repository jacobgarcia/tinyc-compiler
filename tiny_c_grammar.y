%{
    #include <stdio.h>
	#include "table.h"
    /* Function definitions */
	void yyerror (char *string);
	extern int yylineno;
%}

 /* Define the elements of the attribute stack */
%union {
    float dval;
    struct symtab *symp;
}

 /* NAME is used for identifier tokens */
 /* NUMBER is used or real numbers */
%token <symp> NAME
%token <dval> NUMBER
 /* NAME is used for identifier tokens */
 /* NUMBER is used or real numbers */

%token INTEGER
%token FLOAT
%token IF
%token THEN
%token ELSE
%token WHILE
%token READ
%token WRITE
%token SEMI
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE
%token LT
%token RT
%token ASSIGN
%token EQ
%token PLUS
%token MINUS
%token TIMES
%token DIV
%token ID
%token INT_NUM
%token FLOAT_NUM
%token DO

%%
program:				    var_dec stmt_seq {printf("Compilación exitosa\n");}
							;

var_dec:					var_dec single_dec  | 
							;

single_dec: 				type ID SEMI
							;

type:						INTEGER | FLOAT
							;

stmt_seq:					stmt_seq stmt  | 
							;

stmt:						IF exp THEN stmt  | IF exp THEN stmt ELSE stmt
                    		| WHILE exp DO stmt  | variable ASSIGN exp SEMI
                    		| READ LPAREN variable RPAREN SEMI
                    		| WRITE LPAREN exp RPAREN SEMI
                    		| block
                    		;

block:						LBRACE stmt_seq RBRACE
							;

exp:						simple_exp LT simple_exp | simple_exp EQ simple_exp  | simple_exp
							;

simple_exp:					simple_exp PLUS term | simple_exp MINUS term | term
							;

term:						term TIMES factor  | term DIV factor  | factor
							;

factor:						LPAREN exp RPAREN | INT_NUM  | FLOAT_NUM  | variable
							;

variable:					ID
							;

%%

/* This is where the flex is included */
#include "lex.yy.c"

/* Bison does NOT implement yyerror, so define it here */
void yyerror (char *string){
    //Printing line where conflict was found. Subtracted to fix variable 
    printf ("Error  in line %d\n",yylineno-1);
}

/* This function looks for a name in the symbol table, if it is */
/* not there it store it in the next available space.           */
symtab_entry_p symlook(string s) {
    string p;
    symtab_entry_p res = g_hash_table_lookup(table, s);
    if (res == NULL){
        symtab_entry_p new_entry = malloc(sizeof(symtab_entry_));
        new_entry->name = strdup(s);
        if (g_hash_table_insert(table, new_entry->name, new_entry))
            return new_entry;
        else{
            printf("Error inserting at hash table");
            exit(1);    /* cannot continue */
        }
    }
    else {
        return res;
    }
} 
void printItem(gpointer key, gpointer value, gpointer user_data){
    symtab_entry_p item = (symtab_entry_p) value;
    printf("Identifier -> %s\n",item->name);
}

void printTable(){
    printf("**************************\n");
	printf("****** Symbol Table ******\n");
    printf("**************************\n\n");

    g_hash_table_foreach(table, (GHFunc)printItem, NULL);

}

/* Bison does NOT define the main entry point so define it here */
main (){
    table = g_hash_table_new(g_str_hash, g_str_equal);
    yyparse();
    printTable();
}