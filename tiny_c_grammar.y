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
    symtab_entry_p symp;
    conditional_p cond;
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

stmt:						IF exp THEN m stmt n ELSE m stmt m{
                                backPatch($2->trueList, $4);
                                backPatch($2->falseList, $8);
                                GList *temp = NULL;
                                temp = g_list_concat($6->trueList, $9->trueList);
                                temp = g_list_concat($5->trueList, temp);
                                conditional_p list = malloc(sizeof(conditional_));
                                list->trueList = temp;
                                $$ = list;
                                backPatch($6->trueList, $10);
                            }|
                            WHILE m exp DO m stmt{
                                //printList($3->trueList, "TrueList");
                                backPatch($3->trueList, $5);
                                //printList($3->falseList, "falseList");
                                conditional_p list = malloc(sizeof(conditional_));
                                list->trueList = $3->falseList;
                                $$ = list;
                                quad_p temp = genGoTo($2);
                                backPatch($3->falseList, temp->address+1);
                            }|
                            variable ASSIGN simple_exp SEMI {
                                if ($1->type == -1){
                                    printf("ERROR at line %d: variable %s not declared \n",yylineno,$1->name);
                                    exit(1);
                                }
                                else {
                                    gen($3, NULL, ASSIGNING, $1);
                                    if ($1->type == INT){
                                        if ($3->type == FLO){
                                            printf("Warning at line %d: assigning float to %s, precision will be lost\n", yylineno, $1->name);
                                        }
                                    }
                                    else{

                                        if ($3->type == INT){
                                            printf("Warning at line %d: assigning integer to %s, conversion will be done\n", yylineno, $1->name);
                                        }
                                    }
                                }
                            }|
                            READ LPAREN variable RPAREN SEMI{

                            }|
                            WRITE LPAREN exp RPAREN SEMI{

                            }|
                            block{
                                conditional_p list = malloc(sizeof(conditional_));
                                list->trueList = NULL;
                                list->falseList = NULL;
                                $$ = list;
                            }
                    		;

block:						LBRACE stmt_seq RBRACE{

                            }
							;

exp:
                            simple_exp RT simple_exp {
                                conditional_p cond = malloc(sizeof(conditional_));
                                quad_p temp = gen($1, $3, RT_GOTO, NULL);
                                cond->trueList = g_list_append(cond->trueList, temp);
                                temp = genGoTo(0);
                                cond->falseList = g_list_append(cond->falseList, temp);
                                $$ = cond;
                            }|
                            simple_exp LT simple_exp {
                                conditional_p cond = malloc(sizeof(conditional_));
                                quad_p temp = gen($1, $3, LT_GOTO, NULL);
                                cond->trueList = g_list_append(cond->trueList, temp);
                                temp = genGoTo(0);
                                cond->falseList = g_list_append(cond->falseList, temp);
                                $$ = cond;
                            }|
                            simple_exp EQ simple_exp  {
                                conditional_p cond = malloc(sizeof(conditional_));
                                quad_p temp = gen($1, $3, EQ_GOTO, NULL);
                                cond->trueList = g_list_append(cond->trueList, temp);
                                temp = genGoTo(0);
                                cond->falseList = g_list_append(cond->falseList, temp);
                                $$ = cond;
                            }|LPAREN exp RPAREN {
                                $$ = $2;
                            };


simple_exp:					simple_exp PLUS term {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                temp->type = FLO;
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                checkTypeCompilation($1,$3,temp,"adding");
                                gen($1,$3,ADD,temp);
                                $$ = temp;
                            }
                            |
                            simple_exp MINUS term {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                temp->type = FLO;
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                checkTypeCompilation($1,$3,temp,"substracting");
                                gen($1,$3,SUBSTRACT,temp);
                                $$ = temp;
                            }|
                            term {
                                $$ = $1;
                            };

term:						term TIMES factor {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                checkTypeCompilation($1,$3,temp,"multiplying");
                                gen($1,$3,MULT,temp);
                                $$ = temp;
                            }|
                            term DIV factor {
                                symtab_entry_p temp = malloc(sizeof(symtab_entry_));
                                sprintf(integerString, "t%d", tempCounter++);
                                temp->name = strdup(integerString);
                                checkTypeCompilation($1,$3,temp,"dividing");
                                gen($1,$3,DIVIDE,temp);
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
                                //printf("Checking int value %d\n",$1);
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
                                $$ = quadCounter;
                            };

