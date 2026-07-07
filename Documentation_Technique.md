# 📚 Documentation Technique — Jumeau Numérique Centre de Tri DEEE

## Table des matières
1. [Architecture du modèle](#architecture)
2. [Liste complète des 57 attributs](#attributs)
3. [Paramètres de simulation](#parametres)
4. [Codes des blocs SimEvents](#codes)
5. [KPIs et formules de calcul](#kpis)

---

## 1. Architecture du modèle {#architecture}

Le modèle est composé de 8 blocs Simulink interconnectés, chacun représentant
une étape physique du process de traitement des DEEE.

```
Source_DEEE → Bloc_Demantèlement → Bloc_Broyage → Bloc_Tri
            → Bloc_Separation_Matiere → Bloc_Hydrometallurgie
            → Pannes_Equipements (Stateflow) → Dashboard KPI
```

---

## 2. Liste complète des 57 attributs {#attributs}

Chaque entité DEEE dans le modèle SimEvents porte **57 attributs** qui
la caractérisent tout au long du process. Ces attributs sont déclarés dans
l'onglet **Entity type** du bloc `Generateur_DEEE` et mis à jour à chaque
étape du process.

---

### 🔵 Groupe 1-Identification et classification (4 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 1 | `categorie` | int (1-4) | 0 | Catégorie REP : 1=GEM, 2=PAM, 3=Écrans, 4=IT | Generateur_DEEE |
| 2 | `masse` | double [t] | 0 | Masse courante de l'entité [tonnes] | Generateur_DEEE |
| 3 | `valorisable` | int (1-2) | 1 | Statut valorisation : 1=valorisable, 2=refus | Server_GEM/PAM/ECR/IT |
| 4 | `tps_service` | double [h] | 0 | Durée de service dans le Server courant [h] | Tous les Server |

---

### 🟢 Groupe 2-Composition matière (5 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 5 | `masse_fe` | double [t] | 0 | Masse métaux ferreux dans l'entité [t] | Generateur_DEEE |
| 6 | `masse_nfe` | double [t] | 0 | Masse métaux non ferreux (Cu, Al) [t] | Generateur_DEEE |
| 7 | `masse_plastique` | double [t] | 0 | Masse plastiques [t] | Generateur_DEEE |
| 8 | `masse_verre` | double [t] | 0 | Masse verre [t] | Generateur_DEEE |
| 9 | `masse_autre` | double [t] | 0 | Masse autres matériaux (cartes, câbles) [t] | Generateur_DEEE |

> **Source calibration** : ADEME Registre National DEEE 2020 — composition
> massique moyenne par catégorie REP

---

### 🟡 Groupe 3-Fraction dominante et routage séparation (2 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 10 | `fraction_dominante` | int (1-5) | 1 | Fraction massique majoritaire : 1=Fe, 2=NFe, 3=Plas, 4=Verre, 5=Autre | Generateur_DEEE |
| 11 | `masse_recuperee` | double [t] | 0 | Masse récupérée après séparation physique [t] | Server_Magnetique/Foucault/Optique/Densimetrique |

---

### 🔴 Groupe 4-Métaux précieux (6 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 12 | `masse_Cu` | double [kg] | 0 | Masse cuivre dans l'entité [kg] | Generateur_DEEE |
| 13 | `masse_Au` | double [g] | 0 | Masse or dans l'entité [g] | Generateur_DEEE |
| 14 | `masse_Ag` | double [g] | 0 | Masse argent dans l'entité [g] | Generateur_DEEE |
| 15 | `masse_Cu_init` | double [kg] | 0 | Masse Cu initiale avant hydromet [kg] | Generateur_DEEE |
| 16 | `masse_Au_init` | double [g] | 0 | Masse Au initiale avant hydromet [g] | Generateur_DEEE |
| 17 | `masse_Ag_init` | double [g] | 0 | Masse Ag initiale avant hydromet [g] | Generateur_DEEE |

> **Source calibration** : ADEME Prospective Métaux Critiques 2022
> Teneurs : Cu=12-28 kg/t, Au=0.8-12 g/t, Ag=40-350 g/t selon catégorie

---

### 🟠 Groupe 5-Valeur économique (1 attribut)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 18 | `valeur_euro` | double [€] | 0 | Valeur marchande estimée des métaux [€] — cours LME 2024 | Generateur_DEEE / Server_Electrolyse |

> **Calcul** : `valeur_euro = masse_Cu × 8.5 + masse_Au × 60 + masse_Ag × 0.8`
> **Source** : LME (London Metal Exchange) cours moyens 2024

---

### 🔵 Groupe 6-Broyage et granulométrie (3 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 19 | `granulometrie` | double [mm] | 0 | Granulométrie courante des fragments [mm] | Server_Demont / Server_Broyeur1 / Server_Broyeur2 |
| 20 | `grain_route` | int (1-2) | 1 | Routage crible : 1=passant, 2=refus recirculation | Server_Crible1 / Server_Crible2 |
| 21 | `nb_passages` | int | 0 | Nombre de passages dans les broyeurs (anti-boucle) | Server_Broyeur1 / Server_Broyeur2 |

---

### 🟣 Groupe 7-Démantèlement et dépollution (4 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 22 | `dangereux` | int (0-1) | 0 | Présence substances dangereuses : 0=non, 1=oui | Server_Depollution |
| 23 | `masse_bat` | double [kg] | 0 | Masse batteries extraites lors dépollution [kg] | Server_Depollution |
| 24 | `masse_Hg` | double [g] | 0 | Masse mercure extrait (écrans fluorescents) [g] | Server_Depollution |
| 25 | `route_depollution` | int (1-2) | 2 | Routage Switch_Danger : 1=dangereux, 2=sain | Server_Depollution |

> **Probabilités danger par catégorie** : GEM=15%, PAM=8%, ECR=20%, IT=12%
> **Source** : Réglementation DEEE — Directive 2012/19/UE

---

### 🟤 Groupe 8-KPIs séparation matière (12 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 26 | `purete_Fe` | double [0-1] | 0 | Pureté fraction ferreux en sortie séparateur magnétique | Server_Magnetique |
| 27 | `rendement_Fe` | double [0-1] | 0 | Rendement récupération Fe = masse_recup / masse_entree | Server_Magnetique |
| 28 | `pertes_Fe` | double [t] | 0 | Pertes Fe dans les résidus [t] | Server_Magnetique |
| 29 | `purete_NFe` | double [0-1] | 0 | Pureté fraction NFe en sortie courants de Foucault | Server_Foucault |
| 30 | `rendement_NFe` | double [0-1] | 0 | Rendement récupération NFe | Server_Foucault |
| 31 | `pertes_NFe` | double [t] | 0 | Pertes NFe dans les résidus [t] | Server_Foucault |
| 32 | `purete_Plas` | double [0-1] | 0 | Pureté fraction plastiques en sortie tri optique | Server_Optique |
| 33 | `rendement_Plas` | double [0-1] | 0 | Rendement récupération plastiques | Server_Optique |
| 34 | `pertes_Plas` | double [t] | 0 | Pertes plastiques dans les résidus [t] | Server_Optique |
| 35 | `purete_Verre` | double [0-1] | 0 | Pureté fraction verre en sortie densimétrique | Server_Densimetrique |
| 36 | `rendement_Verre` | double [0-1] | 0 | Rendement récupération verre | Server_Densimetrique |
| 37 | `pertes_Verre` | double [t] | 0 | Pertes verre dans les résidus [t] | Server_Densimetrique |

---

### 🔵 Groupe 9-Hydrométallurgie — rendements (3 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 38 | `rendement_Cu` | double [%] | 0 | Rendement global récupération Cu = (masse_Cu_final / masse_Cu_init) × 100 | Server_Electrolyse |
| 39 | `rendement_Au` | double [%] | 0 | Rendement global récupération Au | Server_Electrolyse |
| 40 | `rendement_Ag` | double [%] | 0 | Rendement global récupération Ag | Server_Electrolyse |

---

### 🟡 Groupe 10-Bilan énergétique (4 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 41 | `energie_lixiv` | double [kWh] | 0 | Énergie consommée lors de la lixiviation [kWh] | Server_Lixiviation |
| 42 | `energie_precip` | double [kWh] | 0 | Énergie consommée lors de la précipitation [kWh] | Server_Precipitation |
| 43 | `energie_electro` | double [kWh] | 0 | Énergie consommée lors de l'électrolyse [kWh] | Server_Electrolyse |
| 44 | `energie_totale` | double [kWh] | 0 | Énergie totale hydromet = lixiv + precip + electro [kWh] | Server_Electrolyse |

---

### 🟢 Groupe 11-Bilan énergétique global process (4 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 45 | `energie_broyage` | double [kWh] | 0 | Énergie broyeurs 1+2 + convoyeurs [kWh] | Server_Broyeur1 / Server_Broyeur2 |
| 46 | `energie_tri` | double [kWh] | 0 | Énergie postes de tri + convoyeur tri [kWh] | Server_GEM/PAM/ECR/IT |
| 47 | `energie_separation` | double [kWh] | 0 | Énergie séparateurs physiques [kWh] | Server_Magnetique/Foucault/Optique |
| 48 | `energie_totale_process` | double [kWh] | 0 | Énergie totale process complet [kWh] | Server_Electrolyse |

---

### 🔴 Groupe 12-Modélisation thermique (2 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 49 | `temp_cuve` | double [°C] | 20 | Température atteinte dans la cuve de lixiviation [°C] | Server_Lixiviation |
| 50 | `eta_lixiv_reel` | double [0-1] | 0 | Rendement lixiviation corrigé par la température (loi d'Arrhenius simplifiée) | Server_Lixiviation |

> **Modèle thermique** : T(t) = T_cible - (T_cible - T_amb) × exp(-t/τ)
> avec T_cible=70°C, T_amb=20°C, τ=2h

---

### 🟠 Groupe 13-Gestion des effluents acides (3 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 51 | `volume_effluent` | double [L] | 0 | Volume d'effluent acide produit [litres] | Server_Lixiviation |
| 52 | `conc_acide` | double [mol/L] | 0 | Concentration acide résiduel en sortie [mol/L] | Server_Lixiviation / Server_Precipitation |
| 53 | `pH_effluent` | double | 0 | pH de l'effluent à chaque étape | Server_Lixiviation / Server_Precipitation / Server_Electrolyse |

---

### 🟣 Groupe 14-Récupération de chaleur (2 attributs)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 54 | `chaleur_recuperee` | double [kWh] | 0 | Chaleur totale récupérée (3 sources) [kWh] | Server_Lixiviation / Server_Precipitation / Server_Electrolyse |
| 55 | `energie_lixiv_nette` | double [kWh] | 0 | Énergie lixiviation nette après récupération [kWh] | Server_Lixiviation |

---

### 🔵 Groupe 15-Taux de récupération (1 attribut)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 56 | `taux_recuperation` | double [%] | 0 | Taux de récupération chaleur = Q_recup / Q_brute × 100 | Server_Lixiviation |

---

### 🟤 Groupe 16-Énergie lixiviation brute (1 attribut)

| # | Attribut | Type | Valeur initiale | Rôle | Bloc assigneur |
|---|----------|------|----------------|------|----------------|
| 57 | `energie_lixiv_brute` | double [kWh] | 0 | Énergie lixiviation avant récupération chaleur [kWh] | Server_Lixiviation |

---

## 3. Récapitulatif par groupe

| Groupe | Nombre attributs | Domaine |
|--------|-----------------|---------|
| Identification | 4 | Catégorie, masse, routage |
| Composition matière | 5 | Fe, NFe, Plastique, Verre, Autre |
| Fraction dominante | 2 | Routage séparation |
| Métaux précieux | 6 | Cu, Au, Ag — initial et courant |
| Valeur économique | 1 | EUR - cours LME 2024 |
| Broyage | 3 | Granulométrie, passages, routage |
| Démantèlement | 4 | Danger, batteries, mercure, routage |
| KPIs séparation | 12 | Pureté, rendement, pertes × 4 procédés |
| Hydromet rendements | 3 | Cu, Au, Ag - rendement global |
| Énergie hydromet | 4 | Lixiviation, précipitation, électrolyse, total |
| Énergie process | 4 | Broyage, tri, séparation, total process |
| Thermique | 2 | Température cuve, rendement corrigé |
| Effluents | 3 | Volume, concentration, pH |
| Récupération chaleur | 2 | Chaleur récupérée, énergie nette |
| Taux récupération | 1 | % récupération global |
| Énergie brute | 1 | Référence avant récupération |
| **TOTAL** | **57** | |

---

## 4. Paramètres de simulation {#parametres}

Voir `params_DEEE.m` pour la liste complète des 30+ paramètres
calibrés sur données industrielles publiques.

---

## 5. KPIs et formules de calcul {#kpis}

| KPI | Formule | Cible |
|-----|---------|-------|
| Taux captation | N_valorise / (N_valorise + N_refus) × 100 | 91% |
| OEE | Disponibilité × Performance × Qualité | 75% |
| Disponibilité | t_service / (t_service + t_panne + t_maint) | 96.8% |
| Rendement Cu | masse_Cu_final / masse_Cu_init × 100 | 84.5% |
| Récupération chaleur | Q_recup / Q_brute × 100 | - |
| Énergie nette | Énergie_brute - Chaleur_récupérée | 850 kWh/t |

---

*Documentation générée pour le projet DEEE Digital Twin*
*Auteur : Fabrice TSAMO - github.com/fabrice-py/DEEE-Digital-Twin*
