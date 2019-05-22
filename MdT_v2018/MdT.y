%{
/* MdT.y
* Analyseur syntaxique
*/
#include <stdlib.h>
#include <time.h>

#include "MdT.h"

typedef enum {FALSE=0,TRUE} BOOL;

BOOL mode_verbeux = TRUE;

int linenumber = 0;

void yyerror(const char *s) {
	printf("Erreur syntaxique ligne %d : %s\n",linenumber,s);
}

%}

%error-verbose

%token SYMBOLE
%token ETAT
%token GAUCHE
%token DROITE
%token SEP

%%
  
MdT: blanc liste_quadruplets description_init;

blanc:SYMBOLE { symbole_blanc = $1; }
	;

liste_quadruplets: quadruplet
	| liste_quadruplets  quadruplet
	;

quadruplet: ETAT SYMBOLE SYMBOLE ETAT { ajouter_quad( $1 , $2, $3, $4); }
	| ETAT SYMBOLE GAUCHE ETAT	 { ajouter_quad( $1 , $2, SYMBGAUCHE, $4); }
	| ETAT SYMBOLE DROITE ETAT	 { ajouter_quad( $1 , $2, SYMBDROITE, $4); }
	;

description_init: liste_symboles ETAT  { pos_tete_init = nb_cases_ruban; /*position de la TLC */} 
	liste_symboles  { etat_machine = $2; /* etat initial */}
	;

liste_symboles: liste_symboles SYMBOLE { ajouter_ruban($2);}
	| SYMBOLE { ajouter_ruban($1);}
	;



%%
void affiche_symbole(FILE *pOut, int x) {
	if ( x>=0 ) {
		fprintf(pOut,"S%d",x);
	}
	else {
		switch (x) {
			case SYMBGAUCHE: fprintf(pOut,"G");break;
			case SYMBDROITE: fprintf(pOut,"D");break;
			default: fprintf(pOut,"%c",x+'Z'+5);
		}
	}
}

void ajouter_quad(int etat_i, int symb_i, int action, int etat_f) {
	if ( nb_quad == taille_tab_quad ) {
		taille_tab_quad += BUFFER_TABLEAU_QUAD;
		tab_quad = (quadruplet *) realloc(tab_quad, taille_tab_quad * sizeof(quadruplet) );
	}
	tab_quad[nb_quad].num = nb_quad;
	tab_quad[nb_quad].etat_initial = etat_i;
	tab_quad[nb_quad].symbole = symb_i;
	tab_quad[nb_quad].action = action;
	tab_quad[nb_quad].etat_final = etat_f;
	nb_quad++;
}

void affiche_quad(FILE * pOut, int i)
{
	fprintf(pOut,"(%d)\tq%d",i,tab_quad[i].etat_initial);
	affiche_symbole(pOut,tab_quad[i].symbole);
	affiche_symbole(pOut,tab_quad[i].action);
	fprintf(pOut,"q%d",tab_quad[i].etat_final);
}

void affiche_quadruplets() {
	int i;
	printf("Liste des quadruplets:\n");
	for (i=0 ; i<nb_quad ; i++) {
		affiche_quad(stdout,i);printf("\n");
	}

}
void affiche_ruban() {
	int i;
	printf("ruban:\n");
	for (i=0 ; i<nb_cases_ruban ; i++) {
		/* on affiche que les cases affectées, la taille réelle du ruban est taille_tab_ruban */
		if (i==pos_tete_init) {
			printf("[q%d",etat_machine);
		}
		affiche_symbole(stdout,tab_ruban[i]);
		if (i==pos_tete_init) {
			printf("]");
		}
	}
	printf("\n");

}
void ajouter_ruban(int symbole) {
	if ( nb_cases_ruban == taille_tab_ruban ) {
		taille_tab_ruban += BUFFER_TABLEAU_RUBAN;
		tab_ruban = (int *) realloc(tab_ruban, taille_tab_ruban * sizeof(int) );
	}
	tab_ruban[nb_cases_ruban] = symbole;
	nb_cases_ruban++;
}

void ajouter_debut_ruban(int symbole) {
	int i;
	if ( nb_cases_ruban == taille_tab_ruban ) {
		taille_tab_ruban += BUFFER_TABLEAU_RUBAN;
		tab_ruban = (int *) realloc(tab_ruban, taille_tab_ruban * sizeof(int) );
	}
	for(i=nb_cases_ruban; i>0; i--) {
		tab_ruban[i] = tab_ruban[i-1];
	}
	tab_ruban[0] = symbole;
	nb_cases_ruban++;
}

//trie par etat_initial et symbole
void echanger(int comp, int i) {
	quadruplet quad = tab_quad[comp];
	tab_quad[comp] = tab_quad[i];
	tab_quad[i] = quad;
}

int partition( int deb, int fin) {
	int compt=deb;
	int pivot=tab_quad[deb].etat_initial;
	int i;

	for (i=deb+1;i<=fin;i++) {
		if (tab_quad[i].etat_initial<pivot) {
			compt++;
			echanger(compt,i);
		}
	}
	echanger(compt,deb);
	return(compt);
}

void tri_rapide (int debut,int fin) {
	if(debut<fin) {
		int pivot=partition(debut,fin);
		tri_rapide(debut,pivot-1);
		tri_rapide(pivot+1,fin);
	}
}

