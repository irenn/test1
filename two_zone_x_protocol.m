%% WSN Energy Protocol — Two-Zone PCH (X-coordinate based)
%
%  Zone 1 : X <  50  →  PCH1 (fixed, closest to zone centre)
%  Zone 2 : X >= 50  →  PCH2 (fixed, closest to zone centre)
%
%  Energy parameters are kept identical to original_protocol_save.m so
%  that the two simulations can be compared with compare_protocols.m.
%
%  Outputs
%    two_zone_x_results.mat  — loaded by compare_protocols.m
%    own 4-subplot figure

clear all; close all; clc;

%% ── Parameters (match original protocol) ────────────────────────────────
n            = 100;
Eo           = 0.5;            % Initial node energy (J)
ETX          = 50e-9;          % Tx electronics (J/bit)
ERX          = 50e-9;          % Rx electronics (J/bit)
Efs          = 10e-12;         % Free-space amp  (J/bit/m²)
Emp          = 0.0013e-12;     % Multipath amp   (J/bit/m⁴)
EDA          = 5e-9;           % Data aggregation (J/bit)
do           = 87.7;           % Threshold distance (m)  — same as original
packetLength = 4000;           % bits
rmax         = 2000;           % rounds — same as original

%% ── Network & Base Station ───────────────────────────────────────────────
xm = 100; ym = 100;
zone_boundary = 50;            % X-axis boundary between zones

BS.x = 0.5 * xm;
BS.y = 1.75 * ym;

%% ── Initialise Nodes ─────────────────────────────────────────────────────
zone1_nodes = [];   % X <  50
zone2_nodes = [];   % X >= 50

for i = 1:n
    S(i).xd     = rand() * xm;
    S(i).yd     = rand() * ym;
    S(i).E      = Eo;
    S(i).G      = 0;
    S(i).type   = 'N';
    S(i).d_to_BS = sqrt((S(i).xd - BS.x)^2 + (S(i).yd - BS.y)^2);

    if S(i).xd < zone_boundary
        S(i).zone   = 1;
        zone1_nodes(end+1) = i;
    else
        S(i).zone   = 2;
        zone2_nodes(end+1) = i;
    end
end

%% ── Select PCH1 — zone 1 node closest to zone centre ────────────────────
cx1 = zone_boundary / 2;   cy1 = ym / 2;   % centre of Zone 1
min_d1 = inf;   PCH1_id = zone1_nodes(1);
for i = zone1_nodes
    d = sqrt((S(i).xd - cx1)^2 + (S(i).yd - cy1)^2);
    if d < min_d1;  min_d1 = d;  PCH1_id = i;  end
end
S(PCH1_id).type = 'C';
S(PCH1_id).E    = 2 * Eo;   % double energy as PCH

%% ── Select PCH2 — zone 2 node closest to zone centre ────────────────────
cx2 = zone_boundary + (xm - zone_boundary) / 2;   cy2 = ym / 2;
min_d2 = inf;   PCH2_id = zone2_nodes(1);
for i = zone2_nodes
    d = sqrt((S(i).xd - cx2)^2 + (S(i).yd - cy2)^2);
    if d < min_d2;  min_d2 = d;  PCH2_id = i;  end
end
S(PCH2_id).type = 'C';
S(PCH2_id).E    = 2 * Eo;

fprintf('PCH1 (X < 50)  at (%.2f, %.2f)\n', S(PCH1_id).xd, S(PCH1_id).yd);
fprintf('PCH2 (X >= 50) at (%.2f, %.2f)\n', S(PCH2_id).xd, S(PCH2_id).yd);

%% ── Result arrays ────────────────────────────────────────────────────────
ALIVE_2Z   = zeros(1, rmax);
DEAD_2Z    = zeros(1, rmax);
ENERGY_2Z  = zeros(1, rmax);
PACKETS_2Z = zeros(1, rmax);

transmissions = 0;
first_dead    = 0;

%% ── Main Simulation Loop ─────────────────────────────────────────────────
for r = 1:rmax

    %% Count alive / dead / energy
    alive = 0;  dead = 0;  E_total = 0;
    for i = 1:n
        if S(i).E > 0
            alive   = alive   + 1;
            E_total = E_total + S(i).E;
        else
            dead = dead + 1;
        end
    end

    ALIVE_2Z(r)  = alive;
    DEAD_2Z(r)   = dead;
    ENERGY_2Z(r) = E_total;

    if first_dead == 0 && dead > 0
        first_dead = r;
        fprintf('First node died at round %d\n', r);
    end

    if alive == 0
        fprintf('All nodes dead at round %d\n', r);
        break;
    end

    %% Zone-1 nodes transmit to PCH1
    for i = zone1_nodes
        if S(i).E > 0 && i ~= PCH1_id && S(PCH1_id).E > 0
            d = sqrt((S(i).xd - S(PCH1_id).xd)^2 + (S(i).yd - S(PCH1_id).yd)^2);
            if d <= do
                e_tx = ETX * packetLength + Efs * packetLength * d^2;
            else
                e_tx = ETX * packetLength + Emp * packetLength * d^4;
            end
            S(i).E = S(i).E - e_tx;
            if S(i).E <= 0
                S(i).E = 0;
            else
                S(PCH1_id).E = S(PCH1_id).E - (ERX + EDA) * packetLength;
                transmissions = transmissions + 1;
            end
        end
    end

    %% Zone-2 nodes transmit to PCH2
    for i = zone2_nodes
        if S(i).E > 0 && i ~= PCH2_id && S(PCH2_id).E > 0
            d = sqrt((S(i).xd - S(PCH2_id).xd)^2 + (S(i).yd - S(PCH2_id).yd)^2);
            if d <= do
                e_tx = ETX * packetLength + Efs * packetLength * d^2;
            else
                e_tx = ETX * packetLength + Emp * packetLength * d^4;
            end
            S(i).E = S(i).E - e_tx;
            if S(i).E <= 0
                S(i).E = 0;
            else
                S(PCH2_id).E = S(PCH2_id).E - (ERX + EDA) * packetLength;
                transmissions = transmissions + 1;
            end
        end
    end

    %% PCH1 sends aggregated data to BS
    if S(PCH1_id).E > 0
        d_BS = S(PCH1_id).d_to_BS;
        if d_BS <= do
            e_tx = ETX * packetLength + Efs * packetLength * d_BS^2;
        else
            e_tx = ETX * packetLength + Emp * packetLength * d_BS^4;
        end
        S(PCH1_id).E = max(0, S(PCH1_id).E - e_tx);
    end

    %% PCH2 sends aggregated data to BS
    if S(PCH2_id).E > 0
        d_BS = S(PCH2_id).d_to_BS;
        if d_BS <= do
            e_tx = ETX * packetLength + Efs * packetLength * d_BS^2;
        else
            e_tx = ETX * packetLength + Emp * packetLength * d_BS^4;
        end
        S(PCH2_id).E = max(0, S(PCH2_id).E - e_tx);
    end

    PACKETS_2Z(r) = transmissions;

    if mod(r, 500) == 0
        fprintf('Round %4d | Alive: %3d | Dead: %3d | Energy: %.4f J\n', ...
            r, alive, dead, E_total);
    end
