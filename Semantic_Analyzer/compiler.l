%{
#include <stdio.h>
#include <string.h>
#include "compiler.tab.h"

int lineCount=1;
int nestedCommentCount=0;
int commentFlag=0;
int scopeCount=0;
char *tokenTablePtr;

void addToken(char*);
%}

digit			[0-9]
letter			[a-zA-Z_]
E			    [Ee][+-]?{digit}+

singlelineComment       (\/\/.*)
multilineCommentStart   (\/\*)
multilineCommentEnd     (\*\/)

%x DETECT_COMMENT

%%

{singlelineComment}     {}

{multilineCommentStart}     {   
                                BEGIN(DETECT_COMMENT);
					            nestedCommentCount++; 
					        }
					
<DETECT_COMMENT>{multilineCommentStart}     {   
                                                nestedCommentCount++;
                                                if(nestedCommentCount>1)
                                                    commentFlag = 1;
                                            }
					
<DETECT_COMMENT>{multilineCommentEnd} 	{   
                                            BEGIN(INITIAL); 
                                            lineCount++;
                                            if(nestedCommentCount>0)
                                                nestedCommentCount--;
                                            if(nestedCommentCount==0)
                                                BEGIN(INITIAL);
                                        }
                    			
<DETECT_COMMENT>\n 		{lineCount++;}

<DETECT_COMMENT>. 		{}


"char"			{  return(CHAR); }
"int"			{  return(INT); }
"float"			{  return(FLOAT); }
"double"		{  return(DOUBLE); }
"short"			{  return(SHORT); }
"long"			{  return(LONG); }
"signed"		{  return(SIGNED); }
"unsigned"		{  return(UNSIGNED); }
"break"			{  return(BREAK); }
"continue"		{  return(CONTINUE); }
"void"			{  return(VOID); }
"const"			{  return(CONST); }
"if"			{  return(IF); }
"else"			{  return(ELSE); }
"for"			{  return(FOR); }
"do"			{  return(DO); }
"while"			{  return(WHILE); }
"return"		{  return(RETURN); }

'(\\.|[^\\'])+'		                {  addToken(yytext); return(CHCONSTANT); }
{digit}+({E})?     			        {  addToken(yytext); return(INTCONSTANT); }
{digit}*"."{digit}+({E})?	    	{  addToken(yytext); return(FLCONSTANT); }
{digit}+"."{digit}*({E})?		    {  addToken(yytext); return(FLCONSTANT); }

{letter}({letter}|{digit})*		    {  addToken(yytext); return(IDENTIFIER); }

">>="			{  return(RIGHT_ASSIGN); }
"<<="			{  return(LEFT_ASSIGN); }
"+="			{  return(ADD_ASSIGN); }
"-="			{  return(SUB_ASSIGN); }
"*="			{  return(MUL_ASSIGN); }
"/="			{  return(DIV_ASSIGN); }
"%="			{  return(MOD_ASSIGN); }
"&="			{  return(AND_ASSIGN); }
"^="			{  return(XOR_ASSIGN); }
"|="			{  return(OR_ASSIGN); }
">>"			{  return(RIGHT_OP); }
"<<"			{  return(LEFT_OP); }
"++"			{  return(INC_OP); }
"--"			{  return(DEC_OP); }
"&&"			{  return(AND_OP); }
"||"			{  return(OR_OP); }
"^"			    {  return(XOR_OP); }
"<="			{  return(LE_OP); }
">="			{  return(GE_OP); }
"=="			{  return(EQ_OP); }
"!="			{  return(NE_OP); }
";"			    {  return(';'); }
"{"		        {  scopeCount++; makeList("{",'p',lineCount); return('{'); }
"}"		        {  scopeCount--; makeList("}",'p',lineCount); return('}'); }
","			    {  return(','); }
":"			    {  return(':'); }
"="			    {  return('='); }
"("			    {  return('('); }
")"			    {  return(')'); }
"["		        {  return('['); }
"]"		        {  return(']'); }
"."			    {  return('.'); }
"&"			    {  return('&'); }
"!"			    {  return('!'); }
"-"			    {  return('-'); }
"+"			    {  return('+'); }
"*"			    {  return('*'); }
"/"			    {  return('/'); }
"%"			    {  return('%'); }
"<"			    {  return('<'); }
">"			    {  return('>'); }
"|"			    {  return('|'); }


"#include"(.)*"\n"	{ lineCount++; }
"#define"(.)*"\n"	{ lineCount++; }

[ ]			    {}
[\t\v\f]		{}
[\n]			{lineCount++;}
.			    {}

%%

int yywrap() {
	return(1);
}

void addToken(char *yytext) {
    int len = strlen(yytext);
    tokenTablePtr = (char*)malloc((len+1)*sizeof(char));
    strcpy(tokenTablePtr, yytext);
}
