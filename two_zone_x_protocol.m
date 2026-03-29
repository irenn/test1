%% WSN Energy Protocol — Two-Zone PCH (X-coordinate based)
%
%  Network divided vertically: Zone 1 (X < 50) | Zone 2 (X >= 50)
%
%  Each round the alive node with the HIGHEST residual energy in each
%  zone is elected as PCH for that round.  The role therefore rotates
%  naturally among all nodes, spreading the relay cost evenly and
%  preventing any single node from burning out early.
%
%  All energy constants are identical to original_protocol_save.m so
%  results are directly comparable via compare_protocols.m.
%
%  Outputs
%    two_zone_x_results.mat  — loaded by compare_protocols.m
%    own 4-subplot figure

clear all; close all; clc;

%% ── Parameters (identical to original_protocol_save.m) ──────────────────
n            = 100;
Eo           = 0.5;           % J  — initial node energy
ETX          = 50e-9;         % J/bit
ERX          = 50e-9;
Efs          = 10e-12;        % J/bit/m²
Emp          = 0.0013e-12;    % J/bit/m⁴
EDA          = 5e-9;          % J/bit
do           = 87.7;          % threshold distance (m)
packetLength = 4000;          % bits
rmax         = 2000;

%% ── Network and Base Station ─────────────────────────────────────────────
xm = 100;  ym = 100;
zone_boundary = 50;           % vertical X-axis boundary

BS.x = 0.5 * xm;
BS.y = 1.75 * ym;

%% ── Initialise nodes ─────────────────────────────────────────────────────
zone1_nodes = [];   % X <  50
zone2_nodes = [];   % X >= 50

for i = 1:n
    S(i).xd     = rand() * xm;
    S(i).yd     = rand() * ym;
    S(i).E      = Eo;
    S(i).type   = 'N';
    S(i).d_to_BS = sqrt((S(i).xd - BS.x)^2 + (S(i).yd - BS.y)^2);

    if S(i).xd < zone_boundary
        S(i).zone = 1;
        zone1_nodes(end+1) = i;
    else
        S(i).zone = 2;
        zone2_nodes(end+1) = i;
    end
end

fprintf('Zone 1 (X <  50) : %d nodes\n', length(zone1_nodes));
fprintf('Zone 2 (X >= 50) : %d nodes\n', length(zone2_nodes));

%% ── Result arrays ────────────────────────────────────────────────────────
ALIVE_2Z   = zeros(1, rmax);
DEAD_2Z    = zeros(1, rmax);
ENERGY_2Z  = zeros(1, rmax);
PACKETS_2Z = zeros(1, rmax);

transmissions = 0;
first_dead    = 0;

%% ── Simulation loop ──────────────────────────────────────────────────────
for r = 1:rmax

    %% 1) Count alive / dead / total energy ───────────────────────────────
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

    %% 2) Elect PCH for each zone this round (highest residual energy) ────
    %  This rotation distributes the heavy relay cost across all nodes.
    PCH1 = 0;  maxE1 = 0;
    for i = zone1_nodes
        if S(i).E > maxE1
            maxE1 = S(i).E;
            PCH1  = i;
        end
    end

    PCH2 = 0;  maxE2 = 0;
    for i = zone2_nodes
        if S(i).E > maxE2
            maxE2 = S(i).E;
            PCH2  = i;
        end
    end

    %% 3) Zone-1 members → PCH1 ───────────────────────────────────────────
    if PCH1 > 0
        for i = zone1_nodes
            if S(i).E > 0 && i ~= PCH1
                d = sqrt((S(i).xd - S(PCH1).xd)^2 + (S(i).yd - S(PCH1).yd)^2);
                if d > do
                    e_tx = ETX*packetLength + Emp*packetLength*d^4;
                else
                    e_tx = ETX*packetLength + Efs*packetLength*d^2;
                end

                S(i).E = S(i).E - e_tx;
                if S(i).E <= 0
                    S(i).E = 0;
                else
                    % PCH receives and aggregates
                    S(PCH1).E = max(0, S(PCH1).E - (ERX + EDA)*packetLength);
                    transmissions = transmissions + 1;
                end
            end
        end

        % PCH1 forwards aggregated data to BS
        if S(PCH1).E > 0
            d_BS = S(PCH1).d_to_BS;
            if d_BS > do
                e_fwd = ETX*packetLength + Emp*packetLength*d_BS^4;
            else
                e_fwd = ETX*packetLength + Efs*packetLength*d_BS^2;
            end
            S(PCH1).E = max(0, S(PCH1).E - e_fwd);
        end
    end

    %% 4) Zone-2 members → PCH2 ───────────────────────────────────────────
    if PCH2 > 0
        for i = zone2_nodes
            if S(i).E > 0 && i ~= PCH2
                d = sqrt((S(i).xd - S(PCH2).xd)^2 + (S(i).yd - S(PCH2).yd)^2);
                if d > do
                    e_tx = ETX*packetLength + Emp*packetLength*d^4;
                else
                    e_tx = ETX*packetLength + Efs*packetLength*d^2;
                end

                S(i).E = S(i).E - e_tx;
                if S(i).E <= 0
                    S(i).E = 0;
                else
                    S(PCH2).E = max(0, S(PCH2).E - (ERX + EDA)*packetLength);
                    transmissions = transmissions + 1;
                end
            end
        end

        % PCH2 forwards aggregated data to BS
        if S(PCH2).E > 0
            d_BS = S(PCH2).d_to_BS;
            if d_BS > do
                e_fwd = ETX*packetLength + Emp*packetLength*d_BS^4;
            else
                e_fwd = ETX*packetLength + Efs*packetLength*d_BS^2;
            end
            S(PCH2).E = max(0, S(PCH2).E - e_fwd);
        end
    end

    PACKETS_2Z(r) = transmissions;

    if mod(r, 200) == 0
        fprintf('Round %4d | Alive: %3d | Dead: %3d | Energy: %.4f J\n', ...
            r, alive, dead, E_total);
    end
end

final_round_2z = r;

%% ── Save for compare_protocols.m ────────────────────────────────────────
save('two_zone_x_results.mat', ...
    'ALIVE_2Z', 'DEAD_2Z', 'ENERGY_2Z', 'PACKETS_2Z', ...
    'first_dead', 'final_round_2z', 'n', 'rmax',       ...
    'zone1_nodes', 'zone2_nodes', 'S', 'BS', 'xm', 'ym', 'zone_boundary');

fprintf('\nResults saved → two_zone_x_results.mat\n');
fprintf('Run compare_protocols.m to compare with original protocol.\n');

%% ── Protocol-specific figures ────────────────────────────────────────────
figure('Name', 'Two-Zone X PCH Protocol', 'Position', [100 100 1200 800]);

subplot(2,2,1); hold on;
plot([zone_boundary zone_boundary], [0 ym], 'k--', 'LineWidth', 2, ...
    'DisplayName', 'Zone Boundary');
for i = 1:n
    if S(i).E > 0 && S(i).zone == 1
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
fprintf('Total rounds simulated: %d\n', final_round_2z);
fprintf('First node death      : Round %d\n', first_dead);
fprintf('Final alive nodes     : %d\n', alive);
fprintf('Zone 1 (X < 50)       : %d nodes\n', length(zone1_nodes));
fprintf('Zone 2 (X >= 50)      : %d nodes\n', length(zone2_nodes));
fprintf('==============================\n');
