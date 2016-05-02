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
    struct conditional *cond;
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
%type <symp> term;
%type <symp> factor;
%type <symp> variable;
%type <ival> m;
%type <cond> exp;
%type <cond> n;
%type <cond> stmt;

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

stmt_seq:					stmt_seq stmt {

                            }|
							;

stmt:						IF exp THEN m stmt{
                                backPatch($2->trueList, $4);
                                $$->trueList = g_list_concat($2->falseList, $5->trueList);
                            }|
                            IF exp THEN m stmt n ELSE m stmt{
                                backPatch($2->trueList, $4);
                                backPatch($2->falseList, $8);
                                GList *temp = g_list_concat($6->trueList, $9->trueList);
                                $$->trueList = g_list_concat($5->trueList, temp);
                            }|
                            WHILE m exp DO m stmt{
                                printf("Call to backpatch with address:%d\n", $5);
                                printList($3->trueList, "TrueList");
                                backPatch($3->trueList, $5);
                                $$->trueList = $3->falseList;
                                genGoTo($2);
                            }|
                            variable ASSIGN simple_exp SEMI {
                                if ($1->type == -1){
                                    printf("ERROR at line %d: variable %s not declared \n",yylineno,$1->name);
                                    exit(1);
                                }
                                else {
                                    gen($3, NULL, ":=", $1);
                                    if ($1->type == INT){
                                        if ($3->type == FLO){
                                            //printf("Warning at line %d: assigning float to %s, precision will be lost\n", yylineno, $1->name);
                                            $1->value  = $3->value;
                                        }
                                        else {
                                            $1->value  = $3->value;
                                        }
                                    }
                                    else{
                                        $1->value  = $3->value;
                                        if ($3->type == INT){
                                            //printf("Warning at line %d: assigning integer to %s, conversion will be done\n", yylineno, $1->name);
                                            $1->value  = $3->value;
                                        }
                                        else {
                                            $1->value  = $3->value;
                                        }
                                    }
                                    //printf("Asignando %s a %f\n",$1->name,$1->value);
                                }
                            }|
                            READ LPAREN variable RPAREN SEMI{

                            }|
                            WRITE LPAREN exp RPAREN SEMI{

                            }|
                            block{

                            }
                    		;

block:						LBRACE stmt_seq RBRACE{

                            }
							;

exp:
                            simple_exp RT simple_exp {
                                conditional_p cond = malloc(sizeof(conditional_));
                                quad_p temp = initGotoQuad(quadCounter);
                                cond->trueList = g_list_append(cond->trueList, temp);
                                temp = initGotoQuad(quadCounter+1);
                                cond->falseList = g_list_append(cond->falseList, temp);
                                gen($1, $3, "> goto", NULL);
                                genGoTo(0);
                                $$ = cond;
                            }|
                            simple_exp LT simple_exp {
                                conditional_p cond = malloc(sizeof(conditional_));
                                quad_p temp = gen($1, $3, "< goto", NULL);
                                cond->trueList = g_list_append(cond->trueList, temp);
                                temp = genGoTo(0);
                                cond->falseList = g_list_append(cond->falseList, temp);
                                $$ = cond;
                            }|
                            simple_exp EQ simple_exp  {
                                conditional_p cond = malloc(sizeof(conditional_));
                                quad_p temp = initGotoQuad(quadCounter);
                                cond->trueList = g_list_append(cond->trueList, temp);
                                temp = initGotoQuad(quadCounter+1);
                                cond->falseList = g_list_append(cond->falseList, temp);
                                gen($1, $3, "== goto", NULL);
                                genGoTo(0);
                                $$ = cond;
                            }|LPAREN exp RPAREN {
                                $$ = $2;
                            };


simple_exp:					simple_exp PLUS term {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                temp->type = FLO;
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);

                                if (($1->type == FLO  && $3->type == INT)){
                                    //printf("Warning at line %d: adding integers and floats\n", yylineno);

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    //printf("Warning at line %d: adding integers and floats\n", yylineno);

                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {
                                    //
                                }
                                gen($1,$3,"+",temp);
                                $$ = temp;
                            }
                            |
                            simple_exp MINUS term {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                temp->type = FLO;
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                if (($1->type == FLO  && $3->type == INT)){
                                    //printf("Warning at line %d: substracting integers and floats\n", yylineno);

                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    //printf("Warning at line %d: substracting integers and floats\n", yylineno);

                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {

                                }
                                gen($1,$3,"-",temp);
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
                                    //printf("Warning at line %d: multiplying integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    //printf("Warning at line %d: multiplying integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {
                                    temp->type = FLO;
                                }
                                gen($1,$3,"*",temp);
                                $$ = temp;
                            }|
                            term DIV factor {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                if (($1->type == FLO  && $3->type == INT)){
                                    //printf("Warning at line %d: dividing integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == FLO){
                                    //printf("Warning at line %d: dividing integers and floats\n", yylineno);
                                    temp->type = FLO;
                                }
                                else if ($1->type == INT  && $3->type == INT){
                                    temp->type = INT;
                                }
                                else {
                                    temp->type = FLO;
                                }
                                gen($1,$3,"/",temp);
                                $$ = temp;
                            }|
                            factor {
                                $$ = $1;
                            };

