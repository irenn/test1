%% Improved WSN Energy Protocol with Two-Zone PCH (X-axis division)
% This protocol divides the network into two zones (x<50 and x>=50)
% Each zone has its own Permanent Cluster Head (PCH)
% This reduces transmission distances and balances energy consumption
clear all;
close all;
clc;
%% Network Parameters
n = 100;                    % Number of nodes
p = 0.05;                   % Percentage of cluster heads
Eo = 0.5;                   % Initial energy of nodes (J)
ETX = 50*10^-9;            % Energy for transmission (J/bit)
ERX = 50*10^-9;            % Energy for reception (J/bit)
Efs = 10*10^-12;           % Free space model (J/bit/m^2)
Emp = 0.0013*10^-12;       % Multipath model (J/bit/m^4)
EDA = 5*10^-9;             % Data aggregation energy (J/bit)
do = sqrt(Efs/Emp);        % Threshold distance
packetLength = 4000;       % Packet length (bits)
ctrPacketLength = 100;     % Control packet length (bits)
%% Network Dimensions
xm = 100;                   % X-dimension of network (m)
ym = 100;                   % Y-dimension of network (m)
zone_boundary = 50;         % X-coordinate boundary between zones
%% Base Station Location
BS.x = 50;                  % Base station X coordinate
BS.y = 175;                 % Base station Y coordinate (far from network)
%% Initialize Nodes
zone1_nodes = [];           % Nodes with x < 50
zone2_nodes = [];           % Nodes with x >= 50
for i = 1:n
    S(i).xd = rand(1,1)*xm;
    S(i).yd = rand(1,1)*ym;
    S(i).G = 0;
    S(i).E = Eo;
    S(i).type = 'N';        % Normal node
    S(i).d_to_BS = sqrt((S(i).xd - BS.x)^2 + (S(i).yd - BS.y)^2);
    % Assign to zones based on X coordinate
    if S(i).xd < zone_boundary
        S(i).zone = 1;
        zone1_nodes = [zone1_nodes i];
    else
        S(i).zone = 2;
        zone2_nodes = [zone2_nodes i];
    end
end
%% Select PCH for Zone 1 (x < 50) - Node closest to zone center
zone1_center_x = zone_boundary/2;
zone1_center_y = ym/2;
min_dist_z1 = inf;
PCH1_id = zone1_nodes(1);
for i = zone1_nodes
    dist_to_center = sqrt((S(i).xd - zone1_center_x)^2 + (S(i).yd - zone1_center_y)^2);
    if dist_to_center < min_dist_z1
        min_dist_z1 = dist_to_center;
        PCH1_id = i;
    end
end
S(PCH1_id).type = 'C';      % Set as PCH for Zone 1
S(PCH1_id).E = Eo * 2;      % Give PCH double energy
%% Select PCH for Zone 2 (x >= 50) - Node closest to zone center
zone2_center_x = zone_boundary + (xm - zone_boundary)/2;
zone2_center_y = ym/2;
min_dist_z2 = inf;
PCH2_id = zone2_nodes(1);
for i = zone2_nodes
    dist_to_center = sqrt((S(i).xd - zone2_center_x)^2 + (S(i).yd - zone2_center_y)^2);
    if dist_to_center < min_dist_z2
        min_dist_z2 = dist_to_center;
        PCH2_id = i;
    end
