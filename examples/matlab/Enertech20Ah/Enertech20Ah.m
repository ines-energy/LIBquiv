% LIBquiv function defining the model parameters for the Enertech 20Ah cell. 

% Cell name: Enertech
% Product name: SPB58253172P2
% Nominal capacity: 20 Ah
% Nominal voltage: 3.75 V
% Negative electrode material: Graphite
% Positive electrode material: Lithium nickel manganese cobalt oxide (NMC) and lithium manganese oxide (LMO) blend
% Discharge cut-off voltage: 3.0 V
% Charge cut-off voltage: 4.2 V
% Cell format: Pouch cell

% The parameterization process is described in the following publication: 
% J. A. Braun, R. Behmann, D. Schmider, W. G. Bessler, "State of charge and state of health diagnosis of batteries with voltage-controlled models," J. Power Sources 544, 231828. https://doi.org/10.1016/j.jpowsour.2022.231828
% The OCV curve is from the corresponding Zenodo repository:
% J. A. Braun, R. Behmann, D. Schmider, W. G. Bessler, "Code and measurement data – State of charge and state of health diagnosis of batteries with voltage-controlled models," Zenodo 2022, https://doi.org/10.5281/zenodo.6817725


function LIB = Enertech20Ah()
% instantiate virtual battery object
LIB = LIBquiv();


% Electrical model parameters
% -------------------------------------------------------------------------
LIB.C_N = 19.96*3600; % [As] nominal capacity
LIB.R_s = @(T,X_NE,X_PE,I) 1.0e-3; % [Ohm] serial resistance
    
% RC-Element 1: Negative electrode (NE)
LIB.C_NE = 10.536; % [F] Capacitance of RC-Element 1 (NE)
LIB.R_NE = @(T,X_NE,X_PE,I) 4.6667e-5 * abs(I) + 1.7667e-3; % [Ohm] Resistance of RC-Element 1 (NE)

% RC-Element 2: Positve electrode (PE)
LIB.C_PE = 0; % [F] Capacitance of RC-Element 2 (PE)
LIB.R_PE = @(T,X_NE,X_PE,I) 0; % [Ohm] Resistance of RC-Element 2 (PE)

% RC-Element 3: additional RC-Element (if needed)
LIB.C_3 = 0; % [F] Capacitance of RC-Element 3
LIB.R_3 = @(T,X_NE,X_PE,I) 0; % [Ohm] Resistance of RC-Element 3


% Thermal model parameters
% -------------------------------------------------------------------------
LIB.thermalModel = 0; % Switch on (1) of off (0) thermal model. If off (0), then T_ambient is used as cell temperature.
LIB.T_ambient = 293.15; % [K] Ambient temperature


% Hysteresis model parameters
% -------------------------------------------------------------------------
LIB.hysteresisModel = 0; % Type of hysteresis model. 0 = off, 1 = instantaneous hysteresis based on tanh, 2 = Plett one-state hysteresis model


% Bulk diffusion model
% ------------------------------------------------------------------
LIB.diffusionModel = 3; % Type of diffusion model. 0: No diffusion, 1: Diffusion at NE, 2: Diffusion at PE, 3: Diffusion at NE and PE
LIB.f_shell = 0.2; % [] Fraction of surface capacity in total capacity
LIB.D = 600; % [A] Bulk diffusion coefficient


% Open-circuit voltage curve
% ------------------------------------------------------------------
% Note that LIBquiv per default uses half-cell OCVs. 
% In order to use full-cell OCV, import the full-cell OCV as PE data and set the NE data to zero. Set the PE stoichiometry limits to 1...0. 
% Note also that LIBquiv expects the data in form of vectors of length 1001 (0 to 100 % in increments of 0.1 %).

OCVData = readtable("OCV_vs_SOC_curve.csv");
LIB.V0_PE_1001P = interp1(OCVData.SOC,OCVData.V0,0:0.001:1)'; % Assign full-cell OCV to the PE 
LIB.dV0dT_PE_1001P = zeros(1001,1); % No analysis of the thermal behavior of the OCV curve was performed -> dV0/dT = 0.    
LIB.V0_NE_1001P = zeros(1001,1); % Set NE potential to 0
LIB.dV0dT_NE_1001P = zeros(1001,1); % No analysis of the thermal behavior of the OCV curve was performed -> dV0/dT = 0.    

LIB.X_NE_lower = 0; % [] Stoichiometry of NE where SOC = 0 %
LIB.X_NE_upper = 1; % [] Stoichiometry of NE where SOC = 100 %
LIB.X_PE_lower = 1; % [] Stoichiometry of PE where SOC = 100 %
LIB.X_PE_upper = 0; % [] Stoichiometry of PE where SOC = 0 %

end