/* Test #3*/
/* This is the "simple" version of the test program */
/* Definitions go first */

int j;
float i;
int h;
int h2;
float h3;
float j7;
int i7;
int h7;

/* There is no "main" program, just blocks */
{
h3 := 10.0;
i := 0;

while (i < 10) do {
   j := i*10;
   i := i+1;
}

h := j/i;
h2 := h / h3;
h := 100*h;

}