bison -v calc_grammar.y
flex calc.l
gcc -O2 -o calc_grammar -DYACC calc_grammar.tab.c `pkg-config --cflags --libs glib-2.0` -lfl
