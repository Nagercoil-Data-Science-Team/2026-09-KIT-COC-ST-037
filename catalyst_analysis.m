

clear;
clc;
close all;

fprintf('\n');
fprintf('====================================================\n');
fprintf('        ZnO/SiO2 NANOCATALYST ANALYSIS\n');
fprintf('====================================================\n\n');

%% ============================================================
% 1. INPUT FILE
%% ============================================================

Input_File = 'ZnO_SiO2_Synthetic_Catalyst_Dataset.xlsx';

if ~isfile(Input_File)
    error(['Input file not found: ', Input_File, ...
        '\nPlace the Excel file in the current MATLAB folder.']);
end

% Read main dataset
Data = readtable(Input_File, ...
    'Sheet','Main_Dataset');

fprintf('Dataset loaded successfully.\n');
fprintf('Number of catalysts : %d\n',height(Data));
fprintf('Number of variables : %d\n\n',width(Data));

%% ============================================================
% 2. CHECK REQUIRED VARIABLES
%% ============================================================

Required_Variables = { ...
    'Catalyst_ID',...
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
    'Calcination_Temperature',...
    'Conversion',...
    'Yield',...
    'Selectivity'};

for i = 1:length(Required_Variables)

    if ~ismember(Required_Variables{i}, ...
            Data.Properties.VariableNames)

        error('Missing variable: %s', ...
            Required_Variables{i});

    end

end

fprintf('All required variables are available.\n');

%% ============================================================
% 3. BASIC DATA QUALITY ANALYSIS
%% ============================================================

fprintf('\n');
fprintf('---------------- DATA QUALITY ----------------\n');

% Missing values in each column
Missing_Count = sum(ismissing(Data));

% Total missing values
Total_Missing = sum(Missing_Count);

% ------------------------------------------------------------
% Duplicate row detection
% ------------------------------------------------------------
%
% duplicatedRows() is NOT a standard MATLAB function.
%
% The following method uses unique() and works with table data.
% ------------------------------------------------------------

[~,Unique_Index] = unique(Data,'rows','stable');

Duplicate_Count = height(Data) - length(Unique_Index);

fprintf('Total missing values : %d\n',Total_Missing);
fprintf('Duplicate rows       : %d\n',Duplicate_Count);

%% ============================================================
% 4. DATASET SIZE
%% ============================================================

fprintf('\n');
fprintf('---------------- DATASET INFORMATION ----------------\n');

fprintf('Total catalyst records : %d\n',height(Data));
fprintf('Total variables        : %d\n',width(Data));

%% ============================================================
% 5. CATALYST PERFORMANCE SUMMARY
%% ============================================================

fprintf('\n');
fprintf('---------------- CATALYTIC PERFORMANCE ----------------\n');

Mean_Conversion = mean(Data.Conversion,'omitnan');
Mean_Yield = mean(Data.Yield,'omitnan');
Mean_Selectivity = mean(Data.Selectivity,'omitnan');

Max_Conversion = max(Data.Conversion);
Max_Yield = max(Data.Yield);
Max_Selectivity = max(Data.Selectivity);

Min_Conversion = min(Data.Conversion);
Min_Yield = min(Data.Yield);
Min_Selectivity = min(Data.Selectivity);

Std_Conversion = std(Data.Conversion,'omitnan');
Std_Yield = std(Data.Yield,'omitnan');
Std_Selectivity = std(Data.Selectivity,'omitnan');

fprintf('\nMean values:\n');

fprintf('Conversion  : %.2f %%\n',Mean_Conversion);
fprintf('Yield       : %.2f %%\n',Mean_Yield);
fprintf('Selectivity : %.2f %%\n',Mean_Selectivity);

fprintf('\nMaximum values:\n');

fprintf('Conversion  : %.2f %%\n',Max_Conversion);
fprintf('Yield       : %.2f %%\n',Max_Yield);
fprintf('Selectivity : %.2f %%\n',Max_Selectivity);

fprintf('\nMinimum values:\n');

fprintf('Conversion  : %.2f %%\n',Min_Conversion);
fprintf('Yield       : %.2f %%\n',Min_Yield);
fprintf('Selectivity : %.2f %%\n',Min_Selectivity);

fprintf('\nStandard deviation:\n');

fprintf('Conversion  : %.2f\n',Std_Conversion);
fprintf('Yield       : %.2f\n',Std_Yield);
fprintf('Selectivity : %.2f\n',Std_Selectivity);

%% ============================================================
% 6. OVERALL CATALYST SCORE
%% ============================================================

