%% compare_protocols.m
%
%  Overlays key metrics from both protocols on shared figures.
%
%  Workflow
%  --------
%    1. Run  two_zone_x_protocol.m    → generates two_zone_x_results.mat
%    2. Run  original_protocol_save.m → generates original_results.mat
%    3. Run  this script              → comparison figures
%
%  Note on fairness
%  ----------------
%  The two protocols start with different total network energy:
%    • Two-Zone X PCH : 98 nodes × 0.5 J + 2 PCH × 1 J  ≈  51 J
%    • Original        : 50 nodes × 0.5 J + 50 nodes × 2 J  = 125 J
%  Subplot (2,2,4) therefore shows *normalised* residual energy (%) so
%  that energy efficiency can be compared fairly.

clear; close all;

%% ── Verify files exist ───────────────────────────────────────────────────
if ~exist('two_zone_x_results.mat', 'file')
    error(['two_zone_x_results.mat not found.\n' ...
           'Run two_zone_x_protocol.m first.']);
end
if ~exist('original_results.mat', 'file')
    error(['original_results.mat not found.\n' ...
           'Run original_protocol_save.m first.']);
end

%% ── Load results into structs (avoids variable name collisions) ──────────
twoz = load('two_zone_x_results.mat');
orig = load('original_results.mat');

%% ── Prepare Two-Zone X data ─────────────────────────────────────────────
r2         = twoz.final_round_2z;
rounds_2z  = 1:r2;
alive_2z   = twoz.ALIVE_2Z(1:r2);
dead_2z    = twoz.DEAD_2Z(1:r2);
energy_2z  = twoz.ENERGY_2Z(1:r2);
fd_2z      = twoz.first_dead;          % round of first death (0 = none)

E_init_2z  = energy_2z(1);            % total initial energy of this run

%% ── Prepare Original data ────────────────────────────────────────────────
% CC(k) = alive nodes at round (k-1)  [k=1 → round 0]
cc_raw     = orig.CC(:)';             % flatten to row vector
et_raw     = orig.Et(:)';

% Keep only entries up to the last round a node was alive
last_alive = find(cc_raw > 0, 1, 'last');
if isempty(last_alive); last_alive = length(cc_raw); end

cc         = cc_raw(1:last_alive);
et         = et_raw(1:last_alive);
rounds_orig = 0:(last_alive - 1);    % round numbers: 0, 1, …
dead_orig   = orig.n - cc;
fd_orig     = orig.first_dead;

E_init_orig = et(1);

%% ── Comparison figure ────────────────────────────────────────────────────
fig = figure('Name', 'Protocol Comparison', 'Position', [50 50 1300 850]);

%% Subplot 1 — Alive Nodes over Time
subplot(2,2,1);
plot(rounds_2z,  alive_2z, 'b-', 'LineWidth', 2, ...
    'DisplayName', 'Two-Zone X PCH');
hold on;
plot(rounds_orig, cc, 'r-', 'LineWidth', 2, ...
    'DisplayName', 'Original Protocol');

% Mark first-death rounds with vertical dashed lines
if fd_2z > 0
    plot([fd_2z fd_2z], [0 twoz.n], 'b--', 'LineWidth', 1.4, ...
        'HandleVisibility', 'off');
    text(fd_2z + 5, twoz.n * 0.9, sprintf('2Z: R%d', fd_2z), ...
        'Color', 'b', 'FontSize', 8);
end
if fd_orig > 0
    plot([fd_orig fd_orig], [0 orig.n], 'r--', 'LineWidth', 1.4, ...
        'HandleVisibility', 'off');
    text(fd_orig + 5, orig.n * 0.8, sprintf('Orig: R%d', fd_orig), ...
        'Color', 'r', 'FontSize', 8);
end

xlabel('Rounds');  ylabel('Alive Nodes');
title('Network Lifetime');
legend('Location', 'southwest');
grid on;  hold off;

%% Subplot 2 — Residual Energy (absolute)
subplot(2,2,2);
plot(rounds_2z,  energy_2z, 'b-', 'LineWidth', 2, ...
    'DisplayName', 'Two-Zone X PCH');
hold on;
plot(rounds_orig, et, 'r-', 'LineWidth', 2, ...
    'DisplayName', 'Original Protocol');
xlabel('Rounds');  ylabel('Residual Energy (J)');
title('Network Residual Energy (absolute)');
legend('Location', 'northeast');
grid on;  hold off;

%% Subplot 3 — Dead Nodes over Time
subplot(2,2,3);
plot(rounds_2z,  dead_2z,  'b-', 'LineWidth', 2, ...
    'DisplayName', 'Two-Zone X PCH');
hold on;
plot(rounds_orig, dead_orig, 'r-', 'LineWidth', 2, ...
    'DisplayName', 'Original Protocol');
xlabel('Rounds');  ylabel('Dead Nodes');
title('Node Deaths Over Time');
legend('Location', 'northwest');
grid on;  hold off;

%% Subplot 4 — Normalised Residual Energy (fair comparison)
subplot(2,2,4);
norm_2z   = (energy_2z  / E_init_2z)   * 100;
norm_orig = (et          / E_init_orig) * 100;
plot(rounds_2z,  norm_2z,   'b-', 'LineWidth', 2, ...
    'DisplayName', 'Two-Zone X PCH');
hold on;
plot(rounds_orig, norm_orig, 'r-', 'LineWidth', 2, ...
    'DisplayName', 'Original Protocol');
xlabel('Rounds');  ylabel('Residual Energy (%)');
title({'Normalised Residual Energy', ...
       '(removes initial-energy bias, fair comparison)'});
legend('Location', 'northeast');
grid on;  hold off;

sgtitle('Protocol Comparison: Two-Zone X PCH  vs  Original', ...
    'FontSize', 13, 'FontWeight', 'bold');

%% ── Console summary ──────────────────────────────────────────────────────
fprintf('\n============================================================\n');
fprintf('                   COMPARISON SUMMARY                      \n');
fprintf('============================================================\n');
fprintf('%-38s  %12s  %12s\n', 'Metric', '2-Zone X PCH', 'Original');
fprintf('%-38s  %12d  %12d\n', 'First node death (round)', ...
    fd_2z, fd_orig);
fprintf('%-38s  %12d  %12d\n', 'Final alive nodes', ...
    alive_2z(end), cc(end));
fprintf('%-38s  %12d  %12d\n', 'Effective simulation duration (rounds)', ...
    r2, rounds_orig(end));
fprintf('%-38s  %12.3f  %12.3f\n', 'Initial total energy (J)', ...
    E_init_2z, E_init_orig);
fprintf('%-38s  %12d  %12d\n', 'Number of nodes', twoz.n, orig.n);
fprintf('============================================================\n');
fprintf('\n');
fprintf('NOTE: Initial energies differ by design:\n');
fprintf('  Two-Zone X PCH  : 98 nodes × 0.5 J + 2 PCH × 1 J  = %.1f J\n', E_init_2z);
fprintf('  Original        : 50 nodes × 0.5 J + 50 nodes × 2 J = %.1f J\n', E_init_orig);
fprintf('Use subplot (2,2,4) – normalised energy – for a fair\n');
fprintf('comparison of energy-consumption efficiency.\n\n');