end
S(PCH2_id).type = 'C';      % Set as PCH for Zone 2
S(PCH2_id).E = Eo * 2;      % Give PCH double energy
fprintf('Zone 1 PCH (x < 50) located at: (%.2f, %.2f)\n', S(PCH1_id).xd, S(PCH1_id).yd);
fprintf('Zone 2 PCH (x >= 50) located at: (%.2f, %.2f)\n', S(PCH2_id).xd, S(PCH2_id).yd);
%% Simulation Parameters
rmax = 5000;                % Maximum rounds
transmissions = 0;
alive = n;
countCHs = 0;
dead = 0;
first_dead = 0;
total_energy = n * Eo;
%% Initialize result arrays
STATISTICS.DEAD = zeros(1, rmax);
STATISTICS.ALIVE = zeros(1, rmax);
STATISTICS.ENERGY = zeros(1, rmax);
STATISTICS.PACKETS = zeros(1, rmax);
STATISTICS.ZONE1_ENERGY = zeros(1, rmax);
STATISTICS.ZONE2_ENERGY = zeros(1, rmax);
%% Main Simulation Loop
for r = 1:rmax
    % Count alive and dead nodes
    alive = 0;
    dead = 0;
    total_energy_current = 0;
    zone1_energy = 0;
    zone2_energy = 0;
    for i = 1:n
        if S(i).E > 0
            alive = alive + 1;
            total_energy_current = total_energy_current + S(i).E;
            if S(i).zone == 1
                zone1_energy = zone1_energy + S(i).E;
            else
                zone2_energy = zone2_energy + S(i).E;
            end
        else
            dead = dead + 1;
        end
    end
    STATISTICS.DEAD(r) = dead;
    STATISTICS.ALIVE(r) = alive;
    STATISTICS.ENERGY(r) = total_energy_current;
    STATISTICS.ZONE1_ENERGY(r) = zone1_energy;
    STATISTICS.ZONE2_ENERGY(r) = zone2_energy;
    if first_dead == 0 && dead > 0
        first_dead = r;
        fprintf('First node died at round: %d\n', first_dead);
    end
    if alive == 0
        fprintf('All nodes dead at round: %d\n', r);
        break;
    end
    %% Data Transmission Phase
    % Zone 1 nodes (x < 50) send data to PCH1
    for i = zone1_nodes
        if S(i).E > 0 && i ~= PCH1_id
            distance = sqrt((S(i).xd - S(PCH1_id).xd)^2 + (S(i).yd - S(PCH1_id).yd)^2);
            if distance < do
                energy_tx = ETX * packetLength + Efs * packetLength * distance^2;
            else
                energy_tx = ETX * packetLength + Emp * packetLength * distance^4;
            end
            S(i).E = S(i).E - energy_tx;
            if S(i).E > 0
                S(PCH1_id).E = S(PCH1_id).E - ERX * packetLength - EDA * packetLength;
                transmissions = transmissions + 1;
            else
                S(i).E = 0;
            end
        end
    end
    % Zone 2 nodes (x >= 50) send data to PCH2
    for i = zone2_nodes
        if S(i).E > 0 && i ~= PCH2_id
            distance = sqrt((S(i).xd - S(PCH2_id).xd)^2 + (S(i).yd - S(PCH2_id).yd)^2);
            if distance < do
                energy_tx = ETX * packetLength + Efs * packetLength * distance^2;
            else
                energy_tx = ETX * packetLength + Emp * packetLength * distance^4;
            end
            S(i).E = S(i).E - energy_tx;
            if S(i).E > 0
                S(PCH2_id).E = S(PCH2_id).E - ERX * packetLength - EDA * packetLength;
                transmissions = transmissions + 1;
            else
                S(i).E = 0;
            end
        end
    end
    %% PCH1 sends aggregated data to BS
    if S(PCH1_id).E > 0
        distance_BS = S(PCH1_id).d_to_BS;
        if distance_BS < do
            energy_tx_BS = ETX * packetLength + Efs * packetLength * distance_BS^2;
        else
            energy_tx_BS = ETX * packetLength + Emp * packetLength * distance_BS^4;
        end
        S(PCH1_id).E = S(PCH1_id).E - energy_tx_BS;
        if S(PCH1_id).E < 0
            S(PCH1_id).E = 0;
        end
    end
    %% PCH2 sends aggregated data to BS
    if S(PCH2_id).E > 0
        distance_BS = S(PCH2_id).d_to_BS;
        if distance_BS < do
            energy_tx_BS = ETX * packetLength + Efs * packetLength * distance_BS^2;
        else
            energy_tx_BS = ETX * packetLength + Emp * packetLength * distance_BS^4;
        end
        S(PCH2_id).E = S(PCH2_id).E - energy_tx_BS;
        if S(PCH2_id).E < 0
            S(PCH2_id).E = 0;
        end
    end
    STATISTICS.PACKETS(r) = transmissions;
    % Display progress every 500 rounds
    if mod(r, 500) == 0
        fprintf('Round %d: Alive = %d, Dead = %d, Energy = %.2f J\n', ...
            r, alive, dead, total_energy_current);
    end
