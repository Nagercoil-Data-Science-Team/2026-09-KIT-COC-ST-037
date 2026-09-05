%% ============================================================
% SYNTHETIC ZnO/SiO2 CATALYST-REACTION DATASET
% Solvent-Free Knoevenagel Condensation
% Benzaldehyde + Malononitrile
% =============================================================

clear;
clc;
close all;

rng(42);   % Reproducibility

%% ============================================================
% 1. DATASET SIZE
% =============================================================

N = 1000;

%% ============================================================
% 2. CATALYST DESCRIPTORS
% =============================================================

% ZnO loading on SiO2 (%)
ZnO_Loading = 5 + (25 - 5) .* rand(N,1);

% ZnO particle size (nm)
Particle_Size = 5 + (50 - 5) .* rand(N,1);

% Surface area (m2/g)
Surface_Area = 100 + (500 - 100) .* rand(N,1);

% Pore volume (cm3/g)
Pore_Volume = 0.10 + (1.00 - 0.10) .* rand(N,1);

% Relative acidity
Acidity = 0.10 + (1.00 - 0.10) .* rand(N,1);

% Relative basicity
Basicity = 0.20 + (1.00 - 0.20) .* rand(N,1);

% Zn oxidation state
% ZnO is primarily Zn(II)
Zn_Oxidation_State = 2.0 + 0.02 .* randn(N,1);

% Oxygen vacancy index
Oxygen_Vacancy_Index = 0.05 + (0.80 - 0.05) .* rand(N,1);

% Crystallinity (%)
Crystallinity = 50 + (99 - 50) .* rand(N,1);

% ZnO dispersion (%)
ZnO_Dispersion = 50 + (99 - 50) .* rand(N,1);

%% ============================================================
% 3. REACTION DESCRIPTORS
% ============================================================

Reaction = repmat("Knoevenagel condensation",N,1);

Aldehyde = repmat("Benzaldehyde",N,1);

Active_Methylene = repmat("Malononitrile",N,1);

Mechanism = repmat("Base-catalyzed condensation",N,1);

Solvent_Free = repmat("Yes",N,1);

%% ============================================================
% 4. REACTION CONDITIONS
% ============================================================

% Catalyst loading (wt.%)
Catalyst_Loading = 0.5 + (10 - 0.5) .* rand(N,1);

% Reaction temperature (degree C)
Temperature = 40 + (120 - 40) .* rand(N,1);

% Reaction time (min)
Reaction_Time = 5 + (180 - 5) .* rand(N,1);

% Substrate-to-catalyst ratio
Substrate_Catalyst_Ratio = 2 + (20 - 2) .* rand(N,1);

% Pressure (bar)
Pressure = 1.0 + (5.0 - 1.0) .* rand(N,1);

%% ============================================================
% 5. REGENERATION / CALCINATION
% =============================================================

Calcination_Temperature = 300 + (600 - 300) .* rand(N,1);

Regeneration = strings(N,1);

for i = 1:N

    if Calcination_Temperature(i) < 400

        Regeneration(i) = "Mild regeneration";

    elseif Calcination_Temperature(i) < 500

        Regeneration(i) = "Moderate regeneration";

    else

        Regeneration(i) = "High-temperature regeneration";

    end

end

%% ============================================================
% 6. CATALYST ID
% =============================================================

Catalyst_ID = strings(N,1);

for i = 1:N
    Catalyst_ID(i) = sprintf("ZnO-SiO2-%03d",i);
end

%% ============================================================
% 7. SYNTHETIC PERFORMANCE MODEL
% =============================================================

% Temperature effect
Temperature_Effect = exp( ...
    -((Temperature - 80).^2) ./ (2 * 25^2));

% Reaction-time effect
Time_Effect = 1 - exp(-Reaction_Time ./ 50);

% Catalyst-property effect
Catalyst_Effect = ...
      0.30 .* Basicity ...
    + 0.20 .* (ZnO_Dispersion ./ 100) ...
    + 0.15 .* (Surface_Area ./ 500) ...
    + 0.15 .* Oxygen_Vacancy_Index ...
    + 0.10 .* (ZnO_Loading ./ 25) ...
    + 0.10 .* (Crystallinity ./ 100);

% Catalyst-loading effect
Loading_Effect = exp( ...
    -((Catalyst_Loading - 4).^2) ./ (2 * 2.5^2));

% Particle-size effect
Particle_Effect = exp( ...
    -((Particle_Size - 15).^2) ./ (2 * 12^2));

%% ============================================================
% 8. CONVERSION
% =============================================================

Conversion = ...
      45 ...
    + 35 .* Temperature_Effect ...
    + 12 .* Time_Effect ...
    + 12 .* Catalyst_Effect ...
    + 8 .* Loading_Effect ...
    + 5 .* Particle_Effect ...
    + 3 .* randn(N,1);

% Keep conversion within physical range
Conversion = max(0,min(99.5,Conversion));

%% ============================================================
% 9. SELECTIVITY
% =============================================================

