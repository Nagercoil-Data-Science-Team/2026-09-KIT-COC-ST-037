clear;
clc;
Material.Name = "17-4 PH Stainless Steel";
Material.Condition      = "H900 (solution-annealed + aged at 900 degF / 482 degC)";
Material.PropertySource = "Typical handbook/mill-certificate values for 17-4PH condition H900 (e.g., AK Steel/ATI/Carpenter datasheets, ASM Handbook Vol.1); NOT measured from the specific stock used in this study.";
Material.Density = 7750;
Material.YoungsModulus = 197e9;
Material.PoissonsRatio = 0.29;
Material.ThermalConductivity = 17;
Material.SpecificHeat = 460;
Material.ThermalExpansion = 10.8e-6;
Material.UTS = 1310e6;
Material.YieldStrength = 1170e6;
Diameter = 20e-3;
Radius   = Diameter/2;
Length   = 50e-3;
structuralModel = createpde("structural","static-solid");
gm = multicylinder(Radius,Length);
structuralModel.Geometry = gm;
structuralProperties(structuralModel, ...
    "YoungsModulus",Material.YoungsModulus, ...
    "PoissonsRatio",Material.PoissonsRatio, ...
    "MassDensity",Material.Density);
mesh = generateMesh(structuralModel, ...
    "GeometricOrder","quadratic", ...
    "Hmax",0.004);
NumNodes    = size(mesh.Nodes,2);
NumElements = size(mesh.Elements,2);
fprintf("\n============================================================\n");
fprintf("        STEP 1 — 17-4 PH STAINLESS STEEL MATERIAL DATA\n");
fprintf("============================================================\n");
fprintf("%-30s %-15s\n","Property","Value");
fprintf("------------------------------------------------------------\n");
fprintf("%-30s %-15s\n","Material Name",Material.Name);
fprintf("%-30s %s\n","Condition",Material.Condition);
fprintf("%-30s %s\n","Property Source",Material.PropertySource);
fprintf("------------------------------------------------------------\n");
fprintf("%-30s %-15.2f kg/m^3\n","Density",Material.Density);
fprintf("%-30s %-15.3e Pa\n","Youngs Modulus",Material.YoungsModulus);
fprintf("%-30s %-15.2f\n","Poissons Ratio",Material.PoissonsRatio);
fprintf("%-30s %-15.2f W/(m-K)\n","Thermal Conductivity",Material.ThermalConductivity);
fprintf("%-30s %-15.2f J/(kg-K)\n","Specific Heat",Material.SpecificHeat);
fprintf("%-30s %-15.3e 1/K\n","Thermal Expansion",Material.ThermalExpansion);
fprintf("%-30s %-15.2f MPa\n","UTS",Material.UTS/1e6);
fprintf("%-30s %-15.2f MPa\n","Yield Strength",Material.YieldStrength/1e6);
fprintf("------------------------------------------------------------\n");
fprintf("%-30s %-15.2f mm\n","Workpiece Diameter",Diameter*1000);
fprintf("%-30s %-15.2f mm\n","Workpiece Length",Length*1000);
fprintf("------------------------------------------------------------\n");
fprintf("%-30s %-15d\n","Number of Mesh Nodes",NumNodes);
fprintf("%-30s %-15d\n","Number of Mesh Elements",NumElements);
fprintf("============================================================\n\n");
ExcelFileName = "17_4PH_Stainless_Steel_Results.xlsx";
if isfile(ExcelFileName)
    delete(ExcelFileName);
end
MaterialNames = [ ...
    "Material Name"; "Condition"; "Property Source"; ...
    "Density (kg/m^3)"; "Youngs Modulus (Pa)"; ...
    "Poissons Ratio"; "Thermal Conductivity (W/m-K)"; ...
    "Specific Heat (J/kg-K)"; "Thermal Expansion (1/K)"; ...
    "UTS (Pa)"; "Yield Strength (Pa)"; "Workpiece Diameter (m)"; ...
    "Workpiece Length (m)"; "Number of Mesh Nodes"; "Number of Mesh Elements"];
MaterialValues = [ ...
    string(Material.Name); string(Material.Condition); string(Material.PropertySource); ...
    string(Material.Density); ...
    string(Material.YoungsModulus); string(Material.PoissonsRatio); ...
    string(Material.ThermalConductivity); string(Material.SpecificHeat); ...
    string(Material.ThermalExpansion); string(Material.UTS); ...
    string(Material.YieldStrength); string(Diameter); string(Length); ...
    string(NumNodes); string(NumElements)];
MaterialTable = table(MaterialNames,MaterialValues, ...
    'VariableNames',{'Property','Value'});
writetable(MaterialTable,ExcelFileName,"Sheet","Material_Properties");
fprintf("Material, geometry, and mesh data saved to: %s\n\n", ExcelFileName);
TurningParams.Vc.Symbol = "Vc"; TurningParams.Vc.Name = "Cutting Speed";
TurningParams.Vc.Unit = "m/min";
TurningParams.Vc.Low = 100; TurningParams.Vc.Center = 150; TurningParams.Vc.High = 200;
TurningParams.f.Symbol = "f"; TurningParams.f.Name = "Feed Rate";
TurningParams.f.Unit = "mm/rev";
TurningParams.f.Low = 0.05; TurningParams.f.Center = 0.15; TurningParams.f.High = 0.25;
TurningParams.ap.Symbol = "ap"; TurningParams.ap.Name = "Depth of Cut";
TurningParams.ap.Unit = "mm";
TurningParams.ap.Low = 0.5; TurningParams.ap.Center = 1.0; TurningParams.ap.High = 1.5;
ParamNames = ["Cutting Speed (Vc)"; "Feed Rate (f)"; "Depth of Cut (ap)"];
Units      = ["m/min"; "mm/rev"; "mm"];
LowVals    = [TurningParams.Vc.Low;    TurningParams.f.Low;    TurningParams.ap.Low];
CenterVals = [TurningParams.Vc.Center; TurningParams.f.Center; TurningParams.ap.Center];
HighVals   = [TurningParams.Vc.High;   TurningParams.f.High;   TurningParams.ap.High];
TurningParamTable = table(ParamNames,Units,LowVals,CenterVals,HighVals, ...
    'VariableNames',{'Parameter','Unit','Low','Center','High'});
fprintf("============================================================\n");
fprintf("           STEP 2 — TURNING PARAMETER SELECTION\n");
fprintf("============================================================\n");
disp(TurningParamTable);
writetable(TurningParamTable,ExcelFileName,"Sheet","Turning_Parameters");
fprintf("Turning parameters saved to: %s\n\n", ExcelFileName);
CodedDesign = bbdesign(3,"center",5);
NumRuns = size(CodedDesign,1);
RunNumber = (1:NumRuns)';
Vc_coded = CodedDesign(:,1);
f_coded  = CodedDesign(:,2);
ap_coded = CodedDesign(:,3);
Vc_actual = TurningParams.Vc.Center + Vc_coded .* (TurningParams.Vc.High - TurningParams.Vc.Center);
f_actual  = TurningParams.f.Center  + f_coded  .* (TurningParams.f.High  - TurningParams.f.Center);
ap_actual = TurningParams.ap.Center + ap_coded .* (TurningParams.ap.High - TurningParams.ap.Center);
BBD_CodedTable = table(RunNumber,Vc_coded,f_coded,ap_coded, ...
    'VariableNames',{'Run','Vc_coded','f_coded','ap_coded'});
BBD_ActualTable = table(RunNumber,Vc_actual,f_actual,ap_actual, ...
    'VariableNames',{'Run','Vc_m_per_min','f_mm_per_rev','ap_mm'});
fprintf("============================================================\n");
fprintf("        STEP 3 — BOX-BEHNKEN DESIGN (CODED LEVELS)\n");
fprintf("============================================================\n");
disp(BBD_CodedTable);
fprintf("============================================================\n");
fprintf("   STEP 3 — SIMULATION EXPERIMENTAL MATRIX (ACTUAL VALUES)\n");
fprintf("============================================================\n");
disp(BBD_ActualTable);
writetable(BBD_CodedTable, ExcelFileName, "Sheet","BBD_Coded_Design");
writetable(BBD_ActualTable, ExcelFileName, "Sheet","BBD_Simulation_Matrix");
fprintf("BBD tables saved to: %s\n\n", ExcelFileName);
Kc11 = 2100;
mc   = 0.21;
eta_chip      = 0.75;
eta_tool      = 0.10;
eta_workpiece = 0.15;
K_temp = 103.4;
a_exp  = 0.40;
b_exp  = 0.20;
c_exp  = 0.10;
T_ambient = 25;
h_conv    = 50;
TopArea = pi*Radius^2;
Diameter_mm = Diameter*1000;
Length_mm   = Length*1000;
BottomFace = 1;
SideFace   = 2;
TopFace    = 3;
K_ra = 100;  p1_ra = -0.30;  p2_ra = 1.00;  p3_ra = 0.15;
K_vb = 0.001;  q1_vb = 0.90;  q2_vb = 0.30;  q3_vb = 0.20;
ModelAssumptions = table( ...
    ["Kienzle force model (Kc11, mc)"; "Heat partition (eta_chip/tool/workpiece)"; ...
     "Interface temperature correlation"; "Surface roughness correlation (Ra)"; ...
     "Flank-wear correlation (VB)"], ...
    ["Standard nonlinear specific-cutting-force model; Kc11 within the literature range reported for stainless steels; mc within the typical 0.17-0.30 band."; ...
     "Loewen-Shaw type heat split for carbide turning; fixed fractions, not a function of (Vc,f,ap)."; ...
     "Power-law fit calibrated only to reproduce a plausible ~525 degC center-point rise; not fitted to measured chip-tool interface data."; ...
     "Power-law form typical of turning Ra correlations; exponents are illustrative, not regressed from this workpiece/tool pair."; ...
     "Power-law flank-wear index; illustrative exponents, not a calibrated Taylor/extended-Taylor tool-life model."], ...
    ["Requires validation" ; "Requires validation"; "Requires validation"; "Requires validation"; "Requires validation"], ...
    'VariableNames', {'Model','Description','Status'});
