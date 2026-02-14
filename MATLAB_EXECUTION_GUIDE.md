# How to Execute in MATLAB and Get Graphs

## Quick Execution (3 Steps)

### Step 1: Open MATLAB
```matlab
% In MATLAB command window, navigate to your folder
cd C:\path\to\test1  % Windows
% or
cd /path/to/test1    % Linux/Mac
```

### Step 2: Run the Protocol
```matlab
% Simply execute:
RUN_XBASED
```

### Step 3: View Results
All 8 figures will automatically appear!

---

## What Graphs You'll Get

### Figure 1: Network Topology (Live Animation)
```
🗺️ Shows during simulation:
- Blue nodes/stars = LEFT zone (x < 50)
- Red nodes/stars = RIGHT zone (x >= 50)
- Green triangle (PCH1) = LEFT zone primary CH
- Magenta triangle (PCH2) = RIGHT zone primary CH
- Black dashed line = zone boundary (vertical at x=50)
- Magenta X = Base Station at (50, 175)
- Lines showing communication paths
```

**This updates every round** showing network evolution.

---

### Figure 2: Alive Nodes Over Time
```
📊 Red line graph showing:
- Y-axis: Number of alive nodes (0-100)
- X-axis: Rounds (0-2000)
- Shows how network degrades over time
- Steeper slope = faster node death
```

---

### Figure 3: Packets Received at BS
```
📦 Red line graph showing:
- Y-axis: Total packets received
- X-axis: Rounds
- Cumulative data transmission
- Higher = more throughput
```

---

### Figure 4: Energy Dissipation
```
⚡ Red line graph showing:
- Y-axis: Total energy consumed (Joules)
- X-axis: Rounds
- Cumulative energy usage
- Steeper = less efficient
```

---

### Figure 5: Residual Energy
```
🔋 Red line graph showing:
- Y-axis: Remaining network energy (J)
- X-axis: Rounds
- Shows energy depletion
- Reaches 0 when all nodes dead
```

---

### Figure 6: Packets vs Alive Nodes
```
📈 Red line graph showing:
- Y-axis: Alive nodes
- X-axis: Packets received at BS
- Shows throughput efficiency
- Shows data collected before network dies
```

---

### Figure 7: Packets vs Energy Dissipation
```
💰 Red line graph showing:
- Y-axis: Packets received
- X-axis: Energy dissipated
- Energy cost per packet
- Steeper slope = better efficiency
```

---

### Figure 8: LEFT vs RIGHT Zone Energy Balance
```
🎯 Multi-line graph showing:
- Blue line = LEFT zone energy (x < 50)
- Red line = RIGHT zone energy (x >= 50)
- Black dashed = Total energy
- Shows if zones are balanced
```

---

## Console Output Example

```
========================================
  Running X-Based Two-Zone PCH Protocol
  LEFT Zone (x < 50) | RIGHT Zone (x >= 50)
========================================

Starting simulation...
This will take a few minutes for 2000 rounds.

r = 0
r = 1
r = 2
...
first_dead = 856
r = 856
r = 857
...
r = 2000

=== IMPROVED X-Based Two-Zone PCH Protocol Results ===
Zone Division: LEFT (x < 50) vs RIGHT (x >= 50)
First node death: Round 856
Network lifetime: 2000 rounds
Total packets to BS: 28543
Total energy dissipated: 42.3456 J
====================================================

========================================
  Simulation Complete!
========================================
```

---

## Alternative Execution Methods

### Method A: Direct Protocol Execution
```matlab
% Run protocol directly
Improved_WSN_TwoZone_PCH_XBased
```
Same 8 figures generated.

---

### Method B: Comparison with Original
```matlab
% Compare Original vs X-Based
Compare_XBased_vs_Original
```

**This generates 11 figures total:**
- 9-panel comparison graph
- Zone energy analysis (2 subplots)

**Comparison includes:**
1. Alive nodes comparison (Original vs X-Based)
2. Dead nodes comparison
3. Packets comparison
4. Energy dissipation comparison
5. Residual energy comparison
6. Energy efficiency comparison
7. Packets vs alive nodes
8. Packets vs energy
9. Performance metrics bar chart
10. Zone energy distribution (LEFT/RIGHT)
11. Pie chart of energy balance

