%{
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>

int tokenNumber = 0, lineNumber = 1;
int nestedCommentCount = 0, numberOfCommentLines = 0;
bool nestedMultilineComment = 0;
int commentFlag = 0;
FILE *fq;
%}

digit			[0-9]
letter			[a-zA-Z_]

singlelineComment       (\/\/.*)
multilineCommentStart   (\/\*)
multilineCommentEnd     (\*\/)

%x DETECT_COMMENT

%%

{singlelineComment}     { lineNumber++; fprintf(fq, "%s", yytext); }

{multilineCommentStart}     {   
                                fprintf(fq, "%s", yytext);
                                BEGIN(DETECT_COMMENT);
					            nestedCommentCount++; 
					        }
					
<DETECT_COMMENT>{multilineCommentStart}     {   
                                                fprintf(fq, "%s", yytext);
                                                nestedCommentCount++;
                                                if(nestedCommentCount>1)
                                                    commentFlag = 1;
                                            }
					
<DETECT_COMMENT>{multilineCommentEnd} 	{   
                                            fprintf(fq, "%s", yytext);
                                            BEGIN(INITIAL); 
                                            lineNumber++;
                                            if(nestedCommentCount>0)
                                                nestedCommentCount--;
                                            if(nestedCommentCount==0)
                                                BEGIN(INITIAL);
                                        }
                    			
<DETECT_COMMENT>\n 		{ lineNumber++; fprintf(fq, "\n"); }

<DETECT_COMMENT>. 		{ fprintf(fq, "%s", yytext); }


"auto"			{  fprintf(fq, "AUTO "); }
"char"			{  fprintf(fq, "CHAR "); }
"int"			{  fprintf(fq, "INT "); }
"double"		{  fprintf(fq, "DOUBLE "); }
"short"			{  fprintf(fq, "SHORT "); }
"long"			{  fprintf(fq, "LONG "); }
"signed"		{  fprintf(fq, "SIGNED "); }
"unsigned"		{  fprintf(fq, "UNSIGNED "); }
"break"			{  fprintf(fq, "BREAK "); }
"continue"		{  fprintf(fq, "CONTINUE "); }
"void"			{  fprintf(fq, "VOID "); }
"const"			{  fprintf(fq, "CONST "); }
"if"			{  fprintf(fq, "IF "); }
"else"			{  fprintf(fq, "ELSE "); }
"for"			{  fprintf(fq, "FOR "); }
"while"			{  fprintf(fq, "WHILE "); }
"return"		{  fprintf(fq, "RETURN "); }

"#include"(.)*"\n"	{ lineNumber++; }
"#define"(.)*"\n"	{ lineNumber++; }

[\t ]		    { fprintf(fq, "%s", yytext); }
[\n]			{ lineNumber++; fprintf(fq, "\n"); }

[-+]?({digit}*[.])?{digit}+([eE][-+]?{digit}+)?     {  fprintf(fq, "CONSTANT "); }
{letter}({letter}|{digit})*		                    {  fprintf(fq, "IDENTIFIER "); }
\"(\\.|[^\\"])*\"		                            {  fprintf(fq, "STRING_LITERAL "); }
'(\\.|[^\\'])+'		                                {  fprintf(fq, "CONSTANT "); }

">>="			{  fprintf(fq, "RIGHT_ASSIGN "); }
"<<="			{  fprintf(fq, "LEFT_ASSIGN "); }
"+="			{  fprintf(fq, "ADD_ASSIGN "); }
"-="			{  fprintf(fq, "SUB_ASSIGN "); }
"*="			{  fprintf(fq, "MUL_ASSIGN "); }
"/="			{  fprintf(fq, "DIV_ASSIGN "); }
"%="			{  fprintf(fq, "MOD_ASSIGN "); }
"&="			{  fprintf(fq, "AND_ASSIGN "); }
"^="			{  fprintf(fq, "XOR_ASSIGN "); }
"|="			{  fprintf(fq, "OR_ASSIGN "); }
">>"			{  fprintf(fq, "RIGHT_OP "); }
"<<"			{  fprintf(fq, "LEFT_OP "); }
"++"			{  fprintf(fq, "INC_OP "); }
"--"			{  fprintf(fq, "DEC_OP "); }
"&&"			{  fprintf(fq, "AND_OP "); }
"||"			{  fprintf(fq, "OR_OP "); }
"^"			    {  fprintf(fq, "XOR_OP "); }
"<="			{  fprintf(fq, "LE_OP "); }
">="			{  fprintf(fq, "GE_OP "); }
"=="			{  fprintf(fq, "EQ_OP "); }
"!="			{  fprintf(fq, "NE_OP "); }
";"			    {  fprintf(fq, "';' ");  }
"{"		        {  fprintf(fq, "'{' ");  }
"}"		        {  fprintf(fq, "'}' ");  }
","			    {  fprintf(fq, "',' ");  }
":"			    {  fprintf(fq, "':' ");  }
"="			    {  fprintf(fq, "'=' ");  }
"("			    {  fprintf(fq, "'(' ");  }
")"			    {  fprintf(fq, "')' ");  }
"["		        {  fprintf(fq, "'[' ");  }
"]"		        {  fprintf(fq, "']' ");  }
"."			    {  fprintf(fq, "'.' ");  }
"&"			    {  fprintf(fq, "'&' ");  }
"!"			    {  fprintf(fq, "'!' ");  }
"-"			    {  fprintf(fq, "'-' ");  }
"+"			    {  fprintf(fq, "'+' ");  }
"*"			    {  fprintf(fq, "'*' ");  }
"/"			    {  fprintf(fq, "'/' ");  }
"%"			    {  fprintf(fq, "'%%' ");  }
"<"			    {  fprintf(fq, "'<' ");  }
">"			    {  fprintf(fq, "'>' ");  }
"|"			    {  fprintf(fq, "'|' ");  }
.			    {}

%%

int yywrap() {}

int main() {
    FILE *fp;

    char inputfile[50], outputfile[50];
    printf("Enter the inputfile: \n");
    scanf("%s",inputfile);
    printf("Enter the outputfile: \n");
    scanf("%s",outputfile);
    
    fp = fopen(inputfile,"r");
    yyin = fp;
    fq = fopen(outputfile,"w");
    yyout = fq;

    yylex();

    printf("\nNumber of Lines: %d", lineNumber);

    return 0;
}
