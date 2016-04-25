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


struct symtab {
  char *name;                    /* The name is just the string */
  union num_type value;                          /* The value is a float */
  int type;                           /* The value is a float */
} symtab_entry_;

typedef char * string;
typedef struct symtab *symtab_entry_p;


struct quad{
	symtab_entry_p source1, source2, destination;
	int address;
	string op;
} quad_;

typedef struct quad *quad_p;

GHashTable *table;
GList *quadList = NULL;
int quadCounter = 0;
int tempCounter = 0;
char integerString[4];

void equal_hash(gconstpointer a, gconstpointer b);

/* Function prototype for the symbol table look up routine */
void gen(symtab_entry_p source1, symtab_entry_p source2, string op, symtab_entry_p destination);
symtab_entry_p symbAdd(string s);
symtab_entry_p symlook(string s);
string printType(int type);
void printTable();