int run(int nb_iterations) {
	int cpt_quad, cpt_instr = pos_tete_init, action, test_trouve, iterateur = 0,i;
	if (mode_verbeux) printf("iter\t(etat,rub)\tN.Quad.\tQuad.\truban\n\
------------------------------------------------------\n");
	while ( iterateur++<nb_iterations ) {
		test_trouve = 0;
		for (cpt_quad = 0; cpt_quad < nb_quad; cpt_quad++) {
			//un quadruplet existe
			if(tab_quad[cpt_quad].etat_initial == etat_machine &&
					tab_quad[cpt_quad].symbole == tab_ruban[cpt_instr]) {
				test_trouve = 1;
				//on effectue l'action correpondante
				if ( mode_verbeux ) {
					printf("%d \t (%d,",iterateur,etat_machine);
					affiche_symbole(stdout,tab_ruban[cpt_instr]);
					printf(")\t\t");
					affiche_quad(stdout,cpt_quad);
					printf("\t");
				}
				switch(tab_quad[cpt_quad].action) {
				case SYMBDROITE : //D
					cpt_instr--;
					if(cpt_instr < 0) {
						ajouter_debut_ruban(symbole_blanc);
						cpt_instr = 0;
					}
					break;
				case SYMBGAUCHE : //G
					cpt_instr++;
					if(cpt_instr == nb_cases_ruban) ajouter_ruban(symbole_blanc);
					break;
				default : //S ou marqueur
					tab_ruban[cpt_instr] = tab_quad[cpt_quad].action;
					break;
				}
				etat_machine = tab_quad[cpt_quad].etat_final;
				if ( mode_verbeux ) {
					for(i=0; i<nb_cases_ruban; i++) {
						if ( i==cpt_instr ) printf("<");
						affiche_symbole(stdout,tab_ruban[i]);
						if ( i==cpt_instr ) printf(">");
					}
					printf("\n");
				}
				break;
			}
			else {
				//on a depasse l'etat initial sans trouver de quadruplet, fin
				if(tab_quad[cpt_quad].etat_initial > etat_machine) {
					printf("Blocage (Etat:%d, Ruban:", etat_machine);
					affiche_symbole(stdout,tab_ruban[cpt_instr]);
					printf(")\n");
					return iterateur-1;
				}
			}
		}
		if (!test_trouve) {
			printf("Blocage (Etat:%d, Ruban:", etat_machine);
			affiche_symbole(stdout,tab_ruban[cpt_instr]);
			printf(")\n");
			return iterateur-1;
		}
	}
	return nb_iterations;
}

void affiche_ligne_commande() {
	printf("Parametres de la ligne de commande :\n");
	printf("  -[h|H|?] : aide sur la ligne de commande\n");
	printf("  -[s|S] : mode silencieux\n");
	printf("  -[n|N] nb : Nombre d'iteration max\n");
	printf("Le fichier de parametrage de la machine doit transmis par le\n\
flux d'entree standard.\n");
}

int main(int argc, char ** argv)
{
	int valeur_retour, i;
	FILE * fic;  //fichier de sortie
	int nb_iterations_max = 1000;
	clock_t t1, t2;

	printf("MdT v0.3f (%s)\nSimulateur de Machine de Turing\n\n",__DATE__);
	/* lecture des paramètres */
	i = 1;
	while ( i<argc ) {
		switch (argv[i][1]) {
			case '?':
			case 'H':
			case 'h': affiche_ligne_commande();
				exit(0);
				break;
			case 'N':
			case 'n': /* nombre d'iteration max*/
				nb_iterations_max = atoi(argv[i+1]);
				break;
			case 'S':
			case 's': /*mode silencieux*/
				mode_verbeux = FALSE;
				i--;
				break;
			default: printf("Parametre de la ligne de commande inconnu : %s\n",
				argv[i]);
				affiche_ligne_commande();
				exit(1);
		}
		i+=2;
	}
	/* appel de l'analyseur syntaxique */
	yyparse();
	/**/
	if (nb_quad == 0 || etat_machine == -1 || nb_cases_ruban == 0) {
	    printf("symbole_blanc=%d, nb_quad = %d, etat_machine = %d, nb_cases_ruban = %d\n",
			symbole_blanc,nb_quad,etat_machine,nb_cases_ruban);
		printf("Veuillez passer en paramètre un fichier correct.\nType : ./MdT < quadruplets\n\n");
		return 0;
	}
	if ( mode_verbeux ) {
		printf("Symbole blanc : ");affiche_symbole(stdout, symbole_blanc);printf("\n");
		affiche_quadruplets();
		affiche_ruban();
	}
	tri_rapide (0, nb_quad-1);

	t1 = clock();
	valeur_retour = run(nb_iterations_max);
	t2 = clock();
	printf("Calcul en %g s.\n",(double)(t2-t1)/(double)CLOCKS_PER_SEC);
	if ( valeur_retour != nb_iterations_max ) {  //bien fonctionne, on ecrit dans le fichier de sortie
		fic = fopen(FICHIER_SORTIE,"w+");
		printf("Blocage : %d iterations.\n",valeur_retour);
		if ( mode_verbeux ) printf("Ruban en sortie : ");
		for(i=0; i<nb_cases_ruban; i++) {
			affiche_symbole(fic,tab_ruban[i]);
			if ( mode_verbeux ) {
				affiche_symbole(stdout,tab_ruban[i]);
			}
		}
		fclose(fic);
	}
	else {
		fic = fopen(FICHIER_SORTIE,"w+");
		if ( !fic ) fprintf(stderr,"Erreur de fichier (%s).\n",FICHIER_SORTIE);
		printf("Erreur: nb d'iterations max atteint (%d).\n",valeur_retour);
		if ( mode_verbeux ) printf("Ruban en sortie : ");
		for (i=0; i<nb_cases_ruban; i++) {
			affiche_symbole(fic,tab_ruban[i]);
			if ( mode_verbeux ) {
				affiche_symbole(stdout,tab_ruban[i]);
			}
		}
		fclose(fic);
	}
	printf("\n\nLe resultat a ete inscrit dans le fichier \"%s\".\n\n",FICHIER_SORTIE);
}
