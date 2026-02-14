%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%         Comparison Script: Original vs Improved Two-Zone PCH        %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;

fprintf('===============================================\n');
fprintf('   WSN PROTOCOL COMPARISON ANALYSIS\n');
fprintf('   Original Single PCH vs Two-Zone PCH\n');
fprintf('===============================================\n\n');

fprintf('Running Original Single PCH Protocol...\n');
run('Original_WSN_Single_PCH.m');
close all;

% Load original results
load('original_single_pch_results.mat');
orig_stats = STATISTICS;
orig_CC = CC;
orig_PBS = PBS;
orig_MKK = MKK;
orig_RR = RR;
orig_PRBS = PRBS;
orig_FDD = FDD;
orig_first_dead = first_dead;
orig_Etot = Etot;
orig_lifetime = length(orig_CC);

fprintf('\nRunning Improved Two-Zone PCH Protocol...\n');
run('Improved_WSN_TwoZone_PCH.m');
close all;

% Load improved results
load('improved_twozone_pch_results.mat');
impr_stats = STATISTICS;
impr_CC = CC;
impr_PBS = PBS;
impr_MKK = MKK;
impr_RR = RR;
impr_PRBS = PRBS;
impr_FDD = FDD;
impr_first_dead = first_dead;
impr_Etot = Etot;
impr_lifetime = length(impr_CC);

fprintf('\n===============================================\n');
fprintf('   GENERATING COMPARISON GRAPHS\n');
fprintf('===============================================\n\n');

%% Comprehensive Comparison Figure
fig1 = figure('Position', [50, 50, 1600, 1000]);

