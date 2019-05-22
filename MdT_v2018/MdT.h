#include <stdio.h>

#ifndef ANA_TURING_H
#define ANA_TURING_H

#define BUFFER_TABLEAU_QUAD 50 //taille de depart
#define BUFFER_TABLEAU_RUBAN 50 //taille de depart
#define FICHIER_SORTIE "sortie_ruban"
#define SYMBGAUCHE -2
#define SYMBDROITE -1

typedef struct s_quadruplet {
  int num, etat_initial, symbole, action, etat_final;
} quadruplet;

//déclaration du prototype de la fonction yylex() pour éviter un warning :
//warning: implicit declaration of function 'yylex' is invalid
//      in C99 [-Wimplicit-function-declaration]
//      yychar = yylex ();
//               ^
//char yylex();
// --> ne fonctionne pas : l'analyse syntaxique n'appelle plus la bonne fonction d'analyse lexicale...

/************************ globales *********************/
quadruplet * tab_quad = 0;
int taille_tab_quad = 0; // permet de reallouer si on depasse les  quadruplets
int nb_quad = 0; // permet de compter les quadruplets

int * tab_ruban = 0;
int taille_tab_ruban = 0; // permet de reallouer si on depasse les  quadruplets
int nb_cases_ruban = 0; // permet de compter les cases du ruban
int pos_tete_init = 0; //position initiale de la tete de L/E

int etat_machine = -1;

int symbole_blanc = 0;

// ajoute le quadruplet dans le tableau tab_quad
void ajouter_quad(int etat_i, int symb_i, int action, int etat_f);

// ajoute le symbole au tableau ruban
void ajouter_ruban(int symbole);

void tri_rapide (int debut,int fin);

int run(int nb_iterations);

#endif
