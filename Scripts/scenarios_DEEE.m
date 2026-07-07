%% =========================================================
%  scenarios_DEEE.m — Analyse What-If
%  Centre de tri DEEE | MATLAB R2026a
% =========================================================
fprintf('=== Analyse What-If DEEE ===\n\n');

%% --- Définition des scénarios ---
MTBF_B1_vec = [40, 80, 120, 160, 200];  % h — valeurs fixes
n_sc        = length(MTBF_B1_vec);

% Initialisation structure résultats
resultats          = struct();
resultats.MTBF_B1  = zeros(1, n_sc);
resultats.OEE_B1   = zeros(1, n_sc);
resultats.dispo_B1 = zeros(1, n_sc);
resultats.taux_capt  = zeros(1, n_sc);
resultats.n_valorise = zeros(1, n_sc);
resultats.OEE_global = zeros(1, n_sc);

%% --- Boucle scénarios ---
for i = 1:n_sc

    % Sauvegarder la valeur AVANT params_DEEE
    val_MTBF = MTBF_B1_vec(i);

    % Chargement paramètres de base
    params_DEEE;

    % Restaurer les variables de la boucle après params_DEEE
    MTBF_B1_vec = [40, 80, 120, 160, 200];
    n_sc        = 5;

    % Appliquer la valeur du scénario
    MTBF_B1 = val_MTBF;
    D_B1    = MTBF_B1 / (MTBF_B1 + MTTR_B1);

    fprintf('Simulation scenario %d/5 — MTBF_B1 = %dh ...\n', i, val_MTBF);

    % Lancement simulation
    out_sc = sim('DEEE_centre_tri');

    % Extraction résultats
    try
        resultats.OEE_B1(i) = out_sc.logsout.getElement('OEE_B1').Values.Data(end) * 100;
    catch
        resultats.OEE_B1(i) = 0;
    end
    try
        resultats.dispo_B1(i) = out_sc.logsout.getElement('dispo_B1').Values.Data(end) * 100;
    catch
        resultats.dispo_B1(i) = 0;
    end
    try
        N_val = out_sc.n_fe.Data(end) + out_sc.n_plas.Data(end) + ...
                out_sc.n_verre.Data(end) + out_sc.n_hydromet.Data(end);
        N_ref = out_sc.n_refus.Data(end);
        resultats.taux_capt(i)  = N_val / max(N_val + N_ref, 1) * 100;
        resultats.n_valorise(i) = N_val;
    catch
        resultats.taux_capt(i)  = 0;
        resultats.n_valorise(i) = 0;
    end
    try
        resultats.OEE_global(i) = out_sc.OEE_data.Data(end) * 100;
    catch
        resultats.OEE_global(i) = 0;
    end

    resultats.MTBF_B1(i) = val_MTBF;

    fprintf('  → OEE_B1=%.1f%%  Dispo=%.1f%%  Captation=%.1f%%\n', ...
        resultats.OEE_B1(i), resultats.dispo_B1(i), resultats.taux_capt(i));
end

fprintf('\n=== Simulations terminees ===\n');

%% --- AFFICHAGE RÉSULTATS ---
MTBF_x = [40, 80, 120, 160, 200];
figure('Name','Analyse What-If DEEE','Position',[50 50 1400 700]);

% G1 — OEE Broyeur1 vs MTBF
subplot(2,3,1);
plot(MTBF_x, resultats.OEE_B1, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
yline(75, 'r--', 'Cible OEE 75%', 'LineWidth', 1.5);
xlabel('MTBF Broyeur1 [h]');
ylabel('OEE Broyeur1 [%]');
title('OEE Broyeur1 vs MTBF','FontWeight','bold');
ylim([60 110]); grid on;

% G2 — Disponibilité Broyeur1 vs MTBF
subplot(2,3,2);
plot(MTBF_x, resultats.dispo_B1, 'r-s', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
yline(93, 'g--', 'Cible 93%', 'LineWidth', 1.5);
xlabel('MTBF Broyeur1 [h]');
ylabel('Disponibilite [%]');
title('Disponibilite Broyeur1 vs MTBF','FontWeight','bold');
ylim([80 105]); grid on;

% G3 — Taux captation vs MTBF
subplot(2,3,3);
plot(MTBF_x, resultats.taux_capt, 'g-^', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
yline(91, 'r--', 'Cible 91%', 'LineWidth', 1.5);
xlabel('MTBF Broyeur1 [h]');
ylabel('Taux captation [%]');
title('Taux captation vs MTBF','FontWeight','bold');
ylim([80 100]); grid on;

% G4 — Entités valorisées vs MTBF
subplot(2,3,4);
bar(MTBF_x, resultats.n_valorise, 'FaceColor', [0.3 0.7 0.4]);
xlabel('MTBF Broyeur1 [h]');
ylabel('Entites valorisees');
title('Production valorisee vs MTBF','FontWeight','bold');
grid on;

% G5 — OEE global vs MTBF
subplot(2,3,5);
plot(MTBF_x, resultats.OEE_global, 'm-d', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
yline(75, 'r--', 'Cible 75%', 'LineWidth', 1.5);
xlabel('MTBF Broyeur1 [h]');
ylabel('OEE global [%]');
title('OEE global vs MTBF','FontWeight','bold');
ylim([60 110]); grid on;

% G6 — Tableau récapitulatif
subplot(2,3,6);
axis off;
header = sprintf('%-10s %-10s %-10s %-10s', 'MTBF[h]','OEE_B1%','Dispo%','Capt%');
text(0.02, 0.95, header, 'FontName','Courier','FontSize',9,...
    'Units','normalized','FontWeight','bold');
for i = 1:5
    ligne = sprintf('%-10d %-10.1f %-10.1f %-10.1f', ...
        MTBF_x(i), resultats.OEE_B1(i), ...
        resultats.dispo_B1(i), resultats.taux_capt(i));
    text(0.02, 0.95-i*0.13, ligne, 'FontName','Courier','FontSize',9,...
        'Units','normalized');
end
title('Recapitulatif scenarios','FontWeight','bold');

sgtitle('Analyse What-If — Impact MTBF Broyeur1 sur performance centre DEEE',...
    'FontSize', 13, 'FontWeight', 'bold');

fprintf('=== Dashboard what-if genere ===\n');