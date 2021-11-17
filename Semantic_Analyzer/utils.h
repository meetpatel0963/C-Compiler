struct tokenNode
{
	char *token, type[20], line[100];
	char *scope[20];
	int scopeValue;
	int funcCount;
	struct tokenNode *next;
};
typedef struct tokenNode tokenNode;

struct funcNode {
	char funcName[30];
	int line;
	char funcReturn[20];
	struct  funcNode *next;
};
typedef struct funcNode funcNode;


tokenNode *symbolPtr = NULL;
tokenNode *constantPtr = NULL;
tokenNode *parsedPtr = NULL;
extern int functionCount;
extern int scopeCount;
char typeBuffer = ' ';
char *sourceCode;
int tempCheckType = 3;
int semanticErr = 0, lineSemanticCount;


int checkScope(char *tempToken, int lineCount) {
	tokenNode *temp = NULL;
	char type[20];
	int flag = 0, tempFlag = 0;

	for (tokenNode *p = symbolPtr ; p != NULL ; p = p->next) {
		if (strcmp(tempToken, "printf") == 0 || strcmp(tempToken, "scanf") == 0) {
			tempFlag = 1;
		}
		else {
			if (strcmp(tempToken, p->token) == 0) {
				strcpy(type, p->type);
				flag = 1;
				break;
			}
		}

	}
	if (flag == 0 && tempFlag == 0) {
		printf("\n%s : %d : Undeclared variable  \n", sourceCode, lineCount - 1);
		semanticErr = 1;
	}
	else {
		addSymbol(tempToken, lineCount);
		if (strcmp(type, "VOID") == 0)
			return (1);
		if (strcmp(type, "CHAR") == 0)
			return (2);
		if (strcmp(type, "INT") == 0)
			return (3);
		if (strcmp(type, "FLOAT") == 0)
			return (4);
	}
}

void checkType(int value1, int value2, int lineCount) {
	lineSemanticCount = lineCount;
	if (value1 == 0)
		value1 = tempCheckType;
	if (value2 == 0)
		value2 = tempCheckType;
	if (value1 < value2) {
		printf("\n%s : %d : Type mismatch error \n", sourceCode, lineSemanticCount - 1);
		semanticErr = 1;
	}
	tempCheckType = 3;
}

void checkDeclaration(char *tokenName, int tokenLine, int scopeVal) {
	char type[20];
	char line[40], lineBuffer[20];

	snprintf(lineBuffer, 20, "%d", tokenLine);
	strcpy(line, " ");
	strcat(line, lineBuffer);

	switch (typeBuffer) {
	case 'i': strcpy(type, "INT"); break;
	case 'f': strcpy(type, "FLOAT"); break;
	case 'v': strcpy(type, "VOID"); break;
	case 'c': strcpy(type, "CHAR"); break;
	}

	for (tokenNode *p = symbolPtr ; p != NULL ; p = p->next) {
		if (strcmp(p->token, tokenName) == 0 && p->scopeValue == scopeCount) {
			semanticErr = 1;
			if (strcmp(p->type, type) == 0) {
				printf("\n%s : %d : Multiple declaration \n", sourceCode, tokenLine);
				return;
			}
			else {
				printf("\n%s : %d : Multiple declaration with different data types \n", sourceCode, tokenLine);
				return;
			}
		}
	}

	addSymbol(tokenName, tokenLine, scopeCount);
}

void addSymbol(char *tokenName, int tokenLine, int scopeVal) {
	char line[40], lineBuffer[20];

	snprintf(lineBuffer, 20, "%d", tokenLine);
	strcpy(line, " ");
	strcat(line, lineBuffer);

	char type[20];
	for (tokenNode *p = symbolPtr ; p != NULL ; p = p->next) {
		// printf("\n%s %s %d %d %d %d", tokenName, p->token, scopeCount, p->scopeValue, functionCount, p->funcCount);
		if (strcmp(p->token, tokenName) == 0 && p->scopeValue == scopeCount) {
			strcat(p->line, line);
			return;
		}
	}

	tokenNode *temp = (tokenNode*)malloc(sizeof(tokenNode));
	temp->token = (char*)malloc(strlen(tokenName) + 1);
	strcpy(temp->token, tokenName);

	switch (typeBuffer) {
	case 'i': strcpy(temp->type, "INT"); break;
	case 'f': strcpy(temp->type, "FLOAT"); break;
	case 'v': strcpy(temp->type, "VOID"); break;
	case 'c': strcpy(temp->type, "CHAR"); break;
	}

	temp->funcCount = functionCount;

	if (scopeCount == 0) {
		strcpy(temp->scope, "GLOBAL");
		temp->scopeValue = scopeCount;
	}
	else {
		strcpy(temp->scope, "NESTING");
		temp->scopeValue = scopeCount;
	}

	strcpy(temp->line, line);
	temp->next = NULL;
	tokenNode *p = symbolPtr;

	if (p == NULL) {
		symbolPtr = temp;
	}
	else {
		while (p->next != NULL) {
			p = p->next;
		}
		p->next = temp;
	}
}

void addConstant(char *tokenName, int tokenLine) {
	char line[40], lineBuffer[20];

	snprintf(lineBuffer, 20, "%d", tokenLine);
	strcpy(line, " ");
	strcat(line, lineBuffer);

	for (tokenNode *p = constantPtr ; p != NULL ; p = p->next)
		if (strcmp(p->token, tokenName) == 0) {
			strcat(p->line, line);
			return;
		}

	tokenNode *temp = (tokenNode*)malloc(sizeof(tokenNode));
	temp->token = (char*)malloc(strlen(tokenName) + 1);

	strcpy(temp->token, tokenName);
	strcpy(temp->line, line);
	temp->next = NULL;

	tokenNode *p = constantPtr;

	if (p == NULL) {
		constantPtr = temp;
	}
	else {
		while (p->next != NULL) {
			p = p->next;
		}
		p->next = temp;
	}
}

void makeList(char *tokenName, char tokenType, int tokenLine) {
	char line[40], lineBuffer[20];

	snprintf(lineBuffer, 20, "%d", tokenLine);
	strcpy(line, " ");
	strcat(line, lineBuffer);

	char type[20];

	switch (tokenType) {
	case 'c':
		strcpy(type, "Constant");
		break;
	case 'v':
		strcpy(type, "Identifier");
		break;
	case 'p':
		strcpy(type, "Punctuator");
		break;
	case 'o':
		strcpy(type, "Operator");
		break;
	case 'k':
		strcpy(type, "Keyword");
		break;
	case 's':
		strcpy(type, "String Literal");
		break;
	case 'd':
		strcpy(type, "Preprocessor Statement");
		break;
	}


	for (tokenNode *p = parsedPtr ; p != NULL ; p = p->next)
		if (strcmp(p->token, tokenName) == 0) {
			strcat(p->line, line);
			return;
		}

	tokenNode *temp = (tokenNode*)malloc(sizeof(tokenNode));
	temp->token = (char*)malloc(strlen(tokenName) + 1);
	strcpy(temp->token, tokenName);
	strcpy(temp->type, type);
	strcpy(temp->line, line);
	temp->next = NULL;

	tokenNode *p = parsedPtr;
	if (p == NULL) {
		parsedPtr = temp;
	}
	else {
		while (p->next != NULL) {
			p = p->next;
		}
		p->next = temp;
	}
}
