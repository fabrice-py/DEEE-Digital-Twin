%% =========================================================
%  dashboard_DEEE.m-Tableau de bord KPI final
%  Centre de tri DEEE/MATLAB R2026a
% =========================================================
clc;
fprintf('=== Calcul des KPIs ===\n');

%% --- EXTRACTION DEPUIS TIMESERIES ---
try; N_fe        = out.n_fe.Data(end);        catch; N_fe        = 0; end
try; N_plas      = out.n_plas.Data(end);      catch; N_plas      = 0; end
try; N_verre     = out.n_verre.Data(end);     catch; N_verre     = 0; end
try; N_hydromet  = out.n_hydromet.Data(end);  catch; N_hydromet  = 0; end
try; N_refus     = out.n_refus.Data(end);     catch; N_refus     = 0; end
try; N_dangereux = out.n_dangereux.Data(end); catch; N_dangereux = 0; end

try
    OEE_data = out.OEE_data.Data;
    if isempty(OEE_data); OEE_data = zeros(100,1); end
catch
    OEE_data = zeros(100,1);
end

try
    dispo_data = out.disponibilite_data.Data;
    t_data     = out.disponibilite_data.Time;
    if isempty(dispo_data)
        dispo_data = ones(100,1);
        t_data     = linspace(0, T_sim, 100)';
    end
catch
    dispo_data = ones(100,1);
    t_data     = linspace(0, T_sim, 100)';
end

%% --- KPIs ---
N_autre         = 0;
N_valorise      = N_fe + N_plas + N_verre + N_autre + N_hydromet;
N_total_process = N_valorise + N_refus;

if N_total_process > 0
    tau_captation = N_valorise / N_total_process * 100;
    tau_refus     = N_refus    / N_total_process * 100;
else
    tau_captation = 0;
    tau_refus     = 0;
end

N_total      = N_valorise + N_refus + N_dangereux;
OEE_final    = OEE_data(end)   * 100;
dispo_finale = dispo_data(end) * 100;

fprintf('\n--- KPIs calcules ---\n');
fprintf('  Entites totales      : %d\n',      N_total);
fprintf('  Entites valorisees   : %d\n',      N_valorise);
fprintf('  dont Hydromet        : %d\n',      N_hydromet);
fprintf('  Entites dangereuses  : %d\n',      N_dangereux);
fprintf('  Entites refus        : %d\n',      N_refus);
fprintf('  Taux de captation    : %.1f %%\n', tau_captation);
fprintf('  Taux de refus        : %.1f %%\n', tau_refus);
fprintf('  OEE final            : %.1f %%\n', OEE_final);
fprintf('  Disponibilite finale : %.1f %%\n', dispo_finale);

%% FIGURE 1-Dashboard KPI principal
figure('Name','Dashboard KPI DEEE','Position',[50 50 1400 900]);

% G1 — Répartition fractions
subplot(2,3,1);
fractions_val = [N_fe, N_plas, N_verre, N_hydromet];
labels_val    = {'Metaux Fe','Plastiques','Verre','Hydromet'};
couleurs      = [0.2 0.6 0.9; 0.3 0.8 0.4; 0.8 0.3 0.3; 0.6 0.2 0.8];
if sum(fractions_val) > 0
    pie(fractions_val + 0.001, labels_val);
    colormap(couleurs);
else
    text(0.5, 0.5, 'Pas de donnees', 'HorizontalAlignment','center','Units','normalized');
end
title('Repartition fractions valorisees','FontWeight','bold');

% G2 — Répartition entités
subplot(2,3,2);
b2 = bar([N_valorise, N_refus, N_dangereux],'FaceColor','flat');
b2.CData = [0.3 0.8 0.4; 0.9 0.3 0.3; 0.9 0.7 0.1];
set(gca,'XTickLabel',{'Valorise','Refus','Dangereux'});
ylabel('Nombre d entites');
title('Repartition entites','FontWeight','bold');
grid on;

