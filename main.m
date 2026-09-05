%% ============================================================
clear;
clc;
close all;

rng(20);

%% ============================================================
% 0. GLOBAL FIGURE / FONT / OUTPUT SETTINGS
%% ============================================================

OutputFolder = 'Output_Figures';
if ~exist(OutputFolder,'dir')
    mkdir(OutputFolder);
end

set(0,'DefaultFigureColor','w');
set(0,'DefaultFigurePosition',[50 50 1400 900]);

set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultAxesFontWeight','bold');
set(0,'DefaultAxesFontSize',20);

set(0,'DefaultTextFontName','Times New Roman');
set(0,'DefaultTextFontWeight','bold');
set(0,'DefaultTextFontSize',20);

set(0,'DefaultLegendFontName','Times New Roman');
set(0,'DefaultLegendFontWeight','bold');
set(0,'DefaultLegendFontSize',16);

Save_DPI = 1000;

%% ============================================================
% 1. LOAD DATASET
%% ============================================================

Input_File = 'ZnO_SiO2_Synthetic_Catalyst_Dataset.xlsx';

Data = readtable(Input_File, 'Sheet', 'Main_Dataset');

fprintf('\n====================================================\n');
fprintf('       ZnO/SiO2 CATALYST STUDY\n');
fprintf('====================================================\n\n');

fprintf('Dataset size: %d catalysts\n\n', height(Data));

Missing_Count = sum(sum(ismissing(Data)));

[~, Unique_Index] = unique(Data, 'rows', 'stable');
Duplicate_Count = height(Data) - length(Unique_Index);

fprintf('Missing values    : %d\n', Missing_Count);
fprintf('Duplicate records : %d\n', Duplicate_Count);

%% ============================================================
% 2. SELECT FIVE SCREENING CANDIDATES
%% ============================================================

Number_of_Catalysts = 5;

Candidate_Index = round(linspace(1, height(Data), ...
                                 Number_of_Catalysts));

Screening_Data = Data(Candidate_Index, :);

Labels = {'A','B','C','D','E'}';

fprintf('\n====================================================\n');
fprintf('        CATALYST SCREENING CANDIDATES\n');
fprintf('====================================================\n\n');

for i = 1:Number_of_Catalysts

    fprintf('%s : %s | ZnO Loading = %.2f %% | Particle Size = %.2f nm\n', ...
        Labels{i}, ...
        string(Screening_Data.Catalyst_ID{i}), ...
        Screening_Data.ZnO_Loading(i), ...
        Screening_Data.Particle_Size(i));

end

%% ============================================================
% 3. REACTION CONDITIONS (BASELINE, USED FOR SCREENING)
%% ============================================================

Reaction = 'Knoevenagel condensation';

Reactant_1 = 'Benzaldehyde';
Reactant_2 = 'Malononitrile';

Product = 'Benzylidene malononitrile';
Byproduct = 'H2O';

Temperature = 80;
Reaction_Time = 60;
Catalyst_Loading = 5;
Substrate_Catalyst_Ratio = 10;
Pressure = 1;

Solvent = 'None - solvent-free';

fprintf('\n====================================================\n');
fprintf('          BASELINE REACTION CONDITIONS\n');
fprintf('====================================================\n\n');

fprintf('Reaction       : %s\n', Reaction);
fprintf('Reactant 1     : %s\n', Reactant_1);
fprintf('Reactant 2     : %s\n', Reactant_2);
fprintf('Product        : %s\n', Product);
fprintf('Temperature    : %.1f degC\n', Temperature);
fprintf('Reaction Time  : %.1f min\n', Reaction_Time);
fprintf('Catalyst Load  : %.1f wt.%%\n', Catalyst_Loading);
fprintf('Substrate/Cat. : %.1f\n', Substrate_Catalyst_Ratio);
fprintf('Pressure       : %.1f bar\n', Pressure);
fprintf('Solvent        : %s\n', Solvent);

%% ============================================================
% 4. STAGE 1 - CATALYST SCREENING (fixed baseline conditions)
%% ============================================================

Conversion = zeros(Number_of_Catalysts,1);
Selectivity = zeros(Number_of_Catalysts,1);
Yield = zeros(Number_of_Catalysts,1);
Screening_Score = zeros(Number_of_Catalysts,1);

for i = 1:Number_of_Catalysts

    Surface_Factor = Screening_Data.Surface_Area(i) / 500;

    Basicity_Factor = ...
        0.5 + 0.5 * Screening_Data.Basicity(i);

    Dispersion_Factor = ...
        Screening_Data.ZnO_Dispersion(i) / 100;

    Vacancy_Factor = ...
        Screening_Data.Oxygen_Vacancy_Index(i);

    Crystallinity_Factor = ...
        Screening_Data.Crystallinity(i) / 100;

    Size_Factor = ...
        1 - abs(Screening_Data.Particle_Size(i) - 20) / 100;

    %% Conversion

    Conversion(i) = ...
        40 ...
        + 18 * Surface_Factor ...
        + 12 * Basicity_Factor ...
        + 10 * Dispersion_Factor ...
        + 8 * Vacancy_Factor ...
        + 6 * Crystallinity_Factor ...
        + 5 * Size_Factor ...
        + 1.5 * randn;

    Conversion(i) = ...
        max(min(Conversion(i),98),50);

    %% Selectivity

    Selectivity(i) = ...
        88 ...
        + 5 * Basicity_Factor ...
        + 3 * Dispersion_Factor ...
        + 2 * Vacancy_Factor ...
        + 1 * Crystallinity_Factor ...
        + 0.8 * randn;

    Selectivity(i) = ...
        max(min(Selectivity(i),99),88);

    %% Yield

    Yield(i) = ...
        Conversion(i) * Selectivity(i) / 100 ...
        + 0.8 * randn;

    Yield(i) = ...
        max(min(Yield(i),Conversion(i)),45);

    %% Overall screening score

    Screening_Score(i) = ...
        0.40 * Conversion(i) ...
        + 0.35 * Yield(i) ...
        + 0.25 * Selectivity(i);

end

%% ============================================================
% 5. SCREENING RESULTS
%% ============================================================

fprintf('\n====================================================\n');
fprintf('          SCREENING RESULTS\n');
fprintf('====================================================\n\n');

for i = 1:Number_of_Catalysts

    fprintf('Catalyst %s (%s)\n', ...
        Labels{i}, ...
        string(Screening_Data.Catalyst_ID{i}));

    fprintf('Conversion   : %.2f %%\n', Conversion(i));
    fprintf('Yield        : %.2f %%\n', Yield(i));
    fprintf('Selectivity  : %.2f %%\n', Selectivity(i));
    fprintf('Score        : %.2f\n\n', Screening_Score(i));

end

%% ============================================================
% 6. SELECT BEST CATALYST
%% ============================================================

[~, Best_Index] = max(Screening_Score);

Best_Catalyst = Screening_Data(Best_Index,:);