end
%% Save Results
save('two_zone_x_results.mat', 'STATISTICS', 'S', 'n', 'rmax', 'first_dead', ...
    'zone1_nodes', 'zone2_nodes', 'PCH1_id', 'PCH2_id');
%% Visualization

% Figure 1: Network Topology with Zones
figure(1);
hold on;
% Draw vertical zone boundary
plot([zone_boundary zone_boundary], [0 ym], 'k--', 'LineWidth', 2);
% Plot nodes
for i = 1:n
    if S(i).type == 'C'
        if S(i).zone == 1
            plot(S(i).xd, S(i).yd, 'r^', 'MarkerSize', 12, 'LineWidth', 2);
        else
            plot(S(i).xd, S(i).yd, 'm^', 'MarkerSize', 12, 'LineWidth', 2);
        end
    elseif S(i).E > 0
        if S(i).zone == 1
            plot(S(i).xd, S(i).yd, 'bo', 'MarkerSize', 6);
        else
            plot(S(i).xd, S(i).yd, 'co', 'MarkerSize', 6);
        end
    else
        plot(S(i).xd, S(i).yd, 'kx', 'MarkerSize', 6);
    end
end
plot(BS.x, BS.y, 'gs', 'MarkerSize', 15, 'LineWidth', 3);
text(zone_boundary-45, 95, 'Zone 1 (x < 50)', 'FontSize', 10, 'FontWeight', 'bold');
text(zone_boundary+5,  95, 'Zone 2 (x >= 50)', 'FontSize', 10, 'FontWeight', 'bold');
xlabel('X (m)');
ylabel('Y (m)');
title('Network Topology - Two-Zone PCH (X-axis split)');
legend('Zone Boundary', 'PCH1 (Zone 1)', 'PCH2 (Zone 2)', ...
    'Alive Z1', 'Alive Z2', 'Dead Nodes', 'Base Station');
grid on;
hold off;

% Figure 2: Alive vs Dead Nodes
figure(2);
plot(1:r, STATISTICS.ALIVE(1:r), 'b-', 'LineWidth', 2);
hold on;
plot(1:r, STATISTICS.DEAD(1:r), 'r-', 'LineWidth', 2);
xlabel('Rounds');
ylabel('Number of Nodes');
title('Node Lifetime');
legend('Alive Nodes', 'Dead Nodes');
grid on;
hold off;

% Figure 3: Total Network Energy
figure(3);
plot(1:r, STATISTICS.ENERGY(1:r), 'g-', 'LineWidth', 2);
xlabel('Rounds');
ylabel('Total Energy (J)');
title('Network Energy Consumption');
grid on;

% Figure 4: Zone Energy Distribution
figure(4);
plot(1:r, STATISTICS.ZONE1_ENERGY(1:r), 'r-', 'LineWidth', 2);
hold on;
plot(1:r, STATISTICS.ZONE2_ENERGY(1:r), 'm-', 'LineWidth', 2);
xlabel('Rounds');
ylabel('Energy (J)');
title('Energy Distribution by Zone');
legend('Zone 1 (x < 50)', 'Zone 2 (x >= 50)');
grid on;
hold off;

fprintf('\n=== Two-Zone PCH Protocol (X-axis) Summary ===\n');
fprintf('Total rounds simulated: %d\n', r);
fprintf('First node death: Round %d\n', first_dead);
fprintf('Final alive nodes: %d\n', alive);
fprintf('Total packets transmitted: %d\n', transmissions);
fprintf('Zone 1 nodes (x < 50): %d\n', length(zone1_nodes));
fprintf('Zone 2 nodes (x >= 50): %d\n', length(zone2_nodes));
fprintf('===============================================\n\n');
