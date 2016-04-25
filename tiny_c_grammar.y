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
%type <symp> simple_exp;
%type <symp> exp;
%type <symp> term;
%type <symp> factor;
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
                                    gen($3, NULL, ":=", $1);
                                    printf("Called Gen (Assignment)\n");
                                    if ($1->type == INT){
                                        if ($3->type == FLO){
                                            printf("Warning at line %d: assigning float to %s, precision will be lost\n", yylineno, $1->name);
                                            $1->value  = $3->value;
                                        }
                                        else {
                                            $1->value  = $3->value;
                                        }
                                    }
                                    else{
                                        $1->value  = $3->value;
                                        if ($3->type == INT){
                                            printf("Warning at line %d: assigning integer to %s, conversion will be done\n", yylineno, $1->name);
                                            $1->value  = $3->value;
                                        }
                                        else {
                                            $1->value  = $3->value;
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
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                temp->type = FLO;
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);

                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: adding integers and floats\n", yylineno);

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: adding integers and floats\n", yylineno);

                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {
                                    //
                                }
                                gen($1,$3,"+",temp);
                                printf("Called Gen (Addition)\n");
                                $$ = temp;
                            }
                            |
                            simple_exp MINUS term {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                temp->type = FLO;
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: substracting integers and floats\n", yylineno);

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: substracting integers and floats\n", yylineno);
                                    
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {
                                    
                                }
                                gen($1,$3,"-",temp);
                                printf("Called Gen (Substraction)\n");
                                $$ = temp;
                            }|
                            term {
                                $$ = $1;
                            };

term:						term TIMES factor {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: multiplying integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: multiplying integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {
                                    temp->type = FLO;                                    
                                }
                                gen($1,$3,"*",temp);
                                printf("Called Gen (Mult)\n");
                                $$ = temp;
                            }|
                            term DIV factor {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                if (($1->type == FLO  && $3->type == INT)){
                                    printf("Warning at line %d: dividing integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    printf("Warning at line %d: dividing integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {
                                    temp->type = FLO;
                                }
                                gen($1,$3,"/",temp);
                                printf("Called Gen (Division)\n");
                                $$ = temp;
                            }|
                            factor {
                                $$ = $1;
                            };

factor:						LPAREN exp RPAREN {
                                $$ = $2;
                            }|
                            INT_NUM {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                temp->type = INT;
                                temp->value.i = $1;
                                $$ = temp;
                            }|
                            FLOAT_NUM {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                temp->type = FLO;
                                temp->value.f = $1;
                                $$ = temp;
                            }|
                            variable {
                                $$ = $1;
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
    new_entry->value.i = 1;
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

void gen(symtab_entry_p source1, symtab_entry_p source2, string op, symtab_entry_p destination){
    quad_p newQuad = malloc(sizeof(quad_));
    newQuad->source1 = source1;
    if(source2 != NULL){
        newQuad->source2 = source2;
    }else{
    	newQuad->source2 = NULL;
    }
    newQuad->destination = destination;    
    newQuad->op = op;

    //Caution: may have errors
    newQuad->address = quadCounter++;
    quadList = g_list_append(quadList, newQuad);
    printf("Added\n");
    
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

void printQuad(gpointer value, gpointer user_data){
    quad_p item = (quad_p) value;
    if(item->source2 != NULL){
    	printf("%2d %9s %12s %11s %13s\n",item->address, item->op, item->source1->name, item->source2->name, item->destination->name);
    }else{
    	printf("%2d %9s %12s %11s %13s\n",item->address, item->op, item->source1->name, " ", item->destination->name);
    }    
}

void printQuadList(){
    printf("\n**************************\n");
    printf("****** Quads ******\n");
    printf("**************************\n");

    printf("Add  -  Operator  -  Source1  -  Source2  -  Desatination\n");
    printf("----------------------------------------------------------\n");
    g_list_foreach(quadList, (GFunc)printQuad, NULL);

}

main (){
    table = g_hash_table_new(g_str_hash, g_str_equal);
    yyparse();
    printTable();
    printf("Tamanio lista quads: %d", g_list_length(quadList));
    printQuadList();
}
