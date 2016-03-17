#include <glib.h>
#define NSYMS 50	   /* Assume a maximum number of 50 symbols */

void equal_hash(gconstpointer a, gconstpointer b);

struct symtab {
  char *name;                    /* The name is just the string */
  float value;                          /* The value is a float */
} symtab[NSYMS];

typedef char * string;

/* Function prototype for the symbol table look up routine */
struct symtab *symlook(string);