% G3 — OEE dans le temps
subplot(2,3,3);
t_heures = linspace(0, T_sim, length(OEE_data));
plot(t_heures, OEE_data*100,'b-','LineWidth',1.5);
yline(kpi_OEE_cible*100,'r--','Cible 75%','LineWidth',1.2);
xlabel('Temps [h]'); ylabel('OEE [%]');
title('OEE en temps reel','FontWeight','bold');
ylim([0 110]); grid on;

% G4 — Disponibilité cumulée
subplot(2,3,4);
plot(t_data, dispo_data*100,'r-','LineWidth',1.5);
yline(D_eq*100,'b--',sprintf('Cible %.1f%%',D_eq*100),'LineWidth',1.2);
xlabel('Temps [h]'); ylabel('Disponibilite [%]');
title('Disponibilite cumulee','FontWeight','bold');
ylim([0 110]); grid on;

% G5 — KPIs vs Cibles
subplot(2,3,5);
kpis_val    = [tau_captation, OEE_final, dispo_finale];
kpis_cibles = [kpi_capt_cible*100, kpi_OEE_cible*100, D_eq*100];
b5 = bar(kpis_val,'FaceColor','flat');
b5.CData = [0.3 0.7 0.4; 0.2 0.5 0.9; 0.9 0.6 0.1];
hold on;
plot(1:3, kpis_cibles,'r*','MarkerSize',10,'LineWidth',2);
set(gca,'XTickLabel',{'Taux captation','OEE','Disponibilite'});
ylabel('%'); title('KPIs vs Cibles','FontWeight','bold');
ylim([0 110]); grid on;
legend('Valeur simulee','Cible','Location','southeast');

% G6 — Récapitulatif
subplot(2,3,6);
axis off;
texte = {
    sprintf('Taux captation  : %.1f%% (cible 91%%)',   tau_captation);
    sprintf('OEE             : %.1f%% (cible 75%%)',   OEE_final);
    sprintf('Disponibilite   : %.1f%% (cible 96.8%%)', dispo_finale);
    sprintf('Taux refus      : %.1f%% (cible <10%%)',  tau_refus);
    sprintf('Valorisees      : %d entites',            N_valorise);
    sprintf('dont Hydromet   : %d entites',            N_hydromet);
    sprintf('Dangereuses     : %d entites',            N_dangereux);
    sprintf('Refus           : %d entites',            N_refus);
    sprintf('Total traite    : %d entites',            N_total);
};
for i = 1:length(texte)
    text(0.05, 1-i*0.10, texte{i},'FontSize',10,'FontName','Courier','Units','normalized');
end
title('Recapitulatif KPIs','FontWeight','bold');

sgtitle(sprintf('Dashboard KPI-Centre de tri DEEE/Simulation %dh', T_sim),...
    'FontSize',14,'FontWeight','bold');

%% FIGURE 2-KPIs Séparation Matière
figure('Name','KPIs Separation DEEE','Position',[50 50 1200 600]);