end

final_round_2z = r;

%% ── Save for compare_protocols.m ────────────────────────────────────────
save('two_zone_x_results.mat', ...
    'ALIVE_2Z', 'DEAD_2Z', 'ENERGY_2Z', 'PACKETS_2Z', ...
    'first_dead', 'final_round_2z', 'n', 'rmax',       ...
    'zone1_nodes', 'zone2_nodes', 'PCH1_id', 'PCH2_id', ...
    'S', 'BS', 'xm', 'ym', 'zone_boundary');

fprintf('\nResults saved → two_zone_x_results.mat\n');
fprintf('Run compare_protocols.m to compare with original protocol.\n');

%% ── Protocol-specific figures ────────────────────────────────────────────
figure('Name', 'Two-Zone X PCH Protocol', 'Position', [100 100 1200 800]);

subplot(2,2,1); hold on;
% Vertical zone boundary
plot([zone_boundary zone_boundary], [0 ym], 'k--', 'LineWidth', 2, ...
    'DisplayName', 'Zone Boundary');
for i = 1:n
    if i == PCH1_id
        plot(S(i).xd, S(i).yd, 'r^', 'MarkerSize', 14, 'LineWidth', 2, ...
            'DisplayName', 'PCH1 (X<50)');
    elseif i == PCH2_id
        plot(S(i).xd, S(i).yd, 'm^', 'MarkerSize', 14, 'LineWidth', 2, ...
            'DisplayName', 'PCH2 (X>=50)');
    elseif S(i).E > 0 && S(i).zone == 1
        plot(S(i).xd, S(i).yd, 'bo', 'MarkerSize', 5, 'HandleVisibility', 'off');
    elseif S(i).E > 0 && S(i).zone == 2
        plot(S(i).xd, S(i).yd, 'co', 'MarkerSize', 5, 'HandleVisibility', 'off');
    else
        plot(S(i).xd, S(i).yd, 'kx', 'MarkerSize', 5, 'HandleVisibility', 'off');
    end
end
plot(BS.x, BS.y, 'gs', 'MarkerSize', 15, 'LineWidth', 3, 'DisplayName', 'Base Station');
text(2,  95, 'Zone 1 (X<50)',  'Color', 'b', 'FontWeight', 'bold', 'FontSize', 9);
text(52, 95, 'Zone 2 (X>=50)', 'Color', 'c', 'FontWeight', 'bold', 'FontSize', 9);
xlabel('X (m)'); ylabel('Y (m)'); title('Network Topology (final state)');
legend('Location', 'best'); grid on; hold off;

subplot(2,2,2);
plot(1:final_round_2z, ALIVE_2Z(1:final_round_2z), 'b-', 'LineWidth', 2); hold on;
plot(1:final_round_2z, DEAD_2Z(1:final_round_2z),  'r-', 'LineWidth', 2); hold off;
xlabel('Rounds'); ylabel('Number of Nodes');
title('Node Lifetime'); legend('Alive', 'Dead'); grid on;

subplot(2,2,3);
plot(1:final_round_2z, ENERGY_2Z(1:final_round_2z), 'g-', 'LineWidth', 2);
xlabel('Rounds'); ylabel('Residual Energy (J)');
title('Network Residual Energy'); grid on;

subplot(2,2,4);
plot(1:final_round_2z, PACKETS_2Z(1:final_round_2z), 'b-', 'LineWidth', 2);
xlabel('Rounds'); ylabel('Cumulative Transmissions');
title('Packets Transmitted'); grid on;

sgtitle('Two-Zone X PCH Protocol', 'FontSize', 13, 'FontWeight', 'bold');

fprintf('\n=== Two-Zone X PCH Summary ===\n');
fprintf('Total rounds simulated : %d\n', final_round_2z);
fprintf('First node death       : Round %d\n', first_dead);
fprintf('Final alive nodes      : %d\n', alive);
fprintf('Zone 1 (X<50)          : %d nodes\n', length(zone1_nodes));
fprintf('Zone 2 (X>=50)         : %d nodes\n', length(zone2_nodes));
fprintf('==============================\n');