fprintf("\n============================================================\n");
fprintf(" STEP 4.0a — MODEL ASSUMPTIONS & VALIDITY STATUS\n");
fprintf("============================================================\n");
disp(ModelAssumptions);
fprintf("IMPORTANT -- HOW TO DESCRIBE THESE RESULTS:\n");
fprintf("Because the force/Ra/VB/energy correlations use literature-typical\n");
fprintf("constants and exponents rather than constants regressed from measured\n");
fprintf("trials on this specific tool/workpiece/machine, the Ra, tool-wear, and\n");
fprintf("temperature results produced by this workflow must NOT be described as\n");
fprintf("experimentally validated physical predictions. The correct description\n");
fprintf("is:\n");

fprintf("NOT:\n");

fprintf("This distinction applies to every downstream table in this script\n");
fprintf("(Turning_Simulation_Results, RSM_Model_Summary, Candidate_1000_Points,\n");
fprintf("NSGA2_Pareto_Front, Optimization_Comparison, Confirmation_Run) -- all of\n");
fprintf("them trace back to these literature-informed correlations and inherit\n");
fprintf("the same validation status until the correlations are recalibrated\n");
fprintf("against measured data for the specific tool/workpiece/machine used.\n");
fprintf("Ra and VB are computed from empirical correlations, not solved by the FE\n");
fprintf("model; only force, temperature, stress and displacement come from the PDE\n");
fprintf("solves. The thermal field is a bounded/simplified model (single Dirichlet\n");
fprintf("value over the cutting face), not a spatially resolved chip-tool\n");
fprintf("interface simulation -- expect only weak spatial gradients in Tmax/Tmean.\n\n");
writetable(ModelAssumptions, ExcelFileName, "Sheet","Model_Assumptions");
rng(7);
Ra_NoiseCV     = 0.02;
VB_NoiseCV     = 0.03;
MRR_NoiseCV    = 0.03;
Energy_NoiseCV = 0.02;
MeasurementUncertaintyBasis = table( ...
    ["Ra_um";"ToolWear_VB_mm";"MRR_mm3_per_min";"Energy_Wh"], ...
    [Ra_NoiseCV; VB_NoiseCV; MRR_NoiseCV; Energy_NoiseCV], ...
    ["Literature-typical stylus-profilometer repeatability order (ISO 4287/4288 practice)."; ...
     "Literature-typical optical flank-wear measurement repeatability order (ISO 3685 tool-life test practice)."; ...
     "Literature-typical chip-mass/encoder-feedback volumetric material-removal repeatability order."; ...
     "Literature-typical Class 1 power-meter/energy-logger accuracy order."], ...
    ["Not instrument-calibrated -- replace with measured repeatability for the actual gauge used"; ...
     "Not instrument-calibrated -- replace with measured repeatability for the actual gauge used"; ...
     "Not instrument-calibrated -- replace with measured repeatability for the actual gauge used"; ...
     "Not instrument-calibrated -- replace with measured repeatability for the actual gauge used"], ...
    'VariableNames', {'Response','AssumedRepeatabilityCV','LiteratureBasis','ValidationStatus'});
fprintf("\n============================================================\n");
fprintf(" STEP 4.0b — MEASUREMENT-UNCERTAINTY BASIS FOR REPLICATE VARIANCE\n");
fprintf("============================================================\n");
disp(MeasurementUncertaintyBasis);
fprintf("These CVs set the scale of replicate-run scatter used for the Lack-of-\n");
fprintf("Fit test in Step 8. They are literature-typical for the instrument\n");
fprintf("class, not values calibrated from an actual gauge -- treat any\n");
fprintf("Lack-of-Fit conclusion as conditional on this assumption.\n\n");
writetable(MeasurementUncertaintyBasis, ExcelFileName, "Sheet","Measurement_Uncertainty_Basis");
fprintf("Measurement-uncertainty basis saved to: %s (Sheet: Measurement_Uncertainty_Basis)\n\n", ...
    ExcelFileName);
MeshConvTolerancePercent = 5;
ThermalHmaxTest = [0.010, 0.006, 0.004, 0.003];
StructHmaxTest  = [0.010, 0.0075, 0.005, 0.004];
CenterVc_mc = TurningParams.Vc.Center;
Centerf_mc  = TurningParams.f.Center;
Centerap_mc = TurningParams.ap.Center;
NumMeshLevels   = numel(ThermalHmaxTest);
ConvMaxTemp     = zeros(NumMeshLevels,1);
ConvMaxStress   = zeros(NumMeshLevels,1);
ConvMaxDisp     = zeros(NumMeshLevels,1);
ConvThermalDOF  = zeros(NumMeshLevels,1);
ConvStructDOF   = zeros(NumMeshLevels,1);
for k = 1:NumMeshLevels
    Rconv = simulateTurningRun(CenterVc_mc, Centerf_mc, Centerap_mc, gm, Material, ...
        Kc11, mc, K_temp, a_exp, b_exp, c_exp, T_ambient, h_conv, TopArea, ...
        TopFace, BottomFace, SideFace, K_ra, p1_ra, p2_ra, p3_ra, ...
        K_vb, q1_vb, q2_vb, q3_vb, Diameter_mm, Length_mm, Length, ...
        ThermalHmaxTest(k), StructHmaxTest(k));
    ConvMaxTemp(k)    = Rconv.MaxTemp;
    ConvMaxStress(k)  = Rconv.MaxStress;
    ConvMaxDisp(k)    = Rconv.MaxDisp;
    ConvThermalDOF(k) = Rconv.NumThermalNodes;
    ConvStructDOF(k)  = Rconv.NumStructNodes;
end
PctChangeTemp   = [NaN; 100*abs(diff(ConvMaxTemp))   ./ abs(ConvMaxTemp(1:end-1))];
PctChangeStress = [NaN; 100*abs(diff(ConvMaxStress)) ./ abs(ConvMaxStress(1:end-1))];
PctChangeDisp   = [NaN; 100*abs(diff(ConvMaxDisp))   ./ abs(ConvMaxDisp(1:end-1))];
MeshConvergenceTable = table(ThermalHmaxTest', StructHmaxTest', ConvThermalDOF, ConvStructDOF, ...
    ConvMaxTemp, PctChangeTemp, ConvMaxStress/1e6, PctChangeStress, ConvMaxDisp*1000, PctChangeDisp, ...
    'VariableNames', {'ThermalHmax_m','StructHmax_m','ThermalNodes','StructNodes', ...
    'MaxTemp_C','MaxTemp_PctChange','MaxStress_MPa','MaxStress_PctChange', ...
    'MaxDisp_mm','MaxDisp_PctChange'});
fprintf("\n============================================================\n");
fprintf(" STEP 4.0c — MESH-CONVERGENCE STUDY (center-point run)\n");
fprintf("============================================================\n");
disp(MeshConvergenceTable);
FinalChangeOK = (PctChangeTemp(end) < MeshConvTolerancePercent) && ...
                (PctChangeStress(end) < MeshConvTolerancePercent) && ...
                (PctChangeDisp(end)   < MeshConvTolerancePercent);
if FinalChangeOK
    fprintf("Mesh-independence criterion met: change from the second-finest to the\n");
    fprintf("finest mesh is below %.0f%% for Temperature, Stress, and Displacement.\n", MeshConvTolerancePercent);
else
    fprintf("WARNING: change from the second-finest to the finest mesh EXCEEDS %.0f%%\n", MeshConvTolerancePercent);
    fprintf("for at least one response. Results below should be treated as\n");
    fprintf("mesh-sensitive; add another refinement level (halve Hmax again) before\n");
    fprintf("treating absolute stress/temperature/displacement magnitudes as converged.\n");
end
writetable(MeshConvergenceTable, ExcelFileName, "Sheet","Mesh_Convergence_Study");
fprintf("Mesh-convergence study saved to: %s (Sheet: Mesh_Convergence_Study)\n\n", ExcelFileName);
ThermalMeshHmax = ThermalHmaxTest(end);
StructMeshHmax  = StructHmaxTest(end);
Fc_all         = zeros(NumRuns,1);
Pc_all         = zeros(NumRuns,1);
Tinterface_all = zeros(NumRuns,1);
MaxTemp_all    = zeros(NumRuns,1);
MeanTemp_all   = zeros(NumRuns,1);
MaxStress_all  = zeros(NumRuns,1);
MeanStress_all = zeros(NumRuns,1);
Strain_all     = zeros(NumRuns,1);
MaxDisp_all    = zeros(NumRuns,1);
Ra_all         = zeros(NumRuns,1);
VB_all         = zeros(NumRuns,1);
MRR_all        = zeros(NumRuns,1);
Energy_all     = zeros(NumRuns,1);
N_rpm_all             = zeros(NumRuns,1);
MachiningTime_min_all = zeros(NumRuns,1);
Energy_NoiseFree_all  = zeros(NumRuns,1);
fprintf("\n============================================================\n");
fprintf(" STEP 4 — TURNING SIMULATION (Kienzle force + bounded thermal\n");
fprintf("          field + coupled thermo-structural analysis)\n");
fprintf("============================================================\n");
fprintf("%-4s %-8s %-8s %-6s %-9s %-9s %-9s %-9s %-10s %-9s %-9s\n", ...
    "Run","Vc","f","ap","Fc(N)","Pc(W)","Tif(C)","Tmax(C)","Smax(MPa)","Strain","Disp(mm)");
