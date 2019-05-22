%{
/* MdT.l
 * Analyseur lexicale permettant de lire les quadrulplets
 */
#include <string.h>
#include "MdT.tab.h"
extern int linenumber;

%}

%start COMMENTAIRE

NOMBRE [0-9]+
EOL (\r\n|\r|\n)

/*
 * qNOMBREsNOMBREsNOMBREqNOMBRE
 * qNOMBREsNOMBREGqNOMBRE
 * qNOMBREsNOMBREDqNOMBRE
 *
 */

%%


<COMMENTAIRE>{EOL} { linenumber++; BEGIN 0; }
<COMMENTAIRE>.*	; 

[qQ]{NOMBRE} { yylval = atoi(yytext+1); return ETAT; }

[sS]{NOMBRE} { yylval = atoi(yytext+1); return SYMBOLE; }

[gG] 	{ return GAUCHE; }

[dD] 	{ return DROITE; }

[a-z] 	{ yylval = yytext[0]-'z'-5; return SYMBOLE; }

[A-Z] 	{ yylval = yytext[0]-'Z'-5; return SYMBOLE; }

{EOL}	{ linenumber ++; } 

[ \t]+ 	;

"#" 	{ BEGIN COMMENTAIRE; }

.   	{ fprintf(stderr,"Erreur ligne %d : caractere inconnu '%c'\n",linenumber,yytext[0]); };

%%
