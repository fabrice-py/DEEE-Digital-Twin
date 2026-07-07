%% =========================================================
%  params_init_DEEE.m  - Initialisation du jumeau numérique
%  Centre de tri DEEE 
% =========================================================
clc; clear; close all;
addpath(pwd);
fprintf('=== Chargement paramètres DEEE ===\n');

%% -1. HORIZON ET PAS DE SIMULATION -
T_sim        = 2000;        % durée simulée [heures] — 1 poste de travail
dt           = 0.25;    % pas de temps [h]
T_chauffe    = 0.5;    % montée en régime [h]

%% - 2. SOURCE DEEE - Flux entrant journalier -
Q_jour       = 150;     % tonnage journalier moyen [t/jour]  (Veolia Angers : 55 000/365)
sigma_Q      = 0.20;   % variabilité ± 20 % (saisonnalité, tournées)
Q_heure      = Q_jour / 8; % débit horaire nominal [t/h]

% Répartition par catégorie REP (ADEME Registre 2020)
f_GEM        = 0.42;   % Gros électroménager (lave-linge, frigo...)
f_PAM        = 0.28;   % Petit appareil ménager (bouilloire, sèche-cheveux...)
f_ECR        = 0.18;   % Écrans (TV, moniteurs, tablettes)
f_IT         = 0.12;   % Informatique (PC, imprimantes)

% Vérification : somme des fractions = 1
assert(abs(f_GEM+f_PAM+f_ECR+f_IT - 1.0) < 1e-9, 'Erreur : fractions ≠ 1');

%% - 3. QUAI DE RÉCEPTION -
cap_quai     = 30;     % capacité tampon quai [t]
t_decharg    = 0.01;  % temps déchargement camion [h] = 15 min
n_quais      = 5;      % nombre de quais actifs

%% - 4. TRI MANUEL & AUTOMATISÉ -
% Taux de captation par catégorie (Veolia Angers 2016)
tau_capt_GEM = 0.94;  % 94 % gros électroménager
tau_capt_PAM = 0.91;  % 91 % petit électroménager
tau_capt_ECR = 0.88;  % 88 % écrans
tau_capt_IT  = 0.89;  % 89 % informatique (estimé)

% Débit convoyeur tri optique [t/h] (Veolia Angers)
debit_conv   = 4.0;   
% Cadence démantèlement écrans [unités/h] (Veolia Angers)
debit_ecrans = 200;   
% Poids moyen écran [t/unité]
m_ecran      = 0.008; % 8 kg/écran

% Ressources humaines
n_op_tri     = 8;     % opérateurs poste tri [ETP]
cadence_op   = 0.5;   % t/h par opérateur (benchmark ADEME)

%% - 5. DÉMANTÈLEMENT & BROYAGE -
eta_broyeur  = 0.65;  % rendement broyeur standard (Paprec : 60-70 %)
eta_smasher  = 0.85;  % rendement Smasher (Paprec : +20-30 % vs standard)

% Modèle de disponibilité équipements
MTBF         = 120;   % Mean Time Between Failures [h]
MTTR         = 4;     % Mean Time To Repair [h]
D_eq         = MTBF / (MTBF + MTTR); % Disponibilité = 96.8 %

% Paramètre loi exponentielle pannes (pour SimEvents)
lambda_panne = 1 / MTBF; % taux de défaillance [1/h]
mu_rep       = 1 / MTTR;  % taux de réparation [1/h]

%% - 6. BILAN MATIÈRE & VALORISATION -
tau_val_global  = 0.78;  % taux valorisation global (ADEME 2020 : 78 %)
objectif_val    = 0.65;  % objectif réglementaire UE
purity_plast    = 0.97;  % pureté plastique sortie tri optique (Veolia)

% Composition massique moyenne DEEE (ADEME)
frac_metaux_fe  = 0.35;  % métaux ferreux
frac_metaux_nfe = 0.15;  % métaux non ferreux (Cu, Al)
frac_plastiques = 0.22;  % plastiques
frac_verre      = 0.08;  % verre (principalement écrans)
frac_autre      = 1 - frac_metaux_fe - frac_metaux_nfe - frac_plastiques - frac_verre;

