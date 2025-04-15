/**********************************************************************
Projet         : Modèle PLS sur spectres FTIR
Auteur         : RChazal
Date           : 15/04/2025
Description    : chargment des données, prétraitement, PLS, et évaluation des performances
***********************************************************************/
/* notes additionnelles */
/* test de SAS pour ce travail, déjà effectué sous R et python */
/* j'irai donc vite, et me contentera de la prédictio du pcoum à partir des données sauvées de mon jeu de thèse */


/* Création de la bibliothèque */
libname FTIR_lig "/home/u63912112/FTIR_lig";


/* Chargement du fichier Excel */
proc import datafile="/home/u63912112/FTIR_lig/MPall2000-600cm-1modiffSAS.xlsx"
    out=FTIR_lig.data
    dbms=xlsx
    replace;
    getnames=yes;
run;

/* Vérification des variables importées */
proc contents data=FTIR_lig.data;
run;

/* Sélection des variables utiles dans un nouveau dataset */
data FTIR_lig.spectrespcoum;
    set FTIR_lig.data;
    keep data pcoum data_:;
run;

/* Vérification des données dans le dataset filtré */
proc contents data=FTIR_lig.spectrespcoum;
run;


/* plot du 1er spectre, afin de vérifier son état */
/* Extraire le premier échantillon */
data spectre_1;
    set FTIR_lig.spectrespcoum;
    if _N_ = 1;  /* On garde uniquement le premier échantillon */
    keep data_:;
run;

/* Transposer les données pour avoir les longueurs d’onde en lignes */
proc transpose data=spectre_1 out=spectre_1_long name=longueur_onde;
run;

/* Nettoyage et conversion des noms de variables en longueurs d’onde */
data spectre_1_long;
    set spectre_1_long;
    longueur_txt = tranwrd(substr(longueur_onde, 6), '_', '.');  /* Supprime "data_" et remplace _ par . */
    longueur = input(longueur_txt, best.);
    absorbance = col1;
run;

/* Tracé du spectre */
proc sgplot data=spectre_1_long;
    series x=longueur y=absorbance;
    xaxis label='Longueur d''onde (cm⁻¹)' reverse;
    yaxis label='Absorbance';
    title "Spectre FTIR brut - Échantillon 1";
run;




/*normalisation */
/*SAS nativement n'est pas capable de normaliser un jeu de données ligne par ligne, il est nécéssaire de construire une fonction */

data FTIR_lig.data_norm;
    set FTIR_lig.data;

    array spectre data_:;
    n = dim(spectre);

    /* Calcul de la moyenne et écart-type ligne par ligne */
    /*déclaration des variables */
    mean = 0;
    std = 0;

    /* Moyenne */
    do i = 1 to n;
        mean + spectre[i];
    end;
    mean = mean / n;

    /* Écart-type */
    do i = 1 to n;
        std + (spectre[i] - mean)**2;
    end;
    std = sqrt(std / (n - 1));

    /* Normalisation */
    do i = 1 to n;
        if std ne 0 then
            spectre[i] = (spectre[i] - mean) / std;
        else
            spectre[i] = .;
    end;

    drop i mean std n;
run;


/* plot du 1er spectre, afin de vérifier son état */
/* Extraire le premier échantillon */
data un_spectre;
    set FTIR_lig.data_norm;
    if _N_ = 1;
run;

/* Transposer les données pour avoir les longueurs d’onde en lignes */
proc transpose data=un_spectre out=spectre_long name=Variable;
    var data_:;
run;

/* Nettoyage et conversion des noms de variables en longueurs d’onde */
data spectre_long;
    set spectre_long;
    x = _n_;
run;

/* Tracé du spectre */
proc sgplot data=spectre_long;
    series x=x y=col1 / lineattrs=(color=blue thickness=2);
    xaxis label="Indice spectral";
    yaxis label="Intensité normalisée (Z-score)";
    title "Spectre normalisé (1er échantillon)";
run;