factor:					    INT_NUM {
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

m:                          {
                                $$ = quadCounter + 1;
                            };

n:                          {
                                quad_p temp = initGotoQuad(0);
                                $$->trueList = g_list_append($$->trueList, temp);
                                genGoTo(0);
                            };

%%

/* This is where the flex is included */
#include "lex.yy.c"

void printListItem(gpointer data, gpointer userData){
    quad_p item = (quad_p)data;
    if(item->source1 == NULL){
        printf("%2d %9s %12s %11s %13s %12d\n",item->address, item->op, " ",
                " ", " ", item->next);
    }
    else if(item->source2 != NULL){
        if(item->destination == NULL){
            printf("%2d %9s %12s %11s %13s\n",item->address, item->op,
            item->source1->name, item->source2->name, " ");
        }else{
            printf("%2d %9s %12s %11s %13s\n",item->address, item->op,
            item->source1->name, item->source2->name, item->destination->name);
        }
    }else{
        printf("%2d %9s %12s %11s %13s\n",item->address, item->op,
        item->source1->name, " ", item->destination->name);
    }
}

void printList(GList *list, char *listName){
    printf("Printing %s \n", listName);
    g_list_foreach(list, (GFunc)printListItem, NULL);
}

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

quad_p gen(symtab_entry_p source1, symtab_entry_p source2, string op, symtab_entry_p destination){
    quad_p newQuad = malloc(sizeof(quad_));
    newQuad->source1 = source1;
    if(source2 != NULL){
        newQuad->source2 = source2;
    }else{
    	newQuad->source2 = NULL;
    }

    newQuad->destination = destination;
    newQuad->op = op;

    if(destination == NULL){
        printf("Created Goto comparison at address: %d\n", quadCounter);
        newQuad->next = 0;
    }

    //Caution: may have errors
    newQuad->address = quadCounter++;

    quadList = g_array_append_val(quadList, newQuad);
    return newQuad;
}

quad_p genGoTo(unsigned int address){
    symtab_entry_p temp = malloc(sizeof(symtab_entry_));
    quad_p newQuad = initGotoQuad(address);

    //Caution: may have errors
    printf("Added GoTO in line %d with next: %d\n ", quadCounter-1, address);
    return newQuad;
}

void backPatchItem(gpointer data, gpointer user_data){
    int address = (int)user_data;
    quad_p quad = (quad_p)data;
    if((strcmp(quad->op, "goto")||strcmp(quad->op, "< goto")||strcmp(quad->op, "> goto") ||strcmp(quad->op, "== goto")) && (quad->next == 0)){
        printf("Quad number %d is changing next from %d to %d\n", quad->address, quad->next, address);
        quad->next = address;
    }
}

void backPatch(GList *list, unsigned int address){
    g_list_foreach(list, (GFunc) backPatchItem, (gpointer)address);
}

void printSymbolItem(gpointer key, gpointer value, gpointer user_data){
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

void printSymbolTable(){
    printf("\n**************************\n");
	printf("****** Symbol Table ******\n");
    printf("**************************\n");

    g_hash_table_foreach(table, (GHFunc)printSymbolItem, NULL);
}


void printQuadList(){
    printf("\n**************************\n");
    printf("****** Quads ******\n");
    printf("**************************\n");

    printf("Add  -  Operator  -  Source1  -  Source2  -  Destination  -  Next\n");
    printf("-------------------------------------------------------------------\n");
    int i=0;
    for(i; i < quadList->len; i++){
        quad_p item = g_array_index(quadList, quad_p, i);
        if(item->source1 == NULL){
            printf("%2d %9s %12s %11s %13s %12d\n",item->address, item->op, " ",
                    " ", " ", item->next);
        }
        else if(item->source2 != NULL){
            if(item->destination == NULL){
                printf("%2d %9s %12s %11s %13s\n",item->address, item->op,
                item->source1->name, item->source2->name, " ");
            }else{
                printf("%2d %9s %12s %11s %13s\n",item->address, item->op,
                item->source1->name, item->source2->name, item->destination->name);
            }
        }else{
        	printf("%2d %9s %12s %11s %13s\n",item->address, item->op,
            item->source1->name, " ", item->destination->name);
        }
    }

}

quad_p initGotoQuad(int address){
    quad_p temp = malloc(sizeof(quad_));

    temp->address = quadCounter++;
    temp->next = address;
    temp->source1 = NULL;
    temp->source2 = NULL;
    temp->destination = NULL;
    temp->op = "goto";

    quadList = g_array_append_val(quadList, temp);
    return temp;
}

main (){
    table = g_hash_table_new(g_str_hash, g_str_equal);
    quadList = g_array_new(FALSE, FALSE, sizeof(quad_p));
    yyparse();
    //printSymbolTable();
    printQuadList();
}
