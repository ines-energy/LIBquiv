% LIBquiv function defining the model parameters for the Eikto 150 Ah cell. 

% Producer: Eikto
% Product name: YJT40110413-150Ah
% Nominal capacity: 150 Ah
% Nominal voltage: 3.2 V
% Negative electrode material: Graphite
% Positive electrode material: Lithium iron phosphate (LFP)  
% Discharge cut-off voltage: 2.8 V
% Charge cut-off voltage: 3.6 V
% Cell format: Prismatic cell 

% The parameterization process is described in:
% Patricia O. Mmeka, David Schmider, Nicolle Medina, Peter Blechschmid, Edwin Knobbe, Wolfgang G. Bessler, "Low-complexity parameterization of a degradation-sensitive equivalent circuit model", in: ModVal 2026: Symposium on Modeling and Experimental Validation of Electrochemical Energy Technologies, Lausanne, Switzerland, March 10-11, 2026.
% The half-cell data are calculated with the help of the thermodynamic data from the corresponding publications:
% Source E (NE): Smekens 2015 Electrochimica Acta, 174, 615–624, https://doi.org/10.1016/j.electacta.2015.06.015. 
% Source dS (NE): Reynier 2003 J. Power Sources, 119-121, 850–855, https://doi.org/10.1016/S0378-7753(03)00285-4. 
% Source E (PE): Verbrugge 2017 J. Electrochem. Soc., 164(11), E3243-E3253, https://doi.org/10.1149/2.0341708jes. 
% Source dS (PE): Viswanathan 2010 J. Power Sources, 195(11), 3720–3729, https://doi.org/10.1016/j.jpowsour.2009.11.103.


function LIB = Eikto150Ah()
% instantiate virtual battery object
LIB = LIBquiv();


% Electrical model parameters
% -------------------------------------------------------------------------
LIB.C_N = 167*3600; % [As] nominal capacity
LIB.R_s = @(T,X_NE,X_PE,I) 1.179e-04 * exp(3.3e+04/LIB.R*(1/T-1/298.15)); % [Ohm] serial resistance

% RC-Element 1: Negative electrode (NE)
LIB.C_NE = 3.004e+04; % [F] Capacitance of RC-Element 1 (NE)
LIB.R_NE = @(T,X_NE,X_PE,I) (LIB.R*T)./(2*LIB.F*max([abs(I),1e-10])).* asinh(LIB.F/(LIB.R*T).* (1.061e-04 * exp(3.3e+04/LIB.R*(1/T-1/298.15)).*(1/(X_NE.^0.5*(1-X_NE).^0.5))).* max([abs(I),1e-10])); % [Ohm] Resistance of RC-Element 1 (NE)

% RC-Element 2: Positve electrode (PE)
LIB.C_PE = 4.506e+04; % [F] Capacitance of RC-Element 2 (PE)
LIB.R_PE = @(T,X_NE,X_PE,I) 3.738e-05 * exp(3.3e+04/LIB.R*(1/T-1/298.15)) * ( ((sign(-I)+1)/((X_PE)*2)) +  ((sign(I)+1)./((1-X_PE)*2)) )/2; % [Ohm] Resistance of RC-Element 2 (PE)

% RC-Element 3: additional RC-Element (if needed)
LIB.C_3 = 0; % [F] Capacitance of RC-Element 3
LIB.R_3 = @(T,X_NE,X_PE,I) 0; % [Ohm] Resistance of RC-Element 3


% Thermal model parameters
% -------------------------------------------------------------------------
LIB.thermalModel = 1; % Switch on (1) of off (0) thermal model. If off (0), then T_ambient is used as cell temperature.
LIB.T_ambient = 298.15; % [K] Ambient temperature
LIB.T_init = LIB.T_ambient; % [K] Initial temperature
LIB.R_th = 0.414; % [K/W] Thermal resistance
LIB.C_th = 2898; % [J/K] Thermal capacity


% Hysteresis model parameters
% -------------------------------------------------------------------------
LIB.hysteresisModel = 2; % Type of hysteresis model. 0 = off, 1 = instantaneous hysteresis based on tanh, 2 = Plett one-state hysteresis model
LIB.dV0_hys = @(T,X_NE,X_PE,I) 4.67e-2 * exp(1.666e+04/LIB.R*(1/T-1/298.15)); % [V] Hysteresis voltage
LIB.gamma_hys = 1000; % Hysteresis dynamics (for Plett model)


% Half-cell thermodynamic material parameters
% -------------------------------------------------------------------------
% Imports half-cell data for both half-cells from CSV.
% The data files need to have 3 columns: Stoichiometry X [], V0 [V], dV0/dT [V/K].
% Input parameters: Path to NE file, path to PE file.

LIB.importHalfCellDataCSV("Half_cell_data_NE_Eikto150Ah.csv","Half_cell_data_PE_Eikto150Ah.csv");  

LIB.X_NE_lower = 0.00387; % [] Stoichiometry of NE where SOC = 0 %
LIB.X_NE_upper = 0.9521237; % [] Stoichiometry of NE where SOC = 100 %
LIB.X_PE_lower = 0.0000187; % [] Stoichiometry of PE where SOC = 100 %
LIB.X_PE_upper = 0.8865; % [] Stoichiometry of PE where SOC = 0 %

end