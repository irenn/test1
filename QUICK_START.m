%% QUICK START GUIDE - How to Run WSN Protocols in MATLAB
%
% This guide shows you how to execute the WSN protocols and get graphs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% OPTION 1: Run X-Based Protocol Only (LEFT/RIGHT zones)
% This gives you the same type of graphs as your original code
% Just run this one line:

Improved_WSN_TwoZone_PCH_XBased

% You will get 8 figures:
% - Figure 1: Network topology (animated during simulation)
% - Figure 2: Alive nodes over time
% - Figure 3: Packets to BS
% - Figure 4: Energy dissipation
% - Figure 5: Residual energy
% - Figure 6: Packets vs alive nodes
% - Figure 7: Packets vs energy
% - Figure 8: LEFT/RIGHT zone energy balance

%% OPTION 2: Compare Original vs X-Based
% This runs both protocols and shows side-by-side comparison

Compare_XBased_vs_Original

% You will get:
% - 9-panel comparison graph
% - Zone energy analysis graphs
% - Performance improvement percentages in console

%% OPTION 3: Run Original Protocol Only

Original_WSN_Single_PCH

% Same graphs as your original code

%% OPTION 4: Run Y-Based Protocol (UPPER/LOWER zones)

Improved_WSN_TwoZone_PCH

% Zones divided by y-coordinate instead of x

%% TIPS FOR VIEWING GRAPHS

% 1. To save all open figures:
% figHandles = findall(0, 'Type', 'figure');
% for i = 1:length(figHandles)
%     saveas(figHandles(i), sprintf('figure_%d.png', i));
% end

% 2. To keep figures from previous run:
% set(0, 'DefaultFigureWindowStyle', 'docked')

% 3. To run faster (less plotting):
% Comment out plot commands in the main loop
% Only final figures will be generated

% 4. To run in background:
% Run with '-nodisplay' flag from command line:
% matlab -nodisplay -r "Improved_WSN_TwoZone_PCH_XBased; exit"

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXPECTED OUTPUT IN CONSOLE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% === IMPROVED X-Based Two-Zone PCH Protocol Results ===
% Zone Division: LEFT (x < 50) vs RIGHT (x >= 50)
% First node death: Round XXX
% Network lifetime: XXX rounds
% Total packets to BS: XXXXX
% Total energy dissipated: X.XXXX J
% ====================================================
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CUSTOMIZATION

% To change simulation parameters, edit the .m file:
%
% rmax = 2000;        % Increase for longer simulation
% n = 200;            % More nodes
% Eo = 1.0;           % More initial energy
% zone_boundary = 60; % Move boundary

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% END OF QUICK START GUIDE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