Selectivity = ...
      75 ...
    + 12 .* Basicity ...
    + 5 .* (ZnO_Dispersion ./ 100) ...
    + 4 .* (Surface_Area ./ 500) ...
    + 3 .* Oxygen_Vacancy_Index ...
    + 2 .* (Crystallinity ./ 100) ...
    + 2 .* randn(N,1);

% Keep selectivity within range
Selectivity = max(50,min(99.9,Selectivity));

%% ============================================================
% 10. YIELD
% =============================================================

Yield = Conversion .* Selectivity ./ 100;

% Add small variation
Yield = Yield + 1.5 .* randn(N,1);

% Yield cannot exceed conversion
Yield = min(Yield,Conversion);

% Keep yield within range
Yield = max(0,min(99.5,Yield));

%% ============================================================
% 11. PERFORMANCE CATEGORY
% =============================================================

Performance_Category = strings(N,1);

for i = 1:N

    if Conversion(i) >= 90 && ...
       Yield(i) >= 85 && ...
       Selectivity(i) >= 90

        Performance_Category(i) = "Excellent";

    elseif Conversion(i) >= 75 && ...
           Yield(i) >= 70

        Performance_Category(i) = "Good";

    elseif Conversion(i) >= 60 && ...
           Yield(i) >= 55

        Performance_Category(i) = "Moderate";

    else

        Performance_Category(i) = "Low";

    end

end

%% ============================================================
% 12. CREATE MAIN DATASET TABLE
% =============================================================

Dataset = table( ...
    Catalyst_ID, ...
    ZnO_Loading, ...
    Particle_Size, ...
    Surface_Area, ...
    Pore_Volume, ...
    Acidity, ...
    Basicity, ...
    Zn_Oxidation_State, ...
    Oxygen_Vacancy_Index, ...
    Crystallinity, ...
    ZnO_Dispersion, ...
    Reaction, ...
    Aldehyde, ...
    Active_Methylene, ...
    Mechanism, ...
    Solvent_Free, ...
    Catalyst_Loading, ...
    Temperature, ...
    Reaction_Time, ...
    Substrate_Catalyst_Ratio, ...
    Pressure, ...
    Calcination_Temperature, ...
    Regeneration, ...
    Conversion, ...
    Yield, ...
    Selectivity, ...
    Performance_Category);

%% ============================================================
% 13. DISPLAY DATASET
% =============================================================

disp(' ');
disp('============================================================');
disp('      ZnO/SiO2 SYNTHETIC CATALYST DATASET');
disp('============================================================');

disp(Dataset(1:10,:));

%% ============================================================
% 14. DATASET STATISTICS
% =============================================================

disp(' ');
disp('================ DATASET INFORMATION =================');

fprintf('Total samples       : %d\n',height(Dataset));
fprintf('Total columns       : %d\n',width(Dataset));

fprintf('\nMean Conversion     : %.2f %%\n',mean(Conversion));
fprintf('Mean Yield          : %.2f %%\n',mean(Yield));
fprintf('Mean Selectivity    : %.2f %%\n',mean(Selectivity));

fprintf('\nMaximum Conversion  : %.2f %%\n',max(Conversion));
fprintf('Maximum Yield       : %.2f %%\n',max(Yield));
fprintf('Maximum Selectivity : %.2f %%\n',max(Selectivity));

fprintf('\nMinimum Conversion  : %.2f %%\n',min(Conversion));
fprintf('Minimum Yield       : %.2f %%\n',min(Yield));
fprintf('Minimum Selectivity : %.2f %%\n',min(Selectivity));

%% ============================================================
% 15. SAVE MAIN DATASET TO EXCEL
% =============================================================

Excel_File = 'ZnO_SiO2_Synthetic_Catalyst_Dataset.xlsx';

writetable(Dataset,Excel_File,'Sheet','Main_Dataset');

%% ============================================================
% 16. SUMMARY SHEET
% =============================================================

Metric = { ...
    'Number of Samples';
    'Number of Features';
    'Mean Conversion (%)';
    'Mean Yield (%)';
    'Mean Selectivity (%)';
    'Maximum Conversion (%)';
    'Maximum Yield (%)';
    'Maximum Selectivity (%)';
    'Minimum Conversion (%)';
    'Minimum Yield (%)';
    'Minimum Selectivity (%)'};

Value = [ ...
    height(Dataset);
    width(Dataset);
    mean(Conversion);
    mean(Yield);
    mean(Selectivity);
    max(Conversion);
    max(Yield);
    max(Selectivity);
    min(Conversion);
    min(Yield);
    min(Selectivity)];

Summary = table(Metric,Value);

writetable(Summary,Excel_File,'Sheet','Summary');

%% ============================================================
% 17. FEATURE DESCRIPTION SHEET
% =============================================================

Feature_Name = { ...
    'ZnO Loading (%)';
    'Particle Size (nm)';
    'Surface Area (m2/g)';
    'Pore Volume (cm3/g)';
    'Acidity';
    'Basicity';
    'Zn Oxidation State';
    'Oxygen Vacancy Index';
    'Crystallinity (%)';
    'ZnO Dispersion (%)';
    'Catalyst Loading (wt.%)';
    'Temperature (C)';
    'Reaction Time (min)';
    'Substrate/Catalyst Ratio';
    'Pressure (bar)';
    'Calcination Temperature (C)';
    'Conversion (%)';
    'Yield (%)';
    'Selectivity (%)'};