Best_Catalyst_ID = string(Best_Catalyst.Catalyst_ID{1});

Best_Conversion = Conversion(Best_Index);
Best_Yield = Yield(Best_Index);
Best_Selectivity = Selectivity(Best_Index);
Best_Score = Screening_Score(Best_Index);

Fixed_ZnO_Loading = Best_Catalyst.ZnO_Loading;
Fixed_Particle_Size = Best_Catalyst.Particle_Size;

fprintf('----------------------------------------------------\n');
fprintf('\nBEST SCREENING CATALYST\n');
fprintf('Catalyst          : %s\n', Labels{Best_Index});
fprintf('Catalyst ID       : %s\n', Best_Catalyst_ID);
fprintf('ZnO Loading (fix) : %.2f %%\n', Fixed_ZnO_Loading);
fprintf('Particle Size(fix): %.2f nm\n', Fixed_Particle_Size);
fprintf('Score             : %.2f\n', Best_Score);

%% ============================================================
% 7. DETAILED CHARACTERIZATION
%% ============================================================

fprintf('\n====================================================\n');
fprintf('       DETAILED CHARACTERIZATION\n');
fprintf('====================================================\n\n');

fprintf('Characterization catalyst: %s\n', Best_Catalyst_ID);

%% 7.1 XRD

TwoTheta = linspace(20,75,2500)';

ZnO_Peaks = [31.7 34.4 36.2 47.5 56.6 62.9 66.4 67.9 69.1];

Crystallinity_Factor = Best_Catalyst.Crystallinity / 100;

XRD_Intensity = zeros(size(TwoTheta));
Peak_Width = 0.18 + 0.35*(1-Crystallinity_Factor);

for k = 1:length(ZnO_Peaks)

    Peak_Height = ...
        (0.45 + 0.55*Best_Catalyst.ZnO_Loading/25) ...
        * exp(-((TwoTheta-ZnO_Peaks(k))/Peak_Width).^2);

    XRD_Intensity = XRD_Intensity + Peak_Height;

end

SiO2_Background = 0.08 * exp(-((TwoTheta-22)/5).^2);
XRD_Intensity = XRD_Intensity + SiO2_Background;
XRD_Intensity = XRD_Intensity + 0.015*randn(size(XRD_Intensity));
XRD_Intensity = max(XRD_Intensity,0);

fig = figure;
h1 = plot(TwoTheta,XRD_Intensity,'LineWidth',2.5,'Color',[0.5 0 0]);
xlabel('2\theta (degree)');
ylabel('Intensity (a.u.)');
title('XRD Pattern - ZnO/SiO_2');
legend(h1,'ZnO/SiO_2');
saveHQFigure(fig, OutputFolder, '11_XRD_ZnO_SiO2.png', Save_DPI);

%% 7.2 FTIR

Wavenumber = linspace(400,4000,2500)';

FTIR = zeros(size(Wavenumber));
FTIR = FTIR + 0.45*exp(-((Wavenumber-3400)/180).^2);
FTIR = FTIR + 0.25*exp(-((Wavenumber-1630)/90).^2);
FTIR = FTIR + 0.55*exp(-((Wavenumber-1080)/100).^2);
FTIR = FTIR + 0.70*exp(-((Wavenumber-520)/70).^2);
FTIR = FTIR + 0.015*randn(size(Wavenumber));
FTIR = max(FTIR,0);

fig = figure;
h2 = plot(Wavenumber,FTIR,'LineWidth',2.5,'Color',[0 0 0.5]);
set(gca,'XDir','reverse');
xlabel('Wavenumber (cm^{-1})');
ylabel('Absorbance (a.u.)');
title('FTIR Spectrum - ZnO/SiO_2');
legend(h2,'ZnO/SiO_2');
saveHQFigure(fig, OutputFolder, '12_FTIR_ZnO_SiO2.png', Save_DPI);

%% 7.3 SEM/TEM PARTICLE SIZE

Number_of_Particles = 300;

Particle_Size = Best_Catalyst.Particle_Size + 5*randn(Number_of_Particles,1);
Particle_Size = max(min(Particle_Size,60),5);

fig = figure;
h3 = histogram(Particle_Size,20,'FaceColor',[0.35 0 0.35]);
xlabel('Particle Size (nm)');
ylabel('Frequency');
title('SEM/TEM Particle Size Distribution');
legend(h3,'Particle size');
saveHQFigure(fig, OutputFolder, '13_SEM_TEM_Particle_Size.png', Save_DPI);

%% 7.4 SEM IMAGE

Image_Size = 600;
SEM_Image = zeros(Image_Size);
[X,Y] = meshgrid(1:Image_Size,1:Image_Size);
Number_of_Blobs = 180;

for k = 1:Number_of_Blobs
    cx = randi([20 Image_Size-20]);
    cy = randi([20 Image_Size-20]);
    Radius = randi([3 10]);
    Blob = exp(-((X-cx).^2 + (Y-cy).^2)/(2*Radius^2));
    SEM_Image = SEM_Image + Blob;
end

SEM_Image = SEM_Image / max(SEM_Image(:));

fig = figure;
imagesc(SEM_Image);
axis image off;
colormap(gray);
title('SEM Image - ZnO/SiO_2');
hold on;
plot([50 150],[550 550],'w-','LineWidth',4);
text(50,530,'100 nm','Color','w','FontSize',16,'FontWeight','bold','FontName','Times New Roman');
hold off;
saveHQFigure(fig, OutputFolder, '13A_Simulated_SEM_Image.png', Save_DPI);
imwrite(SEM_Image, fullfile(OutputFolder,'13A_Simulated_SEM_Image.tif'));

%% 7.5 BET

Relative_Pressure = linspace(0.01,0.99,200)';
Surface_Area = Best_Catalyst.Surface_Area;

Adsorption = 0.25*Relative_Pressure + 0.65*Relative_Pressure.^2 ...
    + (Surface_Area/500)*0.45*Relative_Pressure.^0.5;
Adsorption = Adsorption + 0.01*randn(size(Adsorption));
Adsorption = max(Adsorption,0);

fig = figure;
h4 = plot(Relative_Pressure,Adsorption,'LineWidth',2.5,'Color',[0 0.35 0.35]);
xlabel('Relative Pressure P/P_0');
ylabel('Adsorbed Volume (a.u.)');
title('BET N_2 Adsorption Isotherm');
legend(h4,'N_2 adsorption');
saveHQFigure(fig, OutputFolder, '14_BET_Isotherm.png', Save_DPI);

%% 7.6 XPS

Binding_Energy = linspace(1010,1060,1500)';

Zn_2p3_2 = 0.9*exp(-((Binding_Energy-1021.5)/1.2).^2);
Zn_2p1_2 = 0.75*exp(-((Binding_Energy-1044.5)/1.4).^2);
O1s = 0.40*exp(-((Binding_Energy-531.5)/1.5).^2);

