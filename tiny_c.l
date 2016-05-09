/*    Project:    Syntatic Analizer
*    Purpose:     Analyze declarations in a tinyC program
*    Authors:     Jacob Rivera
*                Oscar Sánchez
*               Mario García
*    Date:        Sepetember 10th, 2015
*/

%{
    #include <stdio.h>
%}


%%

[ \t]    ;                                     /* ignore white space */

[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]         {
                                                int i = 0;                         //Defining a counter
                                                while(yytext[i]!=0) {          //Until end of string
                                                    if(yytext[i] == '\n'){
                                                        yylineno++;                // Found New Line, incremet
                                                    }
                                                    i++;
                                                }
                                            }

"int"                                       {    /*Reserved Word*/
                                                ////printf("integer ");
                                                return INTEGER;
                                            }

"float"                                     {    /*Reserved Word*/
                                                ////printf("float ");
                                                return FLOAT;
                                            }

"do"                                        {    /*Reserved Word*/
                                                ////printf("do ");
                                                return DO;
                                            }


"if"                                        {    /*Reserved Word*/
                                                ////printf("if ");
                                                return IF;
                                            }

"then"                                      {    /*Reserved Word*/
                                                //printf("then ");
                                                return THEN;
                                            }

"else"                                      {    /*Reserved Word*/
                                                //printf("else ");
                                                return ELSE;
                                            }

"while"                                     {    /*Reserved Word*/
                                                //printf("while ");
                                                return WHILE;
                                            }

"read"                                      {    /*Reserved Word*/
                                                //printf("read ");
                                                return READ;
                                            }

"write"                                     {    /*Reserved Word*/
                                                //printf("write ");
                                                return WRITE;
                                            }


";"                                         {    /*Punctuation*/
                                                //printf("semi\n");
                                                return SEMI;
                                            }

"("                                         {    /*Punctuation*/
                                                //printf("LPAREN ");
                                                return LPAREN;
                                            }

")"                                         {    /*Punctuation*/
                                                //printf("RPAREN ");
                                                return RPAREN;
                                            }

"{"                                         {    /*Punctuation*/
                                                //printf("LBRACE \n");
                                                return LBRACE;
                                            }

"}"                                         {    /*Punctuation*/
                                                //printf("RBRACE \n");
                                                return RBRACE;
                                            }


"<"                                         {    /*Relational*/
                                                //printf("LT ");
                                                return LT;
                                            }

">"                                         {    /*Relational*/
                                                //printf("RT ");
                                                return RT;
                                            }

":="                                        {/*Assignment Operation*/
                                                //printf("Assign ");
                                                return ASSIGN;
                                            }

"=="                                        {    /*Relational*/
                                                //printf("EQ ");
                                                return EQ;
                                            }


"+"                                         {    /*Relational*/
                                                //printf("+ ");
                                                return PLUS;
                                            }

"-"                                         {    /*Relational*/
                                                //printf("- ");
                                                return MINUS;
                                            }

"*"                                         {    /*Relational*/
                                                //printf("* ");
                                                return TIMES;
                                            }

"/"                                         {    /*Relational*/
                                                //printf("/ ");
                                                return DIV;
                                            }


\n                                          {    /* New Line */
                                                yylineno++; /*Increasing variable value*/
                                            }


[0-9][0-9]*                                 {    /* integer numbers*/
                                                //printf("int_num ");
                                                yylval.ival = atoi(yytext);
                                                return INT_NUM;
                                            }

0(c|C)[0-7]                                 {    /*octal number*/
                                                //printf("int_num ");
                                                yylval.ival = atoi(yytext);
                                                return INT_NUM;
                                            }


0(x|X)[0-9A-Fa-f]                           {    /*Hexadecimal Number*/
                                                //printf("int_num ");
                                                yylval.ival = atoi(yytext);
                                                return INT_NUM;
                                            }

[+-]?[0-9]*"."[0-9]+([eE][-+]?[0-9]+)?      {    /*Float Number*/
                                                //printf("float_num ");
                                                yylval.fval = atof(yytext);
                                                return FLOAT_NUM;
                                            }


[A-Za-z][A-Za-z0-9]*                        {
                                                //printf("identifier ");
                                                //yylval.symp = symlook(yytext);
                                                yylval.str = yytext;
                                                return ID;
                                            }


.                                           {    /*Any other character different from the above ones*/
                                                printf("Found Lexical Error\n");
                                            }