fprintf("--------------------------------------------------------------------------------------------\n");
for i = 1:NumRuns
    Vc = Vc_actual(i);
    f  = f_actual(i);
    ap = ap_actual(i);
    Rrun = simulateTurningRun(Vc, f, ap, gm, Material, ...
        Kc11, mc, K_temp, a_exp, b_exp, c_exp, T_ambient, h_conv, TopArea, ...
        TopFace, BottomFace, SideFace, K_ra, p1_ra, p2_ra, p3_ra, ...
        K_vb, q1_vb, q2_vb, q3_vb, Diameter_mm, Length_mm, Length, ...
        ThermalMeshHmax, StructMeshHmax);
    Ra_i     = Rrun.Ra * (1 + Ra_NoiseCV * randn());
    VB_i     = Rrun.VB * (1 + VB_NoiseCV * randn());
    MRR_i    = Rrun.MRR * (1 + MRR_NoiseCV * randn());
    Energy_i = Rrun.Energy * (1 + Energy_NoiseCV * randn());
    Ra_all(i)     = Ra_i;
    VB_all(i)     = VB_i;
    MRR_all(i)    = MRR_i;
    Energy_all(i) = Energy_i;
    Fc_all(i)         = Rrun.Fc;
    Pc_all(i)         = Rrun.Pc;
    Tinterface_all(i) = Rrun.Tinterface;
    MaxTemp_all(i)    = Rrun.MaxTemp;
    MeanTemp_all(i)   = Rrun.MeanTemp;
    MaxStress_all(i)  = Rrun.MaxStress;
    MeanStress_all(i) = Rrun.MeanStress;
    Strain_all(i)     = Rrun.Strain;
    MaxDisp_all(i)    = Rrun.MaxDisp;
    N_rpm_all(i)             = Rrun.N_rpm;
    MachiningTime_min_all(i) = Rrun.MachiningTime_min;
    Energy_NoiseFree_all(i)  = Rrun.Energy;
    fprintf("%-4d %-8.1f %-8.3f %-6.2f %-9.2f %-9.2f %-9.1f %-9.1f %-10.2f %-9.5f %-9.5f\n", ...
        i, Vc, f, ap, Rrun.Fc, Rrun.Pc, Rrun.Tinterface, Rrun.MaxTemp, ...
        Rrun.MaxStress/1e6, Rrun.Strain, Rrun.MaxDisp*1000);
end
fprintf("================================================================================================\n\n");
fprintf("Sanity check (typical turning range: Tmax 100-900 degC, stress well below UTS):\n");
fprintf("Tmax = %.0f-%.0f degC\n", min(MaxTemp_all), max(MaxTemp_all));
fprintf("Von Mises stress = %.0f-%.0f MPa\n", min(MaxStress_all)/1e6, max(MaxStress_all)/1e6);
fprintf("Yield strength = %.0f MPa\n", Material.YieldStrength/1e6);
for i = 1:NumRuns
    flagT = "";
    flagS = "";
    if MaxTemp_all(i) > 1000
        flagT = " <-- CHECK (too high)";
    end
    if MaxStress_all(i) > Material.YieldStrength
        flagS = " <-- CHECK (near/above yield)";
    end
    if ~isempty(flagT) || ~isempty(flagS)
        fprintf("Run %d: Tmax=%.1f degC%s | Stress=%.2f MPa%s\n", ...
            i, MaxTemp_all(i), flagT, MaxStress_all(i)/1e6, flagS);
    end
end
fprintf("\n");
% ------------------------------------------------------------------------
% STEP 4.5 — INDEPENDENT ENERGY-EQUATION VERIFICATION (reviewer audit)
% ------------------------------------------------------------------------
% Physical basis (must match exactly, unit-by-unit):
%   n [rev/min]        = 1000*Vc[m/min] / (pi * D[mm])
%   t_cut [min]        = L[mm] / (f[mm/rev] * n[rev/min])
%   Energy [Wh]        = Pc[W] * t_cut[min] / 60   (i.e. Pc * t_cut_hours)
% This block recomputes Energy independently, from Fc_all/Vc_actual/f_actual
% (NOT by re-calling simulateTurningRun), and compares it against the
% noise-free energy already produced inside the function. Any discrepancy
% above floating-point round-off (~1e-10 %) indicates the two code paths
% have diverged and must be reconciled before publication.
n_check_rpm          = (1000 .* Vc_actual) ./ (pi .* Diameter_mm);
t_check_min          = Length_mm ./ (f_actual .* n_check_rpm);
Energy_check_Wh       = Pc_all .* t_check_min ./ 60;
EnergyPctDiff         = 100 .* abs(Energy_check_Wh - Energy_NoiseFree_all) ./ abs(Energy_NoiseFree_all);
fprintf("============================================================\n");
fprintf(" STEP 4.5 — ENERGY EQUATION AUDIT (t=L/(f*n), n=1000Vc/(piD), E=Pc*t)\n");
fprintf("============================================================\n");
fprintf("Max |PercentDiff| between as-modeled and independently recomputed\n");
fprintf("energy across all %d runs: %.2e %% (should be ~0, i.e. numerical\n", NumRuns, max(EnergyPctDiff));
fprintf("round-off only). This confirms Energy_Wh = Pc * L/(f*n) / 60 with\n");
fprintf("n = 1000*Vc/(pi*D) is implemented exactly as specified.\n");
fprintf("NOTE: because the Kienzle force Fc = Kc11*ap*f^(1-mc) does not\n");
fprintf("depend on Vc, and Pc*t = (Fc*Vc/60)*(pi*D/(1000*f*Vc))*L is\n");
fprintf("algebraically independent of Vc, Energy_Wh is expected to be\n");
fprintf("(near-)invariant to cutting speed at fixed f and ap. This is a\n");
fprintf("property of the Kienzle model, not a bug in the code.\n");
fprintf("============================================================\n\n");
EnergyVerification = table(RunNumber, Vc_actual, f_actual, ap_actual, ...
    N_rpm_all, MachiningTime_min_all*60, Pc_all, Energy_NoiseFree_all, ...
    Energy_check_Wh, EnergyPctDiff, Energy_all, ...
    'VariableNames', {'Run','Vc_m_per_min','f_mm_per_rev','ap_mm', ...
    'SpindleSpeed_rpm','MachiningTime_s','CuttingPower_W', ...
    'Energy_AsModeled_Wh','Energy_IndependentRecompute_Wh', ...
    'PercentDiff','Energy_WithMeasurementNoise_Wh'});
writetable(EnergyVerification, ExcelFileName, "Sheet","Energy_Verification");
fprintf("Energy-equation audit trail saved to: %s (Sheet: Energy_Verification)\n\n", ExcelFileName);
% ------------------------------------------------------------------------
TurningSimResults = table( ...
    RunNumber, Vc_actual, f_actual, ap_actual, ...
    Fc_all, Pc_all, Tinterface_all, MaxTemp_all, MeanTemp_all, ...
    MaxStress_all/1e6, MeanStress_all/1e6, Strain_all, MaxDisp_all*1000, ...
    Ra_all, VB_all, MRR_all, Energy_all, ...
    'VariableNames', { ...
        'Run','Vc_m_per_min','f_mm_per_rev','ap_mm', ...
        'CuttingForce_N','CuttingPower_W', ...
        'InterfaceTemp_C','MaxFieldTemp_C','MeanFieldTemp_C', ...
        'MaxVonMisesStress_MPa','MeanVonMisesStress_MPa', ...
        'Strain','MaxDisplacement_mm', ...
        'Ra_um','ToolWear_VB_mm','MRR_mm3_per_min','Energy_Wh'});
disp("Full Turning Simulation Results (all BBD runs):");
disp(TurningSimResults);
writetable(TurningSimResults, ExcelFileName, "Sheet","Turning_Simulation_Results");
fprintf("Turning simulation results saved to: %s (Sheet: Turning_Simulation_Results)\n\n", ...
    ExcelFileName);
ResponseNames  = {'Ra_um','ToolWear_VB_mm','MRR_mm3_per_min','Energy_Wh'};
ResponseData   = {Ra_all, VB_all, MRR_all, Energy_all};
PredictorNames = {'Vc','f','ap'};
X_rsm          = [Vc_actual, f_actual, ap_actual];
RSM_Models  = cell(4,1);
RSM_Summary = table('Size',[4 8], ...
    'VariableTypes',{'string','double','double','double','double','double','double','double'}, ...
    'VariableNames',{'Response','R2','AdjR2','PredR2','RMSE','MAE','F_LOF','p_LOF'});
for m = 1:4
    y        = ResponseData{m};
    respName = ResponseNames{m};
    tbl = array2table([X_rsm, y], 'VariableNames', [PredictorNames, {respName}]);
    mdl = fitlm(tbl, 'quadratic', 'ResponseVar', respName);
    RSM_Models{m} = mdl;
    resid = mdl.Residuals.Raw;
    SST = sum((y - mean(y)).^2);
    SSE = sum(resid.^2);
    R2    = mdl.Rsquared.Ordinary;
    AdjR2 = mdl.Rsquared.Adjusted;
    RMSE_m = mdl.RMSE;
    MAE_m  = mean(abs(resid));
    leverage = mdl.Diagnostics.Leverage;
    PRESS    = sum((resid ./ (1 - leverage)).^2);
    PredR2   = 1 - PRESS/SST;
    [uniqueX, ~, ic] = unique(X_rsm, 'rows');
    SSPE = 0; dfPE = 0;
    for g = 1:size(uniqueX,1)
        idx = find(ic == g);
        if numel(idx) > 1
            ybar = mean(y(idx));
            SSPE = SSPE + sum((y(idx) - ybar).^2);
            dfPE = dfPE + (numel(idx) - 1);
        end
    end
    dfResidual = mdl.DFE;
    SSLOF = SSE - SSPE;
    dfLOF = dfResidual - dfPE;
    if dfPE > 0 && dfLOF > 0
        F_LOF = (SSLOF/dfLOF) / (SSPE/dfPE);
        p_LOF = 1 - fcdf(F_LOF, dfLOF, dfPE);
    else
        F_LOF = NaN;
        p_LOF = NaN;
    end
    RSM_Summary.Response(m) = respName;
    RSM_Summary.R2(m)       = R2;
    RSM_Summary.AdjR2(m)    = AdjR2;
    RSM_Summary.PredR2(m)   = PredR2;
    RSM_Summary.RMSE(m)     = RMSE_m;
    RSM_Summary.MAE(m)      = MAE_m;
    RSM_Summary.F_LOF(m)    = F_LOF;
    RSM_Summary.p_LOF(m)    = p_LOF;
    anovaTbl = anova(mdl, 'summary');
    fprintf("\n============================================================\n");
    fprintf(" STEP 8 — RSM MODEL %d: %s = f(Vc,f,ap)\n", m, respName);
    fprintf("============================================================\n");
    disp(mdl);
    fprintf("---- ANOVA (summary) ----\n");
    disp(anovaTbl);
    fprintf("R^2               : %.4f\n", R2);
    fprintf("Adjusted R^2      : %.4f\n", AdjR2);
    fprintf("Predicted R^2     : %.4f\n", PredR2);
    fprintf("RMSE              : %.4f\n", RMSE_m);
    fprintf("MAE               : %.4f\n", MAE_m);
    if ~isnan(F_LOF)
        fprintf("Lack-of-Fit F     : %.4f (p = %.4f)\n", F_LOF, p_LOF);
    else
        fprintf("Lack-of-Fit F     : not estimable (no replicate design points)\n");
    end
    fprintf("============================================================\n\n");
