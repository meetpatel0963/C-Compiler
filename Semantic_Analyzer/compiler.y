%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "compiler.tab.h"
#include "utils.h"

extern FILE *yyin;
extern int lineNumber;
extern char *tokenTablePtr;
extern int nestedCommentCount;
extern int commentFlag;

int errorFlag = 0;
char *sourceCode = NULL;

void makeList(char *,char,int);
%}

%token AUTO CONST BREAK CONTINUE RETURN SHORT LONG SIGNED UNSIGNED
%token CHAR INT FLOAT DOUBLE VOID FOR DO WHILE IF ELSE
%token IDENTIFIER INTCONSTANT CHCONSTANT FLCONSTANT

%token INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP AND_OP OR_OP XOR_OP
%token MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN 
%token AND_ASSIGN XOR_ASSIGN OR_ASSIGN

%nonassoc UMINUS
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%start S

%%

primary_expression
	:   IDENTIFIER  		    { $$=checkScope(tokenTablePtr, lineNumber); }
	|   CHCONSTANT    		    { tempCheckType=2; addConstant(tokenTablePtr, lineNumber); }
	|   INTCONSTANT    		    { tempCheckType=3; addConstant(tokenTablePtr, lineNumber); }
    |   FLCONSTANT              { tempCheckType=4; addConstant(tokenTablePtr, lineNumber); }
	|   '(' expression ')' 	    { makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); $$=$2; }
	;