Feature_Type = { ...
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Catalyst';
    'Reaction';
    'Reaction';
    'Reaction';
    'Reaction';
    'Reaction';
    'Regeneration';
    'Target';
    'Target';
    'Target'};

Feature_Description = { ...
    'ZnO amount supported on SiO2';
    'Average ZnO nanoparticle size';
    'Specific surface area';
    'Total pore volume';
    'Relative surface acidity';
    'Relative surface basicity';
    'Zn oxidation state';
    'Relative oxygen vacancy level';
    'Relative crystallinity';
    'ZnO dispersion on SiO2';
    'Amount of catalyst used';
    'Reaction temperature';
    'Reaction duration';
    'Substrate-to-catalyst ratio';
    'Reaction pressure';
    'Catalyst regeneration temperature';
    'Reactant conversion';
    'Desired product yield';
    'Desired product selectivity'};

Feature_Table = table( ...
    Feature_Name, ...
    Feature_Type, ...
    Feature_Description);

writetable(Feature_Table, ...
    Excel_File, ...
    'Sheet','Feature_Description');

%% ============================================================
% 18. CORRELATION MATRIX
% =============================================================

Numeric_Data = Dataset{:, ...
    {'ZnO_Loading',...
     'Particle_Size',...
     'Surface_Area',...
     'Pore_Volume',...
     'Acidity',...
     'Basicity',...
     'Zn_Oxidation_State',...
     'Oxygen_Vacancy_Index',...
     'Crystallinity',...
     'ZnO_Dispersion',...
     'Catalyst_Loading',...
     'Temperature',...
     'Reaction_Time',...
     'Substrate_Catalyst_Ratio',...
     'Pressure',...
     'Conversion',...
     'Yield',...
     'Selectivity'}};

Correlation_Matrix = corrcoef(Numeric_Data);

Variable_Names = { ...
    'ZnO_Loading',...
    'Particle_Size',...
    'Surface_Area',...
    'Pore_Volume',...
    'Acidity',...
    'Basicity',...
    'Zn_Oxidation_State',...
    'Oxygen_Vacancy_Index',...
    'Crystallinity',...
    'ZnO_Dispersion',...
    'Catalyst_Loading',...
    'Temperature',...
    'Reaction_Time',...
    'Substrate_Catalyst_Ratio',...
    'Pressure',...
    'Conversion',...
    'Yield',...
    'Selectivity'};

Correlation_Table = array2table( ...
    Correlation_Matrix, ...
    'VariableNames',Variable_Names, ...
    'RowNames',Variable_Names);

writetable( ...
    Correlation_Table, ...
    Excel_File, ...
    'Sheet','Correlation', ...
    'WriteRowNames',true);

%% ============================================================
% 19. PERFORMANCE CATEGORY SUMMARY
% =============================================================

Category = categorical(Performance_Category);

Category_Count = countcats(Category);

Category_Names = categories(Category);

Category_Summary = table( ...
    Category_Names, ...
    Category_Count, ...
    'VariableNames',{'Performance_Category','Number_of_Samples'});

writetable( ...
    Category_Summary, ...
    Excel_File, ...
    'Sheet','Performance_Summary');

%% ============================================================
% 20. CONVERSION DISTRIBUTION
% =============================================================

figure;

histogram(Conversion,20);

xlabel('Conversion (%)');
ylabel('Frequency');
title('Synthetic Conversion Distribution');
grid on;

%% ============================================================
% 21. YIELD DISTRIBUTION
% =============================================================

figure;

histogram(Yield,20);

xlabel('Yield (%)');
ylabel('Frequency');
title('Synthetic Yield Distribution');
grid on;

%% ============================================================
% 22. SELECTIVITY DISTRIBUTION
% =============================================================

figure;

histogram(Selectivity,20);

xlabel('Selectivity (%)');
ylabel('Frequency');
title('Synthetic Selectivity Distribution');
grid on;

%% ============================================================
% 23. CORRELATION HEATMAP
% =============================================================

figure;

imagesc(Correlation_Matrix);

colorbar;

title('Catalyst-Reaction Feature Correlation');

xticks(1:length(Variable_Names));
yticks(1:length(Variable_Names));

xticklabels(Variable_Names);
yticklabels(Variable_Names);

xtickangle(45);

axis square;

%% ============================================================
% 24. FINAL MESSAGE
% =============================================================

disp(' ');
disp('============================================================');
disp('       DATASET CREATION COMPLETED SUCCESSFULLY');
disp('============================================================');

fprintf('Excel file: %s\n',Excel_File);

disp(' ');
disp('Excel sheets created:');

disp('1. Main_Dataset');
disp('2. Summary');
disp('3. Feature_Description');
disp('4. Correlation');
disp('5. Performance_Summary');

disp(' ');
disp('IMPORTANT:');
disp('All generated catalyst and performance values are');
disp('SYNTHETIC/SIMULATED values for computational workflow.');
disp('They must NOT be presented as experimental measurements.');

disp('============================================================');