/* la normalisation a l'air de fonctionner */
/* SAS n'est pas adapté à ce type de tache, je vais donc m'arreter là pour les prétraitements */
/* donc, pas de déconvolution par dérivée 2, contrairement à ce qui était initialement prévu*/

/*PLS */
/* 7 composantes basées sur une analyse Python */
/* Cross-validation Leave-One-Out car SAS ne permet pas de fixer un nombre de segments */


proc pls data=FTIR_lig.data_norm
    method=pls
    nfac=7
    cv=one     /* Leave-One-Out Cross Validation */
    plots=none;
    model pcoum = data_:;
    output out=FTIR_lig.pls_out
           p=pcoum_pred   /* prédictions sur entraînement */
           cvpred;         /* génère CVPRED automatiquement */
run;

/*vérification de la PLS */
proc contents data=FTIR_lig.pls_out;
run;


/*Calcul des métriques à partir de la table de sortie*/
/* Calcul des erreurs sur entraînement et cross-validation */
/* R2 : Coefficient de détermination */
proc corr data=FTIR_lig.pls_out;
    var pcoum_pred;  /* Prédictions sur l'ensemble d'entraînement */
    with pcoum;  /* Valeurs réelles */
run;

/* Calcul du RMSE et du MAE */
/* calcul des résidus */
data error_metrics;
    set FTIR_lig.pls_out;
    residual = pcoum - pcoum_pred;  /* Calcul des résidus */
    abs_residual = abs(residual);   /* Calcul des erreurs absolues */
    squared_residual = residual**2; /* Calcul des erreurs au carré */
run;

/* Calcul du RMSE */
proc means data=error_metrics noprint;
    var squared_residual;
    output out=rmse_result mean=rmse_value;
run;

data _null_;
    set rmse_result;
    rmse = round(sqrt(rmse_value), 0.001);
    put "RMSE arrondi: " rmse;
run;

/* Calcul du MAE */
proc means data=error_metrics noprint;
    var abs_residual;
    output out=mae_result mean=mae_value;
run;

data _null_;
    set mae_result;
    put "MAE: " mae_value;
run;



/* Tracer les résidus pour examiner leur distribution */
proc sgplot data=error_metrics;
    scatter x=pcoum_pred y=residual / markerattrs=(symbol=circlefilled color=red);
    xaxis label="Prédictions (pcoum_pred)";
    yaxis label="Résidus";
run;




/* statistiques */
data error_metrics;
    set FTIR_lig.pls_out;
    resid_train = pcoum - pcoum_pred;
    abs_resid_train = abs(resid_train);
    sq_resid_train = resid_train**2;

    resid_cv = pcoum - pcoum_cvpred;
    abs_resid_cv = abs(resid_cv);
    sq_resid_cv = resid_cv**2;
run;

/*Corrélation de Pearson (entraînement + CV)*/
title "Corrélation - Entraînement";
proc corr data=FTIR_lig.pls_out;
    var pcoum_pred;
    with pcoum;
run;

title "Corrélation - Validation croisée";
proc corr data=FTIR_lig.pls_out;
    var cvpred;
    with pcoum;
run;


/*RMSE et MAE – Entraînement*/
proc means data=error_metrics noprint;
    var sq_resid_train abs_resid_train;
    output out=train_errors mean=sqmean_train amean_train=mae_train;
run;

data _null_;
    set train_errors;
    rmse_train = sqrt(sqmean_train);
    put "RMSE (Entraînement): " rmse_train;
    put "MAE  (Entraînement): " mae_train;
run;


/*RMSE et MAE – Validation croisée*/
proc means data=error_metrics noprint;
    var sq_resid_cv abs_resid_cv;
    output out=cv_errors mean=sqmean_cv amean_cv=mae_cv;
run;

data _null_;
    set cv_errors;
    rmse_cv = sqrt(sqmean_cv);
    put "RMSE (Validation croisée): " rmse_cv;
    put "MAE  (Validation croisée): " mae_cv;
run;
