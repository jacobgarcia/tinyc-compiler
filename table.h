#include <glib.h>
#include <stdio.h>
#include <stdlib.h>
enum type_
{
    INT, FLO
};

struct symtab {
  char *name;                    /* The name is just the string */
  float value;                           /* The value is a float */
  int type;                           /* The value is a float */
} symtab_entry_;

union num_type{
    int i;
    float f;
};

typedef char * string;
typedef struct symtab *symtab_entry_p;

GHashTable *table;

void equal_hash(gconstpointer a, gconstpointer b);

/* Function prototype for the symbol table look up routine */
symtab_entry_p symlook(string);
char* printType(int type);
