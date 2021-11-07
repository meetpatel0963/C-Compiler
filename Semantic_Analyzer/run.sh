bison -d compiler.y
flex compiler.l
gcc compiler.tab.c lex.yy.c
./a.exe input.c
rm compiler.tab.c compiler.tab.h lex.yy.c