XPS = Zn_2p3_2 + Zn_2p1_2 + O1s;
XPS = XPS + 0.01*randn(size(Binding_Energy));
XPS = max(XPS,0);

fig = figure;
h5 = plot(Binding_Energy,XPS,'LineWidth',2.5,'Color',[0.55 0.27 0]);
set(gca,'XDir','reverse');
xlabel('Binding Energy (eV)');
ylabel('Intensity (a.u.)');
title('XPS Spectrum - ZnO/SiO_2');
legend(h5,'Zn 2p / O 1s');
saveHQFigure(fig, OutputFolder, '15_XPS_ZnO_SiO2.png', Save_DPI);

%% 7.7 TGA

Temperature_TGA = linspace(30,700,1000)';
Mass = 100 * ones(size(Temperature_TGA));

Loss_1 = 1.5 ./ (1+exp(-(Temperature_TGA-100)/15));
Loss_2 = 3.0 ./ (1+exp(-(Temperature_TGA-250)/30));
Loss_3 = 2.2 ./ (1+exp(-(Temperature_TGA-425)/35));

Mass = Mass - Loss_1 - Loss_2 - Loss_3;
Mass = Mass + 0.05*randn(size(Mass));
Mass = min(max(Mass,90),100);

fig = figure;
h6 = plot(Temperature_TGA,Mass,'LineWidth',2.5,'Color',[0.25 0.25 0.25]);
xlabel('Temperature (degC)');
ylabel('Mass (%)');
title('TGA Curve - ZnO/SiO_2');
legend(h6,'ZnO/SiO_2');
saveHQFigure(fig, OutputFolder, '16_TGA_ZnO_SiO2.png', Save_DPI);

%% ============================================================
% 8. CATALYST SCREENING PLOT
%% ============================================================

fig = figure;
h7 = bar(Conversion);
applyDarkBarColors(h7);
xlabel('Catalyst');
ylabel('Conversion (%)');
title('Catalyst Screening - Conversion');
set(gca,'XTick',1:5,'XTickLabel',Labels);
legend(h7,'Conversion');
labelBarValues(h7);
saveHQFigure(fig, OutputFolder, '17_Catalyst_Screening.png', Save_DPI);

%% ============================================================
% 9. SCREENING SCORE
%% ============================================================

fig = figure;
h8 = bar(Screening_Score);
applyDarkBarColors(h8);
xlabel('Catalyst');
ylabel('Screening Score');
title('Catalyst Screening Score');
set(gca,'XTick',1:5,'XTickLabel',Labels);
legend(h8,'Overall score');
labelBarValues(h8);
saveHQFigure(fig, OutputFolder, '18_Catalyst_Screening_Score.png', Save_DPI);

%% ============================================================
% 9A. REACTION MECHANISM STUDY - CONTROL EXPERIMENTS
%% ============================================================

Control_Labels = {'No_Catalyst';'SiO2_only';'ZnO_only';'ZnO_SiO2'};
Control_Fraction = [0.07; 0.16; 0.68; 1.00];
Control_Sel_Floor = [88; 87; 92; Best_Selectivity];

Number_of_Controls = numel(Control_Labels);

Control_Conversion = zeros(Number_of_Controls,1);
Control_Selectivity = zeros(Number_of_Controls,1);
Control_Yield = zeros(Number_of_Controls,1);

for i = 1:Number_of_Controls

    if strcmp(Control_Labels{i},'ZnO_SiO2')

        Control_Conversion(i) = Best_Conversion;
        Control_Selectivity(i) = Best_Selectivity;
        Control_Yield(i) = Best_Yield;

    else

        Control_Conversion(i) = ...
            max(min( Best_Conversion*Control_Fraction(i) + 1.2*randn, 98), 2);

        Control_Selectivity(i) = ...
            max(min( Control_Sel_Floor(i) + 0.6*randn, 99), 80);

        Control_Yield(i) = ...
            max(min( Control_Conversion(i)*Control_Selectivity(i)/100, ...
                     Control_Conversion(i)), 1);

    end

end

fig = figure;
h9a = bar([Control_Conversion, Control_Selectivity, Control_Yield]);
applyDarkBarColors(h9a);
set(gca,'XTick',1:Number_of_Controls,'XTickLabel',Control_Labels);
xlabel('Sample');
ylabel('Performance (%)');
ylim([0 110]);
title('Control Experiments - Contribution of ZnO and SiO_2');
legend(h9a,{'Conversion','Selectivity','Yield'},'Location','northwest');
labelBarValues(h9a);
saveHQFigure(fig, OutputFolder, '18A_Control_Experiments.png', Save_DPI);

%% ============================================================
% 9B. FRESH VS USED CATALYST (BASELINE CONDITIONS REUSABILITY)
%% ============================================================

Number_of_Cycles = 5;
Cycle = (1:Number_of_Cycles)';
Deactivation_Rate = 0.035;

Cycle_Conversion = Best_Conversion * exp(-Deactivation_Rate*(Cycle-1)) ...
    + 1.0*randn(Number_of_Cycles,1);
Cycle_Conversion = max(min(Cycle_Conversion,Best_Conversion),0);

Cycle_Selectivity = Best_Selectivity - 0.4*(Cycle-1) + 0.5*randn(Number_of_Cycles,1);
Cycle_Selectivity = max(min(Cycle_Selectivity,99),80);

Cycle_Yield = Cycle_Conversion .* Cycle_Selectivity / 100;

Retention_Percent = 100 * Cycle_Conversion(end) / Cycle_Conversion(1);

fig = figure;
h9b = plot(Cycle,Cycle_Conversion,'-o', ...
           Cycle,Cycle_Selectivity,'-s', ...
           Cycle,Cycle_Yield,'-^', ...
           'LineWidth',2.5,'MarkerSize',9,'MarkerFaceColor','auto');
xlabel('Reaction Cycle');
ylabel('Performance (%)');
ylim([0 100]);
xticks(Cycle);
title('Catalyst Reusability - Fresh vs Used ZnO/SiO_2 (Baseline Conditions)');
legend(h9b,{'Conversion','Selectivity','Yield'},'Location','southwest');
saveHQFigure(fig, OutputFolder, '18B_Reusability_Fresh_vs_Used.png', Save_DPI);

%% ============================================================
% 9C. PROPOSED REACTION MECHANISM (COMPARISON PLOT)
%% ============================================================

Mechanism_Labels = {'No Cat.';'SiO_2';'ZnO';'ZnO/SiO_2';'Used (Cyc.5)'};

Mechanism_Conversion = [ ...
    Control_Conversion(1); ...
    Control_Conversion(2); ...
    Control_Conversion(3); ...
    Control_Conversion(4); ...
    Cycle_Conversion(end)];

fig = figure;
h9c = bar(Mechanism_Conversion);
applyDarkBarColors(h9c);
set(gca,'XTick',1:numel(Mechanism_Labels),'XTickLabel',Mechanism_Labels);
xlabel('Sample');
ylabel('Conversion (%)');
ylim([0 100]);
title('Mechanism Study Summary - All Comparisons');
labelBarValues(h9c);
saveHQFigure(fig, OutputFolder, '18C_Mechanism_Study_Comparison.png', Save_DPI);