% Plot 1: Alive Nodes Over Time
subplot(3, 3, 1);
plot(1:orig_lifetime, orig_CC, 'b-', 'LineWidth', 2.5);
hold on;
plot(1:impr_lifetime, impr_CC, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Alive Nodes', 'FontSize', 11, 'FontWeight', 'bold');
title('Network Lifetime Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 2: Dead Nodes Over Time
subplot(3, 3, 2);
orig_dead_vec = [orig_stats.DEAD];
impr_dead_vec = [impr_stats.DEAD];
plot(1:length(orig_dead_vec), orig_dead_vec, 'b-', 'LineWidth', 2.5);
hold on;
plot(1:length(impr_dead_vec), impr_dead_vec, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Dead Nodes', 'FontSize', 11, 'FontWeight', 'bold');
title('Node Mortality Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 3: Packets to BS Over Time
subplot(3, 3, 3);
plot(1:length(orig_PBS), orig_PBS, 'b-', 'LineWidth', 2.5);
hold on;
plot(1:length(impr_PBS), impr_PBS, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Total Packets to BS', 'FontSize', 11, 'FontWeight', 'bold');
title('Data Transmission Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 4: Energy Dissipation Over Time
subplot(3, 3, 4);
plot(orig_RR, orig_MKK, 'b-', 'LineWidth', 2.5);
hold on;
plot(impr_RR, impr_MKK, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Energy Dissipated (J)', 'FontSize', 11, 'FontWeight', 'bold');
title('Cumulative Energy Dissipation', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 5: Residual Energy Over Time
subplot(3, 3, 5);
plot(orig_RR, orig_Etot - orig_MKK, 'b-', 'LineWidth', 2.5);
hold on;
plot(impr_RR, impr_Etot - impr_MKK, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Residual Energy (J)', 'FontSize', 11, 'FontWeight', 'bold');
title('Network Residual Energy', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 6: Energy Efficiency (Energy per Round)
subplot(3, 3, 6);
if length(orig_MKK) > 1
    orig_energy_per_round = diff(orig_MKK);
    plot(2:length(orig_MKK), movmean(orig_energy_per_round, 20), 'b-', 'LineWidth', 2.5);
    hold on;
end
if length(impr_MKK) > 1
    impr_energy_per_round = diff(impr_MKK);
    plot(2:length(impr_MKK), movmean(impr_energy_per_round, 20), 'r-', 'LineWidth', 2.5);
end
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Energy/Round (J)', 'FontSize', 11, 'FontWeight', 'bold');
title('Energy Efficiency (20-round avg)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 7: Packets vs Alive Nodes
subplot(3, 3, 7);
plot(orig_PBS, orig_FDD, 'b-', 'LineWidth', 2.5);
hold on;
plot(impr_PBS, impr_FDD, 'r-', 'LineWidth', 2.5);
xlabel('Packets Received at BS', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Alive Nodes', 'FontSize', 11, 'FontWeight', 'bold');
title('Throughput vs Network Health', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 8: Packets vs Energy Dissipation
subplot(3, 3, 8);
plot(orig_MKK, orig_PRBS, 'b-', 'LineWidth', 2.5);
hold on;
plot(impr_MKK, impr_PRBS, 'r-', 'LineWidth', 2.5);
xlabel('Energy Dissipated (J)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Packets to BS', 'FontSize', 11, 'FontWeight', 'bold');
title('Energy Cost per Packet', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'Improved (Two-Zone PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 9: Performance Metrics Bar Chart
subplot(3, 3, 9);
metrics_data = [orig_first_dead, impr_first_dead;
                orig_lifetime, impr_lifetime;
                orig_PBS(end), impr_PBS(end)];

bar_handle = bar(metrics_data');
bar_handle(1).FaceColor = [0.2 0.4 0.8];
bar_handle(2).FaceColor = [0.8 0.2 0.2];

set(gca, 'XTickLabel', {'Original', 'Improved'});
ylabel('Value', 'FontSize', 11, 'FontWeight', 'bold');
title('Key Performance Indicators', 'FontSize', 12, 'FontWeight', 'bold');
legend('First Node Death', 'Network Lifetime', 'Total Packets', 'Location', 'best');
grid on;

sgtitle('WSN Protocol Comparison: Original Single PCH vs Improved Two-Zone PCH', ...
    'FontSize', 15, 'FontWeight', 'bold');

%% Calculate Improvement Percentages
fprintf('\n===============================================\n');
fprintf('   PERFORMANCE IMPROVEMENT ANALYSIS\n');
fprintf('===============================================\n\n');

fprintf('--- Network Lifetime Metrics ---\n');
fprintf('First Node Death:\n');
fprintf('  Original:   Round %d\n', orig_first_dead);
fprintf('  Improved:   Round %d\n', impr_first_dead);
improvement_fnd = ((impr_first_dead - orig_first_dead) / orig_first_dead) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_fnd);

fprintf('Total Network Lifetime:\n');
fprintf('  Original:   %d rounds\n', orig_lifetime);
fprintf('  Improved:   %d rounds\n', impr_lifetime);
improvement_lifetime = ((impr_lifetime - orig_lifetime) / orig_lifetime) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_lifetime);

fprintf('--- Data Transmission Metrics ---\n');
fprintf('Total Packets to BS:\n');
fprintf('  Original:   %d packets\n', orig_PBS(end));
fprintf('  Improved:   %d packets\n', impr_PBS(end));
improvement_packets = ((impr_PBS(end) - orig_PBS(end)) / orig_PBS(end)) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_packets);

fprintf('--- Energy Consumption Metrics ---\n');
fprintf('Total Energy Dissipated:\n');
fprintf('  Original:   %.4f J\n', orig_MKK(end));
fprintf('  Improved:   %.4f J\n', impr_MKK(end));
improvement_energy = ((orig_MKK(end) - impr_MKK(end)) / orig_MKK(end)) * 100;
fprintf('  Energy Saved: %+.2f%%\n\n', improvement_energy);

if length(orig_MKK) > 1 && length(impr_MKK) > 1
    avg_orig_energy_per_round = mean(diff(orig_MKK));
    avg_impr_energy_per_round = mean(diff(impr_MKK));
    fprintf('Average Energy per Round:\n');
    fprintf('  Original:   %.6f J/round\n', avg_orig_energy_per_round);
    fprintf('  Improved:   %.6f J/round\n', avg_impr_energy_per_round);
    improvement_efficiency = ((avg_orig_energy_per_round - avg_impr_energy_per_round) / avg_orig_energy_per_round) * 100;
    fprintf('  Efficiency Gain: %+.2f%%\n\n', improvement_efficiency);
end

fprintf('--- Throughput Efficiency ---\n');
orig_packets_per_energy = orig_PBS(end) / orig_MKK(end);
impr_packets_per_energy = impr_PBS(end) / impr_MKK(end);
fprintf('Packets per Joule:\n');
fprintf('  Original:   %.2f packets/J\n', orig_packets_per_energy);
fprintf('  Improved:   %.2f packets/J\n', impr_packets_per_energy);
improvement_throughput = ((impr_packets_per_energy - orig_packets_per_energy) / orig_packets_per_energy) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_throughput);

fprintf('===============================================\n');
fprintf('   SUMMARY TABLE\n');
fprintf('===============================================\n\n');

fprintf('%-35s | %-15s | %-15s | %-15s\n', 'Metric', 'Original', 'Improved', 'Change');
fprintf('----------------------------------------------------------------------------------------------------\n');
fprintf('%-35s | %-15d | %-15d | %+.2f%%\n', 'First Node Death (rounds)', ...
    orig_first_dead, impr_first_dead, improvement_fnd);
fprintf('%-35s | %-15d | %-15d | %+.2f%%\n', 'Network Lifetime (rounds)', ...
    orig_lifetime, impr_lifetime, improvement_lifetime);
fprintf('%-35s | %-15d | %-15d | %+.2f%%\n', 'Total Packets to BS', ...
    orig_PBS(end), impr_PBS(end), improvement_packets);
fprintf('%-35s | %-15.4f | %-15.4f | %+.2f%%\n', 'Total Energy Dissipated (J)', ...
    orig_MKK(end), impr_MKK(end), improvement_energy);
fprintf('%-35s | %-15.2f | %-15.2f | %+.2f%%\n', 'Packets per Joule', ...
    orig_packets_per_energy, impr_packets_per_energy, improvement_throughput);
fprintf('----------------------------------------------------------------------------------------------------\n\n');

%% Zone Energy Distribution (Improved Protocol Only)
if isfield(impr_stats, 'ZONE1_ENERGY')
    fprintf('===============================================\n');
    fprintf('   ZONE ENERGY ANALYSIS (Improved Protocol)\n');
    fprintf('===============================================\n\n');

    zone1_total = sum([impr_stats.ZONE1_ENERGY]);
    zone2_total = sum([impr_stats.ZONE2_ENERGY]);
    total_zone_energy = zone1_total + zone2_total;

    fprintf('Total Energy Contribution:\n');
    fprintf('  Zone 1 (y < 50):  %.4f J (%.2f%%)\n', zone1_total, (zone1_total/total_zone_energy)*100);
    fprintf('  Zone 2 (y >= 50): %.4f J (%.2f%%)\n\n', zone2_total, (zone2_total/total_zone_energy)*100);

    % Zone balance figure
    fig2 = figure('Position', [100, 100, 1200, 500]);

    subplot(1, 2, 1);
    zone1_vec = [impr_stats.ZONE1_ENERGY];
    zone2_vec = [impr_stats.ZONE2_ENERGY];
    rounds_vec = 1:length(zone1_vec);

    plot(rounds_vec, zone1_vec, 'b-', 'LineWidth', 2.5);
    hold on;
    plot(rounds_vec, zone2_vec, 'c-', 'LineWidth', 2.5);
    plot(rounds_vec, zone1_vec + zone2_vec, 'k--', 'LineWidth', 2);
    xlabel('Rounds', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Energy (J)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Zone Energy Distribution (Improved)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('Zone 1 (y < 50)', 'Zone 2 (y >= 50)', 'Total', 'Location', 'best');
    grid on;
    hold off;

    subplot(1, 2, 2);
    pie([zone1_total, zone2_total], {'Zone 1 (y < 50)', 'Zone 2 (y >= 50)'});
    title('Energy Balance Between Zones', 'FontSize', 13, 'FontWeight', 'bold');
    colormap([0.2 0.4 0.8; 0.2 0.8 0.8]);

    saveas(fig2, 'zone_energy_analysis.png');
    fprintf('Zone energy analysis saved as: zone_energy_analysis.png\n\n');
end

%% Save comparison figure
saveas(fig1, 'protocol_comparison_detailed.png');
fprintf('Detailed comparison saved as: protocol_comparison_detailed.png\n\n');

fprintf('===============================================\n');
fprintf('   ANALYSIS COMPLETE!\n');
fprintf('===============================================\n\n');

fprintf('KEY FINDINGS:\n');
if improvement_fnd > 0
    fprintf('✓ First node survives %.2f%% longer with Two-Zone PCH\n', improvement_fnd);
else
    fprintf('✗ First node dies %.2f%% earlier with Two-Zone PCH\n', abs(improvement_fnd));
end

if improvement_lifetime > 0
    fprintf('✓ Network lifetime extended by %.2f%%\n', improvement_lifetime);
else
    fprintf('✗ Network lifetime reduced by %.2f%%\n', abs(improvement_lifetime));
end

if improvement_packets > 0
    fprintf('✓ Data throughput increased by %.2f%%\n', improvement_packets);
else
    fprintf('✗ Data throughput decreased by %.2f%%\n', abs(improvement_packets));
end

if improvement_energy > 0
    fprintf('✓ Energy consumption reduced by %.2f%%\n', improvement_energy);
else
    fprintf('✗ Energy consumption increased by %.2f%%\n', abs(improvement_energy));
end

if improvement_throughput > 0
    fprintf('✓ Energy efficiency improved by %.2f%%\n', improvement_throughput);
else
    fprintf('✗ Energy efficiency decreased by %.2f%%\n', abs(improvement_throughput));
end

fprintf('\n===============================================\n\n');
