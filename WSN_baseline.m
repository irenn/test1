%% Baseline WSN Energy Protocol with Single PCH
% This protocol uses a single Permanent Cluster Head (PCH) for the entire network

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

%% Base Station Location
BS.x = 50;                  % Base station X coordinate
BS.y = 175;                 % Base station Y coordinate (far from network)

%% Initialize Nodes
for i = 1:n
    S(i).xd = rand(1,1)*xm;
    S(i).yd = rand(1,1)*ym;
    S(i).G = 0;
    S(i).E = Eo;
    S(i).type = 'N';        % Normal node
    S(i).d_to_BS = sqrt((S(i).xd - BS.x)^2 + (S(i).yd - BS.y)^2);
end

%% Single PCH Selection (Node closest to center)
center_x = xm/2;
center_y = ym/2;
min_dist = inf;
PCH_id = 1;

for i = 1:n
    dist_to_center = sqrt((S(i).xd - center_x)^2 + (S(i).yd - center_y)^2);
    if dist_to_center < min_dist
        min_dist = dist_to_center;
        PCH_id = i;
    end
end

S(PCH_id).type = 'C';       % Set as Permanent Cluster Head
S(PCH_id).E = Eo * 2;       % Give PCH double energy

fprintf('Single PCH located at: (%.2f, %.2f)\n', S(PCH_id).xd, S(PCH_id).yd);

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

%% Main Simulation Loop
for r = 1:rmax

    % Count alive and dead nodes
    alive = 0;
    dead = 0;
    total_energy_current = 0;

    for i = 1:n
        if S(i).E > 0
            alive = alive + 1;
            total_energy_current = total_energy_current + S(i).E;
        else
            dead = dead + 1;
        end
    end

    STATISTICS.DEAD(r) = dead;
    STATISTICS.ALIVE(r) = alive;
    STATISTICS.ENERGY(r) = total_energy_current;

    if first_dead == 0 && dead > 0
        first_dead = r;
        fprintf('First node died at round: %d\n', first_dead);
    end

    if alive == 0
        fprintf('All nodes dead at round: %d\n', r);
        break;
    end

    %% Data Transmission Phase
    % All nodes send data to PCH
    for i = 1:n
        if S(i).E > 0 && i ~= PCH_id
            % Calculate distance to PCH
            distance = sqrt((S(i).xd - S(PCH_id).xd)^2 + (S(i).yd - S(PCH_id).yd)^2);

            % Energy consumption for transmission
            if distance < do
                energy_tx = ETX * packetLength + Efs * packetLength * distance^2;
            else
                energy_tx = ETX * packetLength + Emp * packetLength * distance^4;
            end

            S(i).E = S(i).E - energy_tx;

            if S(i).E > 0
                % PCH receives data
                S(PCH_id).E = S(PCH_id).E - ERX * packetLength - EDA * packetLength;
                transmissions = transmissions + 1;
            else
                S(i).E = 0;
            end
        end
    end

    %% PCH sends aggregated data to BS
    if S(PCH_id).E > 0
        distance_BS = S(PCH_id).d_to_BS;

        if distance_BS < do
            energy_tx_BS = ETX * packetLength + Efs * packetLength * distance_BS^2;
        else
            energy_tx_BS = ETX * packetLength + Emp * packetLength * distance_BS^4;
        end

        S(PCH_id).E = S(PCH_id).E - energy_tx_BS;

        if S(PCH_id).E < 0
            S(PCH_id).E = 0;
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
save('baseline_results.mat', 'STATISTICS', 'S', 'n', 'rmax', 'first_dead');

%% Visualization
figure('Position', [100, 100, 1200, 800]);

% Plot 1: Network Topology
subplot(2, 2, 1);
hold on;
for i = 1:n
    if S(i).type == 'C'
        plot(S(i).xd, S(i).yd, 'r^', 'MarkerSize', 12, 'LineWidth', 2);
    elseif S(i).E > 0
        plot(S(i).xd, S(i).yd, 'bo', 'MarkerSize', 6);
    else
        plot(S(i).xd, S(i).yd, 'kx', 'MarkerSize', 6);
    end
end
plot(BS.x, BS.y, 'gs', 'MarkerSize', 15, 'LineWidth', 3);
xlabel('X (m)');
ylabel('Y (m)');
title('Network Topology - Baseline (Single PCH)');
legend('PCH', 'Alive Nodes', 'Dead Nodes', 'Base Station');
grid on;
hold off;

% Plot 2: Alive vs Dead Nodes
subplot(2, 2, 2);
plot(1:r, STATISTICS.ALIVE(1:r), 'b-', 'LineWidth', 2);
hold on;
plot(1:r, STATISTICS.DEAD(1:r), 'r-', 'LineWidth', 2);
xlabel('Rounds');
ylabel('Number of Nodes');
title('Node Lifetime');
legend('Alive Nodes', 'Dead Nodes');
grid on;
hold off;

% Plot 3: Total Network Energy
subplot(2, 2, 3);
plot(1:r, STATISTICS.ENERGY(1:r), 'g-', 'LineWidth', 2);
xlabel('Rounds');
ylabel('Total Energy (J)');
title('Network Energy Consumption');
grid on;

% Plot 4: Packets Transmitted
subplot(2, 2, 4);
plot(1:r, STATISTICS.PACKETS(1:r), 'm-', 'LineWidth', 2);
xlabel('Rounds');
ylabel('Packets Transmitted');
title('Data Transmission');
grid on;

sgtitle('Baseline WSN Protocol - Single PCH');

fprintf('\n=== Baseline Protocol Summary ===\n');
fprintf('Total rounds simulated: %d\n', r);
fprintf('First node death: Round %d\n', first_dead);
fprintf('Final alive nodes: %d\n', alive);
fprintf('Total packets transmitted: %d\n', transmissions);
fprintf('================================\n\n');
