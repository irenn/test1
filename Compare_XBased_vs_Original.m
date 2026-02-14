%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%    Comparison: Original vs X-Based Two-Zone PCH                     %
%    Original: Single PCH (y>50)                                       %
%    Improved: Two PCHs (LEFT x<50, RIGHT x>=50)                      %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;

fprintf('===============================================\n');
fprintf('   WSN PROTOCOL COMPARISON ANALYSIS\n');
fprintf('   Original Single PCH vs X-Based Two-Zone\n');
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

fprintf('\nRunning X-Based Two-Zone PCH Protocol...\n');
run('Improved_WSN_TwoZone_PCH_XBased.m');
close all;

% Load X-based results
load('improved_xbased_twozone_pch_results.mat');
xbased_stats = STATISTICS;
xbased_CC = CC;
xbased_PBS = PBS;
xbased_MKK = MKK;
xbased_RR = RR;
xbased_PRBS = PRBS;
xbased_FDD = FDD;
xbased_first_dead = first_dead;
xbased_Etot = Etot;
xbased_lifetime = length(xbased_CC);

fprintf('\n===============================================\n');
fprintf('   GENERATING COMPARISON GRAPHS\n');
fprintf('===============================================\n\n');

%% Comprehensive Comparison Figure
fig1 = figure('Position', [50, 50, 1600, 1000]);