n:                          {
                                conditional_p cond = malloc(sizeof(conditional_));
                                quad_p temp = genGoTo(0);
                                GList *test = NULL;
                                test = g_list_append(test, temp);
                                cond->trueList = test;
                                $$ = cond;
                            };

%%

/* This is where the flex is included */
#include "lex.yy.c"

void checkTypeCompilation(symtab_entry_p s1, symtab_entry_p s2, symtab_entry_p d, string s){
    if ((s1->type == FLO  && s2->type == INT)){
        printf("Warning at line %d: %s integers and floats\n", yylineno, s);
        d->type = FLO;
    }
    else if (s1->type == INT  && s2->type == FLO){
        printf("Warning at line %d: %s integers and floats\n", yylineno, s);
        d->type = FLO;
    }
    else if (s1->type == INT  && s2->type == INT){
        d->type = INT;
    }
    else {
        d->type = FLO;
    }
}

string translateOp(int op){
    switch(op){
        case ADD:
            return "+";
        case SUBSTRACT:
            return "-";
        case MULT:
            return "*";
        case DIVIDE:
            return "/";
        case LT_GOTO:
            return "<";
        case RT_GOTO:
            return ">";
        case GOTO:
            return "goto";
        case EQ_GOTO:
            return "==";
        case ASSIGNING:
            return ":=";
    }
}