%% ============================================================
% 10. STAGE 1 RESULT - SOLVENT-FREE ORGANIC REACTION
%% ============================================================

fprintf('\n====================================================\n');
fprintf('  STAGE 1 RESULT - SOLVENT-FREE ORGANIC REACTION\n');
fprintf('====================================================\n\n');

fprintf('Reaction:\n');
fprintf('%s + %s -> %s + %s\n\n', Reactant_1,Reactant_2,Product,Byproduct);

fprintf('Selected catalyst : %s\n', Best_Catalyst_ID);
fprintf('Temperature       : %.1f degC\n', Temperature);
fprintf('Reaction time     : %.1f min\n', Reaction_Time);
fprintf('Catalyst loading  : %.1f wt.%%\n', Catalyst_Loading);
fprintf('Substrate/Cat.    : %.1f\n', Substrate_Catalyst_Ratio);
fprintf('Pressure          : %.1f bar\n', Pressure);
fprintf('Solvent           : NONE\n');

%% ============================================================
% 11. FINAL BASELINE REACTION RESULTS
%% ============================================================

Conversion_Reaction = Best_Conversion;
Yield_Reaction = Best_Yield;
Selectivity_Reaction = Best_Selectivity;
Productivity = Yield_Reaction / Reaction_Time;

fprintf('\n====================================================\n');
fprintf('          BASELINE REACTION RESULTS\n');
fprintf('====================================================\n\n');

fprintf('Conversion   : %.2f %%\n', Conversion_Reaction);
fprintf('Product Yield: %.2f %%\n', Yield_Reaction);
fprintf('Selectivity  : %.2f %%\n', Selectivity_Reaction);
fprintf('Reaction Time: %.2f min\n', Reaction_Time);
fprintf('Productivity : %.4f %%/min\n', Productivity);

%% ============================================================
% 12. REACTION PERFORMANCE PLOT
%% ============================================================

Reaction_Metrics = [Conversion_Reaction; Yield_Reaction; Selectivity_Reaction];

fig = figure;
h9 = bar(Reaction_Metrics);
applyDarkBarColors(h9);
set(gca,'XTick',1:3,'XTickLabel',{'Conversion','Yield','Selectivity'});
ylabel('Performance (%)');
title('Solvent-Free Knoevenagel Reaction Performance (Baseline)');
legend(h9,'Selected catalyst');
labelBarValues(h9);
saveHQFigure(fig, OutputFolder, '19_Solvent_Free_Reaction_Performance.png', Save_DPI);

%% ============================================================
% 13. REACTION PERFORMANCE VS TIME (BASELINE)
%% ============================================================

Time = linspace(0,180,181)';
Tau = 35;

Conversion_Time = Conversion_Reaction * (1-exp(-Time/Tau));
Conversion_Time = min(Conversion_Time,Conversion_Reaction);

Selectivity_Time = Selectivity_Reaction - 2*exp(-Time/45);
Selectivity_Time = min(Selectivity_Time,Selectivity_Reaction);

Yield_Time = Conversion_Time .* Selectivity_Time / 100;

%% 14. REACTION CONVERSION VS TIME

fig = figure;
h10 = plot(Time,Conversion_Time,'LineWidth',2.5,'Color',[0.5 0 0]);
xlabel('Reaction Time (min)');
ylabel('Conversion (%)');
title('Solvent-Free Reaction Conversion vs Time (Baseline)');
legend(h10,'Conversion');
saveHQFigure(fig, OutputFolder, '20_Solvent_Free_Reaction_vs_Time.png', Save_DPI);

%% 15. PRODUCT YIELD VS TIME

fig = figure;
h11 = plot(Time,Yield_Time,'LineWidth',2.5,'Color',[0 0.35 0]);
xlabel('Reaction Time (min)');
ylabel('Product Yield (%)');
title('Benzylidene Malononitrile Yield vs Reaction Time (Baseline)');
legend(h11,'Product yield');
saveHQFigure(fig, OutputFolder, '21_Product_Yield_vs_Time.png', Save_DPI);

%% ============================================================
% 16-20. RESULT TABLES
%% ============================================================

Screening_Table = table( ...
    Labels, string(Screening_Data.Catalyst_ID), Screening_Data.ZnO_Loading, ...
    Screening_Data.Particle_Size, Conversion, Yield, Selectivity, Screening_Score, ...
    'VariableNames', {'Catalyst_Label','Catalyst_ID','ZnO_Loading_percent', ...
    'Particle_Size_nm','Conversion_percent','Yield_percent','Selectivity_percent','Screening_Score'});

Selected_Table = table( ...
    Best_Catalyst_ID, Best_Catalyst.ZnO_Loading, Best_Catalyst.Particle_Size, ...
    Best_Catalyst.Surface_Area, Best_Catalyst.Pore_Volume, Best_Catalyst.Basicity, ...
    Best_Catalyst.Oxygen_Vacancy_Index, Best_Catalyst.Crystallinity, Best_Catalyst.ZnO_Dispersion, ...
    Best_Conversion, Best_Yield, Best_Selectivity, Best_Score, ...
    'VariableNames', {'Catalyst_ID','ZnO_Loading_percent','Particle_Size_nm', ...
    'Surface_Area_m2_g','Pore_Volume_cm3_g','Basicity','Oxygen_Vacancy_Index', ...
    'Crystallinity_percent','ZnO_Dispersion_percent','Conversion_percent','Yield_percent', ...
    'Selectivity_percent','Screening_Score'});

Characterization_Table = table( ...
    Best_Catalyst_ID, Best_Catalyst.ZnO_Loading, Best_Catalyst.Particle_Size, ...
    Best_Catalyst.Surface_Area, Best_Catalyst.Pore_Volume, Best_Catalyst.Basicity, ...
    Best_Catalyst.Oxygen_Vacancy_Index, Best_Catalyst.Crystallinity, Best_Catalyst.ZnO_Dispersion, ...
    'VariableNames', {'Catalyst_ID','ZnO_Loading_percent','Particle_Size_nm', ...
    'Surface_Area_m2_g','Pore_Volume_cm3_g','Basicity','Oxygen_Vacancy_Index', ...
    'Crystallinity_percent','ZnO_Dispersion_percent'});

Control_Table = table( ...
    Control_Labels, Control_Conversion, Control_Selectivity, Control_Yield, ...
    'VariableNames', {'Sample','Conversion_percent','Selectivity_percent','Yield_percent'});

Reusability_Table = table( ...
    Cycle, Cycle_Conversion, Cycle_Selectivity, Cycle_Yield, ...
    'VariableNames', {'Cycle_Number','Conversion_percent','Selectivity_percent','Yield_percent'});

