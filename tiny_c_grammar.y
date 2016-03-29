/*	Project:	Syntatic Analizer
*	Purpose: 	Syntatic rules and program execution
*	Authors: 	Jacob Rivera
*				Oscar Sánchez
*                Mario García
*	Date:		March 29 , 2015
*/

%{
	#include "table.h"
    /* Function definitions */
	void yyerror (char *string);
	extern int yylineno;
%}

 /* Define the elements of the attribute stack */
%union {
    int ival;
    float fval;
    string str;
    entry_p val;
    struct symtab *symp;
}
// Tokens from tinyc_l
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
%token <str> ID
%token <ival> INT_NUM
%token <fval> FLOAT_NUM
%token DO

// Types of syntax rules
%type <ival> type;
%type <val> simple_exp;
%type <val> exp;
%type <val> term;
%type <val> factor;
%type <symp> variable;

%%
program:				    var_dec stmt_seq {printf("\n\nCompilation successful\n\n");}
							;

var_dec:					var_dec single_dec  |
							;

single_dec: 				type ID {
                                symtab_entry_p new = symbAdd($2);
                                new->type = $1;
                            } SEMI;

type:						INTEGER {
                                $$ = INT;
                            }|
                            FLOAT {
                                $$ = FLO;
                            };

stmt_seq:					stmt_seq stmt  |
							;

stmt:						IF exp THEN stmt  | IF exp THEN stmt ELSE stmt
                    		| WHILE exp DO stmt  |
                            variable ASSIGN exp SEMI {
                                if ($1->type == -1){
                                    printf("ERROR at line %d: variable %s not declared \n",yylineno,$1->name);
                                    exit(1);
                                }
                                else {
                                    if ($1->type == INT){
                                        if ($3->type == FLO){
                                            printf("Warning at line %d: assigning float to %s, precision will be lost\n", yylineno, $1->name);
                                            $1->value  = (int) $3->value.f;
                                        }
                                        else {
                                            $1->value  = $3->value.i;
                                        }
                                    }
                                    else{
                                        $1->value  = $3->value.f;
                                        if ($3->type == INT){
                                            printf("Warning at line %d: assigning integer to %s, conversion will be done\n", yylineno, $1->name);
                                            $1->value  = (float) $3->value.i;
                                        }
                                        else {
                                            $1->value  = $3->value.f;
                                        }
                                    }
                                    //printf("Asignando %s a %f\n",$1->name,$1->value);
                                }
                            }
                    		| READ LPAREN variable RPAREN SEMI
                    		| WRITE LPAREN exp RPAREN SEMI
                    		| block
                    		;

block:						LBRACE stmt_seq RBRACE
							;

exp:						simple_exp LT simple_exp {
                                if (($1->type == FLO  && $3->type == INT)){
                                    if($1->value.f < (float) $3->value.i) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    if((float) $1->value.i < $3->value.f) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    if($1->value.i < $3->value.i) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }
                                }
                                else {
                                    if($1->value.f < $3->value.f) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }
                                }
                            }|
                            simple_exp EQ simple_exp  {
                                if (($1->type == FLO  && $3->type == INT)){
                                    if($1->value.f == (float) $3->value.i) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    if((float) $1->value.i == $3->value.f) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    if($1->value.i == $3->value.i) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }
                                }
                                else {
                                    if($1->value.f == $3->value.f) {
                                        $$->value.i = 1;
                                    }
                                    else {
                                        $$->value.i = 0;
                                    }
                                }
                            }|
                            simple_exp {
                                $$ = $1;
                            };