void printListItem(gpointer data, gpointer userData){
    quad_p item = (quad_p)data;
    if(item->source1 == NULL){
        printf("%2d %9s %12s %11s %13s %12d\n",item->address, translateOp(item->op), " ",
                " ", " ", item->next);
    }
    else if(item->source2 != NULL){
        if(item->destination == NULL){
            printf("%2d %9s %12s %11s %13s\n",item->address, translateOp(item->op),
            item->source1->name, item->source2->name, " ");
        }else{
            printf("%2d %9s %12s %11s %13s\n",item->address, translateOp(item->op),
            item->source1->name, item->source2->name, item->destination->name);
        }
    }else{
        printf("%2d %9s %12s %11s %13s\n",item->address, translateOp(item->op),
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
    printf ("The unknown string: %s ", string);
    exit(1);
}

symtab_entry_p symbAdd(string s){
    symtab_entry_p new_entry = malloc(sizeof(symtab_entry_));
    new_entry->name = strdup(s);
    new_entry->value.i = 0;
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

quad_p gen(symtab_entry_p source1, symtab_entry_p source2, int op, symtab_entry_p destination){
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
        //printf("Created Goto comparison at address: %d\n", quadCounter);
        newQuad->next = 0;
        //printf("Hexa Address: %p value: %d\n", &newQuad->next, newQuad->next);
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
    //printf("Added GoTO in line %d with next: %d\n", quadCounter, address);
    return newQuad;
}

void backPatchItem(gpointer data, gpointer user_data){
    int address = (int)user_data;
    quad_p quad = (quad_p)data;
    if((quad->op == GOTO||quad->op == LT_GOTO||quad->op == RT_GOTO ||quad->op == EQ_GOTO) && (quad->next == 0)){
        //printf("Quad number %d is changing next from %d to %d\n", quad->address, quad->next, address);
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
    printf("\n\n\n**************************\n");
    printf("****** Quads ******\n");
    printf("**************************\n");

    printf("Add  -  Operator  -  Source1  -  Source2  -  Destination  -  Next\n");
    printf("-------------------------------------------------------------------\n");
    int i=0;
    for(i; i < quadList->len; i++){
        quad_p item = g_array_index(quadList, quad_p, i);
        if(item->source1 == NULL){
            printf("%2d %9s %12s %11s %13s %12d\n",item->address, translateOp(item->op), " ",
                    " ", " ", item->next);
        }
        else if(item->source2 != NULL){
            if(item->destination == NULL){
                printf("%2d %9s %12s %11s %13s %12d\n",item->address, translateOp(item->op),
                item->source1->name, item->source2->name, " ", item->next);
            }else{
                printf("%2d %9s %12s %11s %13s\n",item->address, translateOp(item->op),
                item->source1->name, item->source2->name, item->destination->name);
            }
        }else{
        	printf("%2d %9s %12s %11s %13s\n",item->address, translateOp(item->op),
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
    temp->op = GOTO;

    quadList = g_array_append_val(quadList, temp);
    return temp;
}

void doOperation(quad_p quad){
    if(quad->source1->type == INT && quad->source2->type == INT){
        //printf("Source1: %d Source2: %d\n", quad->source1->value.i, quad->source2->value.i);
        switch(quad->op){
            case ADD:
                quad->destination->value.i = quad->source1->value.i + quad->source2->value.i;
                break;

            case SUBSTRACT:
                quad->destination->value.i = quad->source1->value.i - quad->source2->value.i;
                break;

            case MULT:
                quad->destination->value.i = quad->source1->value.i * quad->source2->value.i;
                break;

            case DIVIDE:
                quad->destination->value.i = quad->source1->value.i / quad->source2->value.i;
                break;
        }
        //printf("Source1: %d Source2: %d\n", quad->source1->value.i, quad->source2->value.i);
    }
    else if (quad->source1->type == FLO && quad->source2->type == INT){
        //printf("Source1: %f Source2: %d\n", quad->source1->value.f, quad->source2->value.i);
        switch(quad->op){
            case ADD:
                quad->destination->value.f = quad->source1->value.f + quad->source2->value.i;
                break;

            case SUBSTRACT:
                quad->destination->value.f = quad->source1->value.f - quad->source2->value.i;
                break;

            case MULT:
                quad->destination->value.f = quad->source1->value.f * quad->source2->value.i;
                break;

            case DIVIDE:
                quad->destination->value.f = quad->source1->value.f / quad->source2->value.i;
                break;
        }
        //printf("Source1: %f Source2: %d\n", quad->source1->value.f, quad->source2->value.i);
    }
    else if (quad->source1->type == INT && quad->source2->type == FLO){
        //printf("Source1: %d Source2: %f\n", quad->source1->value.i, quad->source2->value.f);
        switch(quad->op){
            case ADD:
                quad->destination->value.f = quad->source1->value.i + quad->source2->value.f;
                break;

            case SUBSTRACT:
                quad->destination->value.f = quad->source1->value.i - quad->source2->value.f;
                break;

            case MULT:
                quad->destination->value.f = quad->source1->value.i * quad->source2->value.f;
                break;

            case DIVIDE:
                quad->destination->value.f = quad->source1->value.i / quad->source2->value.f;
                break;
        }
        //printf("Source1: %d Source2: %f\n", quad->source1->value.i, quad->source2->value.f);
    }
    else if(quad->source1->type == FLO && quad->source2->type == FLO){
        //printf("Source1: %f Source2: %f\n", quad->source1->value.f, quad->source2->value.f);
        switch(quad->op){
            case ADD:
                quad->destination->value.f = quad->source1->value.f + quad->source2->value.f;
                break;

            case SUBSTRACT:
                quad->destination->value.f = quad->source1->value.f - quad->source2->value.f;
                break;

            case MULT:
                quad->destination->value.f = quad->source1->value.f * quad->source2->value.f;
                break;

            case DIVIDE:
                quad->destination->value.f = quad->source1->value.f / quad->source2->value.f;
                break;
        }
        //printf("Source1: %f Source2: %f\n", quad->source1->value.f, quad->source2->value.f);
    }

}

void doAssign(quad_p quad){
    if(quad->source1->type == INT && quad->destination->type == INT){
        //printf("Source1: %d Destination: %d\n", quad->source1->value.i, quad->destination->value.i);
        quad->destination->value.i = quad->source1->value.i;
    }
    else if (quad->source1->type == FLO && quad->destination->type == INT){
        //printf("Source1: %f Destination: %d\n", quad->source1->value.f, quad->destination->value.i);
        quad->destination->value.i = quad->source1->value.f;
    }
    else if (quad->source1->type == INT && quad->destination->type == FLO){
        //printf("Source1: %d Destination: %f\n", quad->source1->value.i, quad->destination->value.f);
        quad->destination->value.f = quad->source1->value.i;
    }
    else if(quad->source1->type == FLO && quad->destination->type == FLO){
        //printf("Source1: %f Destination: %f\n", quad->source1->value.f, quad->destination->value.f);
        quad->destination->value.f = quad->source1->value.f;
    }
}

void doComparison(quad_p quad, int *i){
    if(quad->source1->type == INT && quad->source2->type == INT){
        //printf("Comparing %d < %d \n", quad->source1->value.i , quad->source2->value.i);
        switch(quad->op){
            case LT_GOTO:
                if(quad->source1->value.i < quad->source2->value.i){
                    //printf("Goin' to: %d\n", quad->next);
                    *i = quad->next -1;
                }
                break;
            case RT_GOTO:
                if(quad->source1->value.i > quad->source2->value.i){
                    *i = quad->next - 1;
                }
                break;
            case EQ_GOTO:
                if(quad->source1->value.i == quad->source2->value.i){
                    *i = quad->next -1;
                }
                break;
        }
    }
    else if (quad->source1->type == FLO && quad->source2->type == INT){
        //printf("Comparing %f < %d \n", quad->source1->value.f , quad->source2->value.i);
        switch(quad->op){
            case LT_GOTO:
                if(quad->source1->value.f < quad->source2->value.i){
                    //printf("Goin' to: %d\n", quad->next);
                    *i = quad->next -1;
                }
                break;
            case RT_GOTO:
                if(quad->source1->value.f > quad->source2->value.i){
                    *i = quad->next - 1;
                }
                break;
            case EQ_GOTO:
                if(quad->source1->value.f == quad->source2->value.i){
                    *i = quad->next -1;
                }
                break;
        }
    }
    else if (quad->source1->type == INT && quad->source2->type == FLO){
        //printf("Comparing %d < %f \n", quad->source1->value.i , quad->source2->value.f);
        switch(quad->op){
            case LT_GOTO:
                if(quad->source1->value.i < quad->source2->value.f){
                    //printf("Goin' to: %d\n", quad->next);
                    *i = quad->next -1;
                }
                break;
            case RT_GOTO:
                if(quad->source1->value.i > quad->source2->value.f){
                    *i = quad->next - 1;
                }
                break;
            case EQ_GOTO:
                if(quad->source1->value.i == quad->source2->value.f){
                    *i = quad->next -1;
                }
                break;
        }
    }
    else if(quad->source1->type == FLO && quad->source2->type == FLO){
        //printf("Comparing %f < %f \n", quad->source1->value.f , quad->source2->value.f);
        switch(quad->op){
            case LT_GOTO:
                if(quad->source1->value.f < quad->source2->value.f){
                    //printf("Goin' to: %d\n", quad->next);
                    *i = quad->next -1;
                }
                break;
            case RT_GOTO:
                if(quad->source1->value.f > quad->source2->value.f){
                    *i = quad->next - 1;
                }
                break;
            case EQ_GOTO:
                if(quad->source1->value.f == quad->source2->value.f){
                    *i = quad->next -1;
                }
                break;
        }
    }
}

void interpreter(){
    int i=1;
    printf("\n\nExecuting... \n\n");
    for(i; i <= quadList->len; i++){
        quad_p quad = g_array_index(quadList, quad_p, i-1);
        printf("Doing %s at quad: %d\n", translateOp(quad->op), quad->address);
        if(quad->op == GOTO){
            //printf("Goin' to: %d\n", quad->next);
            i = quad->next - 1;
        }else if (quad->op == LT_GOTO || quad->op == RT_GOTO || quad->op == EQ_GOTO){
            doComparison(quad, &i);
        }else if (quad->op == ASSIGNING){
            doAssign(quad);
        }else{
            doOperation(quad);
        }
    }
    printf("\nFinished Execution...\n");
}

main (){
    table = g_hash_table_new(g_str_hash, g_str_equal);
    quadList = g_array_new(FALSE, FALSE, sizeof(quad_p));
    yyparse();
    printSymbolTable();
    printQuadList();
    interpreter();
}