% Plot 1: Alive Nodes Over Time
subplot(3, 3, 1);
plot(1:orig_lifetime, orig_CC, 'b-', 'LineWidth', 2.5);
hold on;
plot(1:xbased_lifetime, xbased_CC, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Alive Nodes', 'FontSize', 11, 'FontWeight', 'bold');
title('Network Lifetime Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 2: Dead Nodes Over Time
subplot(3, 3, 2);
orig_dead_vec = [orig_stats.DEAD];
xbased_dead_vec = [xbased_stats.DEAD];
plot(1:length(orig_dead_vec), orig_dead_vec, 'b-', 'LineWidth', 2.5);
hold on;
plot(1:length(xbased_dead_vec), xbased_dead_vec, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Dead Nodes', 'FontSize', 11, 'FontWeight', 'bold');
title('Node Mortality Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 3: Packets to BS Over Time
subplot(3, 3, 3);
plot(1:length(orig_PBS), orig_PBS, 'b-', 'LineWidth', 2.5);
hold on;
plot(1:length(xbased_PBS), xbased_PBS, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Total Packets to BS', 'FontSize', 11, 'FontWeight', 'bold');
title('Data Transmission Comparison', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 4: Energy Dissipation Over Time
subplot(3, 3, 4);
plot(orig_RR, orig_MKK, 'b-', 'LineWidth', 2.5);
hold on;
plot(xbased_RR, xbased_MKK, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Energy Dissipated (J)', 'FontSize', 11, 'FontWeight', 'bold');
title('Cumulative Energy Dissipation', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 5: Residual Energy Over Time
subplot(3, 3, 5);
plot(orig_RR, orig_Etot - orig_MKK, 'b-', 'LineWidth', 2.5);
hold on;
plot(xbased_RR, xbased_Etot - xbased_MKK, 'r-', 'LineWidth', 2.5);
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Residual Energy (J)', 'FontSize', 11, 'FontWeight', 'bold');
title('Network Residual Energy', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 6: Energy Efficiency (Energy per Round)
subplot(3, 3, 6);
if length(orig_MKK) > 1
    orig_energy_per_round = diff(orig_MKK);
    plot(2:length(orig_MKK), movmean(orig_energy_per_round, 20), 'b-', 'LineWidth', 2.5);
    hold on;
end
if length(xbased_MKK) > 1
    xbased_energy_per_round = diff(xbased_MKK);
    plot(2:length(xbased_MKK), movmean(xbased_energy_per_round, 20), 'r-', 'LineWidth', 2.5);
end
xlabel('Rounds', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Energy/Round (J)', 'FontSize', 11, 'FontWeight', 'bold');
title('Energy Efficiency (20-round avg)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 7: Packets vs Alive Nodes
subplot(3, 3, 7);
plot(orig_PBS, orig_FDD, 'b-', 'LineWidth', 2.5);
hold on;
plot(xbased_PBS, xbased_FDD, 'r-', 'LineWidth', 2.5);
xlabel('Packets Received at BS', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Alive Nodes', 'FontSize', 11, 'FontWeight', 'bold');
title('Throughput vs Network Health', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 8: Packets vs Energy Dissipation
subplot(3, 3, 8);
plot(orig_MKK, orig_PRBS, 'b-', 'LineWidth', 2.5);
hold on;
plot(xbased_MKK, xbased_PRBS, 'r-', 'LineWidth', 2.5);
xlabel('Energy Dissipated (J)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Packets to BS', 'FontSize', 11, 'FontWeight', 'bold');
title('Energy Cost per Packet', 'FontSize', 12, 'FontWeight', 'bold');
legend('Original (Single PCH)', 'X-Based (LEFT/RIGHT PCH)', 'Location', 'best');
grid on;
hold off;

% Plot 9: Performance Metrics Bar Chart
subplot(3, 3, 9);
metrics_data = [orig_first_dead, xbased_first_dead;
                orig_lifetime, xbased_lifetime;
                orig_PBS(end), xbased_PBS(end)];

bar_handle = bar(metrics_data');
bar_handle(1).FaceColor = [0.2 0.4 0.8];
bar_handle(2).FaceColor = [0.8 0.2 0.2];

set(gca, 'XTickLabel', {'Original', 'X-Based'});
ylabel('Value', 'FontSize', 11, 'FontWeight', 'bold');
title('Key Performance Indicators', 'FontSize', 12, 'FontWeight', 'bold');
legend('First Node Death', 'Network Lifetime', 'Total Packets', 'Location', 'best');
grid on;

sgtitle('WSN Protocol Comparison: Original Single PCH vs X-Based Two-Zone PCH (LEFT/RIGHT)', ...
    'FontSize', 15, 'FontWeight', 'bold');

%% Calculate Improvement Percentages
fprintf('\n===============================================\n');
fprintf('   PERFORMANCE IMPROVEMENT ANALYSIS\n');
fprintf('   Zone Division: LEFT (x<50) vs RIGHT (x>=50)\n');
fprintf('===============================================\n\n');

fprintf('--- Network Lifetime Metrics ---\n');
fprintf('First Node Death:\n');
fprintf('  Original:   Round %d\n', orig_first_dead);
fprintf('  X-Based:    Round %d\n', xbased_first_dead);
improvement_fnd = ((xbased_first_dead - orig_first_dead) / orig_first_dead) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_fnd);

fprintf('Total Network Lifetime:\n');
fprintf('  Original:   %d rounds\n', orig_lifetime);
fprintf('  X-Based:    %d rounds\n', xbased_lifetime);
improvement_lifetime = ((xbased_lifetime - orig_lifetime) / orig_lifetime) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_lifetime);

fprintf('--- Data Transmission Metrics ---\n');
fprintf('Total Packets to BS:\n');
fprintf('  Original:   %d packets\n', orig_PBS(end));
fprintf('  X-Based:    %d packets\n', xbased_PBS(end));
improvement_packets = ((xbased_PBS(end) - orig_PBS(end)) / orig_PBS(end)) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_packets);

fprintf('--- Energy Consumption Metrics ---\n');
fprintf('Total Energy Dissipated:\n');
fprintf('  Original:   %.4f J\n', orig_MKK(end));
fprintf('  X-Based:    %.4f J\n', xbased_MKK(end));
improvement_energy = ((orig_MKK(end) - xbased_MKK(end)) / orig_MKK(end)) * 100;
fprintf('  Energy Saved: %+.2f%%\n\n', improvement_energy);

if length(orig_MKK) > 1 && length(xbased_MKK) > 1
    avg_orig_energy_per_round = mean(diff(orig_MKK));
    avg_xbased_energy_per_round = mean(diff(xbased_MKK));
    fprintf('Average Energy per Round:\n');
    fprintf('  Original:   %.6f J/round\n', avg_orig_energy_per_round);
    fprintf('  X-Based:    %.6f J/round\n', avg_xbased_energy_per_round);
    improvement_efficiency = ((avg_orig_energy_per_round - avg_xbased_energy_per_round) / avg_orig_energy_per_round) * 100;
    fprintf('  Efficiency Gain: %+.2f%%\n\n', improvement_efficiency);
end

fprintf('--- Throughput Efficiency ---\n');
orig_packets_per_energy = orig_PBS(end) / orig_MKK(end);
xbased_packets_per_energy = xbased_PBS(end) / xbased_MKK(end);
fprintf('Packets per Joule:\n');
fprintf('  Original:   %.2f packets/J\n', orig_packets_per_energy);
fprintf('  X-Based:    %.2f packets/J\n', xbased_packets_per_energy);
improvement_throughput = ((xbased_packets_per_energy - orig_packets_per_energy) / orig_packets_per_energy) * 100;
fprintf('  Improvement: %+.2f%%\n\n', improvement_throughput);

fprintf('===============================================\n');
fprintf('   SUMMARY TABLE\n');
fprintf('===============================================\n\n');

fprintf('%-35s | %-15s | %-15s | %-15s\n', 'Metric', 'Original', 'X-Based', 'Change');
fprintf('----------------------------------------------------------------------------------------------------\n');
fprintf('%-35s | %-15d | %-15d | %+.2f%%\n', 'First Node Death (rounds)', ...
    orig_first_dead, xbased_first_dead, improvement_fnd);
fprintf('%-35s | %-15d | %-15d | %+.2f%%\n', 'Network Lifetime (rounds)', ...
    orig_lifetime, xbased_lifetime, improvement_lifetime);
fprintf('%-35s | %-15d | %-15d | %+.2f%%\n', 'Total Packets to BS', ...
    orig_PBS(end), xbased_PBS(end), improvement_packets);
fprintf('%-35s | %-15.4f | %-15.4f | %+.2f%%\n', 'Total Energy Dissipated (J)', ...
    orig_MKK(end), xbased_MKK(end), improvement_energy);
fprintf('%-35s | %-15.2f | %-15.2f | %+.2f%%\n', 'Packets per Joule', ...
    orig_packets_per_energy, xbased_packets_per_energy, improvement_throughput);
fprintf('----------------------------------------------------------------------------------------------------\n\n');

%% Zone Energy Distribution (X-Based Protocol Only)
if isfield(xbased_stats, 'ZONE1_ENERGY')
    fprintf('===============================================\n');
    fprintf('   ZONE ENERGY ANALYSIS (X-Based Protocol)\n');
    fprintf('   LEFT Zone (x<50) vs RIGHT Zone (x>=50)\n');
    fprintf('===============================================\n\n');

    zone1_total = sum([xbased_stats.ZONE1_ENERGY]);
    zone2_total = sum([xbased_stats.ZONE2_ENERGY]);
    total_zone_energy = zone1_total + zone2_total;

    fprintf('Total Energy Contribution:\n');
    fprintf('  LEFT Zone (x < 50):  %.4f J (%.2f%%)\n', zone1_total, (zone1_total/total_zone_energy)*100);
    fprintf('  RIGHT Zone (x >= 50): %.4f J (%.2f%%)\n\n', zone2_total, (zone2_total/total_zone_energy)*100);

    % Zone balance figure
    fig2 = figure('Position', [100, 100, 1200, 500]);

    subplot(1, 2, 1);
    zone1_vec = [xbased_stats.ZONE1_ENERGY];
    zone2_vec = [xbased_stats.ZONE2_ENERGY];
    rounds_vec = 1:length(zone1_vec);

    plot(rounds_vec, zone1_vec, 'b-', 'LineWidth', 2.5);
    hold on;
    plot(rounds_vec, zone2_vec, 'r-', 'LineWidth', 2.5);
    plot(rounds_vec, zone1_vec + zone2_vec, 'k--', 'LineWidth', 2);
    xlabel('Rounds', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Energy (J)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Zone Energy Distribution (X-Based)', 'FontSize', 13, 'FontWeight', 'bold');
    legend('LEFT Zone (x < 50)', 'RIGHT Zone (x >= 50)', 'Total', 'Location', 'best');
    grid on;
    hold off;

    subplot(1, 2, 2);
    pie([zone1_total, zone2_total], {'LEFT Zone (x < 50)', 'RIGHT Zone (x >= 50)'});
    title('Energy Balance: LEFT vs RIGHT Zones', 'FontSize', 13, 'FontWeight', 'bold');
    colormap([0.2 0.4 0.8; 0.8 0.2 0.2]);

    saveas(fig2, 'xbased_zone_energy_analysis.png');
    fprintf('Zone energy analysis saved as: xbased_zone_energy_analysis.png\n\n');
end

%% Save comparison figure
saveas(fig1, 'xbased_protocol_comparison.png');
fprintf('Detailed comparison saved as: xbased_protocol_comparison.png\n\n');

fprintf('===============================================\n');
fprintf('   ANALYSIS COMPLETE!\n');
fprintf('===============================================\n\n');

fprintf('KEY FINDINGS (X-Based LEFT/RIGHT Zones):\n');
if improvement_fnd > 0
    fprintf('✓ First node survives %.2f%% longer with X-Based Two-Zone PCH\n', improvement_fnd);
else
    fprintf('✗ First node dies %.2f%% earlier with X-Based Two-Zone PCH\n', abs(improvement_fnd));
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
