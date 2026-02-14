%% Simple Runner: Execute X-Based Two-Zone PCH Protocol
%
% Just run this file in MATLAB to get all graphs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
clc;

fprintf('\n');
fprintf('========================================\n');
fprintf('  Running X-Based Two-Zone PCH Protocol\n');
fprintf('  LEFT Zone (x < 50) | RIGHT Zone (x >= 50)\n');
fprintf('========================================\n\n');

fprintf('Starting simulation...\n');
fprintf('This will take a few minutes for 2000 rounds.\n\n');

% Execute the X-based protocol
Improved_WSN_TwoZone_PCH_XBased

fprintf('\n========================================\n');
fprintf('  Simulation Complete!\n');
fprintf('========================================\n\n');

fprintf('Generated Figures:\n');
fprintf('  Figure 1: Network Topology (animated)\n');
fprintf('  Figure 2: Alive Nodes Over Time\n');
fprintf('  Figure 3: Packets to Base Station\n');
fprintf('  Figure 4: Energy Dissipation\n');
fprintf('  Figure 5: Residual Energy\n');
fprintf('  Figure 6: Packets vs Alive Nodes\n');
fprintf('  Figure 7: Packets vs Energy Dissipation\n');
fprintf('  Figure 8: LEFT/RIGHT Zone Energy Balance\n\n');

fprintf('Results saved to: improved_xbased_twozone_pch_results.mat\n\n');

fprintf('To compare with original protocol, run:\n');
fprintf('  >> Compare_XBased_vs_Original\n\n');

fprintf('========================================\n\n');
