% LIBquiv function defining the model parameters for the Calb 180 Ah cell. 

% Producer: Calb
% Product name: CA180FI
% Nominal capacity: 180 Ah
% Nominal voltage: 3.2 V
% Negative electrode material: Graphite
% Positive electrode material: Lithium iron phosphate (LFP)  
% Discharge cut-off voltage: 2.5 V
% Charge cut-off voltage: 3.65 V
% Cell format: Prismatic cell

% The parameterization process is described in the following publication: 
% J. A. Braun, D. Schmider, W. G. Bessler, "A physics-informed dual-electrode equivalent circuit model for lithium iron phosphate battery cells,” Electrochim. Acta, submitted (02/2026).
% The parameters used here correspond to model "E" from the publication. 
% The thermodynamic data are from the corresponding publications:
% Source E (NE): Smekens 2015 Electrochimica Acta, 174, 615–624, https://doi.org/10.1016/j.electacta.2015.06.015. 
% Source dS (NE): Reynier 2003 J. Power Sources, 119-121, 850–855, https://doi.org/10.1016/S0378-7753(03)00285-4. 
% Source E (PE): Verbrugge 2017 J. Electrochem. Soc., 164(11), E3243-E3253, https://doi.org/10.1149/2.0341708jes. 
% Source dS (PE): Viswanathan 2010 J. Power Sources, 195(11), 3720–3729, https://doi.org/10.1016/j.jpowsour.2009.11.103.
% The original data are corrected using Li metal correction of 29.12 J/(K*mol).

function LIB = Calb180Ah()
% instantiate virtual battery object
LIB = LIBquiv();


% Electrical model parameters
% -------------------------------------------------------------------------    
LIB.C_N = 200.35*3600; % [As] nominal capacity
LIB.R_s = @(T,X_NE,X_PE,I) 4.254e-06 * exp(9.085e+03 / (LIB.R * T)); % [Ohm] serial resistance

% RC-Element 1: Negative electrode (NE)
LIB.C_NE = 35.77; % [F] Capacitance of RC-Element 1 (NE)
LIB.R_NE = @(T,X_NE,X_PE,I) ((2*LIB.R*T)/LIB.F * asinh( max([abs(I),1e-10]) / (2*9.608e+11*exp(-(5.325e+04)/(LIB.R*T))*sqrt((1-X_NE)*X_NE))) ) / max([abs(I),1e-10]); % [Ohm] Resistance of RC-Element 1 (NE)

% RC-Element 2: Positve electrode (PE)
LIB.C_PE = 1055; % [F] Capacitance of RC-Element 2 (PE)
LIB.R_PE = @(T,X_NE,X_PE,I)   1.207e-17 * exp(-(-6.954e+04) / (LIB.R * T)) * (1/X_PE)     * (sign(-I)+1)/2 ...
                            + 1.207e-17 * exp(-(-6.954e+04) / (LIB.R * T)) * (1/(1-X_PE)) * (sign( I)+1)/2; % [Ohm] Resistance of RC-Element 2 (PE)

% RC-Element 3: additional RC-Element
LIB.C_3 = 31250; % [F] Capacitance of RC-Element 3
LIB.R_3 = @(T,X_NE,X_PE,I) 3.565e-08 * exp(-(-2.183e+04) / (LIB.R * T)); % [Ohm] Resistance of RC-Element 3
 

% Thermal model parameters
% -------------------------------------------------------------------------   
LIB.thermalModel = 0; % Switch on (1) of off (0) thermal model. If off (0), then T_ambient is used as cell temperature.
LIB.T_ambient = 293.15; % [K] Ambient temperature


% Hysteresis model parameters 
% -------------------------------------------------------------------------   
LIB.hysteresisModel = 2; % Type of hysteresis model. 0 = off, 1 = instantaneous hysteresis based on tanh, 2 = Plett one-state hysteresis model
LIB.dV0_hys = @(T,X_NE,X_PE,I) 5.606e-05 * exp(-(-1.666e+04) / (LIB.R * T)); % [V] Hysteresis voltage
LIB.gamma_hys = 1000; % Hysteresis dynamics (for Plett model)


% Half-cell thermodynamic material parameters
% -------------------------------------------------------------------------   
% Imports thermodynamic data from legacy files and converts to V0 and dV0/dT for internal use.
% The data files with the values for enthalpy and entropy need to have 3 columns: Stoichiometry X [], dH [J/mol],  dS [J/mol/K].
% Input parameters: Path to NE file, path to PE file.

LIB.importThermodynamicData("Graphite_Smekens2015_Reynier2003_x_dH_dS.dat","LFP_Verbrugge2017_Viswanathan2010_x_dH_dS.dat"); 

LIB.X_NE_lower = 0.005; % [] Stoichiometry of NE where SOC = 0 %
LIB.X_NE_upper = 0.75; % [] Stoichiometry of NE where SOC = 100 %
LIB.X_PE_lower = 0.0004; % [] Stoichiometry of PE where SOC = 100 %
LIB.X_PE_upper = 0.995;  % [] Stoichiometry of PE where SOC = 0 %

end