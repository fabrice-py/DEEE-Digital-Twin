# 🏭 Jumeau Numérique — Centre de Tri DEEE
### Digital Twin of a WEEE Sorting and Recycling Center

[![MATLAB](https://img.shields.io/badge/MATLAB-R2026a-orange?logo=mathworks)](https://www.mathworks.com)
[![SimEvents](https://img.shields.io/badge/SimEvents-Discrete%20Event-blue)](https://www.mathworks.com/products/simevents.html)
[![Stateflow](https://img.shields.io/badge/Stateflow-State%20Machine-green)](https://www.mathworks.com/products/stateflow.html)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

---

## 📋 Description du projet

Ce projet implémente un **jumeau numérique complet** d'un centre de tri et de valorisation de Déchets d'Équipements Électriques et Électroniques (DEEE) sous MATLAB/Simulink avec SimEvents et Stateflow.

Le modèle simule l'ensemble du process industriel — de la réception des appareils jusqu'à la valorisation hydrométallurgique des métaux précieux — en calculant en temps réel les KPIs industriels clés.

> **Sources de données** : ADEME Registre National DEEE 2020 · Veolia Angers (55 000 t/an) · Paprec process DEEE · ADEME référentiel coûts 2021

---

## 🎯 Objectifs

- Modéliser un flux industriel DEEE complet par simulation à événements discrets
- Calculer les KPIs industriels : OEE, taux de captation, disponibilité, rendement matière
- Simuler les pannes d'équipements avec des modèles de fiabilité (MTBF/MTTR)
- Optimiser les procédés par analyse de sensibilité (scénarios what-if)
- Produire un bilan matière et énergétique complet incluant la récupération de chaleur

---

## 🏗️ Architecture du modèle

```
Source_DEEE
    │
    ▼
Bloc_Demantèlement ──► Out_Dangereux (filière réglementaire)
    │
    ▼
Bloc_Broyage (double circuit fermé)
    │ Broyeur primaire (marteaux) → Crible 1 (10mm) ↺
    │ Broyeur secondaire (boulets) → Crible 2 (2mm)  ↺
    ▼
Bloc_Tri (4 lignes parallèles)
    ├── Ligne GEM  (τ = 94%)
    ├── Ligne PAM  (τ = 91%)
    ├── Ligne ECR  (τ = 88%)
    └── Ligne IT   (τ = 89%)
    │
    ▼
Bloc_Separation_Matiere
    ├── Séparateur magnétique  → Métaux Fe   (η = 95%)
    ├── Courants de Foucault   → Métaux NFe  (η = 85%)
    ├── Tri optique            → Plastiques  (η = 92%)
    └── Densimétrique          → Verre       (η = 80%)
    │
    ▼
Bloc_Hydrometallurgie
    ├── Lixiviation acide      (H₂SO₄/HNO₃)
    ├── Précipitation sélective (Cu, Au, Ag)
    └── Électrolyse            (pureté > 99.9%)
    │
    ▼
Dashboard KPI (6 figures)

Pannes_Equipements (Stateflow) ──► SF_Broyeur1, SF_Broyeur2,
                                    SF_Magnetique, SF_Optique
```

---

## 📊 KPIs calculés

| KPI | Valeur simulée | Cible industrielle | Source |
|-----|---------------|-------------------|--------|
| Taux de captation | 92.1% | 91% | Veolia Angers |
| OEE global | 79.6% | 75% | Benchmark sectoriel |
| Disponibilité équipements | 99.6% | 96.8% | MTBF/MTTR |
| Taux de refus | 7.9% | < 10% | ADEME 2020 |
| Rendement Cu (hydromet) | 84.5% | 84.5% | Benchmark industriel |
| Rendement Au (hydromet) | 78.4% | 78.4% | Benchmark industriel |
| Énergie sans récupération | 1306 kWh/t | 850 kWh/t | Objectif sectoriel |
| Énergie avec récupération | ~1070 kWh/t | 850 kWh/t | Après optimisation |

---

## 📁 Structure du projet

```
DEEE_Digital_Twin/
│
├── 📄 README.md                    ← Ce fichier
├── 📄 LICENSE
│
├── 🔧 Simulink/
│   └── DEEE_centre_tri.slx         ← Modèle Simulink principal
│
├── 📝 Scripts/
│   ├── params_DEEE.m               ← Initialisation paramètres
│   ├── dashboard_DEEE.m            ← Dashboard KPI (6 figures)
│   └── scenarios_DEEE.m            ← Analyse what-if
│
├── 📊 Results/
│   ├── Figure1_Dashboard_KPI.png
│   ├── Figure2_KPIs_Separation.png
│   ├── Figure3_KPIs_Hydromet.png
│   ├── Figure4_OEE_Equipements.png
│   ├── Figure5_Bilan_Energetique.png
│   └── Figure6_Recuperation_Chaleur.png
│
└── 📚 Docs/
    └── Documentation_Technique.md
```

---

## ⚙️ Prérequis

| Outil | Version | Rôle |
|-------|---------|------|
| MATLAB | R2024b ou supérieur | Environnement principal |
| Simulink | inclus MATLAB | Modélisation système |
| SimEvents | Toolbox | Simulation événements discrets |
| Stateflow | Toolbox | Modèles d'états (pannes) |

### Vérification des toolboxes

```matlab
ver  % Liste toutes les toolboxes installées
% Vérifier : SimEvents, Stateflow
```

---

## 🚀 Démarrage rapide

### 1. Cloner le dépôt

```bash
git clone https://github.com/votre-username/DEEE-Digital-Twin.git
cd DEEE-Digital-Twin
```

### 2. Configurer MATLAB

```matlab
% Dans MATLAB, naviguer vers le dossier du projet
cd('chemin/vers/DEEE-Digital-Twin')
addpath(genpath(pwd))
```

### 3. Lancer la simulation

```matlab
% Charger les paramètres
params_DEEE

% Lancer la simulation (2000h simulées)
out = sim('DEEE_centre_tri')

% Afficher le dashboard KPI
dashboard_DEEE
```

### 4. Lancer l'analyse what-if

```matlab
scenarios_DEEE
```

---

## 🔬 Détail des blocs

### Source_DEEE
Génère les entités DEEE avec :
- Distribution stochastique des catégories (loi uniforme + fractions REP ADEME)
- Masses unitaires par loi log-normale calibrée
- 14 attributs par entité (catégorie, masse, composition matière, métaux précieux)

### Bloc_Demantèlement
- Désassemblage manuel (temps variable selon catégorie)
- Détection et extraction des substances dangereuses (batteries Li-ion, Hg, PCB)
- Routage réglementaire vers filière déchets dangereux

### Bloc_Broyage
- **Broyeur primaire** : rapport de réduction r1 = 5-8 → cible < 10mm
- **Crible vibrant 1** : seuil 10mm avec recirculation (max 3 passages)
- **Broyeur secondaire** : rapport de réduction r2 = 7-10 → cible < 2mm
- **Crible vibrant 2** : seuil 2mm avec recirculation (max 6 passages)

### Bloc_Tri
4 lignes de tri parallèles routées selon l'attribut `categorie` :

| Ligne | Catégorie | Taux captation | Débit |
|-------|-----------|---------------|-------|
| GEM | Gros électroménager | 94% | 4 t/h |
| PAM | Petit électroménager | 91% | 3 t/h |
| ECR | Écrans | 88% | 200 u/h |
| IT | Informatique | 89% | 2 t/h |

### Bloc_Separation_Matiere
5 procédés de séparation physique :

| Procédé | Fraction cible | Rendement | Pureté |
|---------|---------------|-----------|--------|
| Séparateur magnétique | Métaux Fe | 95% | 97% |
| Courants de Foucault | Métaux NFe (Cu, Al) | 85% | 92% |
| Tri optique | Plastiques | 92% | 94% |
| Densimétrique | Verre | 80% | 88% |
| Résidus | Autre | 70% | — |

### Bloc_Hydrometallurgie
3 étapes chimiques en série :

**Lixiviation** (H₂SO₄ / HNO₃)
- Température opératoire : 60-70°C
- Durée : f(granulométrie) — 0.005 à 0.1h (simulé)
- Rendements : Cu=90%, Au=85%, Ag=88%

**Précipitation sélective** (NaOH, ciment Cu)
- Séparation Cu²⁺, Au³⁺, Ag⁺
- Rendements : Cu=95%, Au=92%, Ag=90%

**Électrolyse** (raffinage final)
- Pureté > 99.9%
- Rendements : Cu=99%, Au=99.8%, Ag=99.5%

### Pannes_Equipements (Stateflow)
4 Charts Stateflow indépendants, un par équipement critique :

| Équipement | MTBF | MTTR | Disponibilité |
|-----------|------|------|--------------|
| Broyeur primaire | 80h | 6h | 93.0% |
| Broyeur secondaire | 120h | 4h | 96.8% |
| Séparateur magnétique | 200h | 3h | 98.5% |
| Tri optique | 60h | 2h | 96.8% |

Chaque Chart implémente 3 états : **En_Service → En_Panne → Maintenance → En_Service**

---

## 📈 Dashboard — 6 figures

| Figure | Contenu |
|--------|---------|
| Figure 1 | Dashboard KPI principal (taux captation, OEE, disponibilité) |
| Figure 2 | KPIs séparation matière (rendements et puretés par procédé) |
| Figure 3 | KPIs hydrométallurgie (rendements Cu/Au/Ag, valeur économique) |
| Figure 4 | Performance par équipement (OEE et disponibilité Stateflow) |
| Figure 5 | Bilan énergétique global (kWh/t par étape, coûts opératoires) |
| Figure 6 | Module récupération de chaleur (3 sources, bénéfices annuels) |

---

## 🔄 Analyse What-If

Le script `scenarios_DEEE.m` permet de tester l'impact de différentes valeurs de MTBF sur les KPIs :

```matlab
MTBF_B1_scenarios = [40, 80, 120, 160, 200];  % heures
```

Résultats typiques :

| MTBF Broyeur1 | OEE_B1 | Disponibilité | Taux captation |
|--------------|--------|--------------|---------------|
| 40h | ~68% | 87% | ~92% |
| 80h | ~75% | 93% | ~92% |
| 120h | ~77% | 97% | ~92% |
| 160h | ~78% | 98% | ~92% |
| 200h | ~79% | 99% | ~92% |

---

## 🧪 Validation du modèle

Le modèle est validé par **cohérence de benchmark** en 3 niveaux :

**Niveau 1 — Validation statique**
Les KPIs en régime permanent sont dans les plages de référence industrielle.

**Niveau 2 — Validation de sensibilité**
Les KPIs réagissent dans le bon sens quand on fait varier les paramètres.

**Niveau 3 — Validation par scénarios contrastés**
La comparaison de configurations montre des gains réalistes.

---

## 📚 Sources et références

- ADEME — *Registre National DEEE 2020*
- ADEME — *Référentiel des coûts de gestion des DEEE 2021*
- Veolia — *Centre de tri DEEE d'Angers — Rapport d'activité 2016*
- Paprec — *Process DEEE — Technologie Smasher*
- ADEME — *Prospective Métaux Critiques 2022*
- Directive européenne DEEE 2012/19/UE

---

## 👤 Auteur

**Fabrice TSAMO NGUESOP**
Ingénieur Géométallurgiste | Futur alternant CESI Nanterre
Mastère Spécialisé Management et Gestion des Risques Industriels (Oct. 2026)

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Fabrice_Tsamo-blue?logo=linkedin)](https://www.linkedin.com/in/fabrice-tsamo-ba68b219b

---

## 📄 Licence

Ce projet est sous licence MIT — voir le fichier [LICENSE](LICENSE) pour les détails.

---

*Projet développé dans le cadre d'un portfolio d'ingénierie — données calibrées sur sources publiques françaises.*