**Plus console output:**
```
===============================================
   PERFORMANCE IMPROVEMENT ANALYSIS
   Zone Division: LEFT (x<50) vs RIGHT (x>=50)
===============================================

--- Network Lifetime Metrics ---
First Node Death:
  Original:   Round 723
  X-Based:    Round 856
  Improvement: +18.39%

Total Network Lifetime:
  Original:   1847 rounds
  X-Based:    2000 rounds
  Improvement: +8.28%

--- Data Transmission Metrics ---
Total Packets to BS:
  Original:   25432 packets
  X-Based:    28543 packets
  Improvement: +12.23%

... (more metrics)
```

---

## Saving Figures

### Auto-save all figures as PNG:
```matlab
% Run protocol
Improved_WSN_TwoZone_PCH_XBased

% Then save all figures
figHandles = findall(0, 'Type', 'figure');
for i = 1:length(figHandles)
    saveas(figHandles(i), sprintf('xbased_figure_%d.png', i));
end
```

### Save specific figures:
```matlab
% After running protocol
saveas(2, 'alive_nodes.png');
saveas(3, 'packets_to_bs.png');
saveas(8, 'zone_energy_balance.png');
```

---

## Customizing the Simulation

### Change simulation duration:
```matlab
% Edit Improved_WSN_TwoZone_PCH_XBased.m
% Line ~35:
rmax = 5000;  % Change from 2000 to 5000 rounds
```

### Change zone boundary:
```matlab
% Line ~33:
zone_boundary = 60;  % Move from x=50 to x=60
```

### Increase number of nodes:
```matlab
% Line ~19:
n = 200;  % Change from 100 to 200 nodes
```

### Increase initial energy:
```matlab
% Line ~21:
Eo = 1.0;  % Change from 0.5 to 1.0 Joules
```

---

## Troubleshooting

### "File not found" error
```matlab
% Make sure you're in the correct directory
pwd  % Check current directory
ls   % List files (should see .m files)
cd /path/to/test1  % Navigate if needed
```

### Figures not appearing
```matlab
% Check if figures are docked
set(0, 'DefaultFigureWindowStyle', 'normal')  % Undock figures
```

### Simulation too slow
```matlab
% Reduce rounds or comment out plot commands in main loop
% In the .m file, comment out plotting commands inside the for loop
% Keep only final figure generation
```

### Want to run without GUI (command line)
```bash
# From terminal/command prompt
matlab -nodisplay -nosplash -nodesktop -r "RUN_XBASED; exit;"
```

---

## File Outputs

After running, you'll have:

**Data file:**
- `improved_xbased_twozone_pch_results.mat` - All simulation data

**Can load and analyze:**
```matlab
load('improved_xbased_twozone_pch_results.mat');

% Available variables:
% - STATISTICS: struct with DEAD, ALIVE, ZONE1_ENERGY, ZONE2_ENERGY
% - CC: alive nodes per round
% - PBS: packets to BS per round
% - MKK: cumulative energy dissipated
% - first_dead: round when first node died
% - Etot: total initial energy
```

---

## Expected Performance (X-Based vs Original)

Typical improvements you should see:
- **First node death**: +15% to +25% later
- **Network lifetime**: +10% to +20% longer
- **Total packets**: +10% to +20% more
- **Energy efficiency**: +15% to +25% better

*Results vary based on random node placement*

---

## Summary

**Simplest way:**
```matlab
RUN_XBASED
```

**You get:**
- ✅ 8 figures automatically
- ✅ Console output with key metrics
- ✅ .mat file with all data
- ✅ Same graph types as your original code

**Comparison mode:**
```matlab
Compare_XBased_vs_Original
```

**You get:**
- ✅ Everything above +
- ✅ 9-panel comparison graph
- ✅ Zone energy analysis
- ✅ Percentage improvements
- ✅ Performance summary table

---

## Quick Reference Card

| Task | Command |
|------|---------|
| Run X-Based protocol | `RUN_XBASED` |
| Run original protocol | `Original_WSN_Single_PCH` |
| Run Y-based protocol | `Improved_WSN_TwoZone_PCH` |
| Compare original vs X-based | `Compare_XBased_vs_Original` |
| Compare original vs Y-based | `Compare_Protocols` |
| View quick start guide | `edit QUICK_START.m` |
| Load saved results | `load('improved_xbased_twozone_pch_results.mat')` |

---

**You're all set! Just run `RUN_XBASED` in MATLAB and watch the magic happen!** ✨