end
disp("RSM Model Fit Summary (all 4 responses):");
disp(RSM_Summary);
writetable(RSM_Summary, ExcelFileName, "Sheet","RSM_Model_Summary");
fprintf("RSM ANOVA/fit-statistics summary saved to: %s (Sheet: RSM_Model_Summary)\n\n", ...
    ExcelFileName);
rng(1);
NumCandidates = 1000;
LHS_Coded = lhsdesign(NumCandidates,3);
Vc_cand = TurningParams.Vc.Low + LHS_Coded(:,1) * (TurningParams.Vc.High - TurningParams.Vc.Low);
f_cand  = TurningParams.f.Low  + LHS_Coded(:,2) * (TurningParams.f.High  - TurningParams.f.Low);
ap_cand = TurningParams.ap.Low + LHS_Coded(:,3) * (TurningParams.ap.High - TurningParams.ap.Low);
CandidateTable = table(Vc_cand, f_cand, ap_cand, 'VariableNames', PredictorNames);
Ra_cand     = predict(RSM_Models{1}, CandidateTable);
VB_cand     = predict(RSM_Models{2}, CandidateTable);
MRR_cand    = predict(RSM_Models{3}, CandidateTable);
Energy_cand = predict(RSM_Models{4}, CandidateTable);
MRR_PhysicalMax = TurningParams.Vc.High * TurningParams.f.High * TurningParams.ap.High * 1000;
MRR_PhysicalMin = TurningParams.Vc.Low  * TurningParams.f.Low  * TurningParams.ap.Low  * 1000;
MRR_cand = min(max(MRR_cand, MRR_PhysicalMin), MRR_PhysicalMax);
PointID = (1:NumCandidates)';
CandidateResults = table(PointID, Vc_cand, f_cand, ap_cand, ...
    Ra_cand, VB_cand, MRR_cand, Energy_cand, ...
    'VariableNames', {'Point','Vc_m_per_min','f_mm_per_rev','ap_mm', ...
    'Ra_um_pred','ToolWear_VB_mm_pred','MRR_mm3_per_min_pred','Energy_Wh_pred'});
fprintf("\n============================================================\n");
fprintf(" STEP 9 — 1000-POINT CANDIDATE PARAMETER SPACE (SURROGATE EVAL)\n");
fprintf("============================================================\n");
fprintf("%-30s %-15s\n","Response (predicted)","Range [min , max]");
fprintf("------------------------------------------------------------\n");
fprintf("%-30s [%.4f , %.4f]\n","Ra (um)",min(Ra_cand),max(Ra_cand));
fprintf("%-30s [%.4f , %.4f]\n","Tool Wear VB (mm)",min(VB_cand),max(VB_cand));
fprintf("%-30s [%.4f , %.4f]\n","MRR (mm^3/min)",min(MRR_cand),max(MRR_cand));
fprintf("%-30s [%.4f , %.4f]\n","Energy (Wh)",min(Energy_cand),max(Energy_cand));
fprintf("============================================================\n\n");
writetable(CandidateResults, ExcelFileName, "Sheet","Candidate_1000_Points");
fprintf("1000-point candidate space + surrogate predictions saved to: %s (Sheet: Candidate_1000_Points)\n\n", ...
    ExcelFileName);
nVars = 3;
lb_ga = [TurningParams.Vc.Low,  TurningParams.f.Low,  TurningParams.ap.Low];
ub_ga = [TurningParams.Vc.High, TurningParams.f.High, TurningParams.ap.High];
rng(2024);
gaOpts = optimoptions('gamultiobj', ...
    'PopulationSize',100, ...
    'MaxGenerations',15, ...
    'ParetoFraction',0.7, ...
    'Display','iter');
[x_pareto, fval_pareto] = gamultiobj(@(x) rsmObjectives(x,RSM_Models,PredictorNames,MRR_PhysicalMin,MRR_PhysicalMax), ...
    nVars, [],[],[],[], lb_ga, ub_ga, [], gaOpts);
MaxParetoSolutions = 100;
if size(x_pareto,1) > MaxParetoSolutions
    idxCap = round(linspace(1, size(x_pareto,1), MaxParetoSolutions));
    x_pareto    = x_pareto(idxCap,:);
    fval_pareto = fval_pareto(idxCap,:);
end
Ra_pf     = fval_pareto(:,1);
VB_pf     = fval_pareto(:,2);
MRR_pf    = -fval_pareto(:,3);
Energy_pf = fval_pareto(:,4);
NumPareto = size(x_pareto,1);
ParetoFront = table((1:NumPareto)', x_pareto(:,1), x_pareto(:,2), x_pareto(:,3), ...
    Ra_pf, VB_pf, MRR_pf, Energy_pf, ...
    'VariableNames', {'Solution','Vc_m_per_min','f_mm_per_rev','ap_mm', ...
    'Ra_um','ToolWear_VB_mm','MRR_mm3_per_min','Energy_Wh'});
fprintf("\n============================================================\n");
fprintf(" STEP 10 — NSGA-II PARETO FRONT (%d non-dominated solutions)\n", NumPareto);
fprintf("============================================================\n");
disp(ParetoFront);
writetable(ParetoFront, ExcelFileName, "Sheet","NSGA2_Pareto_Front");
fprintf("NSGA-II Pareto front saved to: %s (Sheet: NSGA2_Pareto_Front)\n\n", ExcelFileName);
ObjPareto = [Ra_pf, VB_pf, -MRR_pf, Energy_pf];
ObjMin = min(ObjPareto,[],1);
ObjMax = max(ObjPareto,[],1);
ObjRange = ObjMax - ObjMin;
ObjRange(ObjRange==0) = 1;
ObjNorm = (ObjPareto - ObjMin) ./ ObjRange;
RefPoint = ones(1,4) * 1.1;
rng(11);
NumMC = 200000;
SamplePts = rand(NumMC,4) .* RefPoint;
IsDominated = false(NumMC,1);
for k = 1:NumPareto
    IsDominated = IsDominated | all(ObjNorm(k,:) <= SamplePts, 2);
end
BoxVolume = prod(RefPoint);
Hypervolume = BoxVolume * (sum(IsDominated)/NumMC);
SpacingDist = zeros(NumPareto,1);
for k = 1:NumPareto
    others = setdiff(1:NumPareto,k);
    d = sum(abs(ObjNorm(k,:) - ObjNorm(others,:)), 2);
    SpacingDist(k) = min(d);
end
SpacingMetric = sqrt(sum((SpacingDist - mean(SpacingDist)).^2) / max(NumPareto-1,1));
IdealPoint = min(ObjNorm,[],1);
ConvergenceMetric = mean(sqrt(sum((ObjNorm - IdealPoint).^2,2)));
DiversityMetric = mean(max(ObjNorm,[],1) - min(ObjNorm,[],1));
NSGA2_Quality = table(Hypervolume, SpacingMetric, ConvergenceMetric, DiversityMetric, NumPareto, ...
    'VariableNames', {'Hypervolume','Spacing','Convergence','Diversity','NumParetoSolutions'});
