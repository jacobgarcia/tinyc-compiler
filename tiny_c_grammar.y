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
    union num_type val;
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
%token <symp> ID
%token <ival> INT_NUM
%token <fval> FLOAT_NUM
%token DO

// Types of syntax rules
%type <val> type;
%type <val> simple_exp;
%type <val> exp;
%type <val> term;
%type <val> factor;
%type <symp> variable;

%%
program:				    var_dec stmt_seq {printf("Compilación exitosa\n");}
							;

var_dec:					var_dec single_dec  |
							;

single_dec: 				type ID SEMI {
                                $2->type = $1.i;
                            };

type:						INTEGER {
                                $$.i = INT;
                            }|
                            FLOAT {
                                $$.i = FLO;
                            };

stmt_seq:					stmt_seq stmt  |
							;

stmt:						IF exp THEN stmt  | IF exp THEN stmt ELSE stmt
                    		| WHILE exp DO stmt  |
                            variable ASSIGN exp SEMI {
                                if ($1->type == -1){
                                    printf("ERROR, VARIABLE %s NOT DECLARED \n",$1->name);
                                    exit(1);
                                }
                            }
                    		| READ LPAREN variable RPAREN SEMI
                    		| WRITE LPAREN exp RPAREN SEMI
                    		| block
                    		;

block:						LBRACE stmt_seq RBRACE
							;

exp:						simple_exp LT simple_exp {
                                if($1.i < $3.i) {
                                    $$.i = 1;
                                }
                                else {
                                    $$.i = 0;
                                }
                            }|
                            simple_exp EQ simple_exp  {
                                if($1.i == $3.i) {
                                    $$.i = 1;
                                }
                                else {
                                    $$.i = 0;
                                }
                            }|
                            simple_exp {
                                $$ = $1;
                            };

simple_exp:					simple_exp PLUS term {
                                $$.i = $1.i + $3.i;
                            }
                            |
                            simple_exp MINUS term {
                                $$.i = $1.i - $3.i;
                            }|
                            term {
                                $$ = $1;
                            };

term:						term TIMES factor {
                                $$.i = $1.i * $3.i;
                            }|
                            term DIV factor {
                                $$.i = $1.i / $3.i;
                            }|
                            factor {
                                $$ = $1;
                            };

factor:						LPAREN exp RPAREN {
                                $$ = $2;
                            }|
                            INT_NUM {
                                $$.i = $1;
                            }|
                            FLOAT_NUM {
                                $$.f = $1;
                            }|
                            variable {
                                $$.f = $1->value;
                            };

variable:					ID {
                                $$ = $1;
                            };

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
        new_entry->type = -1;
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
    printf("%s -> %s -> %f\n",item->name, printType(item->type), 0.0);
}

char* printType(int type){
    switch(type)
    {
        case 0: return "int";
        case 1: return "float";
    }
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