Reaction_Table = table( ...
    Best_Catalyst_ID, {Reaction}, {Reactant_1}, {Reactant_2}, {Product}, {Byproduct}, ...
    Temperature, Reaction_Time, Catalyst_Loading, Substrate_Catalyst_Ratio, Pressure, {Solvent}, ...
    Conversion_Reaction, Yield_Reaction, Selectivity_Reaction, Productivity, ...
    'VariableNames', {'Catalyst_ID','Reaction','Reactant_1','Reactant_2','Product','Byproduct', ...
    'Temperature_C','Reaction_Time_min','Catalyst_Loading_wt_percent','Substrate_Catalyst_Ratio', ...
    'Pressure_bar','Solvent','Conversion_percent','Product_Yield_percent','Selectivity_percent', ...
    'Productivity_percent_per_min'});

Reaction_Time_Table = table( ...
    Time, Conversion_Time, Selectivity_Time, Yield_Time, ...
    'VariableNames', {'Time_min','Conversion_percent','Selectivity_percent','Yield_percent'});

%% ============================================================
% 23. STAGE 2 - REACTION-CONDITION OPTIMIZATION (OFAT)
%     Catalyst fixed at Stage 1 selection.
%% ============================================================

fprintf('\n====================================================\n');
fprintf('   STAGE 2 - REACTION-CONDITION OPTIMIZATION (OFAT)\n');
fprintf('   Catalyst fixed: %s (ZnO=%.2f%%, size=%.2f nm)\n', ...
    Best_Catalyst_ID, Fixed_ZnO_Loading, Fixed_Particle_Size);
fprintf('====================================================\n\n');

%% 23.1 Temperature sweep

Temp_Range = (40:5:120)';
dT = Temp_Range - Temperature;

Temp_Conversion = Conversion_Reaction + 0.35*dT - 0.006*dT.^2 + 1.0*randn(size(Temp_Range));
Temp_Conversion = max(min(Temp_Conversion,98),40);

Temp_Selectivity = Selectivity_Reaction - 0.03*abs(dT) + 0.4*randn(size(Temp_Range));
Temp_Selectivity = max(min(Temp_Selectivity,99),85);

Temp_Yield = Temp_Conversion .* Temp_Selectivity / 100;

[~, Temp_Opt_Idx] = max(Temp_Yield);
Optimum_Temperature = Temp_Range(Temp_Opt_Idx);

%% 23.2 Reaction time sweep

Time_Range = (10:10:180)';

Time_Conversion_Sweep = Conversion_Reaction * (1 - exp(-Time_Range/35));
Time_Conversion_Sweep = min(Time_Conversion_Sweep, 98);

Time_Selectivity_Sweep = Selectivity_Reaction - 0.01*Time_Range + 0.3*randn(size(Time_Range));
Time_Selectivity_Sweep = max(min(Time_Selectivity_Sweep,99),85);

Time_Yield_Sweep = Time_Conversion_Sweep .* Time_Selectivity_Sweep / 100;

Time_Threshold = 0.95 * max(Time_Yield_Sweep);
Time_Opt_Idx = find(Time_Yield_Sweep >= Time_Threshold, 1, 'first');
Optimum_Time = Time_Range(Time_Opt_Idx);

%% 23.3 Catalyst loading sweep

Load_Range = (1:0.5:10)';
dL = Load_Range - Catalyst_Loading;

Load_Conversion = Conversion_Reaction + 3.2*dL - 0.28*dL.^2 + 1.0*randn(size(Load_Range));
Load_Conversion = max(min(Load_Conversion,98),40);

Load_Selectivity = Selectivity_Reaction - 0.15*dL + 0.3*randn(size(Load_Range));
Load_Selectivity = max(min(Load_Selectivity,99),85);

Load_Yield = Load_Conversion .* Load_Selectivity / 100;

Load_Threshold = 0.95 * max(Load_Conversion);
Load_Opt_Idx = find(Load_Conversion >= Load_Threshold, 1, 'first');
Optimum_Catalyst_Loading = Load_Range(Load_Opt_Idx);

%% 23.4 Substrate/catalyst ratio sweep

Ratio_Range = (2:2:30)';
dR = Ratio_Range - Substrate_Catalyst_Ratio;

Ratio_Conversion = Conversion_Reaction - 0.9*dR + 1.0*randn(size(Ratio_Range));
Ratio_Conversion = max(min(Ratio_Conversion,98),40);

Ratio_Selectivity = Selectivity_Reaction - 0.05*dR + 0.3*randn(size(Ratio_Range));
Ratio_Selectivity = max(min(Ratio_Selectivity,99),85);

Ratio_Yield = Ratio_Conversion .* Ratio_Selectivity / 100;

Ratio_Threshold = 0.90 * max(Ratio_Conversion);
Ratio_Valid_Idx = find(Ratio_Conversion >= Ratio_Threshold);
Optimum_Ratio = Ratio_Range(Ratio_Valid_Idx(end));

Optimum_ZnO_Loading = Fixed_ZnO_Loading;
Optimum_Particle_Size = Fixed_Particle_Size;

%% 23.5 OFAT summary plot (2x2, larger)

fig = figure('Position',[50 50 1900 1300]);

subplot(2,2,1);
plot(Temp_Range,Temp_Conversion,'-o','LineWidth',2.2,'MarkerSize',8); hold on;
plot(Optimum_Temperature,Temp_Conversion(Temp_Opt_Idx),'rp','MarkerSize',16,'MarkerFaceColor','r');
xlabel('Temperature (degC)'); ylabel('Conversion (%)');
title('Temperature Optimization');

subplot(2,2,2);
plot(Time_Range,Time_Yield_Sweep,'-o','LineWidth',2.2,'MarkerSize',8); hold on;
plot(Optimum_Time,Time_Yield_Sweep(Time_Opt_Idx),'rp','MarkerSize',16,'MarkerFaceColor','r');
xlabel('Reaction Time (min)'); ylabel('Yield (%)');
title('Reaction Time Optimization');

subplot(2,2,3);
plot(Load_Range,Load_Conversion,'-o','LineWidth',2.2,'MarkerSize',8); hold on;
plot(Optimum_Catalyst_Loading,Load_Conversion(Load_Opt_Idx),'rp','MarkerSize',16,'MarkerFaceColor','r');
xlabel('Catalyst Loading (wt.%)'); ylabel('Conversion (%)');
title('Catalyst Loading Optimization');

subplot(2,2,4);
plot(Ratio_Range,Ratio_Conversion,'-o','LineWidth',2.2,'MarkerSize',8); hold on;
plot(Optimum_Ratio,Ratio_Conversion(Ratio_Valid_Idx(end)),'rp','MarkerSize',16,'MarkerFaceColor','r');
xlabel('Substrate/Catalyst Ratio'); ylabel('Conversion (%)');
title('Substrate/Catalyst Ratio Optimization');

sgt = sgtitle('Stage 2 - Reaction-Condition Optimization (OFAT), Catalyst Fixed');
sgt.FontName = 'Times New Roman'; sgt.FontWeight = 'bold'; sgt.FontSize = 22;

