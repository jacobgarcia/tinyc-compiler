/*	Project:	Syntatic Analizer
*	Purpose: 	Analyze declarations in a tinyC program
*	Authors: 	Jacob Rivera
*				Oscar Sánchez
*                Mario García
*	Date:		March 23, 2015
*/
#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum type_
{
    INT, FLO
};

union num_type{
    int i;
    float f;
};

enum operator_{
    ADD,
    SUBSTRACT,
    MULT,
    DIVIDE,
    LT_GOTO,
    RT_GOTO,
    GOTO,
    EQ_GOTO,
    ASSIGNING
};

struct symtab {
  char *name;                    /* The name is just the string */
  union num_type value;                          /* The value is a float */
  int type;                           /* The value is a float */
} symtab_entry_;
typedef char * string;
typedef struct symtab *symtab_entry_p;

struct conditional {
    GList *trueList;
    GList *falseList;
} conditional_;
typedef struct conditional *conditional_p;


struct quad{
	symtab_entry_p source1, source2, destination;
	unsigned int address;
	unsigned int op;
    unsigned int next;
} quad_;
typedef struct quad *quad_p;

struct conditionalPrime{
    GList *list;
    int m;
}conditionalPrime_;
typedef struct conditionalPrime * conditionalPrime_p;

GHashTable *table;
GArray *quadList = NULL;
int quadCounter = 1;
int tempCounter = 0;
char integerString[10];

void equal_hash(gconstpointer a, gconstpointer b);

/* Function prototype for the symbol table look up routine */
quad_p genGoTo(unsigned int address);
quad_p gen(symtab_entry_p source1, symtab_entry_p source2, int op, symtab_entry_p destination);
quad_p initGotoQuad(int address);
void backPatch(GList *list, unsigned int address);
symtab_entry_p symbAdd(string s);
symtab_entry_p symlook(string s);
string printType(int type);
void printSymbolTable();
void printQuadList();
void printList(GList *list, char *listName);
string translateOp(int op);
