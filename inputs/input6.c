/* This is the "simple" version of the test
   program */
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


 h3 := 10.0;
 i := 0;
 i7 := 2;
 if (i < 10) then{
     j := i*10;
     i := i+1;
 } else{
     i := j+i;
     i := j+i;
     i := j+i;
     i := j+i;
     i := j+i;
     i := j+i;
 }

 h := j/i;
 h2 := h / 10.0;
 h := 100*h;