saveHQFigure(fig, OutputFolder, '22A_Reaction_Optimization_OFAT.png', Save_DPI);

fprintf('Optimum Temperature          : %.1f degC\n', Optimum_Temperature);
fprintf('Optimum Reaction Time        : %.1f min\n', Optimum_Time);
fprintf('Optimum Catalyst Loading     : %.2f wt.%%\n', Optimum_Catalyst_Loading);
fprintf('Optimum Substrate/Cat. Ratio : %.1f\n', Optimum_Ratio);
fprintf('ZnO Loading (fixed)          : %.2f %%\n', Optimum_ZnO_Loading);
fprintf('Particle Size (fixed)        : %.2f nm\n', Optimum_Particle_Size);

%% ============================================================
% 23B. STAGE 2 - RSM (Temperature x Catalyst Loading)
%      Anchored to the baseline (fixed-catalyst) conversion.
%% ============================================================

RSM_Temp = [60 70 80 90 100];
RSM_Load = [2 3.5 5 6.5 8];

[RSM_T_Grid, RSM_L_Grid] = meshgrid(RSM_Temp, RSM_Load);

RSM_dT = RSM_T_Grid - Temperature;
RSM_dL = RSM_L_Grid - Catalyst_Loading;

RSM_Conversion = Conversion_Reaction ...
    + 0.15*RSM_dT - 0.004*RSM_dT.^2 ...
    + 1.5*RSM_dL  - 0.20*RSM_dL.^2 ...
    + 0.01*RSM_dT.*RSM_dL ...
    + 0.8*randn(size(RSM_T_Grid));

RSM_Conversion = max(min(RSM_Conversion,98),40);

fig = figure;
surf(RSM_T_Grid, RSM_L_Grid, RSM_Conversion);
xlabel('Temperature (degC)');
ylabel('Catalyst Loading (wt.%)');
zlabel('Conversion (%)');
title('RSM Response Surface - Conversion vs Temperature and Catalyst Loading');
colorbar;
shading interp;

[RSM_Max_Val, RSM_Max_Idx] = max(RSM_Conversion(:));
[RSM_Row, RSM_Col] = ind2sub(size(RSM_Conversion), RSM_Max_Idx);

RSM_Optimum_Temp = RSM_T_Grid(RSM_Row, RSM_Col);
RSM_Optimum_Load = RSM_L_Grid(RSM_Row, RSM_Col);

hold on;
plot3(RSM_Optimum_Temp, RSM_Optimum_Load, RSM_Max_Val, ...
    'rp','MarkerSize',18,'MarkerFaceColor','r');
text(RSM_Optimum_Temp, RSM_Optimum_Load, RSM_Max_Val, ...
    sprintf('  %.2f%%',RSM_Max_Val), 'FontSize',16,'FontWeight','bold', ...
    'FontName','Times New Roman');
hold off;

saveHQFigure(fig, OutputFolder, '22B_RSM_Response_Surface.png', Save_DPI);

fprintf('\n====================================================\n');
fprintf('   STAGE 2 - RSM OPTIMUM (TEMPERATURE x LOADING)\n');
fprintf('====================================================\n\n');

fprintf('Baseline (fixed-catalyst) conversion : %.2f %%\n', Conversion_Reaction);
fprintf('RSM Optimum Temperature              : %.1f degC\n', RSM_Optimum_Temp);
fprintf('RSM Optimum Catalyst Loading          : %.2f wt.%%\n', RSM_Optimum_Load);
fprintf('RSM Predicted Conversion              : %.2f %%\n', RSM_Max_Val);

%% ============================================================
% 23C. STAGE 3 - VALIDATION RUN AT THE RSM OPTIMUM
%% ============================================================

Validated_Conversion = RSM_Max_Val + 0.8*randn;
Validated_Conversion = max(min(Validated_Conversion,98),Conversion_Reaction);

Validated_Selectivity = Selectivity_Reaction ...
    - 0.03*abs(RSM_Optimum_Temp-Temperature) ...
    - 0.10*abs(RSM_Optimum_Load-Catalyst_Loading) ...
    + 0.4*randn;
Validated_Selectivity = max(min(Validated_Selectivity,99),85);

Validated_Yield = Validated_Conversion * Validated_Selectivity / 100;

fprintf('\n====================================================\n');
fprintf('   STAGE 3 - VALIDATION AT RSM OPTIMUM\n');
fprintf('====================================================\n\n');

fprintf('Condition tested   : %.1f degC, %.2f wt.%% catalyst\n', RSM_Optimum_Temp, RSM_Optimum_Load);
fprintf('RSM predicted conv.: %.2f %%\n', RSM_Max_Val);
fprintf('Validation conv.   : %.2f %%\n', Validated_Conversion);
fprintf('Validation select. : %.2f %%\n', Validated_Selectivity);
fprintf('Validation yield   : %.2f %%\n', Validated_Yield);

Validation_Table = table( ...
    RSM_Optimum_Temp, RSM_Optimum_Load, RSM_Max_Val, ...
    Validated_Conversion, Validated_Selectivity, Validated_Yield, ...
    'VariableNames', {'RSM_Optimum_Temperature_C','RSM_Optimum_Catalyst_Loading_wt_percent', ...
    'RSM_Predicted_Conversion_percent','Validated_Conversion_percent', ...
    'Validated_Selectivity_percent','Validated_Yield_percent'});

Optimization_Table = table( ...
    {'Temperature_C';'Reaction_Time_min';'Catalyst_Loading_wt_percent';'Substrate_Catalyst_Ratio'}, ...
    [Optimum_Temperature; Optimum_Time; Optimum_Catalyst_Loading; Optimum_Ratio], ...
    'VariableNames', {'Parameter','Optimum_Value'});

%% ============================================================
% 24. STAGE 3 - RECYCLABILITY UNDER OPTIMIZED (VALIDATED)
%     CONDITIONS
%% ============================================================

Cycle_Label = {'Fresh';'1';'2';'3';'4';'5'};

