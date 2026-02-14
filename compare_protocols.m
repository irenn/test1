%% Comparison Script for Baseline vs Two-Zone PCH Protocols
% This script runs both protocols and generates comprehensive comparison graphs

clear all;
close all;
clc;

fprintf('====================================\n');
fprintf('WSN Protocol Comparison Analysis\n');
fprintf('====================================\n\n');

fprintf('Running Baseline Protocol (Single PCH)...\n');
run('WSN_baseline.m');
close all;

% Load baseline results
load('baseline_results.mat');
baseline_stats = STATISTICS;
baseline_first_dead = first_dead;
baseline_final_round = find(baseline_stats.ALIVE > 0, 1, 'last');

fprintf('\nRunning Two-Zone PCH Protocol...\n');
run('WSN_two_zone_PCH.m');
close all;

% Load two-zone results
load('two_zone_results.mat');
twozone_stats = STATISTICS;
twozone_first_dead = first_dead;
twozone_final_round = find(twozone_stats.ALIVE > 0, 1, 'last');

%% Generate Comparison Plots
figure('Position', [50, 50, 1400, 900]);

% Plot 1: Alive Nodes Comparison
subplot(2, 3, 1);
plot(1:baseline_final_round, baseline_stats.ALIVE(1:baseline_final_round), 'r-', 'LineWidth', 2);
hold on;
plot(1:twozone_final_round, twozone_stats.ALIVE(1:twozone_final_round), 'b-', 'LineWidth', 2);
xlabel('Rounds', 'FontSize', 11);
ylabel('Number of Alive Nodes', 'FontSize', 11);
title('Alive Nodes Over Time', 'FontSize', 12, 'FontWeight', 'bold');
legend('Baseline (Single PCH)', 'Two-Zone PCH', 'Location', 'best');
grid on;
hold off;

% Plot 2: Dead Nodes Comparison
subplot(2, 3, 2);
plot(1:baseline_final_round, baseline_stats.DEAD(1:baseline_final_round), 'r-', 'LineWidth', 2);
hold on;
plot(1:twozone_final_round, twozone_stats.DEAD(1:twozone_final_round), 'b-', 'LineWidth', 2);
xlabel('Rounds', 'FontSize', 11);
ylabel('Number of Dead Nodes', 'FontSize', 11);
title('Dead Nodes Over Time', 'FontSize', 12, 'FontWeight', 'bold');
legend('Baseline (Single PCH)', 'Two-Zone PCH', 'Location', 'best');
grid on;
hold off;

% Plot 3: Total Energy Comparison
subplot(2, 3, 3);
plot(1:baseline_final_round, baseline_stats.ENERGY(1:baseline_final_round), 'r-', 'LineWidth', 2);
hold on;
plot(1:twozone_final_round, twozone_stats.ENERGY(1:twozone_final_round), 'b-', 'LineWidth', 2);
xlabel('Rounds', 'FontSize', 11);
ylabel('Total Network Energy (J)', 'FontSize', 11);
title('Energy Consumption Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Baseline (Single PCH)', 'Two-Zone PCH', 'Location', 'best');
grid on;
hold off;

% Plot 4: Energy Efficiency (Energy per Round)
subplot(2, 3, 4);
baseline_energy_per_round = -diff(baseline_stats.ENERGY(1:baseline_final_round));
twozone_energy_per_round = -diff(twozone_stats.ENERGY(1:twozone_final_round));

plot(1:length(baseline_energy_per_round), ...
    movmean(baseline_energy_per_round, 50), 'r-', 'LineWidth', 2);
hold on;
plot(1:length(twozone_energy_per_round), ...
    movmean(twozone_energy_per_round, 50), 'b-', 'LineWidth', 2);
xlabel('Rounds', 'FontSize', 11);
ylabel('Energy Consumption per Round (J)', 'FontSize', 11);
title('Energy Efficiency (50-round moving average)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Baseline (Single PCH)', 'Two-Zone PCH', 'Location', 'best');
grid on;
hold off;

% Plot 5: Packet Transmission Comparison
subplot(2, 3, 5);
plot(1:baseline_final_round, baseline_stats.PACKETS(1:baseline_final_round), 'r-', 'LineWidth', 2);
hold on;
plot(1:twozone_final_round, twozone_stats.PACKETS(1:twozone_final_round), 'b-', 'LineWidth', 2);
xlabel('Rounds', 'FontSize', 11);
ylabel('Total Packets Transmitted', 'FontSize', 11);
title('Data Transmission Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Baseline (Single PCH)', 'Two-Zone PCH', 'Location', 'best');
grid on;
hold off;

% Plot 6: Performance Metrics Bar Chart
subplot(2, 3, 6);
metrics = [baseline_first_dead, twozone_first_dead;
           baseline_final_round, twozone_final_round;
           baseline_stats.PACKETS(baseline_final_round), twozone_stats.PACKETS(twozone_final_round)];