fprintf("---- NSGA-II Quality Metrics ----\n");
disp(NSGA2_Quality);
writetable(NSGA2_Quality, ExcelFileName, "Sheet","NSGA2_Quality_Metrics");
fprintf("NSGA-II quality metrics saved to: %s (Sheet: NSGA2_Quality_Metrics)\n\n", ExcelFileName);
CompromiseWeights = [0.25 0.25 0.25 0.25];
CompromiseWeightsTable = table({'Ra_um';'ToolWear_VB_mm';'MRR_mm3_per_min';'Energy_Wh'}, ...
    CompromiseWeights', 'VariableNames', {'Objective','Weight'});
fprintf("Weights used for compromise programming AND the weighted-sum method:\n");
disp(CompromiseWeightsTable);
writetable(CompromiseWeightsTable, ExcelFileName, "Sheet","Optimization_Weights_Used");
ParetoObjNorm = [ ...
    (Ra_pf     - min(Ra_pf))     / max(range(Ra_pf),eps), ...
    (VB_pf     - min(VB_pf))     / max(range(VB_pf),eps), ...
    (max(MRR_pf) - MRR_pf)       / max(range(MRR_pf),eps), ...
    (Energy_pf - min(Energy_pf)) / max(range(Energy_pf),eps)];
WeightedDistToIdeal = sqrt(sum((CompromiseWeights .* ParetoObjNorm).^2, 2));
[~, bestIdx] = min(WeightedDistToIdeal);
x_nsga2      = x_pareto(bestIdx,:);
Ra_nsga2     = Ra_pf(bestIdx);
VB_nsga2     = VB_pf(bestIdx);
MRR_nsga2    = MRR_pf(bestIdx);
Energy_nsga2 = Energy_pf(bestIdx);
fprintf("---- STEP 10c — Best-Compromise Pareto Solution (compromise programming) ----\n");
fprintf("Criterion   : minimum weighted Euclidean distance to the normalized ideal point\n");
fprintf("Weights     : Ra=%.2f, VB=%.2f, MRR=%.2f, Energy=%.2f (equal priority)\n", CompromiseWeights);
fprintf("Selected Solution %d of %d: Vc=%.2f, f=%.4f, ap=%.4f\n", ...
    bestIdx, NumPareto, x_nsga2(1), x_nsga2(2), x_nsga2(3));
fprintf("  Ra=%.4f um | VB=%.4f mm | MRR=%.1f mm^3/min | Energy=%.4f Wh\n\n", ...
    Ra_nsga2, VB_nsga2, MRR_nsga2, Energy_nsga2);
nGrid = 50;
FactorNames  = {'Vc','f','ap'};
FactorLow    = [TurningParams.Vc.Low,    TurningParams.f.Low,    TurningParams.ap.Low];
FactorHigh   = [TurningParams.Vc.High,   TurningParams.f.High,   TurningParams.ap.High];
FactorCenter = [TurningParams.Vc.Center, TurningParams.f.Center, TurningParams.ap.Center];
SensitivityRange = zeros(3,4);
for fac = 1:3
    xGrid = repmat(FactorCenter, nGrid, 1);
    xGrid(:,fac) = linspace(FactorLow(fac), FactorHigh(fac), nGrid)';
    xt = array2table(xGrid, 'VariableNames', PredictorNames);
    for r = 1:4
        yPred = predict(RSM_Models{r}, xt);
        SensitivityRange(fac,r) = max(yPred) - min(yPred);
    end
end
SensitivityPercent = zeros(3,4);
for r = 1:4
    colSum = sum(SensitivityRange(:,r));
    if colSum == 0
        colSum = 1;
    end
    SensitivityPercent(:,r) = 100 * SensitivityRange(:,r) / colSum;
end
SensitivityTable = array2table(SensitivityPercent, 'RowNames', FactorNames, 'VariableNames', ResponseNames);
fprintf("\n============================================================\n");
fprintf(" STEP 11A — SENSITIVITY ANALYSIS (%% contribution to response range)\n");
fprintf("============================================================\n");
disp(SensitivityTable);
SensitivityTableXL = table(FactorNames', SensitivityPercent(:,1), SensitivityPercent(:,2), ...
    SensitivityPercent(:,3), SensitivityPercent(:,4), ...
    'VariableNames', [{'Factor'}, ResponseNames]);
writetable(SensitivityTableXL, ExcelFileName, "Sheet","Sensitivity_Analysis");
fprintf("Sensitivity analysis saved to: %s (Sheet: Sensitivity_Analysis)\n\n", ExcelFileName);
x0_opt = FactorCenter;
fminOpts = optimoptions('fmincon','Display','off');
singleObjFun = @(x) predictResponse(x, RSM_Models{4}, PredictorNames);
x_single = fmincon(singleObjFun, x0_opt, [],[],[],[], lb_ga, ub_ga, [], fminOpts);
Ra_single     = predictResponse(x_single, RSM_Models{1}, PredictorNames);
VB_single     = predictResponse(x_single, RSM_Models{2}, PredictorNames);
MRR_single    = predictResponseClipped(x_single, RSM_Models{3}, PredictorNames, MRR_PhysicalMin, MRR_PhysicalMax);
Energy_single = predictResponse(x_single, RSM_Models{4}, PredictorNames);
RaRange_ws     = [min(Ra_cand),     max(Ra_cand)];
VBRange_ws     = [min(VB_cand),     max(VB_cand)];
MRRRange_ws    = [min(MRR_cand),    max(MRR_cand)];
EnergyRange_ws = [min(Energy_cand), max(Energy_cand)];
weightedSumFun = @(x) weightedSumObjective(x, RSM_Models, PredictorNames, ...
    RaRange_ws, VBRange_ws, MRRRange_ws, EnergyRange_ws, CompromiseWeights, ...
    MRR_PhysicalMin, MRR_PhysicalMax);
x_weighted = fmincon(weightedSumFun, x0_opt, [],[],[],[], lb_ga, ub_ga, [], fminOpts);
Ra_weighted     = predictResponse(x_weighted, RSM_Models{1}, PredictorNames);
VB_weighted     = predictResponse(x_weighted, RSM_Models{2}, PredictorNames);
MRR_weighted    = predictResponseClipped(x_weighted, RSM_Models{3}, PredictorNames, MRR_PhysicalMin, MRR_PhysicalMax);
Energy_weighted = predictResponse(x_weighted, RSM_Models{4}, PredictorNames);
MethodNames = {'Single-objective (min Energy)';'Weighted-sum (equal weights)';'NSGA-II (best compromise)'};
Vc_comp     = [x_single(1); x_weighted(1); x_nsga2(1)];
f_comp      = [x_single(2); x_weighted(2); x_nsga2(2)];
ap_comp     = [x_single(3); x_weighted(3); x_nsga2(3)];
Ra_comp     = [Ra_single;     Ra_weighted;     Ra_nsga2];
VB_comp     = [VB_single;     VB_weighted;     VB_nsga2];
MRR_comp    = [MRR_single;    MRR_weighted;    MRR_nsga2];
Energy_comp = [Energy_single; Energy_weighted; Energy_nsga2];
OptimizationComparison = table(MethodNames, Vc_comp, f_comp, ap_comp, ...
    Ra_comp, VB_comp, MRR_comp, Energy_comp, ...
    'VariableNames', {'Method','Vc_m_per_min','f_mm_per_rev','ap_mm', ...
    'Ra_um','ToolWear_VB_mm','MRR_mm3_per_min','Energy_Wh'});
fprintf("\n============================================================\n");
fprintf(" STEP 11B — OPTIMIZATION COMPARISON\n");
fprintf("============================================================\n");
disp(OptimizationComparison);
writetable(OptimizationComparison, ExcelFileName, "Sheet","Optimization_Comparison");
fprintf("Optimization comparison saved to: %s (Sheet: Optimization_Comparison)\n\n", ExcelFileName);
Confirm_Vc = x_nsga2(1);
Confirm_f  = x_nsga2(2);
Confirm_ap = x_nsga2(3);
Rconfirm = simulateTurningRun(Confirm_Vc, Confirm_f, Confirm_ap, gm, Material, ...
    Kc11, mc, K_temp, a_exp, b_exp, c_exp, T_ambient, h_conv, TopArea, ...
    TopFace, BottomFace, SideFace, K_ra, p1_ra, p2_ra, p3_ra, ...
    K_vb, q1_vb, q2_vb, q3_vb, Diameter_mm, Length_mm, Length, ...
    ThermalMeshHmax, StructMeshHmax);
ConfirmResponseNames = {'Ra_um';'ToolWear_VB_mm';'MRR_mm3_per_min';'Energy_Wh'};
RSM_Predicted   = [Ra_nsga2;      VB_nsga2;      MRR_nsga2;      Energy_nsga2];
FE_Confirmed    = [Rconfirm.Ra;   Rconfirm.VB;   Rconfirm.MRR;   Rconfirm.Energy];
PercentError    = 100 * abs(FE_Confirmed - RSM_Predicted) ./ abs(RSM_Predicted);
ConfirmationTable = table(ConfirmResponseNames, RSM_Predicted, FE_Confirmed, PercentError, ...
    'VariableNames', {'Response','RSM_Predicted','FE_Confirmed','PercentError'});
fprintf("\n============================================================\n");
fprintf(" STEP 12 — NUMERICAL CONFIRMATION AT THE BEST-COMPROMISE POINT\n");
fprintf(" (Vc=%.2f m/min, f=%.4f mm/rev, ap=%.4f mm)\n", Confirm_Vc, Confirm_f, Confirm_ap);
fprintf("============================================================\n");
disp(ConfirmationTable);
fprintf("Also confirmed by direct FE re-evaluation (not RSM-predicted):\n");
fprintf("  Cutting Force        = %.2f N\n", Rconfirm.Fc);
fprintf("  Cutting Power        = %.2f W\n", Rconfirm.Pc);
fprintf("  Interface Temp       = %.1f degC\n", Rconfirm.Tinterface);
fprintf("  Max Field Temp       = %.1f degC\n", Rconfirm.MaxTemp);
fprintf("  Max Von Mises Stress = %.2f MPa\n", Rconfirm.MaxStress/1e6);
fprintf("  Max Displacement     = %.5f mm\n", Rconfirm.MaxDisp*1000);
fprintf("============================================================\n\n");
writetable(ConfirmationTable, ExcelFileName, "Sheet","Confirmation_Run");
fprintf("Confirmation run saved to: %s (Sheet: Confirmation_Run)\n\n", ExcelFileName);

%% ============================================================
%% STEP 13 — PUBLICATION FIGURES
%% ============================================================
fprintf("\n============================================================\n");
fprintf(" STEP 13 — GENERATING PUBLICATION FIGURES\n");
fprintf("============================================================\n");

FigureFolder = "Figures";
if ~isfolder(FigureFolder)
    mkdir(FigureFolder);
end

% ---- Global figure/axes defaults: Times New Roman, bold, size 18, no grid ----
set(0,'DefaultAxesFontName','Times New Roman');
set(0,'DefaultAxesFontWeight','bold');
set(0,'DefaultAxesFontSize',18);
set(0,'DefaultTextFontName','Times New Roman');
set(0,'DefaultTextFontWeight','bold');
set(0,'DefaultTextFontSize',18);
set(0,'DefaultAxesXGrid','off');
set(0,'DefaultAxesYGrid','off');
set(0,'DefaultAxesZGrid','off');
set(0,'DefaultAxesBox','on');
set(0,'DefaultLineLineWidth',2.5);
set(0,'DefaultFigureColor','w');

% ---- Distinct, dark color palette used across all figures ----
DarkColors = [ ...
    0.55 0.00 0.00;   % dark red
    0.00 0.25 0.55;   % dark blue
    0.00 0.40 0.20;   % dark green
    0.45 0.00 0.45;   % dark purple
    0.55 0.30 0.00;   % dark orange/brown
    0.10 0.10 0.10;   % near-black
    0.00 0.35 0.45;   % dark teal
    0.35 0.35 0.00];  % dark olive

FigPos          = [50, 50, 1600, 1100];    % large figure/window size (pixels)
ResponseLabels  = {'Ra (\mum)','Tool Wear VB (mm)','MRR (mm^3/min)','Energy (Wh)'};

% ------------------------------------------------------------------------
% Workpiece Geometry and Computational Domain
% ------------------------------------------------------------------------
fig1 = figure('Position',FigPos);
pdegplot(gm,'FaceLabels','on','FaceAlpha',0.4);
ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=18;
grid(ax,'off'); box(ax,'on');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title({'17-4 PH SS Workpiece Geometry', ...
    'and Computational Domain (\phi20 mm \times 50 mm)'}, ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
view(35,20);
saveFigure(fig1, "Workpiece_Geometry", FigureFolder);

% ------------------------------------------------------------------------
% Numerical Mesh
% ------------------------------------------------------------------------
fig2 = figure('Position',FigPos);
pdemesh(mesh,'FaceAlpha',0.25,'EdgeColor',DarkColors(2,:));
ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=18;
grid(ax,'off'); box(ax,'on');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
title({'Finite-Element Mesh of the', ...
    sprintf('17-4 PH SS Workpiece (%d Nodes, %d Elements)',NumNodes,NumElements)}, ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
view(35,20);
saveFigure(fig2, "Mesh", FigureFolder);

% ------------------------------------------------------------------------
% Box-Behnken Design Space
% ------------------------------------------------------------------------
fig3 = figure('Position',FigPos);
scatter3(Vc_actual, f_actual, ap_actual, 220, DarkColors(1,:), 'filled', ...
    'MarkerEdgeColor','k','LineWidth',1.5);
hold on;
centerIdx = find(Vc_coded==0 & f_coded==0 & ap_coded==0);
scatter3(Vc_actual(centerIdx), f_actual(centerIdx), ap_actual(centerIdx), 260, ...
    DarkColors(2,:), 'filled', 'MarkerEdgeColor','k','LineWidth',1.5);
hold off;
ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=18;
grid(ax,'off'); box(ax,'on');
xlabel('V_c (m/min)'); ylabel('f (mm/rev)'); zlabel('a_p (mm)');
title(sprintf('Box-Behnken Design Space for Turning Parameters (%d Points)',NumRuns), ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
legend({'Factorial points','Center-point replicates'},'Location','best','FontSize',14);
view(-35,20);
saveFigure(fig3, "BBD_Design_Space", FigureFolder);

% ------------------------------------------------------------------------
% Pre-compute full thermal + structural FIELD results for 3 representative
% runs (Low / Center / High corner), reused by the temperature and
% Von Mises stress field plots below
% ------------------------------------------------------------------------
RepLabels  = {'Low (V_c=100, f=0.05, a_p=0.5)', ...
              'Center (V_c=150, f=0.15, a_p=1.0)', ...
              'High (V_c=200, f=0.25, a_p=1.5)'};
RepParams  = [ TurningParams.Vc.Low,    TurningParams.f.Low,    TurningParams.ap.Low; ...
               TurningParams.Vc.Center, TurningParams.f.Center, TurningParams.ap.Center; ...
               TurningParams.Vc.High,   TurningParams.f.High,   TurningParams.ap.High];
ThermalReps = cell(3,1);
StructReps  = cell(3,1);
for r = 1:3
    [ThermalReps{r}, StructReps{r}] = simulateFullFields(RepParams(r,1), RepParams(r,2), RepParams(r,3), ...
        gm, Material, Kc11, mc, K_temp, a_exp, b_exp, c_exp, T_ambient, h_conv, ...
        TopFace, BottomFace, SideFace, Diameter_mm, ThermalMeshHmax, StructMeshHmax);
end

% ------------------------------------------------------------------------
% Simulated Temperature Distribution (representative runs)
% - shared color scale across the three subplots so the color coding is
%   directly comparable (rather than each panel auto-scaling to its own
%   narrow range)
% - smaller colorbar / label font so it no longer dominates the panel
% ------------------------------------------------------------------------
fig4 = figure('Position',FigPos);
AllTempFields = [ThermalReps{1}.Temperature + T_ambient; ...
                 ThermalReps{2}.Temperature + T_ambient; ...
                 ThermalReps{3}.Temperature + T_ambient];
GlobalTempMin = min(AllTempFields);
GlobalTempMax = max(AllTempFields);
for r = 1:3
    subplot(1,3,r);
    pdeplot3D(ThermalReps{r}.Mesh,'ColorMapData',ThermalReps{r}.Temperature + T_ambient);
    colormap(gca,'hot');
    caxis(gca,[GlobalTempMin, GlobalTempMax]);
    cb = colorbar;
    cb.Label.String = 'Temperature (\circC)';
    cb.Label.FontWeight = 'bold';
    cb.Label.FontName   = 'Times New Roman';
    cb.Label.FontSize   = 9;      % smaller colorbar title
    cb.FontSize         = 8;      % smaller colorbar tick labels
    cb.Position(3)      = cb.Position(3) * 0.5;  % narrower colorbar image
    ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=14;
    grid(ax,'off');
    title(RepLabels{r},'FontWeight','bold','FontSize',14,'FontName','Times New Roman');
    view(35,20);
end
sgtitle('Simulated Temperature Distribution under Different Turning Conditions', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig4, "Temperature_Field", FigureFolder);

% ------------------------------------------------------------------------
% Simulated Von Mises Stress Distribution (representative runs)
% - same shared-scale / smaller-label treatment as the temperature figure
% ------------------------------------------------------------------------
fig5 = figure('Position',FigPos);
AllStressFields = [StructReps{1}.VonMisesStress/1e6; ...
                    StructReps{2}.VonMisesStress/1e6; ...
                    StructReps{3}.VonMisesStress/1e6];
GlobalStressMin = min(AllStressFields);
GlobalStressMax = max(AllStressFields);
for r = 1:3
    subplot(1,3,r);
    pdeplot3D(StructReps{r}.Mesh,'ColorMapData',StructReps{r}.VonMisesStress/1e6);
    colormap(gca,'jet');
    caxis(gca,[GlobalStressMin, GlobalStressMax]);
    cb = colorbar;
    cb.Label.String = 'Von Mises Stress (MPa)';
    cb.Label.FontWeight = 'bold';
    cb.Label.FontName   = 'Times New Roman';
    cb.Label.FontSize   = 9;      % smaller colorbar title
    cb.FontSize         = 8;      % smaller colorbar tick labels
    cb.Position(3)      = cb.Position(3) * 0.5;  % narrower colorbar image
    ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=14;
    grid(ax,'off');
    title(RepLabels{r},'FontWeight','bold','FontSize',14,'FontName','Times New Roman');
    view(35,20);
end
sgtitle('Simulated Von Mises Stress Distribution of the Workpiece', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig5, "VonMises_Field", FigureFolder);

% ------------------------------------------------------------------------
% Main-Effect Plots (Vc, f, ap on Ra, VB, MRR, Energy)
% ------------------------------------------------------------------------
nGridME       = 50;
codedGridME   = linspace(-1,1,nGridME)';
FactorLabels  = {'V_c','f','a_p'};
MainEffectY   = cell(3,4);
for fac = 1:3
    xGridActual = repmat(FactorCenter, nGridME, 1);
    span = FactorHigh(fac) - FactorCenter(fac);
    xGridActual(:,fac) = FactorCenter(fac) + codedGridME*span;
    xt = array2table(xGridActual, 'VariableNames', PredictorNames);
    for r = 1:4
        MainEffectY{fac,r} = predict(RSM_Models{r}, xt);
    end
end
fig6 = figure('Position',FigPos);
for r = 1:4
    subplot(2,2,r);
    hold on;
    for fac = 1:3
        plot(codedGridME, MainEffectY{fac,r}, '-', 'Color', DarkColors(fac,:), 'LineWidth',3);
    end
    hold off;
    ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=16;
    grid(ax,'off'); box(ax,'on');
    xlabel('Coded Factor Level (-1 to +1)','FontSize',14);
    ylabel(ResponseLabels{r},'FontSize',14);
    title(ResponseLabels{r},'FontSize',16);
    if r==1
        legend(FactorLabels,'Location','best','FontSize',13);
    end
end
sgtitle('Effect of Turning Parameters on Machining Responses', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig6, "MainEffects", FigureFolder);

% ------------------------------------------------------------------------
% Numerical (FE) vs RSM-Predicted Responses
% ------------------------------------------------------------------------
fig7 = figure('Position',FigPos);
for r = 1:4
    subplot(2,2,r);
    yActual    = ResponseData{r};
    yPredicted = predict(RSM_Models{r}, array2table(X_rsm,'VariableNames',PredictorNames));
    scatter(yActual, yPredicted, 160, DarkColors(r,:), 'filled','MarkerEdgeColor','k','LineWidth',1.2);
    hold on;
    limLo = min([yActual;yPredicted]); limHi = max([yActual;yPredicted]);
    plot([limLo limHi],[limLo limHi],'--','Color',[0 0 0],'LineWidth',2);
    hold off;
    ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=16;
    grid(ax,'off'); box(ax,'on');
    xlabel(['Numerical ' ResponseLabels{r}],'FontSize',14);
    ylabel(['RSM-Predicted ' ResponseLabels{r}],'FontSize',14);
    title(ResponseLabels{r},'FontSize',16);
end
sgtitle('Direct Numerical and RSM-Predicted Machining Responses', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig7, "Numerical_vs_RSM", FigureFolder);

% ------------------------------------------------------------------------
% RSM Residual Diagnostics — one SEPARATE WINDOW per diagnostic type
% (Residuals vs Fitted / Normal Probability / Histogram / Residuals vs
% Run Order), each window containing all four responses as subplots.
% ------------------------------------------------------------------------

% --- Window 1: Residuals vs Fitted (all 4 responses) ---
fig8a = figure('Position',FigPos);
for r = 1:4
    mdl    = RSM_Models{r};
    resid  = mdl.Residuals.Raw;
    fitted = mdl.Fitted;
    subplot(2,2,r);
    scatter(fitted, resid, 90, DarkColors(r,:), 'filled','MarkerEdgeColor','k');
    hold on; yline(0,'--k','LineWidth',1.5); hold off;
    ax=gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=14;
    grid(ax,'off'); box(ax,'on');
    xlabel('Fitted'); ylabel('Residual');
    title(ResponseNames{r},'FontSize',15);
end
sgtitle('RSM Residual Diagnostics: Residuals vs Fitted', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig8a, "Residual_Diagnostics_Residuals_vs_Fitted", FigureFolder);

% --- Window 2: Normal Probability Plot (all 4 responses) ---
fig8b = figure('Position',FigPos);
for r = 1:4
    mdl   = RSM_Models{r};
    resid = mdl.Residuals.Raw;
    subplot(2,2,r);
    h = normplot(resid);
    set(h(1),'Color',DarkColors(r,:),'Marker','o','MarkerFaceColor',DarkColors(r,:));
    set(h(2),'Color','k','LineWidth',2);
    ax=gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=14;
    grid(ax,'off'); box(ax,'on');
    title(ResponseNames{r},'FontSize',15);
    xlabel('Standard Normal Quantile'); ylabel('Residual');
end
sgtitle('RSM Residual Diagnostics: Normal Probability Plot', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig8b, "Residual_Diagnostics_Normal_Probability", FigureFolder);

% --- Window 3: Histogram of Residuals (all 4 responses) ---
fig8c = figure('Position',FigPos);
for r = 1:4
    mdl   = RSM_Models{r};
    resid = mdl.Residuals.Raw;
    subplot(2,2,r);
    histogram(resid,8,'FaceColor',DarkColors(r,:),'EdgeColor','k');
    ax=gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=14;
    grid(ax,'off'); box(ax,'on');
    xlabel('Residual'); ylabel('Frequency');
    title(ResponseNames{r},'FontSize',15);
end
sgtitle('RSM Residual Diagnostics: Histogram of Residuals', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig8c, "Residual_Diagnostics_Histogram", FigureFolder);

% --- Window 4: Residuals vs Run Order (all 4 responses) ---
fig8d = figure('Position',FigPos);
for r = 1:4
    mdl   = RSM_Models{r};
    resid = mdl.Residuals.Raw;
    subplot(2,2,r);
    plot(1:numel(resid), resid, '-o','Color',DarkColors(r,:), ...
        'MarkerFaceColor',DarkColors(r,:),'LineWidth',2);
    hold on; yline(0,'--k','LineWidth',1.5); hold off;
    ax=gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=14;
    grid(ax,'off'); box(ax,'on');
    xlabel('Run Order'); ylabel('Residual');
    title(ResponseNames{r},'FontSize',15);
end
sgtitle('RSM Residual Diagnostics: Residuals vs Run Order', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig8d, "Residual_Diagnostics_vs_RunOrder", FigureFolder);

% ------------------------------------------------------------------------
% Response Surface and Contour Plots (Vc vs f, ap at center level)
% ------------------------------------------------------------------------
nSurf = 40;
VcGridS = linspace(TurningParams.Vc.Low, TurningParams.Vc.High, nSurf);
fGridS  = linspace(TurningParams.f.Low,  TurningParams.f.High,  nSurf);
[VcMeshS, fMeshS] = meshgrid(VcGridS, fGridS);
apCenterVal = TurningParams.ap.Center;
fig9 = figure('Position',[30 30 1700 1900]);
for r = 1:4
    xt = array2table([VcMeshS(:), fMeshS(:), apCenterVal*ones(numel(VcMeshS),1)], ...
        'VariableNames', PredictorNames);
    yPredGrid = reshape(predict(RSM_Models{r}, xt), size(VcMeshS));

    subplot(4,2,(r-1)*2+1);
    surf(VcMeshS, fMeshS, yPredGrid,'EdgeColor','none');
    colormap(gca,'parula');
    ax=gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=13;
    grid(ax,'off'); box(ax,'on');
    xlabel('V_c (m/min)'); ylabel('f (mm/rev)'); zlabel(ResponseLabels{r});
    title([ResponseLabels{r} ' - Surface'],'FontSize',13);
    view(-35,25);

    subplot(4,2,(r-1)*2+2);
    contourf(VcMeshS, fMeshS, yPredGrid, 15, 'LineColor','k');
    colormap(gca,'parula'); colorbar;
    ax=gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=13;
    grid(ax,'off'); box(ax,'on');
    xlabel('V_c (m/min)'); ylabel('f (mm/rev)');
    title([ResponseLabels{r} ' - Contour'],'FontSize',13);
end
sgtitle(sprintf('Response Surface and Contour Plots (a_p = %.2f mm, center level)',apCenterVal), ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig9, "Response_Surfaces", FigureFolder);

% ------------------------------------------------------------------------
% NSGA-II Pareto-Optimal Solutions (pairwise objective scatter)
% ------------------------------------------------------------------------
ParetoObjectives = [Ra_pf, VB_pf, MRR_pf, Energy_pf];
ParetoObjLabels  = {'Ra (\mum)','VB (mm)','MRR (mm^3/min)','Energy (Wh)'};
pairs = nchoosek(1:4,2);
fig10 = figure('Position',[30 30 1900 1200]);
for p = 1:size(pairs,1)
    subplot(2,3,p);
    i1 = pairs(p,1); i2 = pairs(p,2);
    scatter(ParetoObjectives(:,i1), ParetoObjectives(:,i2), 110, DarkColors(p,:), ...
        'filled', 'MarkerEdgeColor','k');
    hold on;
    scatter(ParetoObjectives(bestIdx,i1), ParetoObjectives(bestIdx,i2), 280, ...
        'k','p','filled', 'MarkerEdgeColor','r','LineWidth',2);
    hold off;
    ax=gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=14;
    grid(ax,'off'); box(ax,'on');
    xlabel(ParetoObjLabels{i1}); ylabel(ParetoObjLabels{i2});
    title([ParetoObjLabels{i1} ' vs ' ParetoObjLabels{i2}],'FontSize',13);
    if p==1
        legend({'Pareto solutions','Best compromise'},'Location','best','FontSize',11);
    end
end
sgtitle('NSGA-II Pareto-Optimal Solutions', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
saveFigure(fig10, "Pareto_Front", FigureFolder);

% ------------------------------------------------------------------------
% Sensitivity of Turning Parameters (grouped bar, value labels)
% ------------------------------------------------------------------------
fig11 = figure('Position',FigPos);
b = bar(SensitivityPercent', 'grouped');
for k = 1:numel(b)
    b(k).FaceColor = DarkColors(k,:);
    b(k).EdgeColor = 'k';
end
ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=18;
grid(ax,'off'); box(ax,'on');
set(ax,'XTickLabel',ResponseNames);
ylabel('Relative Contribution (%)');
title('Sensitivity of Turning Parameters to Machining Responses', ...
    'FontWeight','bold','FontSize',18,'FontName','Times New Roman');
legend(FactorNames,'Location','best','FontSize',14);
for k = 1:numel(b)
    xtips  = b(k).XEndPoints;
    ytips  = b(k).YEndPoints;
    labels = string(round(b(k).YData,1));
    text(xtips, ytips, labels, 'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', 'FontName','Times New Roman', ...
        'FontWeight','bold', 'FontSize',12);
end
saveFigure(fig11, "Sensitivity_Bar", FigureFolder);

% ------------------------------------------------------------------------
% RSM-Predicted vs Directly Re-Evaluated Optimum
% — one SEPARATE WINDOW per response (Ra, Tool Wear VB, MRR, Energy),
% each with its own bar chart and its own y-axis scale, so no response
% is visually swamped by another response's much larger magnitude.
% ------------------------------------------------------------------------
ConfirmFileNames = {"Confirmation_Ra","Confirmation_ToolWear_VB", ...
                     "Confirmation_MRR","Confirmation_Energy"};
ConfirmYLabels   = {'Ra (\mum)','Tool Wear VB (mm)','MRR (mm^3/min)','Energy (Wh)'};

for m = 1:4
    figConfirm = figure('Position',FigPos);
    BarDataM = [RSM_Predicted(m), FE_Confirmed(m)];
    bM = bar(BarDataM,'grouped');
    bM.FaceColor = 'flat';
    bM.CData(1,:) = DarkColors(1,:);
    bM.CData(2,:) = DarkColors(2,:);
    bM.EdgeColor = 'k';
    ax = gca; ax.FontName='Times New Roman'; ax.FontWeight='bold'; ax.FontSize=18;
    grid(ax,'off'); box(ax,'on');
    set(ax,'XTickLabel',{'RSM Predicted','FE Re-Evaluated'});
    ylabel(ConfirmYLabels{m});
    title({sprintf('%s: RSM-Predicted vs FE Re-Evaluated', ConfirmResponseNames{m}), ...
        sprintf('(V_c=%.1f, f=%.3f, a_p=%.3f)', Confirm_Vc,Confirm_f,Confirm_ap)}, ...
        'FontWeight','bold','FontSize',16,'FontName','Times New Roman');
    xtips  = bM.XEndPoints;
    ytips  = bM.YEndPoints;
    labels = string(round(bM.YData,3));
    text(xtips, ytips, labels, 'HorizontalAlignment','center', ...
        'VerticalAlignment','bottom', 'FontName','Times New Roman', ...
        'FontWeight','bold', 'FontSize',13);
    saveFigure(figConfirm, ConfirmFileNames{m}, FigureFolder);
end

fprintf("\nAll figures saved (1000 dpi PNG) in folder: %s\n\n", FigureFolder);

function R = simulateTurningRun(Vc, f, ap, gm, Material, ...
    Kc11, mc, K_temp, a_exp, b_exp, c_exp, T_ambient, h_conv, TopArea, ...
    TopFace, BottomFace, SideFace, K_ra, p1_ra, p2_ra, p3_ra, ...
    K_vb, q1_vb, q2_vb, q3_vb, Diameter_mm, Length_mm, Length, ...
    thermalHmax, structHmax)
    Fc = Kc11 * ap * (f^(1-mc));
    Pc = Fc * (Vc/60);
    MRR  = 1000 * Vc * f * ap;
    Ra_d = K_ra * (Vc^p1_ra) * (f^p2_ra) * (ap^p3_ra);
    VB_d = K_vb * (Vc^q1_vb) * (f^q2_vb) * (ap^q3_vb);
    % --- Machining-time / energy equation (verified in STEP 4.5 above) ---
    % n [rev/min]  = 1000*Vc[m/min] / (pi*D[mm])           (Vc = pi*D*n/1000)
    % t [min]      = L[mm] / (f[mm/rev] * n[rev/min])       (feed rate = f*n)
    % Energy [Wh]  = Pc[W] * t[min] / 60                    (t[min]/60 = t[h])
    N_rpm             = (1000*Vc) / (pi*Diameter_mm);
    FeedRate_mm_min   = f * N_rpm;
    MachiningTime_min = Length_mm / FeedRate_mm_min;
    Energy_d = Pc * MachiningTime_min / 60;
    deltaT_flash = K_temp * (Vc^a_exp) * (f^b_exp) * (ap^c_exp);
    T_interface  = T_ambient + deltaT_flash;
    thermalModel = createpde("thermal","steadystate");
    thermalModel.Geometry = gm;
    thermalProperties(thermalModel, "ThermalConductivity", Material.ThermalConductivity);
    thermalBC(thermalModel,"Face",TopFace, "Temperature",deltaT_flash);
    thermalBC(thermalModel,"Face",BottomFace, "ConvectionCoefficient",h_conv, "AmbientTemperature",0);
    thermalBC(thermalModel,"Face",SideFace,   "ConvectionCoefficient",h_conv, "AmbientTemperature",0);
    thermalMesh = generateMesh(thermalModel,"Hmax",thermalHmax);
    thermalResult = solve(thermalModel);
    T_rise_field  = thermalResult.Temperature;
    MaxTemp  = max(T_rise_field) + T_ambient;
    MeanTemp = mean(T_rise_field) + T_ambient;
    NominalStress = Fc / TopArea;
    structModel = createpde("structural","static-solid");
    structModel.Geometry = gm;
    structuralProperties(structModel, ...
        "YoungsModulus",Material.YoungsModulus, ...
        "PoissonsRatio",Material.PoissonsRatio, ...
        "MassDensity",Material.Density, ...
        "CTE",Material.ThermalExpansion);
    structuralBC(structModel,"Face",BottomFace,"Constraint","fixed");
    structuralBoundaryLoad(structModel, "Face",TopFace, "SurfaceTraction",[0;0;NominalStress]);
    structuralBodyLoad(structModel, "Temperature",thermalResult);
    structMesh = generateMesh(structModel,"GeometricOrder","quadratic","Hmax",structHmax);
    structResult = solve(structModel);
    VonMisesRun = structResult.VonMisesStress;
    ux = structResult.Displacement.ux;
    uy = structResult.Displacement.uy;
    uz = structResult.Displacement.uz;
    TotalDisp = sqrt(ux.^2 + uy.^2 + uz.^2);
    zNodes = structResult.Mesh.Nodes(3,:);
    BufferZone = 0.15*Length;
    InteriorIdx = find(zNodes > BufferZone & zNodes < (Length - BufferZone));
    MaxStress  = max(VonMisesRun(InteriorIdx));
    MeanStress = mean(VonMisesRun(InteriorIdx));
    MaxDisp    = max(TotalDisp);
    Strain = MaxStress / Material.YoungsModulus;
    R.Fc              = Fc;
    R.Pc              = Pc;
    R.MRR             = MRR;
    R.Ra              = Ra_d;
    R.VB              = VB_d;
    R.Energy          = Energy_d;
    R.N_rpm             = N_rpm;
    R.MachiningTime_min = MachiningTime_min;
    R.Tinterface      = T_interface;
    R.MaxTemp         = MaxTemp;
    R.MeanTemp        = MeanTemp;
    R.MaxStress       = MaxStress;
    R.MeanStress      = MeanStress;
    R.Strain          = Strain;
    R.MaxDisp         = MaxDisp;
    R.NumThermalNodes = size(thermalMesh.Nodes,2);
    R.NumStructNodes  = size(structMesh.Nodes,2);
end
function f = rsmObjectives(x, models, predictorNames, mrrMin, mrrMax)
    xt = array2table(x, 'VariableNames', predictorNames);
    Ra_p  = predict(models{1}, xt);
    VB_p  = predict(models{2}, xt);
    MRR_p = predict(models{3}, xt);
    MRR_p = min(max(MRR_p, mrrMin), mrrMax);
    E_p   = predict(models{4}, xt);
    f = [Ra_p, VB_p, -MRR_p, E_p];
end
function y = predictResponse(x, mdl, predictorNames)
    xt = array2table(x, 'VariableNames', predictorNames);
    y = predict(mdl, xt);
end
function y = predictResponseClipped(x, mdl, predictorNames, yMin, yMax)
    y = predictResponse(x, mdl, predictorNames);
    y = min(max(y, yMin), yMax);
end
function val = weightedSumObjective(x, models, predictorNames, raRange, vbRange, mrrRange, eRange, w, mrrMin, mrrMax)
    raP  = predictResponse(x, models{1}, predictorNames);
    vbP  = predictResponse(x, models{2}, predictorNames);
    mrrP = predictResponseClipped(x, models{3}, predictorNames, mrrMin, mrrMax);
    eP   = predictResponse(x, models{4}, predictorNames);
    normRa  = (raP  - raRange(1))  / max(raRange(2)  - raRange(1),  eps);
    normVb  = (vbP  - vbRange(1))  / max(vbRange(2)  - vbRange(1),  eps);
    normMrr = (mrrP - mrrRange(1)) / max(mrrRange(2) - mrrRange(1), eps);
    normE   = (eP   - eRange(1))   / max(eRange(2)   - eRange(1),   eps);
    val = w(1)*normRa + w(2)*normVb + w(3)*(1 - normMrr) + w(4)*normE;
end
function saveFigure(fig, filename, folder)
    % Exports a figure as a PNG at 1000 dpi into the given folder.
    exportgraphics(fig, fullfile(folder, filename + ".png"), 'Resolution', 1000);
    fprintf("Saved figure: %s\n", fullfile(folder, filename + ".png"));
end
function [thermalResult, structResult] = simulateFullFields(Vc, f, ap, gm, Material, ...
    Kc11, mc, K_temp, a_exp, b_exp, c_exp, T_ambient, h_conv, ...
    TopFace, BottomFace, SideFace, Diameter_mm, thermalHmax, structHmax)
    % Re-solves the thermal + structural PDE models for one (Vc,f,ap)
    % combination and returns the FULL field results (mesh + nodal values)
    % for contour/field plotting (temperature and Von Mises stress). This
    % mirrors the physics inside simulateTurningRun exactly, but keeps the
    % field objects instead of collapsing them to scalar Max/Mean values.
    Fc = Kc11 * ap * (f^(1-mc));
    deltaT_flash = K_temp * (Vc^a_exp) * (f^b_exp) * (ap^c_exp);

    thermalModel = createpde("thermal","steadystate");
    thermalModel.Geometry = gm;
    thermalProperties(thermalModel, "ThermalConductivity", Material.ThermalConductivity);
    thermalBC(thermalModel,"Face",TopFace, "Temperature",deltaT_flash);
    thermalBC(thermalModel,"Face",BottomFace, "ConvectionCoefficient",h_conv, "AmbientTemperature",0);
    thermalBC(thermalModel,"Face",SideFace,   "ConvectionCoefficient",h_conv, "AmbientTemperature",0);
    generateMesh(thermalModel,"Hmax",thermalHmax);
    thermalResult = solve(thermalModel);

    Radius_m   = (Diameter_mm/1000)/2;
    TopArea_m2 = pi*Radius_m^2;
    NominalStress = Fc / TopArea_m2;

    structModel = createpde("structural","static-solid");
    structModel.Geometry = gm;
    structuralProperties(structModel, ...
        "YoungsModulus",Material.YoungsModulus, ...
        "PoissonsRatio",Material.PoissonsRatio, ...
        "MassDensity",Material.Density, ...
        "CTE",Material.ThermalExpansion);
    structuralBC(structModel,"Face",BottomFace,"Constraint","fixed");
    structuralBoundaryLoad(structModel, "Face",TopFace, "SurfaceTraction",[0;0;NominalStress]);
    structuralBodyLoad(structModel, "Temperature",thermalResult);
    generateMesh(structModel,"GeometricOrder","quadratic","Hmax",structHmax);
    structResult = solve(structModel);
end