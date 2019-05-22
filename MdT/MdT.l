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

"#" { BEGIN COMMENTAIRE; return SEP;}

<COMMENTAIRE>{EOL} { linenumber++; BEGIN 0;  return SEP; }
<COMMENTAIRE>.	{  return SEP; }

<INITIAL>[qQ]{NOMBRE} { yylval = atoi(yytext+1); return ETAT; }
  /* on est oblige de mettre <INITIAL> car l'etat etait pris en compte dans les commentaires
     car les commentaires sont lus symbole par symbole et l'etat faisant 2 symboles
     devenait prioriaire, même si la ligne commençait par #
  */

<INITIAL>[sS]{NOMBRE} { yylval = atoi(yytext+1); return SYMBOLE; }

<INITIAL>[gG] { return GAUCHE; }

<INITIAL>[dD] { return DROITE; }

<INITIAL>[a-z] { yylval = yytext[0]-'z'-5; return SYMBOLE; }
<INITIAL>[A-Z] {	yylval = yytext[0]-'Z'-5; return SYMBOLE; }

<INITIAL>{EOL}+	{ linenumber += strlen(yytext); return SEP; } /* retourner le carat�re */

<INITIAL>[ \t]+ 	return SEP;

<INITIAL>.   	{ fprintf(stderr,"Erreur ligne %d : caractere inconnu '%c'\n",linenumber,yytext[0]); };

%%
