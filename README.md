# 🧪 Chimiométrie FTIR – Lignine | Analyse par PLS sous SAS

Ce projet explore l’application de la régression PLS (Partial Least Squares) sur des spectres FTIR de matériaux végétaux riches en lignine, en utilisant le langage SAS.  
Les données proviennent d’un travail de thèse (extrait anonymisé).  
L’objectif est de prédire la teneur en acide p-coumarique à partir des spectres infrarouges dans la zone 2000–600 cm⁻¹.

---

## 🇫🇷 Présentation

### 🎯 Objectif :
- Entraîner un modèle PLS avec `PROC PLS` sous SAS
- Appliquer ce modèle à un jeu de test
- Évaluer ses performances (RMSE, R²)
- Identifier les limites de SAS dans un contexte chimiométrique

### ⚠️ Problèmes rencontrés :
- Impossibilité d’utiliser un set de test externe
- Problèmes de cross-validation (`CVPRED` instable ou silencieux)
- Pas de persistance du modèle (`SCORE`, `STORE` manquants)
- Limites sur la validation croisée personnalisée

### ✅ Solutions contournées :
- Extraction manuelle des coefficients (table `OUTSTAT`)
- Calcul des prédictions dans une étape `DATA` via produit matriciel
- Calcul séparé des erreurs de prédiction

## 💬 Retour d'expérience : SAS pour la chimiométrie

Ce projet a été réalisé comme une tentative de modélisation PLS dans SAS, à partir de données spectroscopiques issues de mon travail de thèse.

Malgré la disponibilité de `PROC PLS`, j'ai rencontré des **limitations majeures** :
- ⚠️ Impossible de prédire sur un set de test externe
- ⚠️ Pas de persistance du modèle (score / store absents)
- ⚠️ `CVPRED` instable selon les options de validation croisée
- ⚠️ Calculs d'erreur (RMSE, MAE) impossibles sans manipulation manuelle

👉 Le modèle a été **entraîné, évalué et documenté entièrement dans SAS**, mais au prix d'une grande complexité et d'une faible reproductibilité.

> 🔧 Résultats obtenus sur les données d'entraînement :
- R² = **0.98**
- RMSE (entraînement) ≈ [valeur exacte à insérer]
- RMSE (CV) ≈ [valeur exacte à insérer]


### 💡 Recommandation :
Pour toute utilisation sérieuse de la chimiométrie :
- Utiliser Python (`scikit-learn` – `PLSRegression`)
- Utiliser R (`pls`, `caret`, `mixOmics`)
- Ou des outils spécialisés (SIMCA, The Unscrambler, PLS_Toolbox)

---

## 📁 Fichiers

- `pcoum_spectres.sas` : script principal pour l’analyse PLS
- `MPall2000-600cm-1modiffSAS.xlsx` : spectres FTIR + valeurs cibles (extrait anonymisé)
- `SAS fitr lignin - entrainement.PNG` : capture du modèle ou d’un graphique
- `README.md` : ce fichier

---

## 🔗 Projet lié

➡️ Une version équivalente a été développée en Python dans ce dépôt :  
👉 [`FTIR-lignin-predictive-models`](https://github.com/RChazal-dataSc/LifeScience-project---parietal-material-FTIR-lignin-chemistry-2000-400cm-1)

---

## 🇬🇧 English summary

This project explores the use of **PLS regression** in **SAS** for chemometric analysis of FTIR spectra of lignin-rich plant materials.  
The goal is to predict **p-coumaric acid content** from mid-IR spectra.

⚠️ Despite SAS offering `PROC PLS`, several limitations were encountered:
- No support for external test sets
- Cross-validation (`CVPRED`) often unstable
- No model persistence or scoring functionality

✅ Workarounds included:
- Manual extraction of coefficients from `OUTSTAT`
- Custom prediction using matrix operations in SAS

This project highlights the limitations of SAS for modern chemometrics and recommends using Python, R, or specialized software for such analyses.