%% - 7. KPIs CIBLES DE VALIDATION -
kpi_OEE_cible        = 0.75;  % OEE minimal acceptable
kpi_capt_cible       = 0.91;  % taux captation moyen cible
kpi_rendement_cible  = 0.78;  % rendement matière cible (= ADEME national)
kpi_debit_sortie     = Q_heure * tau_val_global; % débit sortie valorisée [t/h]

%% - Configuration export données -
set_param('DEEE_centre_tri', 'SaveOutput', 'on');
set_param('DEEE_centre_tri', 'OutputSaveName', 'yout');
set_param('DEEE_centre_tri', 'SaveFormat', 'Dataset');
%% --- Fiabilité par équipement ---
% Broyeur primaire — équipement lourd, pannes fréquentes
MTBF_B1 = 80;    % h — tombe en panne toutes les 80h en moyenne
MTTR_B1 = 6;     % h — 6h de réparation
D_B1    = MTBF_B1 / (MTBF_B1 + MTTR_B1);  % 93.0%

% Broyeur secondaire — moins sollicité
MTBF_B2 = 120;   % h
MTTR_B2 = 4;     % h
D_B2    = MTBF_B2 / (MTBF_B2 + MTTR_B2);  % 96.8%

% Séparateur magnétique — très fiable
MTBF_Mag = 200;  % h
MTTR_Mag = 3;    % h
D_Mag   = MTBF_Mag / (MTBF_Mag + MTTR_Mag);  % 98.5%

% Tri optique — électronique, pannes courtes mais fréquentes
MTBF_Opt = 60;   % h
MTTR_Opt = 2;    % h
D_Opt   = MTBF_Opt / (MTBF_Opt + MTTR_Opt);  % 96.8%
%% - 8. AFFICHAGE RÉCAPITULATIF -
fprintf('\n--- Flux entrant ---\n');
fprintf('  Débit nominal   : %.2f t/h\n', Q_heure);
fprintf('  Débit sortie KPI: %.2f t/h\n', kpi_debit_sortie);
fprintf('\n--- Disponibilité équipements ---\n');
fprintf('  MTBF = %d h  |  MTTR = %d h\n', MTBF, MTTR);
fprintf('  Disponibilité D = %.1f %%\n', D_eq*100);
fprintf('\n--- KPIs cibles validation ---\n');
fprintf('  OEE cible        >= %.0f %%\n', kpi_OEE_cible*100);
fprintf('  Taux captation    = %.0f %%\n', kpi_capt_cible*100);
fprintf('  Rendement matière = %.0f %%\n', kpi_rendement_cible*100);
fprintf('\n=== Paramètres chargés dans workspace ===\n');
%% --- Bilan énergétique global ---
energie_spec_B1   = 15.0;   % kWh/tonne broyeur primaire
energie_spec_B2   = 25.0;   % kWh/tonne broyeur secondaire
energie_spec_conv = 2.0;    % kWh/tonne convoyeurs
energie_spec_tri  = 5.0;    % kWh/tonne tri
energie_spec_mag  = 1.0;    % kWh/tonne magnétique
energie_spec_nfe  = 3.0;    % kWh/tonne Foucault
energie_spec_opt  = 5.0;    % kWh/tonne optique

% Coût énergie [€/kWh]-(tarif industriel France 2024)
cout_kwh = 0.12;

% Objectif énergétique réglementaire [kWh/tonne traité]
objectif_energie = 850;   % kWh/tonne (benchmark sectoriel)
%% --- Récupération de chaleur ---
eta_echangeur    = 0.75;   % rendement échangeur à plaques
Cp_eau           = 4.18;   % kJ/kg·°C capacité thermique eau
T_reseau         = 20.0;   % °C température eau réseau
T_effluent_moy   = 65.0;   % °C température moyenne effluent

% Économie énergétique théorique [kWh/tonne]
Q_recup_theorique = eta_echangeur * 4.0 * Cp_eau * ...
    (T_effluent_moy - T_reseau) / 3600 * 1000;
fprintf('  Recuperation chaleur theorique : %.0f kWh/t\n', Q_recup_theorique);
%% --- Fonction utilitaire ---
ternaire = @(cond, a, b) a*cond + b*(~cond);