b = bar(metrics', 'grouped');
b(1).FaceColor = [0.8 0.2 0.2];
b(2).FaceColor = [0.2 0.4 0.8];

set(gca, 'XTickLabel', {'First Node Death', 'Network Lifetime', 'Total Packets'});
ylabel('Value', 'FontSize', 11);
title('Key Performance Metrics', 'FontSize', 12, 'FontWeight', 'bold');
legend('Baseline (Single PCH)', 'Two-Zone PCH', 'Location', 'best');
grid on;
xtickangle(15);

sgtitle('WSN Protocol Comparison: Baseline vs Two-Zone PCH', ...
    'FontSize', 14, 'FontWeight', 'bold');

%% Calculate and Display Improvement Metrics
fprintf('\n====================================\n');
fprintf('COMPARATIVE PERFORMANCE ANALYSIS\n');
fprintf('====================================\n\n');

fprintf('--- Network Lifetime ---\n');
fprintf('Baseline First Node Death: Round %d\n', baseline_first_dead);
fprintf('Two-Zone First Node Death: Round %d\n', twozone_first_dead);
improvement_fnd = ((twozone_first_dead - baseline_first_dead) / baseline_first_dead) * 100;
fprintf('Improvement: %.2f%%\n\n', improvement_fnd);

fprintf('--- Total Network Lifetime ---\n');
fprintf('Baseline Final Round: %d\n', baseline_final_round);
fprintf('Two-Zone Final Round: %d\n', twozone_final_round);
improvement_lifetime = ((twozone_final_round - baseline_final_round) / baseline_final_round) * 100;
fprintf('Improvement: %.2f%%\n\n', improvement_lifetime);

fprintf('--- Data Transmission ---\n');
fprintf('Baseline Total Packets: %d\n', baseline_stats.PACKETS(baseline_final_round));
fprintf('Two-Zone Total Packets: %d\n', twozone_stats.PACKETS(twozone_final_round));
improvement_packets = ((twozone_stats.PACKETS(twozone_final_round) - ...
    baseline_stats.PACKETS(baseline_final_round)) / ...
    baseline_stats.PACKETS(baseline_final_round)) * 100;
fprintf('Improvement: %.2f%%\n\n', improvement_packets);

fprintf('--- Energy Efficiency ---\n');
avg_baseline_energy = mean(baseline_energy_per_round);
avg_twozone_energy = mean(twozone_energy_per_round);
fprintf('Baseline Avg Energy/Round: %.6f J\n', avg_baseline_energy);
fprintf('Two-Zone Avg Energy/Round: %.6f J\n', avg_twozone_energy);
improvement_efficiency = ((avg_baseline_energy - avg_twozone_energy) / avg_baseline_energy) * 100;
fprintf('Energy Saving: %.2f%%\n\n', improvement_efficiency);

fprintf('====================================\n\n');

%% Generate Summary Table
fprintf('SUMMARY TABLE:\n');
fprintf('%-30s | %-15s | %-15s | %-15s\n', 'Metric', 'Baseline', 'Two-Zone', 'Improvement');
fprintf('----------------------------------------------------------------\n');
fprintf('%-30s | %-15d | %-15d | %+.2f%%\n', 'First Node Death (rounds)', ...
    baseline_first_dead, twozone_first_dead, improvement_fnd);
fprintf('%-30s | %-15d | %-15d | %+.2f%%\n', 'Network Lifetime (rounds)', ...
    baseline_final_round, twozone_final_round, improvement_lifetime);
fprintf('%-30s | %-15d | %-15d | %+.2f%%\n', 'Total Packets', ...
    baseline_stats.PACKETS(baseline_final_round), ...
    twozone_stats.PACKETS(twozone_final_round), improvement_packets);
fprintf('%-30s | %-15.6f | %-15.6f | %+.2f%%\n', 'Avg Energy/Round (J)', ...
    avg_baseline_energy, avg_twozone_energy, improvement_efficiency);
fprintf('----------------------------------------------------------------\n\n');

%% Save comparison figure
saveas(gcf, 'protocol_comparison.png');
fprintf('Comparison figure saved as: protocol_comparison.png\n\n');

%% Additional Energy Distribution Plot (Two-Zone specific)
if exist('STATISTICS', 'var') && isfield(STATISTICS, 'ZONE1_ENERGY')
    figure('Position', [100, 100, 800, 600]);

    plot(1:twozone_final_round, twozone_stats.ZONE1_ENERGY(1:twozone_final_round), ...
        'r-', 'LineWidth', 2.5);
    hold on;
    plot(1:twozone_final_round, twozone_stats.ZONE2_ENERGY(1:twozone_final_round), ...
        'b-', 'LineWidth', 2.5);
    plot(1:twozone_final_round, twozone_stats.ENERGY(1:twozone_final_round), ...
        'k--', 'LineWidth', 2);

    xlabel('Rounds', 'FontSize', 12);
    ylabel('Energy (J)', 'FontSize', 12);
    title('Energy Distribution Across Zones (Two-Zone PCH)', ...
        'FontSize', 13, 'FontWeight', 'bold');
    legend('Zone 1 (y < 50)', 'Zone 2 (y >= 50)', 'Total Energy', ...
        'Location', 'best', 'FontSize', 11);
    grid on;
    hold off;

    saveas(gcf, 'zone_energy_distribution.png');
    fprintf('Zone energy distribution saved as: zone_energy_distribution.png\n\n');
end

fprintf('====================================\n');
fprintf('Analysis Complete!\n');
fprintf('====================================\n');