simple_exp:					simple_exp PLUS term {
                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: adding integers and floats\n", yylineno);
                                    $$->value.f = $1->value.f + (float) $3->value.i;

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: adding integers and floats\n", yylineno);
                                    $$->value.f = $1->value.i + $3->value.f;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    $$->value.i = $1->value.i + $3->value.i;
                                }
                                else {
                                    $$->value.f = $1->value.f + $3->value.f;
                                }
                            }
                            |
                            simple_exp MINUS term {
                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: substracting integers and floats\n", yylineno);
                                    $$->value.f = $1->value.f - $3->value.i;

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: substracting integers and floats\n", yylineno);
                                    $$->value.f = $1->value.i - $3->value.f;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    $$->value.i = $1->value.i - $3->value.i;
                                }
                                else {
                                    $$->value.f = $1->value.f - $3->value.f;
                                }
                            }|
                            term {
                                $$ = $1;
                            };

term:						term TIMES factor {
                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: multiplying integers and floats\n", yylineno);
                                    $$->value.f = $1->value.f * $3->value.i;

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: multiplying integers and floats\n", yylineno);
                                    $$->value.f = $1->value.i * $3->value.f;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    $$->value.i = $1->value.i * $3->value.i;
                                }
                                else {
                                    $$->value.f = $1->value.f * $3->value.f;
                                }
                            }|
                            term DIV factor {
                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: dividing integers and floats\n", yylineno);
                                    $$->value.f = $1->value.f / $3->value.i;

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: dividing integers and floats\n", yylineno);
                                    $$->value.f = $1->value.i / $3->value.f;
                                    $$->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    $$->value.i = $1->value.i / $3->value.i;
                                }
                                else {
                                    $$->value.f = $1->value.f / $3->value.f;
                                }
                            }|
                            factor {
                                $$ = $1;
                            };

factor:						LPAREN exp RPAREN {
                                $$ = $2;
                            }|
                            INT_NUM {
                                entry_p new_val = malloc(sizeof(entry_));
                                new_val->type = INT;
                                new_val->value.i = $1;
                                $$ = new_val;
                            }|
                            FLOAT_NUM {
                                entry_p new_val = malloc(sizeof(entry_));
                                new_val->type = FLO;
                                new_val->value.f = $1;
                                $$ = new_val;
                            }|
                            variable {
                                entry_p new_val = malloc(sizeof(entry_));
                                new_val->type = $1->type;
                                if ($1->type == FLO)
                                    new_val->value.f = $1->value;
                                else
                                    new_val->value.i = $1->value;
                                $$ = new_val;
                            };

variable:					ID {
                                $$ = symlook($1);
                            };

%%

/* This is where the flex is included */
#include "lex.yy.c"

/* Bison does NOT implement yyerror, so define it here */
void yyerror (char *string){
    //Printing line where conflict was found. Subtracted to fix variable
    printf ("ERROR: unknown character at line %d\n",yylineno);
    exit(1);
}

symtab_entry_p symbAdd(string s){
    symtab_entry_p new_entry = malloc(sizeof(symtab_entry_));
    new_entry->name = strdup(s);
    new_entry->value = 1;
    if (g_hash_table_insert(table, new_entry->name, new_entry))
        return new_entry;
    else{
        printf("ERROR: at inserting to hash table");
        exit(1);    /* cannot continue */
    }
}

symtab_entry_p symlook(string s) {
    string p;
    symtab_entry_p res = g_hash_table_lookup(table, s);
    if (res == NULL){
        symtab_entry_p new_entry = malloc(sizeof(symtab_entry_));
        new_entry->name = strdup(s);
        new_entry->type = -1;
        return new_entry;
    }
    else {
        return res;
    }
}

void printItem(gpointer key, gpointer value, gpointer user_data){
    symtab_entry_p item = (symtab_entry_p) value;
    //printf("%s -> %s -> %f\n",item->name, printType(item->type), item->value);
    printf("%5s  %10s\n",item->name, printType(item->type));
}

string printType(int type){
    switch(type)
    {
        case 0: return "int";
        case 1: return "float";
    }
}

void printTable(){
    printf("\n**************************\n");
	printf("****** Symbol Table ******\n");
    printf("**************************\n");

    g_hash_table_foreach(table, (GHFunc)printItem, NULL);
}

main (){
    table = g_hash_table_new(g_str_hash, g_str_equal);
    yyparse();
    printTable();
}