% Normalize the three main catalytic responses

Conversion_Norm = normalize( ...
    Data.Conversion,'range');

Yield_Norm = normalize( ...
    Data.Yield,'range');

Selectivity_Norm = normalize( ...
    Data.Selectivity,'range');

% Weighted catalyst score
%
% Conversion  = 40%
% Yield       = 35%
% Selectivity = 25%

Catalyst_Score = ...
    0.40 * Conversion_Norm + ...
    0.35 * Yield_Norm + ...
    0.25 * Selectivity_Norm;

Data.Catalyst_Score = Catalyst_Score;

%% ============================================================
% 7. CATALYST RANKING
%% ============================================================

[~,Rank_Index] = ...
    sort(Data.Catalyst_Score,'descend');

Rank = zeros(height(Data),1);

Rank(Rank_Index) = ...
    (1:height(Data))';

Data.Catalyst_Rank = Rank;

% Sort catalysts according to rank
Sorted_Data = sortrows(Data,'Catalyst_Rank');

%% ============================================================
% 8. TOP 10 CATALYSTS
%% ============================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('                 TOP CATALYSTS\n');
fprintf('====================================================\n');

Top_N = min(10,height(Sorted_Data));

Top_Catalysts = Sorted_Data( ...
    1:Top_N, ...
    {'Catalyst_ID',...
    'ZnO_Loading',...
    'Particle_Size',...
    'Surface_Area',...
    'Basicity',...
    'ZnO_Dispersion',...
    'Catalyst_Loading',...
    'Temperature',...
    'Reaction_Time',...
    'Conversion',...
    'Yield',...
    'Selectivity',...
    'Catalyst_Score',...
    'Catalyst_Rank'});

disp(Top_Catalysts);

%% ============================================================
% 9. PERFORMANCE CLASSIFICATION
%% ============================================================

Performance_Category = strings(height(Data),1);

for i = 1:height(Data)

    if Data.Conversion(i) >= 90 && ...
       Data.Yield(i) >= 85 && ...
       Data.Selectivity(i) >= 90

        Performance_Category(i) = "Excellent";

    elseif Data.Conversion(i) >= 80 && ...
           Data.Yield(i) >= 75 && ...
           Data.Selectivity(i) >= 80

        Performance_Category(i) = "Good";

    elseif Data.Conversion(i) >= 60 && ...
           Data.Yield(i) >= 55 && ...
           Data.Selectivity(i) >= 65

        Performance_Category(i) = "Moderate";

    else

        Performance_Category(i) = "Low";

    end

end

Data.Performance_Category = Performance_Category;

%% ============================================================
% 10. PERFORMANCE CATEGORY SUMMARY
%% ============================================================

Category_Data = categorical(Data.Performance_Category);

Category_Names = categories(Category_Data);

Category_Count = zeros(length(Category_Names),1);

for i = 1:length(Category_Names)

    Category_Count(i) = ...
        sum(Category_Data == Category_Names{i});

end

Performance_Summary = table( ...
    string(Category_Names), ...
    Category_Count, ...
    'VariableNames', ...
    {'Performance_Category',...
    'Number_of_Catalysts'});

fprintf('\n');
fprintf('---------------- PERFORMANCE CATEGORY ----------------\n');

disp(Performance_Summary);

%% ============================================================
% 11. PHYSICOCHEMICAL PROPERTY ANALYSIS
%% ============================================================

Physico_Variables = { ...
    'ZnO_Loading',...
    'Particle_Size',...
    'Surface_Area',...
    'Pore_Volume',...
    'Acidity',...
    'Basicity',...
    'Zn_Oxidation_State',...
    'Oxygen_Vacancy_Index',...
    'Crystallinity',...
    'ZnO_Dispersion'};

Mean_Value = zeros(length(Physico_Variables),1);

Std_Value = zeros(length(Physico_Variables),1);

Min_Value = zeros(length(Physico_Variables),1);

Max_Value = zeros(length(Physico_Variables),1);

for i = 1:length(Physico_Variables)

    X = Data.(Physico_Variables{i});

    Mean_Value(i) = mean(X,'omitnan');

    Std_Value(i) = std(X,'omitnan');

    Min_Value(i) = min(X);

    Max_Value(i) = max(X);

end

Physicochemical_Summary = table( ...
    string(Physico_Variables(:)), ...
    Mean_Value, ...
    Std_Value, ...
    Min_Value, ...
    Max_Value, ...
    'VariableNames', ...
    {'Parameter',...
    'Mean',...
    'Std',...
    'Minimum',...
    'Maximum'});