postfix_expression
	:   primary_expression                      { $$=$1; }
	|   postfix_expression '(' ')' 				{ makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
	|   postfix_expression '(' argument_expression_list ')' 	{ makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
	|   postfix_expression INC_OP  				{ makeList("++", 'o', lineNumber);}
	|   postfix_expression DEC_OP  				{ makeList("--", 'o', lineNumber);}
	;

argument_expression_list
	:   assignment_expression                              { $$=$1; }
	|   argument_expression_list ',' assignment_expression { makeList(",",'p', lineNumber); }
	;

unary_expression
	:   postfix_expression          { $$=$1; }
	|   INC_OP unary_expression 	{ makeList("++",'o', lineNumber); }
	|   DEC_OP unary_expression 	{ makeList("--",'o', lineNumber); }
	;

multiplicative_expression
	:   unary_expression                               { $$=$1; }
	|   multiplicative_expression '*' unary_expression { $$ = ($1 > $3) ? $1 : $3; makeList("*",'o', lineNumber); }
	|   multiplicative_expression '/' unary_expression { $$ = ($1 > $3) ? $1 : $3; makeList("/",'o', lineNumber); }
	|   multiplicative_expression '%' unary_expression { $$ = ($1 > $3) ? $1 : $3; makeList("%",'o', lineNumber); }
	;

additive_expression
	:   multiplicative_expression                         { $$=$1; }
	|   additive_expression '+' multiplicative_expression { $$ = ($1 > $3) ? $1 : $3; makeList("+",'o', lineNumber); }
	|   additive_expression '-' multiplicative_expression { $$ = ($1 > $3) ? $1 : $3; makeList("-",'o', lineNumber); }
	;

shift_expression
	:   additive_expression                             { $$=$1; }
	|   shift_expression LEFT_OP additive_expression 	{ makeList("<<",'o', lineNumber); }
	|   shift_expression RIGHT_OP additive_expression   { makeList(">>",'o', lineNumber); }
	;

relational_expression
	:   shift_expression        { $$=$1; }
	|   relational_expression '<' shift_expression
	|   relational_expression '>' shift_expression
	|   relational_expression LE_OP shift_expression { makeList("<=",'o', lineNumber); }
	|   relational_expression GE_OP shift_expression { makeList(">=",'o', lineNumber); }
	;

equality_expression
	:   relational_expression   { $$=$1; }
	|   equality_expression EQ_OP relational_expression { makeList("==",'o', lineNumber); }
	|   equality_expression NE_OP relational_expression { makeList("!=",'o', lineNumber); }
	;

and_expression
	:   equality_expression     { $$=$1; }
	|   and_expression '&' equality_expression 	{ makeList("&", 'o', lineNumber);}
	;

exclusive_or_expression
	:   and_expression          { $$=$1; }
	|   exclusive_or_expression '^' and_expression 	{ makeList("^", 'o', lineNumber); }
	;

inclusive_or_expression
	:   exclusive_or_expression { $$=$1; }
	|   inclusive_or_expression '|' exclusive_or_expression { makeList("|", 'o', lineNumber); }
	;

logical_and_expression
	:   inclusive_or_expression { $$=$1; }
	|   logical_and_expression AND_OP inclusive_or_expression { makeList("&&", 'o', lineNumber); }
	;

logical_or_expression
	:   logical_and_expression  { $$=$1; }
	|   logical_or_expression OR_OP logical_and_expression { makeList("||", 'o', lineNumber); }
	;

conditional_expression
	:   logical_or_expression   { $$=$1; }
	|   logical_or_expression '?' expression ':' conditional_expression { makeList("?:",'o', lineNumber); }
	;

assignment_expression
	:   conditional_expression  { $$=$1; }
	|   unary_expression assignment_operator assignment_expression  { $$=$3; checkType($1, $3, lineNumber); }
	;

assignment_operator
    :   '=' 		    { makeList("=",'o', lineNumber); }
	|   MUL_ASSIGN 	    { makeList("*=",'o', lineNumber); }
	|   DIV_ASSIGN 	    { makeList("/=",'o', lineNumber); }
	|   MOD_ASSIGN 	    { makeList("%=",'o', lineNumber); }
	|   ADD_ASSIGN 	    { makeList("+=",'o', lineNumber); }
	|   SUB_ASSIGN 	    { makeList("-=",'o', lineNumber); }
	|   LEFT_ASSIGN 	{ makeList("<<=",'o', lineNumber); }
	|   RIGHT_ASSIGN 	{ makeList(">==",'o', lineNumber); }
	|   AND_ASSIGN 	    { makeList("&=",'o', lineNumber); }
	|   XOR_ASSIGN 	    { makeList("^=",'o', lineNumber); }
	|   OR_ASSIGN 	    { makeList("|=",'o', lineNumber); }
	;


S   
    :   external_declaration
    |   S external_declaration
    ;

external_declaration    
    :   function_definition
    ;

function_definition     
    :   declaration_specifiers declarator compound_statement
    ;

declaration_specifiers  
    :   type_specifier
    |   type_specifier declaration_specifiers
    |   type_qualifier
    |   type_qualifier declaration_specifiers
    ;

type_specifier  
    :   VOID 		{ makeList("void", 'k', lineNumber); typeBuffer='v'; }
    |   CHAR 		{ makeList("char", 'k', lineNumber); typeBuffer='c'; }
    |   SHORT 	    { makeList("short", 'k', lineNumber); }
    |   INT 		{ makeList("int", 'k', lineNumber); typeBuffer='i'; }
    |   LONG 		{ makeList("long", 'k', lineNumber); }
    |   FLOAT 	    { makeList("float", 'k', lineNumber); typeBuffer='f'; }
    |   DOUBLE 	    { makeList("double", 'k', lineNumber); }
    |   SIGNED 	    { makeList("signed", 'k', lineNumber); }
    |   UNSIGNED 	{ makeList("unsigned", 'k', lineNumber); }
    ;

type_qualifier  
    :   CONST 	{ makeList("const", 'k', lineNumber); }

declarator  
    :   direct_declarator       { $$=$1; }
    ;

direct_declarator   
    :   IDENTIFIER 						                { checkDeclaration(tokenTablePtr, lineNumber, scopeCount); $$=checkScope(tokenTablePtr, lineNumber); }
    |   '(' declarator ')' 					            { makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
    |   direct_declarator '(' parameter_type_list ')' 	{ makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
    |   direct_declarator '(' identifier_list ')' 		{ makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
    |   direct_declarator '(' ')' 				        { makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
    ;

parameter_type_list     
    :   parameter_list
    ;

parameter_list  
    :   parameter_declaration
    |   parameter_list ',' parameter_declaration { makeList(",", 'p', lineNumber); }
    ;

parameter_declaration   
    :   declaration_specifiers declarator
    ;

identifier_list     
    :   IDENTIFIER 				        { checkDeclaration(tokenTablePtr, lineNumber, scopeCount); }
    |   identifier_list ',' IDENTIFIER 	{ checkDeclaration(tokenTablePtr, lineNumber, scopeCount); makeList(",", 'p', lineNumber); }
    ;

compound_statement  
    :   '{' '}'                     
    |   '{' statement_list '}'      
    |   '{' declaration_list '}'    
    ;

declaration_list
	:   declaration
	|   declaration_list declaration
    |   statement_list 
    ; 

declaration
	:   declaration_specifiers ';' 			              { makeList(";", 'p', lineNumber); typeBuffer=' '; }
	|   declaration_specifiers init_declarator_list ';'   { makeList(";", 'p', lineNumber); typeBuffer=' '; }
	;

init_declarator_list
	:   init_declarator
	|   init_declarator_list ',' init_declarator { makeList(",", 'p', lineNumber); }
	;

init_declarator
	:   declarator
	|   declarator '=' initializer { checkType($1, $3, lineNumber); makeList("=", 'o', lineNumber); }
	;

initializer
	:   assignment_expression   { $$=$1; }
	|   '{' initializer_list '}'
	|   '{' initializer_list ',' '}'
	;

initializer_list
	:   initializer
	|   initializer_list ',' initializer { makeList(",", 'p', lineNumber); }
	;

statement_list  
    :   statement
    |   statement_list statement
    |   declaration_list
    ;

statement   
    :   compound_statement    
    |   expression_statement  
    |   selection_statement   
    |   iteration_statement   
    |   jump_statement        
    ;

expression_statement    
    :   ';' 		    { makeList(";", 'p', lineNumber); }
    |   expression ';'  { makeList(";", 'p', lineNumber); }
    ;

expression  
    :   assignment_expression       { $$=$1; }
    |   expression ',' assignment_expression { makeList(",", 'p', lineNumber); }
    ;

selection_statement
    :   IF '(' expression ')' statement %prec LOWER_THAN_ELSE 
				{ makeList("if", 'k', lineNumber); makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
  	|   IF '(' expression ')' statement ELSE statement 
  				{ makeList("if", 'k', lineNumber);  makeList("else", 'k', lineNumber); makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
	;

iteration_statement     :   WHILE '(' expression ')' statement  
                                { makeList("while", 'k', lineNumber); makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
                        |   DO statement WHILE '(' expression ')' ';' 
                                { makeList("do", 'k', lineNumber); makeList("while", 'k', lineNumber); makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); makeList(";", 'p', lineNumber); }
                        |   FOR '(' expression_statement expression_statement ')' statement  
                                { makeList("for", 'k', lineNumber); makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
                        |   FOR '(' expression_statement expression_statement expression ')' statement 
                                { makeList("for", 'k', lineNumber); makeList("(", 'p', lineNumber); makeList(")", 'p', lineNumber); }
                        ;
        
jump_statement  :   CONTINUE ';' 		    { makeList("continue", 'k', lineNumber); makeList(";", 'p', lineNumber); }
                |   BREAK ';'  		        { makeList("break", 'k', lineNumber); makeList(";", 'p', lineNumber); }
                |   RETURN ';'  		    { makeList("return", 'k', lineNumber); makeList(";", 'p', lineNumber); }
                |   RETURN expression ';'	{ makeList("return", 'k', lineNumber); makeList(";", 'p', lineNumber); }
                ;
                
%%

void yyerror() {
	errorFlag = 1;
	fflush(stdout);
	printf("\n%s : %d :Syntax error \n", sourceCode, lineNumber);
}

int main(int argc,char **argv) {
	if(argc <= 1) {
		printf("Invalid ,Expected Format : ./a.exe <\"sourceCode\"> \n");
		return 0;
	}
	
	yyin = fopen(argv[1], "r");
	sourceCode = (char *)malloc(strlen(argv[1]) * sizeof(char));
	sourceCode = argv[1];
	yyparse();
	
	if(nestedCommentCount != 0){
		errorFlag = 1;
    		printf("%s : %d : Comment Does Not End\n", sourceCode, lineNumber);
    		
	}
	if(commentFlag == 1){
		errorFlag = 1;
		printf("%s : %d : Nested Comment\n", sourceCode, lineNumber);
    }

	if(!errorFlag && !semanticErr){
		printf("\n\t\t%s Parsing Completed\n\n", sourceCode);
		FILE *writeParsed = fopen("parsedTable.txt", "w");
        fprintf(writeParsed, "\n\t\t\t\t\t\tParsed Table\n\n\t\t\t\t\tToken\t\t\t\t\t\t\t\t\tType\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tLineNumber\n");
        for(tokenList *ptr = parsedPtr ; ptr != NULL ; ptr = ptr->next) {
            fprintf(writeParsed, "\n%20s%30.30s%70s", ptr->token, ptr->type, ptr->line);
        }
		
  		FILE *writeSymbol = fopen("symbolTable.txt", "w");
        fprintf(writeSymbol, "\n\tSymbolTable\n\n\t\t\t\tToken\t\t\t\t\t\t\t\t\tType\t\t\t\t\t\t\t\tLine Number\n");
        for(tokenList *ptr = symbolPtr ; ptr != NULL ; ptr = ptr->next) {
  			fprintf(writeSymbol, "\n%20s%40.30s%40s", ptr->token, ptr->type, ptr->line);
		}
		
		FILE *writeConstant = fopen("constantTable.txt","w");
        fprintf(writeConstant, "\n\t\t\tConstant Table\n\n\t\t\t\tValue\t\t\t\t\t\t\t\tLine Number\n");
        for(tokenList *ptr = constantPtr ; ptr != NULL ; ptr = ptr->next) {
  	    	fprintf(writeConstant, "\n%20s%40s", ptr->token, ptr->line);
        }
        
  		fclose(writeSymbol);
		fclose(writeConstant);
	}
    
    printf("\n\n");	

    return 0;
}
