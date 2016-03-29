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
  float value;                           /* The value is a float */
  int type;                           /* The value is a float */
} symtab_entry_;

struct entry {
    int type;
    union num_type value;
} entry_;



typedef char * string;
typedef struct symtab *symtab_entry_p;
typedef struct entry *entry_p;

GHashTable *table;

void equal_hash(gconstpointer a, gconstpointer b);

/* Function prototype for the symbol table look up routine */
symtab_entry_p symbAdd(string s);
symtab_entry_p symlook(string s);
string printType(int type);
void printTable();
