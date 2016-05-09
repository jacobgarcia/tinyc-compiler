bison -v tiny_c_grammar.y
flex tiny_c.l
gcc -O2 -o compiler -DYACC tiny_c_grammar.tab.c `pkg-config --cflags --libs glib-2.0` -lfl -g