% G1 — Rendements par procédé
subplot(1,3,1);
rendements  = [0.95, 0.85, 0.92, 0.80] * 100;
cibles_rend = [90, 80, 88, 75];
procedes    = {'Magnetique','Foucault','Optique','Densimetrique'};
b_rend = bar(rendements, 'FaceColor', 'flat');
b_rend.CData = [0.2 0.6 0.9; 0.9 0.5 0.1; 0.3 0.8 0.4; 0.8 0.3 0.3];
hold on;
plot(1:4, cibles_rend, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
set(gca, 'XTickLabel', procedes, 'XTickLabelRotation', 15);
ylabel('Rendement [%]');
title('Rendement recuperation par procede','FontWeight','bold');
ylim([0 110]); grid on;
legend('Valeur simulee','Cible','Location','southeast');

% G2 — Puretés par procédé
subplot(1,3,2);
puretes    = [0.97, 0.92, 0.94, 0.88] * 100;
cibles_pur = [95, 88, 90, 85];
b_pur = bar(puretes, 'FaceColor', 'flat');
b_pur.CData = [0.2 0.6 0.9; 0.9 0.5 0.1; 0.3 0.8 0.4; 0.8 0.3 0.3];
hold on;
plot(1:4, cibles_pur, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
set(gca, 'XTickLabel', procedes, 'XTickLabelRotation', 15);
ylabel('Purete [%]');
title('Purete produit par procede','FontWeight','bold');
ylim([0 110]); grid on;

% G3 — Bilan matière global
subplot(1,3,3);
fractions_masse = [N_fe, N_plas, N_verre, N_hydromet, N_refus];
labels_masse    = {'Fe','Plastiques','Verre','Hydromet','Refus'};
couleurs_masse  = [0.2 0.6 0.9; 0.3 0.8 0.4; 0.8 0.3 0.3; 0.6 0.2 0.8; 0.9 0.3 0.3];
if sum(fractions_masse) > 0
    pie(fractions_masse + 0.001, labels_masse);
    colormap(couleurs_masse);
end
title('Bilan matiere global','FontWeight','bold');

sgtitle('KPIs Separation Matiere-Centre de tri DEEE',...
    'FontSize', 14, 'FontWeight', 'bold');


%% FIGURE 3-KPIs Hydrométallurgie complet
figure('Name','KPIs Hydrometallurgie DEEE','Position',[100 100 1400 800]);

eta_lixiv   = [0.90, 0.85, 0.88];
eta_precip  = [0.95, 0.92, 0.90];
eta_electro = [0.99, 0.998, 0.995];
eta_global  = eta_lixiv .* eta_precip .* eta_electro * 100;

% G1 — Rendement par étape
subplot(2,3,1);
data_etapes = [eta_lixiv; eta_precip; eta_electro] * 100;
b_eta = bar(data_etapes, 'grouped');
b_eta(1).FaceColor = [0.85 0.65 0.13];
b_eta(2).FaceColor = [1.00 0.84 0.00];
b_eta(3).FaceColor = [0.75 0.75 0.75];
set(gca,'XTickLabel',{'Lixiviation','Precipitation','Electrolyse'},...
    'XTickLabelRotation',15);
ylabel('Rendement [%]');
title('Rendement par etape','FontWeight','bold');
ylim([0 110]); grid on;
legend('Cu','Au','Ag','Location','southeast');

% G2 — Rendement global
subplot(2,3,2);
b_glob = bar(eta_global,'FaceColor','flat');
b_glob.CData = [0.85 0.65 0.13; 1.00 0.84 0.00; 0.75 0.75 0.75];
hold on;
plot(1:3,[84.5,78.4,79.0],'r*','MarkerSize',10,'LineWidth',2);
set(gca,'XTickLabel',{'Cuivre','Or','Argent'});
ylabel('Rendement global [%]');
title('Rendement global','FontWeight','bold');
ylim([0 110]); grid on;
legend('Valeur simulee','Cible','Location','southeast');

% G3 — Valeur économique
subplot(2,3,3);
masse_moy_Cu = 2.5e-4;
masse_moy_Au = 0.05;
masse_moy_Ag = 1.5;
val_Cu     = N_hydromet * masse_moy_Cu * eta_global(1)/100 * 8.5;
val_Au     = N_hydromet * masse_moy_Au * eta_global(2)/100 * 60.0;
val_Ag     = N_hydromet * masse_moy_Ag * eta_global(3)/100 * 0.8;
val_totale = val_Cu + val_Au + val_Ag;
b_val = bar([val_Cu,val_Au,val_Ag],'FaceColor','flat');
b_val.CData = [0.85 0.65 0.13; 1.00 0.84 0.00; 0.75 0.75 0.75];
set(gca,'XTickLabel',{'Cu','Au','Ag'});
ylabel('Valeur [EUR]');
title(sprintf('Valeur recuperee — Total : %.0f EUR',val_totale),...
    'FontWeight','bold');
grid on;

% G4 — Bilan énergétique
subplot(2,3,4);
energie_moy_lixiv   = 0.8  * 15 * 1000;   % kWh estimé sur N entités
energie_moy_precip  = 0.1  * 15 * 1000;
energie_moy_electro = 0.35 * 15 * 1000;
energies = [energie_moy_lixiv, energie_moy_precip, energie_moy_electro];
b_en = bar(energies,'FaceColor','flat');
b_en.CData = [0.9 0.3 0.1; 0.9 0.6 0.1; 0.2 0.5 0.9];
set(gca,'XTickLabel',{'Lixiviation','Precipitation','Electrolyse'});
ylabel('Energie [kWh]');
title('Bilan energetique hydromet','FontWeight','bold');
grid on;

% G5 — Profil thermique cuve lixiviation
subplot(2,3,5);
t_vec   = linspace(0, 4, 100);
T_cible = 70; T_amb = 20; tau = 2;
T_profil = T_cible - (T_cible - T_amb) * exp(-t_vec / tau);
plot(t_vec, T_profil, 'r-', 'LineWidth', 2);
hold on;
yline(T_cible, 'b--', sprintf('T cible = %d C', T_cible), 'LineWidth', 1.2);
yline(60, 'g--', 'T ref = 60 C', 'LineWidth', 1.2);
xlabel('Temps [h]'); ylabel('Temperature [°C]');
title('Profil thermique cuve lixiviation','FontWeight','bold');
ylim([0 90]); grid on;

% G6 — Gestion effluents
subplot(2,3,6);
etapes_eff = {'Lixiviation','Precipitation','Electrolyse'};
pH_vals    = [1.5, 3.2, 7.0];
conc_vals  = [0.25, 0.08, 0.0];
yyaxis left;
b_pH = bar(pH_vals, 0.4, 'FaceColor', [0.2 0.6 0.9]);
ylabel('pH effluent');
ylim([0 10]);
yyaxis right;
plot(1:3, conc_vals, 'r-o', 'LineWidth', 2, 'MarkerSize', 8);
ylabel('Concentration acide [mol/L]');
set(gca,'XTickLabel', etapes_eff);
title('Evolution effluents acides','FontWeight','bold');
grid on;
legend('pH','Concentration acide','Location','northeast');

sgtitle(sprintf('KPIs Hydrometallurgie-%d entites | Simulation %dh',...
    N_hydromet, T_sim),'FontSize',14,'FontWeight','bold');

%% FIGURE 4-OEE par équipement
figure('Name','OEE par Equipement','Position',[100 100 1000 500]);
figure(4);

try; dispo_B1  = out.logsout.getElement('dispo_B1').Values.Data(end)*100;  catch; dispo_B1  = 0; end
try; dispo_B2  = out.logsout.getElement('dispo_B2').Values.Data(end)*100;  catch; dispo_B2  = 0; end
try; dispo_Mag = out.logsout.getElement('dispo_Mag').Values.Data(end)*100; catch; dispo_Mag = 0; end
try; dispo_Opt = out.logsout.getElement('dispo_Opt').Values.Data(end)*100; catch; dispo_Opt = 0; end
try; OEE_B1    = out.logsout.getElement('OEE_B1').Values.Data(end)*100;    catch; OEE_B1    = 0; end
try; OEE_B2    = out.logsout.getElement('OEE_B2').Values.Data(end)*100;    catch; OEE_B2    = 0; end
try; OEE_Mag   = out.logsout.getElement('OEE_Mag').Values.Data(end)*100;   catch; OEE_Mag   = 0; end
try; OEE_Opt   = out.logsout.getElement('OEE_Opt').Values.Data(end)*100;   catch; OEE_Opt   = 0; end

equipements = {'Broyeur 1','Broyeur 2','Magnetique','Optique'};
cibles_D    = [D_B1, D_B2, D_Mag, D_Opt] * 100;
cibles_OEE  = [75, 75, 75, 75];

% G1 — Disponibilité par équipement
subplot(1,2,1);
vals_dispo = [dispo_B1, dispo_B2, dispo_Mag, dispo_Opt];
b_d = bar(vals_dispo, 'FaceColor', 'flat');
b_d.CData = [0.9 0.5 0.1; 0.9 0.7 0.1; 0.2 0.6 0.9; 0.3 0.8 0.4];
hold on;
plot(1:4, cibles_D, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
set(gca, 'XTickLabel', equipements, 'XTickLabelRotation', 15);
ylabel('Disponibilite [%]');
title('Disponibilite par equipement','FontWeight','bold');
ylim([0 110]); grid on;
legend('Valeur simulee','Cible','Location','southeast');

% G2 — OEE par équipement
subplot(1,2,2);
vals_OEE = [OEE_B1, OEE_B2, OEE_Mag, OEE_Opt];
b_o = bar(vals_OEE, 'FaceColor', 'flat');
b_o.CData = [0.9 0.5 0.1; 0.9 0.7 0.1; 0.2 0.6 0.9; 0.3 0.8 0.4];
hold on;
plot(1:4, cibles_OEE, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
set(gca, 'XTickLabel', equipements, 'XTickLabelRotation', 15);
ylabel('OEE [%]');
title('OEE par equipement','FontWeight','bold');
ylim([0 110]); grid on;
legend('Valeur simulee','Cible','Location','southeast');

sgtitle('Performance par equipement-Centre de tri DEEE',...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n=== Dashboard genere : 4 figures ===\n');
%% FIGURE 5-Bilan énergétique global
figure('Name','Bilan Energetique Global','Position',[50 50 1400 700]);

% Consommations par étape [kWh/tonne]
etapes_energie = {'Broyeur 1','Broyeur 2','Convoyeurs',...
    'Tri','Magnetique','Foucault','Optique',...
    'Lixiviation','Precipitation','Electrolyse'};
conso_kwh_t = [15, 25, 2, 5, 1, 3, 5, 800, 100, 350];
couleurs_en  = [0.8 0.2 0.1; 0.9 0.4 0.1; 0.5 0.5 0.5;
    0.3 0.7 0.3; 0.2 0.5 0.9; 0.2 0.6 0.8;
    0.3 0.8 0.5; 0.9 0.1 0.1; 0.9 0.5 0.1;
    0.2 0.3 0.9];

% G1 — Consommation par étape
subplot(2,3,1);
b_en = bar(conso_kwh_t, 'FaceColor', 'flat');
b_en.CData = couleurs_en;
set(gca, 'XTickLabel', etapes_energie, 'XTickLabelRotation', 45);
ylabel('Consommation [kWh/tonne]');
title('Consommation specifique par etape','FontWeight','bold');
grid on;

% G2 — Répartition énergétique (pie)
subplot(2,3,2);
groupes = {'Broyage (42 kWh/t)', 'Tri+Sep (14 kWh/t)', ...
    'Hydromet (1250 kWh/t)'};
vals_groupes = [42, 14, 1250];
pie(vals_groupes, groupes);
title('Repartition energetique globale','FontWeight','bold');

% G3 — Coût énergétique par étape [€/tonne]
subplot(2,3,3);
cout_kwh_val = 0.12;
couts_euro = conso_kwh_t * cout_kwh_val;
b_cout = bar(couts_euro, 'FaceColor', 'flat');
b_cout.CData = couleurs_en;
set(gca, 'XTickLabel', etapes_energie, 'XTickLabelRotation', 45);
ylabel('Cout [EUR/tonne]');
title('Cout energetique par etape','FontWeight','bold');
grid on;

% G4 — Énergie totale vs objectif
subplot(2,3,4);
energie_totale_sim = sum(conso_kwh_t);
categories_bilan = {'Broyage','Tri+Sep','Hydromet','Total'};
vals_bilan = [42, 14, 1250, energie_totale_sim];
cibles_bilan = [50, 20, 1200, objectif_energie];
b_bil = bar(vals_bilan, 'FaceColor', 'flat');
b_bil.CData = [0.3 0.7 0.4; 0.2 0.5 0.9; 0.9 0.3 0.1; 0.5 0.2 0.8];
hold on;
plot(1:4, cibles_bilan, 'r*', 'MarkerSize', 10, 'LineWidth', 2);
set(gca, 'XTickLabel', categories_bilan);
ylabel('Energie [kWh/tonne]');
title('Bilan energetique vs objectifs','FontWeight','bold');
legend('Valeur simulee','Cible','Location','northeast');
grid on;

% G5 — Évolution coût opératoire total
subplot(2,3,5);
% Coût total par tonne traitée
cout_total_t = energie_totale_sim * cout_kwh_val;
cout_main_oeuvre = 45;    % €/tonne (benchmark ADEME)
cout_reactifs    = 120;   % €/tonne (acides, réactifs)
cout_total_complet = cout_total_t + cout_main_oeuvre + cout_reactifs;

postes = {'Energie','Main oeuvre','Reactifs','Total'};
couts  = [cout_total_t, cout_main_oeuvre, cout_reactifs, cout_total_complet];
b_op = bar(couts, 'FaceColor', 'flat');
b_op.CData = [0.2 0.5 0.9; 0.9 0.6 0.1; 0.9 0.3 0.1; 0.3 0.7 0.4];
set(gca, 'XTickLabel', postes);
ylabel('Cout [EUR/tonne]');
title('Cout operatoire complet','FontWeight','bold');
grid on;

% G6 — Récapitulatif
subplot(2,3,6);
axis off;
texte_en = {
    sprintf('Energie broyage    : %d kWh/t',   42);
    sprintf('Energie tri+sep    : %d kWh/t',   14);
    sprintf('Energie hydromet   : %d kWh/t',   1250);
    sprintf('Energie TOTALE     : %d kWh/t',   energie_totale_sim);
    sprintf('Cout energie       : %.1f EUR/t',  cout_total_t);
    sprintf('Cout main oeuvre   : %d EUR/t',    cout_main_oeuvre);
    sprintf('Cout reactifs      : %d EUR/t',    cout_reactifs);
    sprintf('COUT TOTAL         : %.1f EUR/t',  cout_total_complet);
    sprintf('Objectif energie   : %d kWh/t',   objectif_energie);
    };
for i = 1:length(texte_en)
    text(0.02, 1-i*0.10, texte_en{i}, 'FontName','Courier', ...
        'FontSize', 9, 'Units','normalized');
end
title('Recapitulatif bilan energetique','FontWeight','bold');

sgtitle('Bilan Energetique Global-Centre de tri DEEE',...
    'FontSize', 14, 'FontWeight', 'bold');
%% FIGURE 6-Impact récupération de chaleur (3 sources)
figure('Name','Recuperation Chaleur DEEE','Position',[50 50 1400 700]);

% PARAMÈTRES DE CALCUL
eta_ech          = 0.75;    % rendement échangeur lixiviation
Cp               = 4.18;    % kJ/kg.°C
T_eff            = 65.0;    % °C température effluent lixiviation
T_res            = 20.0;    % °C température eau réseau
vol_moy          = 4.0;     % L/kg matière traitée
cout_kwh_val     = 0.12;    % EUR/kWh tarif industriel France 2024
tonnes_an        = 55000;   % t/an référence Veolia Angers
objectif_energie = 850;     % kWh/t objectif sectoriel

% CALCUL RÉCUPÉRATION PAR SOURCE
% Source 1 — Lixiviation (échangeur sur effluents chauds)
Q_recup_lixiv = eta_ech * vol_moy * Cp * (T_eff - T_res) / 3600 * 1000;

% Source 2-Précipitation (chaleur de réaction exothermique)
% Cémentation Cu : ΔH = -210 kJ/mol, masse molaire Cu = 63.5 g/mol
% Teneur Cu moyenne : 2.5e-4 kg/entité × 760 entités / masse totale
eta_recup_precip = 0.60;
Q_recup_precip   = eta_recup_precip * 30;   % kWh/tonne estimé

% Source 3 - Électrolyse (effet Joule = 30% énergie dissipée en chaleur)
eta_recup_electro = 0.65;
Q_recup_electro   = eta_recup_electro * 0.30 * 350;   % kWh/tonne

% Total récupéré
Q_recup_total = Q_recup_lixiv + Q_recup_precip + Q_recup_electro;

% Bilans énergétiques
total_sans = 1306;   % kWh/t sans récupération
total_avec = total_sans - Q_recup_total;

% Bilans détaillés par poste
hydromet_sans = 1250;
hydromet_avec = hydromet_sans - Q_recup_total;

% Économies
eco_kwh_an  = Q_recup_total * tonnes_an;
eco_euro_an = eco_kwh_an * cout_kwh_val;
reduction_CO2 = eco_kwh_an * 0.0571 / 1000;   % tCO2 mix électrique FR

% G1 — Énergie avant/après récupération par source
subplot(2,3,1);
categories_rec = {'Sans recup','Lixiv seul','Lixiv+Precip','3 sources'};
vals_comp = [1250, ...
             1250 - Q_recup_lixiv, ...
             1250 - Q_recup_lixiv - Q_recup_precip, ...
             1250 - Q_recup_total];
b_rec = bar(vals_comp, 'FaceColor', 'flat');
b_rec.CData = [0.9 0.3 0.1; 0.9 0.6 0.1; 0.6 0.8 0.2; 0.3 0.8 0.4];
set(gca, 'XTickLabel', categories_rec, 'XTickLabelRotation', 15);
ylabel('Energie hydromet [kWh/t]');
title('Impact cumulatif des 3 sources de recuperation','FontWeight','bold');
yline(objectif_energie, 'r--', sprintf('Objectif %d kWh/t', objectif_energie), ...
    'LineWidth', 1.5);
grid on;
for i = 1:4
    text(i, vals_comp(i)+15, sprintf('%.0f', vals_comp(i)), ...
        'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
end

% G2 — Répartition des 3 sources de récupération
subplot(2,3,2);
sources_rec = [Q_recup_lixiv, Q_recup_precip, Q_recup_electro];
labels_rec  = {sprintf('Lixiviation\n%.0f kWh/t', Q_recup_lixiv), ...
               sprintf('Precipitation\n%.0f kWh/t', Q_recup_precip), ...
               sprintf('Electrolyse\n%.0f kWh/t', Q_recup_electro)};
couleurs_rec = [0.9 0.3 0.1; 0.9 0.6 0.1; 0.2 0.5 0.9];
pie(sources_rec, labels_rec);
colormap(couleurs_rec);
title(sprintf('Repartition recuperation totale\n%.0f kWh/t', Q_recup_total), ...
    'FontWeight','bold');

% G3 — Sensibilité au rendement échangeur lixiviation
subplot(2,3,3);
eta_scenarios = linspace(0.40, 0.95, 50);
Q_vs_eta      = eta_scenarios * vol_moy * Cp * (T_eff - T_res) / 3600 * 1000;
energie_vs_eta = 1250 - Q_vs_eta - Q_recup_precip - Q_recup_electro;
plot(eta_scenarios*100, energie_vs_eta, 'b-', 'LineWidth', 2);
hold on;
yline(objectif_energie, 'r--', sprintf('Objectif %d kWh/t', objectif_energie), ...
    'LineWidth', 1.5);
xline(eta_ech*100, 'g--', sprintf('Standard %.0f%%', eta_ech*100), ...
    'LineWidth', 1.2);
% Point d'atteinte de l'objectif
eta_objectif = interp1(energie_vs_eta, eta_scenarios*100, objectif_energie);
if ~isnan(eta_objectif)
    plot(eta_objectif, objectif_energie, 'r*', 'MarkerSize', 12, 'LineWidth', 2);
    text(eta_objectif+2, objectif_energie+20, ...
        sprintf('eta=%.0f%%', eta_objectif), 'Color', 'red', 'FontWeight','bold');
end
xlabel('Rendement echangeur lixiviation [%]');
ylabel('Energie nette [kWh/t]');
title('Sensibilite au rendement echangeur','FontWeight','bold');
grid on;

% G4 — Bilan global avant/après récupération
subplot(2,3,4);
labels_bilan = {'Broyage','Tri+Sep','Hydromet','TOTAL'};
vals_sans_bilan = [42, 14, hydromet_sans, total_sans];
vals_avec_bilan = [42, 14, hydromet_avec, total_avec];
b_comp = bar([vals_sans_bilan; vals_avec_bilan]', 'grouped');
b_comp(1).FaceColor = [0.9 0.3 0.1];
b_comp(2).FaceColor = [0.3 0.8 0.4];
set(gca, 'XTickLabel', labels_bilan);
ylabel('Energie [kWh/t]');
title('Bilan global avant/apres recuperation','FontWeight','bold');
legend('Sans recuperation','Avec recuperation','Location','northeast');
yline(objectif_energie, 'r--', 'Objectif', 'LineWidth', 1.5);
grid on;

% G5 — Bénéfices économiques et environnementaux annuels
subplot(2,3,5);
yyaxis left;
bar(1, eco_euro_an, 'FaceColor', [0.3 0.8 0.4], 'BarWidth', 0.4);
ylabel('Economie annuelle [EUR]');
ylim([0, eco_euro_an * 1.3]);
text(1, eco_euro_an * 1.05, sprintf('%.0f EUR/an', eco_euro_an), ...
    'HorizontalAlignment','center','FontWeight','bold','Color','green');

yyaxis right;
bar(2, reduction_CO2, 'FaceColor', [0.2 0.5 0.9], 'BarWidth', 0.4);
ylabel('Reduction CO2 [tCO2/an]');
ylim([0, reduction_CO2 * 1.3]);
text(2, reduction_CO2 * 1.05, sprintf('%.1f tCO2/an', reduction_CO2), ...
    'HorizontalAlignment','center','FontWeight','bold','Color','cyan');

set(gca, 'XTick', [1 2], 'XTickLabel', {'Economie EUR','Reduction CO2'});
title(sprintf('Benefices annuels (base %d t/an)', tonnes_an), ...
    'FontWeight','bold');
grid on;

% G6 — Récapitulatif complet
subplot(2,3,6);
axis off;
texte_rec = {
    '--- Sources de recuperation ---';
    sprintf('Lixiviation (echangeur) : %.0f kWh/t',  Q_recup_lixiv);
    sprintf('Precipitation (reaction): %.0f kWh/t',  Q_recup_precip);
    sprintf('Electrolyse (Joule)     : %.0f kWh/t',  Q_recup_electro);
    sprintf('TOTAL recupere          : %.0f kWh/t',  Q_recup_total);
    '--- Bilan energetique ---';
    sprintf('Energie sans recup      : %.0f kWh/t',  total_sans);
    sprintf('Energie avec recup      : %.0f kWh/t',  total_avec);
    sprintf('Gain energetique        : %.0f kWh/t',  total_sans - total_avec);
    sprintf('Objectif sectoriel      : %d kWh/t',    objectif_energie);
    '--- Benefices annuels ---';
    sprintf('Economie financiere     : %.0f EUR/an',  eco_euro_an);
    sprintf('Reduction CO2           : %.1f tCO2/an', reduction_CO2);
   sprintf('Objectif atteint        : %s', ...
    char((total_avec <= objectif_energie) * 'OUI' + ...
         (total_avec > objectif_energie) * 'NON'));
};
for i = 1:length(texte_rec)
    if contains(texte_rec{i}, '---')
        text(0.02, 1-i*0.068, texte_rec{i}, 'FontName','Courier', ...
            'FontSize', 8, 'Units','normalized', ...
            'FontWeight','bold','Color',[0.3 0.7 0.9]);
    else
        text(0.02, 1-i*0.068, texte_rec{i}, 'FontName','Courier', ...
            'FontSize', 8, 'Units','normalized');
    end
end
title('Recapitulatif recuperation chaleur','FontWeight','bold');

sgtitle('Module de Recuperation de Chaleur-3 Sources/Centre de tri DEEE',...
    'FontSize', 14, 'FontWeight', 'bold');