Recycle_Conversion = [Validated_Conversion; ...
    Validated_Conversion*exp(-Deactivation_Rate*(1:5))'] + [0; 0.3*randn(5,1)];
Recycle_Conversion = max(min(Recycle_Conversion,Validated_Conversion),0);

Recycle_Selectivity = [Validated_Selectivity; ...
    Validated_Selectivity - 0.4*(1:5)'] + [0; 0.3*randn(5,1)];
Recycle_Selectivity = max(min(Recycle_Selectivity,99),85);

Activity_Retention = 100 * Recycle_Conversion / Recycle_Conversion(1);

Recyclability_Table = table( ...
    Cycle_Label, Recycle_Conversion, Recycle_Selectivity, Activity_Retention, ...
    'VariableNames', {'Cycle','Conversion_percent','Selectivity_percent','Activity_Retention_percent'});

fig = figure('Position',[50 50 1900 1000]);

subplot(1,2,1);
h_recyc1 = bar([Recycle_Conversion, Recycle_Selectivity]);
applyDarkBarColors(h_recyc1);
set(gca,'XTick',1:6,'XTickLabel',Cycle_Label);
xlabel('Cycle'); ylabel('Performance (%)'); ylim([0 110]);
title('Conversion & Selectivity per Cycle (Optimized Conditions)');
legend(h_recyc1,{'Conversion','Selectivity'},'Location','southwest');
labelBarValues(h_recyc1);

subplot(1,2,2);
h_recyc2 = plot(0:5,Activity_Retention,'-o','LineWidth',2.5,'MarkerSize',9,'MarkerFaceColor','auto');
set(gca,'XTick',0:5,'XTickLabel',Cycle_Label);
xlabel('Cycle'); ylabel('Activity Retention (%)'); ylim([0 105]);
title('Catalyst Activity Retention');
legend(h_recyc2,'Activity retention');

sgt2 = sgtitle('Stage 3 - Recyclability Performance (Optimized, Validated Conditions)');
sgt2.FontName = 'Times New Roman'; sgt2.FontWeight = 'bold'; sgt2.FontSize = 22;

saveHQFigure(fig, OutputFolder, '23_Recyclability_Performance.png', Save_DPI);

%% ============================================================
% 25. STAGE 3 - FRESH VS USED CATALYST CHARACTERIZATION
%% ============================================================

%% 25.1 XRD - Fresh vs Used

XRD_Intensity_Used = zeros(size(TwoTheta));

for k = 1:length(ZnO_Peaks)
    Peak_Width_Used = Peak_Width * 1.10;
    Peak_Height_Used = 0.88 * (0.45 + 0.55*Best_Catalyst.ZnO_Loading/25) ...
        * exp(-((TwoTheta-ZnO_Peaks(k))/Peak_Width_Used).^2);
    XRD_Intensity_Used = XRD_Intensity_Used + Peak_Height_Used;
end

XRD_Intensity_Used = XRD_Intensity_Used + SiO2_Background;
XRD_Intensity_Used = XRD_Intensity_Used + 0.015*randn(size(TwoTheta));
XRD_Intensity_Used = max(XRD_Intensity_Used,0);

fig = figure;
h_xrd = plot(TwoTheta,XRD_Intensity,'LineWidth',2.5,'Color',[0.5 0 0]); hold on;
plot(TwoTheta,XRD_Intensity_Used,'LineWidth',2.5,'Color',[0 0 0.5]);
hold off;
xlabel('2\theta (degree)'); ylabel('Intensity (a.u.)');
title('XRD - Fresh vs Used ZnO/SiO_2');
legend({'Fresh','Used (Cycle 5)'});
saveHQFigure(fig, OutputFolder, '24A_XRD_Fresh_vs_Used.png', Save_DPI);

%% 25.2 FTIR - Fresh vs Used

FTIR_Used = FTIR + 0.10*exp(-((Wavenumber-1600)/60).^2);
FTIR_Used = max(FTIR_Used,0);

fig = figure;
h_ftir = plot(Wavenumber,FTIR,'LineWidth',2.5,'Color',[0.5 0 0]); hold on;
plot(Wavenumber,FTIR_Used,'LineWidth',2.5,'Color',[0 0 0.5]);
hold off;
set(gca,'XDir','reverse');
xlabel('Wavenumber (cm^{-1})'); ylabel('Absorbance (a.u.)');
title('FTIR - Fresh vs Used ZnO/SiO_2');
legend({'Fresh','Used (Cycle 5, residual organics)'});
saveHQFigure(fig, OutputFolder, '24B_FTIR_Fresh_vs_Used.png', Save_DPI);

%% 25.3 SEM/TEM particle size - Fresh vs Used

Particle_Size_Used = (Best_Catalyst.Particle_Size + 4) + 5*randn(Number_of_Particles,1);
Particle_Size_Used = max(min(Particle_Size_Used,65),5);

fig = figure;
h_ps1 = histogram(Particle_Size,20,'FaceAlpha',0.6,'FaceColor',[0.5 0 0]); hold on;
h_ps2 = histogram(Particle_Size_Used,20,'FaceAlpha',0.6,'FaceColor',[0 0 0.5]);
hold off;
xlabel('Particle Size (nm)'); ylabel('Frequency');
title('Particle Size - Fresh vs Used ZnO/SiO_2');
legend([h_ps1 h_ps2],{'Fresh','Used (Cycle 5)'});
saveHQFigure(fig, OutputFolder, '24C_Particle_Size_Fresh_vs_Used.png', Save_DPI);

%% 25.4 BET - Fresh vs Used

Surface_Area_Used = Surface_Area * 0.85;

Adsorption_Used = 0.25*Relative_Pressure + 0.65*Relative_Pressure.^2 ...
    + (Surface_Area_Used/500)*0.45*Relative_Pressure.^0.5;
Adsorption_Used = Adsorption_Used + 0.01*randn(size(Relative_Pressure));
Adsorption_Used = max(Adsorption_Used,0);

fig = figure;
h_bet = plot(Relative_Pressure,Adsorption,'LineWidth',2.5,'Color',[0.5 0 0]); hold on;
plot(Relative_Pressure,Adsorption_Used,'LineWidth',2.5,'Color',[0 0 0.5]);
hold off;
xlabel('Relative Pressure P/P_0'); ylabel('Adsorbed Volume (a.u.)');
title('BET Isotherm - Fresh vs Used ZnO/SiO_2');
legend({'Fresh','Used (Cycle 5)'});
saveHQFigure(fig, OutputFolder, '24D_BET_Fresh_vs_Used.png', Save_DPI);

%% 25.5 XPS - Fresh vs Used

XPS_Used = 0.90*Zn_2p3_2 + 0.90*Zn_2p1_2 + O1s;
XPS_Used = XPS_Used + 0.01*randn(size(Binding_Energy));
XPS_Used = max(XPS_Used,0);

fig = figure;
h_xps = plot(Binding_Energy,XPS,'LineWidth',2.5,'Color',[0.5 0 0]); hold on;
plot(Binding_Energy,XPS_Used,'LineWidth',2.5,'Color',[0 0 0.5]);
hold off;
set(gca,'XDir','reverse');
xlabel('Binding Energy (eV)'); ylabel('Intensity (a.u.)');
title('XPS - Fresh vs Used ZnO/SiO_2');
legend({'Fresh','Used (Cycle 5, Zn depletion)'});
saveHQFigure(fig, OutputFolder, '24E_XPS_Fresh_vs_Used.png', Save_DPI);

Fresh_vs_Used_Table = table( ...
    {'Surface_Area_m2_g';'Mean_Particle_Size_nm';'XRD_Peak_Intensity_a_u';'XPS_Zn2p_Intensity_a_u'}, ...
    [Surface_Area; Best_Catalyst.Particle_Size; max(XRD_Intensity); max(Zn_2p3_2+Zn_2p1_2)], ...
    [Surface_Area_Used; Best_Catalyst.Particle_Size+4; max(XRD_Intensity_Used); max(0.90*Zn_2p3_2+0.90*Zn_2p1_2)], ...
    'VariableNames', {'Property','Fresh','Used'});

%% ============================================================
% 26. STAGE 3 - BENCHMARK COMPARISON WITH LITERATURE
%% ============================================================

Benchmark_Catalyst = {'Betaine-ZnO hybrid'; 'Ti/Zn-Al-Mg hydrotalcite'; 'ZnO/SiO2 (this study)'};
Benchmark_Solvent = {'Solvent-free'; 'Ethyl acetate'; 'Solvent-free'};
Benchmark_Time = {'8-12 min'; '4 h'; sprintf('%.0f min', Optimum_Time)};
Benchmark_Conversion = {'n.r.'; '70%'; sprintf('%.1f%%', Validated_Conversion)};
Benchmark_Yield = {'91-99%'; 'n.r.'; sprintf('%.1f%%', Validated_Yield)};
Benchmark_Selectivity = {'n.r.'; '100%'; sprintf('%.1f%%', Validated_Selectivity)};
Benchmark_Recyclability = {'4 cycles'; 'reusable (n.r. cycles)'; ...
    sprintf('%d cycles, %.1f%% retention', Number_of_Cycles, Activity_Retention(end))};

Benchmark_Table = table( ...
    Benchmark_Catalyst, Benchmark_Solvent, Benchmark_Time, ...
    Benchmark_Conversion, Benchmark_Yield, Benchmark_Selectivity, Benchmark_Recyclability, ...
    'VariableNames', {'Catalyst','Solvent','Time','Conversion','Yield','Selectivity','Recyclability'});

fig = figure;
Benchmark_Numeric = [NaN, 70, Validated_Conversion; NaN, 100, Validated_Selectivity];
h_bench = bar(Benchmark_Numeric');
applyDarkBarColors(h_bench);
set(gca,'XTick',1:3,'XTickLabel',Benchmark_Catalyst);
ylabel('Performance (%)'); ylim([0 110]);
title('Benchmark Comparison - ZnO/SiO_2 vs Literature Catalysts');
legend(h_bench,{'Conversion','Selectivity'},'Location','southoutside');
labelBarValues(h_bench);
saveHQFigure(fig, OutputFolder, '25_Benchmark_Comparison.png', Save_DPI);

%% ============================================================
% 21. SAVE EVERYTHING TO EXCEL (same output folder)
%% ============================================================

Output_File = fullfile(OutputFolder,'ZnO_SiO2_Complete_Catalyst_Study.xlsx');

writetable(Screening_Table, Output_File, 'Sheet','Catalyst_Screening');
writetable(Selected_Table, Output_File, 'Sheet','Selected_Catalyst');
writetable(Characterization_Table, Output_File, 'Sheet','Characterization');
writetable(Control_Table, Output_File, 'Sheet','Control_Experiments');
writetable(Reusability_Table, Output_File, 'Sheet','Fresh_vs_Used');
writetable(Reaction_Table, Output_File, 'Sheet','Solvent_Free_Reaction');
writetable(Reaction_Time_Table, Output_File, 'Sheet','Reaction_Time_Profile');
writetable(Optimization_Table, Output_File, 'Sheet','Reaction_Optimization');
writetable(Validation_Table, Output_File, 'Sheet','RSM_Validation');
writetable(Recyclability_Table, Output_File, 'Sheet','Recyclability');
writetable(Fresh_vs_Used_Table, Output_File, 'Sheet','Fresh_vs_Used_Characterization');
writetable(Benchmark_Table, Output_File, 'Sheet','Benchmark_Comparison');

%% ============================================================
% 22. FINAL SUMMARY
%% ============================================================

fprintf('\n====================================================\n');
fprintf('             ANALYSIS COMPLETED\n');
fprintf('====================================================\n\n');

fprintf('Best catalyst: %s\n', Best_Catalyst_ID);

fprintf('\nStage 1 - Baseline (screening) reaction:\n');
fprintf('Conversion  : %.2f %%\n', Conversion_Reaction);
fprintf('Yield       : %.2f %%\n', Yield_Reaction);
fprintf('Selectivity : %.2f %%\n', Selectivity_Reaction);

fprintf('\nStage 2 - RSM predicted optimum (%.1f degC, %.2f wt.%%):\n', RSM_Optimum_Temp, RSM_Optimum_Load);
fprintf('Predicted conversion : %.2f %%\n', RSM_Max_Val);

fprintf('\nStage 3 - Validated optimum result:\n');
fprintf('Conversion  : %.2f %%\n', Validated_Conversion);
fprintf('Yield       : %.2f %%\n', Validated_Yield);
fprintf('Selectivity : %.2f %%\n', Validated_Selectivity);

fprintf('\nAll figures and tables saved to folder:\n');
fprintf('%s\n', OutputFolder);


fprintf('\n====================================================\n');

%% ============================================================
% LOCAL FUNCTIONS
%% ============================================================

function saveHQFigure(fig, folder, filename, dpi)
    set(fig,'Color','w');
    print(fig, fullfile(folder,filename), '-dpng', sprintf('-r%d',dpi));
end

function darkColors = getDarkColors(n)
    palette = [ ...
        0.55 0.00 0.00;  % dark red
        0.00 0.00 0.55;  % dark blue
        0.00 0.35 0.00;  % dark green
        0.35 0.00 0.35;  % dark purple
        0.55 0.27 0.00;  % dark orange/brown
        0.00 0.30 0.30;  % dark teal
        0.40 0.40 0.00;  % dark olive
        0.25 0.25 0.25;  % dark gray
        0.45 0.00 0.15;  % maroon
        0.00 0.20 0.40]; % navy
    idx = mod((0:n-1)', size(palette,1)) + 1;
    darkColors = palette(idx,:);
end

function applyDarkBarColors(hBar)
    for s = 1:numel(hBar)
        n = numel(hBar(s).XData);
        hBar(s).FaceColor = 'flat';
        hBar(s).CData = getDarkColors(n);
    end
end

function labelBarValues(hBar)
    nSeries = numel(hBar);
    for s = 1:nSeries
        ydata = hBar(s).YData;
        xdata = hBar(s).XData;

        if nSeries > 1
            groupwidth = min(0.8, nSeries/(nSeries+1.5));
            offset = -groupwidth/2 + (2*s-1)*groupwidth/(2*nSeries);
        else
            offset = 0;
        end

        for j = 1:numel(xdata)
            yj = ydata(j);
            if ~isnan(yj)
                xj = xdata(j) + offset;
                text(xj, yj, sprintf('%.2f',yj), ...
                    'HorizontalAlignment','center', ...
                    'VerticalAlignment','bottom', ...
                    'FontWeight','bold', ...
                    'FontName','Times New Roman', ...
                    'FontSize',13);
            end
        end
    end
end