fprintf('\n');
fprintf('---------------- PHYSICOCHEMICAL SUMMARY ----------------\n');

disp(Physicochemical_Summary);

%% ============================================================
% 12. CORRELATION ANALYSIS
%% ============================================================

Correlation_Variables = { ...
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

X = Data{:,Correlation_Variables};

Correlation_Matrix = ...
    corr(X,'Rows','complete');

Correlation_Table = array2table( ...
    Correlation_Matrix, ...
    'VariableNames',Correlation_Variables, ...
    'RowNames',Correlation_Variables);

%% ============================================================
% 13. FEATURE vs PERFORMANCE CORRELATION
%% ============================================================

Feature_Variables = { ...
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
    'Calcination_Temperature'};

Correlation_Results = ...
    zeros(length(Feature_Variables),3);

for i = 1:length(Feature_Variables)

    Feature = Data.(Feature_Variables{i});

    Correlation_Results(i,1) = ...
        corr(Feature,...
        Data.Conversion,...
        'Rows','complete');

    Correlation_Results(i,2) = ...
        corr(Feature,...
        Data.Yield,...
        'Rows','complete');

    Correlation_Results(i,3) = ...
        corr(Feature,...
        Data.Selectivity,...
        'Rows','complete');

end

Feature_Correlation_Table = table( ...
    string(Feature_Variables(:)), ...
    Correlation_Results(:,1), ...
    Correlation_Results(:,2), ...
    Correlation_Results(:,3), ...
    'VariableNames', ...
    {'Feature',...
    'Correlation_Conversion',...
    'Correlation_Yield',...
    'Correlation_Selectivity'});

fprintf('\n');
fprintf('---------------- FEATURE-PERFORMANCE CORRELATION ----------------\n');

disp(Feature_Correlation_Table);

%% ============================================================
% 14. IDENTIFY STRONGEST CORRELATIONS
%% ============================================================

Abs_Conversion = ...
    abs(Correlation_Results(:,1));

Abs_Yield = ...
    abs(Correlation_Results(:,2));

Abs_Selectivity = ...
    abs(Correlation_Results(:,3));

[~,Index_Conversion] = ...
    max(Abs_Conversion);

[~,Index_Yield] = ...
    max(Abs_Yield);

[~,Index_Selectivity] = ...
    max(Abs_Selectivity);

fprintf('\n');
fprintf('---------------- STRONGEST RELATIONSHIPS ----------------\n');

fprintf('\nStrongest Conversion relationship:\n');

fprintf('%s : r = %.4f\n', ...
    Feature_Variables{Index_Conversion}, ...
    Correlation_Results(Index_Conversion,1));

fprintf('\nStrongest Yield relationship:\n');

fprintf('%s : r = %.4f\n', ...
    Feature_Variables{Index_Yield}, ...
    Correlation_Results(Index_Yield,2));

fprintf('\nStrongest Selectivity relationship:\n');

fprintf('%s : r = %.4f\n', ...
    Feature_Variables{Index_Selectivity}, ...
    Correlation_Results(Index_Selectivity,3));

%% ============================================================
% 15. BEST CATALYST
%% ============================================================

Best_Catalyst = Sorted_Data(1,:);

fprintf('\n');
fprintf('====================================================\n');
fprintf('                 BEST CATALYST\n');
fprintf('====================================================\n');

fprintf('Catalyst ID      : %s\n', ...
    string(Best_Catalyst.Catalyst_ID));

fprintf('ZnO Loading      : %.2f %%\n', ...
    Best_Catalyst.ZnO_Loading);

fprintf('Particle Size    : %.2f nm\n', ...
    Best_Catalyst.Particle_Size);

fprintf('Surface Area     : %.2f m2/g\n', ...
    Best_Catalyst.Surface_Area);

fprintf('Pore Volume      : %.3f cm3/g\n', ...
    Best_Catalyst.Pore_Volume);

fprintf('Basicity         : %.3f\n', ...
    Best_Catalyst.Basicity);

fprintf('ZnO Dispersion   : %.2f %%\n', ...
    Best_Catalyst.ZnO_Dispersion);

fprintf('Oxygen Vacancy   : %.3f\n', ...
    Best_Catalyst.Oxygen_Vacancy_Index);

fprintf('Catalyst Loading : %.2f wt%%\n', ...
    Best_Catalyst.Catalyst_Loading);

fprintf('Temperature      : %.2f °C\n', ...
    Best_Catalyst.Temperature);

fprintf('Reaction Time    : %.2f min\n', ...
    Best_Catalyst.Reaction_Time);

fprintf('\n');

fprintf('Conversion       : %.2f %%\n', ...
    Best_Catalyst.Conversion);

fprintf('Yield            : %.2f %%\n', ...
    Best_Catalyst.Yield);

fprintf('Selectivity      : %.2f %%\n', ...
    Best_Catalyst.Selectivity);

fprintf('Catalyst Score   : %.4f\n', ...
    Best_Catalyst.Catalyst_Score);

%% ============================================================
% 16. FIGURE 1 — CONVERSION DISTRIBUTION
%% ============================================================

figure('Name','Conversion Distribution');

histogram(Data.Conversion,25);

xlabel('Conversion (%)');
ylabel('Number of Catalysts');

title('ZnO/SiO_2 Catalyst Conversion Distribution');

grid on;

saveas(gcf,...
    '01_Conversion_Distribution.png');

%% ============================================================
% 17. FIGURE 2 — YIELD DISTRIBUTION
%% ============================================================

figure('Name','Yield Distribution');

histogram(Data.Yield,25);

xlabel('Yield (%)');
ylabel('Number of Catalysts');

title('ZnO/SiO_2 Catalyst Yield Distribution');

grid on;

saveas(gcf,...
    '02_Yield_Distribution.png');

%% ============================================================
% 18. FIGURE 3 — SELECTIVITY DISTRIBUTION
%% ============================================================

figure('Name','Selectivity Distribution');

histogram(Data.Selectivity,25);

xlabel('Selectivity (%)');
ylabel('Number of Catalysts');

title('ZnO/SiO_2 Catalyst Selectivity Distribution');

grid on;

saveas(gcf,...
    '03_Selectivity_Distribution.png');

%% ============================================================
% 19. FIGURE 4 — CATALYST PERFORMANCE
%% ============================================================

figure('Name','Catalyst Performance');

scatter3( ...
    Data.Conversion, ...
    Data.Yield, ...
    Data.Selectivity, ...
    35, ...
    Data.Catalyst_Score, ...
    'filled');

xlabel('Conversion (%)');
ylabel('Yield (%)');
zlabel('Selectivity (%)');

title('ZnO/SiO_2 Catalyst Performance');

colorbar;

grid on;

view(135,25);

saveas(gcf,...
    '04_Catalyst_Performance.png');

%% ============================================================
% 20. FIGURE 5 — CORRELATION HEATMAP
%% ============================================================

figure('Name','Correlation Heatmap');

imagesc(Correlation_Matrix);

colorbar;

axis square;

xticks(1:length(Correlation_Variables));

yticks(1:length(Correlation_Variables));

xticklabels(Correlation_Variables);

yticklabels(Correlation_Variables);

xtickangle(45);

title('ZnO/SiO_2 Catalyst Feature Correlation');

saveas(gcf,...
    '05_Correlation_Heatmap.png');

%% ============================================================
% 21. FIGURE 6 — SURFACE AREA vs CONVERSION
%% ============================================================

figure('Name','Surface Area vs Conversion');

scatter( ...
    Data.Surface_Area, ...
    Data.Conversion, ...
    35, ...
    Data.Catalyst_Score, ...
    'filled');

xlabel('Surface Area (m^2/g)');

ylabel('Conversion (%)');

title('Surface Area vs Conversion');

colorbar;

grid on;

saveas(gcf,...
    '06_SurfaceArea_vs_Conversion.png');

%% ============================================================
% 22. FIGURE 7 — BASICITY vs SELECTIVITY
%% ============================================================

figure('Name','Basicity vs Selectivity');

scatter( ...
    Data.Basicity, ...
    Data.Selectivity, ...
    35, ...
    Data.Catalyst_Score, ...
    'filled');

xlabel('Basicity');

ylabel('Selectivity (%)');

title('Basicity vs Selectivity');

colorbar;

grid on;

saveas(gcf,...
    '07_Basicity_vs_Selectivity.png');

%% ============================================================
% 23. FIGURE 8 — ZnO DISPERSION vs CONVERSION
%% ============================================================

figure('Name','ZnO Dispersion vs Conversion');

scatter( ...
    Data.ZnO_Dispersion, ...
    Data.Conversion, ...
    35, ...
    Data.Catalyst_Score, ...
    'filled');

xlabel('ZnO Dispersion (%)');

ylabel('Conversion (%)');

title('ZnO Dispersion vs Conversion');

colorbar;

grid on;

saveas(gcf,...
    '08_ZnO_Dispersion_vs_Conversion.png');

%% ============================================================
% 24. FIGURE 9 — TEMPERATURE vs CONVERSION
%% ============================================================

figure('Name','Temperature vs Conversion');

scatter( ...
    Data.Temperature, ...
    Data.Conversion, ...
    35, ...
    Data.Catalyst_Score, ...
    'filled');

xlabel('Temperature (°C)');

ylabel('Conversion (%)');

title('Temperature vs Conversion');

colorbar;

grid on;

saveas(gcf,...
    '09_Temperature_vs_Conversion.png');

%% ============================================================
% 25. FIGURE 10 — REACTION TIME vs CONVERSION
%% ============================================================

figure('Name','Reaction Time vs Conversion');

scatter( ...
    Data.Reaction_Time, ...
    Data.Conversion, ...
    35, ...
    Data.Catalyst_Score, ...
    'filled');

xlabel('Reaction Time (min)');

ylabel('Conversion (%)');

title('Reaction Time vs Conversion');

colorbar;

grid on;

saveas(gcf,...
    '10_ReactionTime_vs_Conversion.png');

%% ============================================================
% 26. EXPORT ANALYSIS RESULTS TO EXCEL
%% ============================================================

Output_File = ...
    'ZnO_SiO2_Catalyst_Analysis.xlsx';

% Main analyzed dataset
writetable( ...
    Data, ...
    Output_File, ...
    'Sheet','Analyzed_Dataset');

% Top catalysts
writetable( ...
    Top_Catalysts, ...
    Output_File, ...
    'Sheet','Top_Catalysts');

% Performance summary
writetable( ...
    Performance_Summary, ...
    Output_File, ...
    'Sheet','Performance_Summary');

% Physicochemical properties
writetable( ...
    Physicochemical_Summary, ...
    Output_File, ...
    'Sheet','Physicochemical_Summary');

% Feature-performance correlation
writetable( ...
    Feature_Correlation_Table, ...
    Output_File, ...
    'Sheet','Feature_Correlation');

% Full correlation matrix
writetable( ...
    Correlation_Table, ...
    Output_File, ...
    'Sheet','Correlation_Matrix', ...
    'WriteRowNames',true);

%% ============================================================
% 27. FINAL SUMMARY
%% ============================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('             ANALYSIS COMPLETED\n');
fprintf('====================================================\n');

fprintf('\nInput file:\n');
fprintf('%s\n',Input_File);

fprintf('\nOutput Excel file:\n');
fprintf('%s\n',Output_File);

fprintf('\nGenerated figures:\n');

fprintf('01_Conversion_Distribution.png\n');
fprintf('02_Yield_Distribution.png\n');
fprintf('03_Selectivity_Distribution.png\n');
fprintf('04_Catalyst_Performance.png\n');
fprintf('05_Correlation_Heatmap.png\n');
fprintf('06_SurfaceArea_vs_Conversion.png\n');
fprintf('07_Basicity_vs_Selectivity.png\n');
fprintf('08_ZnO_Dispersion_vs_Conversion.png\n');
fprintf('09_Temperature_vs_Conversion.png\n');
fprintf('10_ReactionTime_vs_Conversion.png\n');

fprintf('\n====================================================\n');
fprintf('              BEST CATALYST SUMMARY\n');
fprintf('====================================================\n');

fprintf('Catalyst ID  : %s\n', ...
    string(Best_Catalyst.Catalyst_ID));

fprintf('Conversion   : %.2f %%\n', ...
    Best_Catalyst.Conversion);

fprintf('Yield        : %.2f %%\n', ...
    Best_Catalyst.Yield);

fprintf('Selectivity  : %.2f %%\n', ...
    Best_Catalyst.Selectivity);

fprintf('Score        : %.4f\n', ...
    Best_Catalyst.Catalyst_Score);

fprintf('\n====================================================\n');

fprintf('\nIMPORTANT SCIENTIFIC NOTE:\n');

fprintf(['The catalyst properties and catalytic performance ',...
    'values in this workflow are synthetic/simulated.\n']);

fprintf(['They should not be presented as experimental XRD, ',...
    'SEM/TEM, BET, XPS, FTIR or reaction measurements.\n']);

fprintf(['Actual catalyst synthesis and experimental ',...
    'characterization are required for experimental claims.\n']);

fprintf('\n====================================================\n');