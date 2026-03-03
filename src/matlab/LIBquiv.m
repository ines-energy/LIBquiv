% ------------------------------------------------------------------
% LIBquiv - Lithium-ion battery equivalent circuit simulation tool
% ------------------------------------------------------------------
% This class represents a virtual lithium-ion battery.
% Authors: Wolfgang Bessler, Ehsan Khorsandnejad, Hanhee Kim, Jonas Braun, David Schmider, Patricia Mmeka
% (c) 2018-2026, all rights reserved
% Licensed under the BSD-3-Clause License.
% See LICENSE file in the project root for full license information.

classdef LIBquiv < handle
    properties
        
        % Electrical model parameters
        % ------------------------------------------------------------------
        
        C_N = 0 % [As] nominal capacity of the cell
        
        % Serial R-Element (Rs)

        R_s = @(T,X_NE,X_PE,I) 0 % [ohm] serial resistance
        
        % RC-Element 1 (NE)

        C_NE = 0 % [F] Capacitance of RC-Element 1 (NE)
        R_NE = @(T,X_NE,X_PE,I) 0 % [ohm] Resistance of RC-Element 1 (NE)
        
        % RC-Element 2 (PE)

        C_PE = 0 % [F] Capacitance of RC-Element 2 (PE)
        R_PE = @(T,X_NE,X_PE,I) 0 % [ohm] Resistance of RC-Element 2 (PE)
        
        % RC-Element 3 (additional)

        C_3 = 0 % [F] Capacitance of RC-Element 3 
        R_3 = @(T,X_NE,X_PE,I) 0 % [ohm] Resistance of RC-Element 3
        
        % Thermal model
        %------------------------------------------------------------------

        thermalModel = 0 % Switch on (1) of off (0) thermal model. If off (0), then T_ambient is used as cell temperature.
        T_ambient = 0 % [K] Ambient temperature
        T_init = 0 % [K] Initial temperature
        R_th = 0 % [K/W] Thermal resistance
        C_th = 0 % [J/K] Thermal capacity
        
        % Hysteresis model
        %------------------------------------------------------------------
        % For Plett model: See Eqs. (11) and (12) in Bessler, W.G., 2024. Capacity and Resistance Diagnosis of Batteries with Voltage-Controlled Models. J. Electrochem. Soc. 171, 080510. https://doi.org/10.1149/1945-7111/ad6938

        hysteresisModel = 0 % Type of hysteresis model. 0 = off, 1 = instantaneous hysteresis based on tanh, 2 = Plett one-state hysteresis model
        dV0_hys = @(T,X_NE,X_PE,I) 0 % [V] Full open-circuit hysteresis voltage 
        gamma_hys = 0 % Hysteresis decay rate constant dynamics (for Plett model)

        % Bulk diffusion model
        % ------------------------------------------------------------------
        % See Eqs. (17) and (18) in Braun, J.A., Behmann, R., Schmider, D., Bessler, W.G., 2022. State of charge and state of health diagnosis of batteries with voltage-controlled models. Journal of Power Sources 544, 231828. https://doi.org/10.1016/j.jpowsour.2022.231828

        diffusionModel = 0 % Type of diffusion model. 0: No diffusion, 1: Diffusion at NE, 2: Diffusion at PE, 3: Diffusion at NE and PE    
        f_shell = 0 % [] Fraction of surface capacity in total capacity        
        D = 0 % [A] Bulk diffusion coefficient 

        % Half-cell thermodynamic material parameters
        %------------------------------------------------------------------

        z = 1 % [] Charge number (equals 1 for Li cells)

        % NE half-cell data

        V0_NE_1001P = [] % [V] Lookup table array with 1001 data points for NE OCV as function of stoichiometry
        dV0dT_NE_1001P = [] % [V/K] Lookup table array with 1001 data points for NE entropic coefficient as function of stoichiometry
        X_NE_lower = 0 % [] Stoichiometry of NE where SOC=0%
        X_NE_upper = 0 % [] Stoichiometry of NE where SOC=100%
        
        % PE half-cell data
        
        V0_PE_1001P = [] % [V] Lookup table array with 1001 data points for PE OCV as function of stoichiometry
        dV0dT_PE_1001P = [] % [V/K] Lookup table array with 1001 data points for PE entropic coefficient as function of stoichiometry
        X_PE_lower = 0 % [] Stoichiometry of PE where SOC=100%
        X_PE_upper = 0 % [] Stoichiometry of PE where SOC=0%
        
        % Aging model
        %------------------------------------------------------------------
        % See Mmeka, P.O., Dubarry, M., Bessler, W.G., 2025. Physics-Informed Aging-Sensitive Equivalent Circuit Model for Predicting the Knee in Lithium-Ion Batteries. J. Electrochem. Soc. 172, 080538. https://doi.org/10.1149/1945-7111/adf9cb
        % Note the use of this model makes the parameters C_N, X_NE_lower X_NE_upper, X_PE_lower, X_PE_upper obsolete, because these become dependent on the aging states.

        agingModel = 0 % Aging model on (1) or off (0)
        aging_C0_NE = 0 % [As] Initial capacity of negative electrode
        aging_C0_PE = 0 % [As] Initial capacity of positive electrode
        aging_V_max = 0 % [V] Charge cut-off voltage
        aging_V_min = 0 % [V] Discharge cut-off voltage
        aging_Q0_LLI_PE = 0 % [As] Initial capacity of LLI at PE
        aging_Q0_LLI_NE = 0 % [As] Initial capacity of LLI at NE
        aging_Q0_LAM_PE = 0 % [As] Initial capacity of LAM at PE
        aging_Q0_LAM_NE = 0 % [As] Initial capacity of LAM at NE
        aging_Q0_SEI_NE = 0 % [As] Initial capacity of SEI at NE
        aging_Q0_PLA_NE = 0 % [As] Initial capacity of plated lithium at NE
        aging_X0_PE = 0 % [] Lithium stoichiometry of pristine PE material
        aging_X0_NE = 0 % [] Lithium stoichiometry of pristine NE material
        aging_X_LAM_PE = 0 % [] Lithium stoichiometry of lost active material in PE
        aging_X_LAM_NE = 0 % [] Lithium stoichiometry of lost active material in NE
        aging_I_LAM_PE = @(I,T,V_PE,X_PE,Q_LAM_PE) 0 % [A] LAM rate at PE
        aging_I_LAM_NE = @(I,T,V_NE,X_NE,Q_LAM_NE,Q_LLI_NE) 0 % [A] LAM rate at NE
        aging_I_LLI_PE = @(I,T,V_PE,X_PE,Q_LLI_PE) 0 % [A] LLI rate at PE
        aging_I_LLI_NE = @(I,T,V_NE,X_NE,Q_LLI_NE,Q_LAM_NE) 0 % [A] LLI rate at NE
        aging_I_SEI_NE = @(I,T,V_NE,X_NE,Q_LLI_NE,Q_LAM_NE,Q_SEI_NE) 0 % [A] SEI rate at NE
        aging_I_PLA_NE = @(I,T,V_NE,X_NE,Q_LLI_NE,Q_LAM_NE) 0 % [A] PLA rate at NE
        aging_accelerationFactor = 1 % [] Factor with which all the above currents are multiplied
        aging_f_R_s = @(Rs,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,C0_PE,C0_NE) 1  % [] Factor for resistance
        aging_f_R_NE = @(R_NE,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,C0_PE,C0_NE,Q_SEI_NE,Q_PLA_NE) 1  % [] Factor for resistance
        aging_f_R_PE = @(R_PE,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,C0_PE,C0_NE) 1  % [] Factor for resistance
        aging_f_R_3 = @(R3,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,C0_PE,C0_NE) 1  % [] Factor for resistance
        
        % Solver parameters
        %------------------------------------------------------------------

        solverType = 0 % 0: Matlab ODE23t, 1: Matlab ODE15s
        toleranceRel = 1e-6 % Absolute tolerance
        toleranceAbs = 1e-6 % Relative tolerance
        
        % Epic constants
        %------------------------------------------------------------------

        F = 96485.33212 % [As/mol] Faraday constant
        R = 8.314462618 % [J/(mol*K)] Kinetic gas constant

        % Internal parameters (not to be changed by the user)
        %------------------------------------------------------------------
        % Current state

        SOC % [] SOC
        I % [A] Cell current
        V % [V] Cell voltage
        Q % [As] Charge
        T % [K] Cell Temperature
        V_RC_NE % [V] Voltage RC-Element 1 (NE)
        V_RC_PE % [V] Voltage RC-Element 2 (NE)
        V_RC_3 % [V] Voltage RC-Element 3
        V_hys % [V] Hysteresis voltage
        V_hys_set % [V] Setpoint hysteresis voltage
        t % [s] Time
        SOC_shell % [] Surface state-of-charge
        SOC_core % [] Bulk state-of-charge
       
        aging_Q_PE % [As] Charge in positive electrode
        aging_Q_NE % [As] Charge in negative electrode
        aging_Q_LAM_PE % [As] Capacity of LAM at PE
        aging_Q_LAM_NE % [As] Capacity of LAM at NE
        aging_Q_LLI_PE % [As] Capacity of LLI at PE
        aging_Q_LLI_NE % [As] Capacity of LLI at NE
        aging_Q_SEI_NE % [As] Capacity of SEI at NE
        aging_Q_PLA_NE % [As] Capacity of plated lithium at NE
        
        % Logged states

        all_SOC % [] Logged state-of-charge
        all_I % [A] Logged cell current
        all_V % [V] Logged cell voltage
        all_V0 % [V] Logged equilibrium voltage
        all_Q % [As] Logged charge
        all_T % [K] Logged temperature
        all_V_RC_NE % [V] Logged voltage RC-Element 1 (NE)
        all_V_RC_PE % [V] Logged voltage RC-Element 2 (PE)
        all_V_RC_3 % [V] Logged voltage RC-Element 3
        all_V_hys % [V] Logged hysteresis voltage 
        all_t % [s] Logged time
        all_SOC_shell % [] Logged surface state-of-charge
        all_SOC_core % [] Logged bulk state-of-charge
        all_aging_Q_PE % [As] Logged charge on positive electrode
        all_aging_Q_NE % [As] Logged charge in negative electrode
        all_aging_Q_LAM_PE % [As] Logged capacity of LAM at PE
        all_aging_Q_LAM_NE % [As] Logged capacity of LAM at NE
        all_aging_Q_LLI_PE % [As] Logged capacity of LLI at PE
        all_aging_Q_LLI_NE % [As] Logged capacity of LLI at NE
        all_aging_Q_SEI_NE % [As] Logged capacity of SEI at NE
        all_aging_Q_Pla_NE % [As] Logged capacity of plated lithium at NE
        
        % Solver

        odesol % Intermediate solution
        yScale % Scale to normalize solution vector
        noStates % Number of dynamic states in solver
        
        % Aging model

        aging_Q_SOC_1 % [As] Charge at full state-of-charge
        aging_Q_SOC_0 % [As] Charge at empty state-of-charge
    end
    
    methods
        % =================================================================
        % Public functions
        % =================================================================
        
        function importThermodynamicData(self,pathNE,pathPE)
        % Imports thermodynamic data from legacy files and converts to V0 and dV0/dT for internal use.
        % The data files with the values for enthalpy and entropy need to have 3 columns: Stoichiometry X [], dH [J/mol],  dS [J/mol/K]
        % The data is assumed to be recorded at 25 °C.
        % For comments in this file use the * symbol
        % Input parameters: Path to NE file, path to PE file
            
            dS0_Li = 29.12; % Entropy of metallic lithium (29.12 J/(mol*K))
            T_ref = 298.15; % Reference temperature for OCV calculation

            % Import of NE data
            fX_dH_dS_NE = fopen(pathNE);
            if fX_dH_dS_NE == -1
                error("LIBquiv: File %s not found or wrong path!", pathNE)
            else
                X_dH_dS_NE = cell2mat(textscan(fX_dH_dS_NE,"%f,%f,%f","CommentStyle","*"));
                fclose(fX_dH_dS_NE);
                X_NE = X_dH_dS_NE(:,1);
                dH_NE = X_dH_dS_NE(:,2);
                dS_NE = X_dH_dS_NE(:,3);

                % Calculate OCV of NE
                V0_NE = -((dH_NE-T_ref*(dS_NE-dS0_Li))/(self.F*self.z));
                dV0dT_NE = (dS_NE - dS0_Li)/(self.F*self.z);              
                
                % Interpolate to 1001 data points for faster processing in getOCVfromX function
                self.V0_NE_1001P = interp1(X_NE,V0_NE,[0:0.001:1]',"linear","extrap");
                self.dV0dT_NE_1001P = interp1(X_NE,dV0dT_NE,[0:0.001:1]',"linear","extrap");
            end
            
            % Import of PE data
            fX_dH_dS_PE = fopen(pathPE);
            if fX_dH_dS_PE == -1
                error("LIBquiv: File %s not found or wrong path!", pathPE)
            else
                X_dH_dS_PE = cell2mat(textscan(fX_dH_dS_PE,"%f,%f,%f","CommentStyle","*"));
                fclose(fX_dH_dS_PE);
                X_PE = X_dH_dS_PE(:,1);
                dH_PE = X_dH_dS_PE(:,2);
                dS_PE = X_dH_dS_PE(:,3);
                
                % Calculate OCV of PE
                V0_PE = -((dH_PE-T_ref*(dS_PE-dS0_Li))/(self.F*self.z));
                dV0dT_PE = (dS_PE - dS0_Li)/(self.F*self.z);              
                
                % Interpolate to 1001 data points for faster processing in getOCVfromX function
                self.V0_PE_1001P = interp1(X_PE,V0_PE,[0:0.001:1]',"linear","extrap");
                self.dV0dT_PE_1001P = interp1(X_PE,dV0dT_PE,[0:0.001:1]',"linear","extrap");
            end
        end

        function importHalfCellDataCSV(self,pathNE,pathPE)
        % Imports half-cell data for both half-cells from CSV.
        % The data files need to have 3 columns: Stoichiometry X [], V0 [V],  dV0/dT [V/K]
        % A reference temperature of 25 °C is assumed.
        % For comments in this file use the # symbol
        % Input parameters: Path to NE file, path to PE file
            
            % Import of NE data
            X_V0_dV0dT_NE = readmatrix(pathNE,"CommentStyle","#");
            X_NE = X_V0_dV0dT_NE(:,1); 
            V0_NE = X_V0_dV0dT_NE(:,2);
            dV0dT_NE = X_V0_dV0dT_NE(:,3);

            % Interpolate to 1001 data points for faster processing in getOCVfromX function
            self.V0_NE_1001P = interp1(X_NE,V0_NE,[0:0.001:1]',"linear","extrap");
            self.dV0dT_NE_1001P = interp1(X_NE,dV0dT_NE,[0:0.001:1]',"linear","extrap");

            % Import of PE data
            X_V0_dV0dT_PE = readmatrix(pathPE,"CommentStyle","#");
            X_PE = X_V0_dV0dT_PE(:,1); 
            V0_PE = X_V0_dV0dT_PE(:,2);
            dV0dT_PE = X_V0_dV0dT_PE(:,3);

            % Interpolate to 1001 data points for faster processing in getOCVfromX function
            self.V0_PE_1001P = interp1(X_PE,V0_PE,[0:0.001:1]',"linear","extrap");
            self.dV0dT_PE_1001P = interp1(X_PE,dV0dT_PE,[0:0.001:1]',"linear","extrap");
        end

        function [V0_1001P, dV0dT_1001P] = importSingleHalfCellDataCSV(~,path)
        % Imports half-cell data for a single half-cell from CSV.
        % Returns two arrays: V0_1001P [V], dV0dT_1001P [V/K]
        % The data files need to have 3 columns: Stoichiometry X [], V0 [V],  dV0/dT [V/K]
        % A reference temperature of 25 °C is assumed.
        % For comments in this file use the # symbol
        % Input parameters: Path to half-cell data file
            
            % Import of half-cell data
            X_V0_dV0dT = readmatrix(path,"CommentStyle","#");
            X = X_V0_dV0dT(:,1); 
            V0 = X_V0_dV0dT(:,2);
            dV0dT = X_V0_dV0dT(:,3);

            % Interpolate to 1001 data points for faster processing in getOCVfromX function
            V0_1001P = interp1(X,V0,[0:0.001:1]',"linear","extrap");
            dV0dT_1001P = interp1(X,dV0dT,[0:0.001:1]',"linear","extrap");
        end

        function init(self,SOC)
        % Initializes the battery object.
        % Input parameters: SOC []
            
            % Error checks on half-cell data and parameters
            if(isempty(self.V0_PE_1001P) || isempty(self.dV0dT_PE_1001P))
                error("LIBquiv: PE half-cell data incomplete. Please import thermodynamic or half-cell data or provide LIBquiv.V0_PE_1001P and LIB.dV0dT_PE_1001P directly.")
            end
            if(isempty(self.V0_NE_1001P) || isempty(self.dV0dT_NE_1001P))
                error("LIBquiv: NE half-cell data incomplete. Please import thermodynamic or half-cell data or provide LIBquiv.V0_NE_1001P and LIB.dV0dT_NE_1001P directly.")
            end
            if(size(self.V0_PE_1001P,1) ~= 1001 || size(self.dV0dT_PE_1001P,1) ~= 1001)
                error("LIBquiv: PE half-cell data incorrect format. Sizes are V0_PE: %s, dV0dT_PE: %s, should be [1001 1].",mat2str(size(self.V0_PE_1001P)),mat2str(size(self.dV0dT_PE_1001P)));
            end
            if(size(self.V0_NE_1001P,1) ~= 1001 || size(self.dV0dT_NE_1001P,1) ~= 1001)
                error("LIBquiv: NE half-cell data incorrect format. Sizes are V0_NE: %s, dV0dT_NE: %s, should be [1001 1].",mat2str(size(self.V0_NE_1001P)),mat2str(size(self.dV0dT_NE_1001P)));
            end
            if(self.thermalModel ~= 0 && self.thermalModel ~= 1)
                error("LIBquiv: Parameter thermalModel can be either 0 or 1.");
            end
            if(self.agingModel ~= 0 && self.diffusionModel ~= 0)
                error("LIBquiv: Aging model not possible in combination with diffusion model.");
            end
            if self.solverType ~= 0 && self.solverType ~= 1
                 error("LIBquiv: SolverType is not supported (only 0 or 1).");
            end
            
            % Set initial state
            self.SOC = SOC;
            self.SOC_shell = SOC;
            self.SOC_core = SOC;
            self.I = 0;

            if(self.thermalModel == 0)
                self.T = self.T_ambient;
            else
                self.T = self.T_init;
            end

            if(self.hysteresisModel < 2)
                self.V_hys = 0;       
            else
                self.V_hys = -0.5*self.dV0_hys(self.T,self.X_NE(SOC),self.X_PE(SOC),self.I); % Assume discharge hysteresis
                self.V_hys_set = self.V_hys;
            end
            
            if(~self.agingModel) 
                self.noStates = 10;
                self.Q = SOC*self.C_N; % Initial charge content
            else
                self.noStates = 18;
                self.Q = 0;
                self.aging_Q_PE = self.aging_X0_PE*self.aging_C0_PE - self.aging_Q0_LLI_PE -self.aging_X_LAM_PE*self.aging_Q0_LAM_PE;
                self.aging_Q_NE = self.aging_X0_NE*self.aging_C0_NE - self.aging_Q0_LLI_NE- self.aging_Q0_SEI_NE - self.aging_Q0_PLA_NE-self.aging_X_LAM_NE*self.aging_Q0_LAM_NE; 
                self.aging_Q_LAM_PE = self.aging_Q0_LAM_PE;
                self.aging_Q_LAM_NE = self.aging_Q0_LAM_NE;
                self.aging_Q_LLI_PE = self.aging_Q0_LLI_PE;
                self.aging_Q_LLI_NE = self.aging_Q0_LLI_NE;
                self.aging_Q_SEI_NE = self.aging_Q0_SEI_NE;
                self.aging_Q_PLA_NE = self.aging_Q0_PLA_NE;
                
                % SOC calibration and determination of capacity
                self.agingCalculateQSOCXCN();
                
                % Set cell to desired SOC
                dQ = self.C_N * (SOC - self.SOC);
                self.aging_Q_PE = self.aging_Q_PE - dQ;
                self.aging_Q_NE = self.aging_Q_NE + dQ;
                self.Q = self.Q + dQ;
                self.SOC = (self.Q-self.aging_Q_SOC_0)/(self.aging_Q_SOC_1-self.aging_Q_SOC_0);
            end
            
            self.V = self.V0();
            self.V_RC_NE = 0;
            self.V_RC_PE = 0;
            self.V_RC_3 = 0;
            self.clear();
        end
        
        function clear(self)
        % Resets results storage arrays.
            
            self.all_SOC = self.SOC;
            self.all_I = self.I;
            self.all_V = self.V;
            self.all_V0 = self.V0;
            self.all_Q = self.Q;
            self.all_T = self.T;
            self.all_V_RC_NE = self.V_RC_NE;
            self.all_V_RC_PE = self.V_RC_PE;
            self.all_V_RC_3 = self.V_RC_3;
            self.all_V_hys = self.V_hys;
            self.all_t = 0;
            self.t = 0;
            self.all_SOC_shell = self.SOC_shell;
            self.all_SOC_core = self.SOC_core;
            
            if(self.agingModel)
                self.all_aging_Q_PE = self.aging_Q_PE;
                self.all_aging_Q_NE = self.aging_Q_NE;
                self.all_aging_Q_LAM_PE = self.aging_Q_LAM_PE;
                self.all_aging_Q_LAM_NE = self.aging_Q_LAM_NE;
                self.all_aging_Q_LLI_PE = self.aging_Q_LLI_PE;
                self.all_aging_Q_LLI_NE = self.aging_Q_LLI_NE;
                self.all_aging_Q_SEI_NE = self.aging_Q_SEI_NE;
                self.all_aging_Q_Pla_NE = self.aging_Q_PLA_NE;
            end
        end
        
        function V_0 = V0(self)
        % Returns the equilibrium voltage.
            
            if self.diffusionModel == 1
                V_0 = self.getOCVfromSOC(self.SOC_shell,self.SOC,self.T);
            elseif self.diffusionModel == 2
                V_0 = self.getOCVfromSOC(self.SOC,self.SOC_shell,self.T);
            elseif  self.diffusionModel == 3 
                V_0 = self.getOCVfromSOC(self.SOC_shell,self.SOC_shell,self.T);
            elseif self.diffusionModel == 0
                V_0 = self.getOCVfromSOC(self.SOC,self.SOC,self.T);
            end 
        end
        
        function CC(self, I, dt, varargin)
        % Performs a constant-current simulation.
        % Input parameters: Current [A], time span [s] [, break criterion]

            if ~isempty(varargin)
                breakCriterion = varargin{1};
            else
                breakCriterion = "0";
            end
            self.solveTransient("I",I,dt,breakCriterion);
        end

        function CP(self, P, dt, varargin)
        % Performs a constant-power simulation.
        % Input parameters: Power [W], time span [s] [, break criterion]
            
            if ~isempty(varargin)
                breakCriterion = varargin{1};
            else
                breakCriterion = "0";
            end
            self.solveTransient("P",P,dt,breakCriterion);
        end

        function CV(self, V, dt, varargin)
        % Performs a constant-voltage simulation.
        % Input parameters: Cell voltage [V], time span [s] [, break criterion]
            
            if ~isempty(varargin)
                breakCriterion = varargin{1};
            else
                breakCriterion = "0";
            end
            self.solveTransient("V",V,dt,breakCriterion);
        end
  
        function X_NE = X_NE(self,SOC)
        % NE lithium stoichiometry as function of SOC.
            
            X_NE = SOC*(self.X_NE_upper - self.X_NE_lower) + self.X_NE_lower;
        end

        function X_NE = X_NE_surf(self)
        % NE lithium stoichiometry as function of self.SOC or self.SOC_shell.
            
            if self.diffusionModel == 1 || self.diffusionModel == 3
                X_NE = self.SOC_shell*(self.X_NE_upper - self.X_NE_lower) + self.X_NE_lower;
            elseif self.diffusionModel == 2 || self.diffusionModel == 0
                X_NE = self.SOC*(self.X_NE_upper - self.X_NE_lower) + self.X_NE_lower;
            end
        end
        
        function X_PE = X_PE(self,SOC)
        % PE lithium stoichiometry as function of SOC.
            
            X_PE = (1-SOC)*(self.X_PE_upper - self.X_PE_lower) + self.X_PE_lower;
        end
        
        function X_PE = X_PE_surf(self)
        % PE lithium stoichiometry as function of self.SOC or self.SOC_shell.
            
            if self.diffusionModel == 1 || self.diffusionModel == 0
                X_PE = (1-self.SOC)*(self.X_PE_upper - self.X_PE_lower) + self.X_PE_lower;
            elseif self.diffusionModel == 2 || self.diffusionModel == 3
                X_PE = (1-self.SOC_shell)*(self.X_PE_upper - self.X_PE_lower) + self.X_PE_lower;
            end
        end
        
        function V = calculateSteadyStateVoltage(self, T, I, SOC)
        % Steady state voltage as function of T, I, SOC.
            
            if(self.diffusionModel > 0)
                warning("LIBquiv: calculateSteadyStateVoltage(): Diffusion voltage is not considered.");
            end
            
            V0 = self.getOCVfromSOC(SOC,SOC,T);
            X_NE = self.X_NE(SOC);
            X_PE = self.X_PE(SOC);
            R_NE = self.R_NE(T,X_NE,X_PE,I);
            R_PE = self.R_PE(T,X_NE,X_PE,I);
            R3 = self.R_3(T,X_NE,X_PE,I);
            Rs = self.R_s(T,X_NE,X_PE,I);
            if(self.agingModel)
                Rs = Rs * self.aging_f_R_s(Rs,self.aging_Q_LLI_PE,self.aging_Q_LLI_NE,self.aging_Q_LAM_PE,self.aging_Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE);
                R_NE = R_NE * self.aging_f_R_NE(R_NE,self.aging_Q_LLI_PE,self.aging_Q_LLI_NE,self.aging_Q_LAM_PE,self.aging_Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE, self.aging_Q_SEI_NE, self.aging_Q_PLA_NE);
                R_PE = R_PE * self.aging_f_R_PE(R_PE,self.aging_Q_LLI_PE,self.aging_Q_LLI_NE,self.aging_Q_LAM_PE,self.aging_Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE);
                R3 = R3 * self.aging_f_R_3(R3,self.aging_Q_LLI_PE,self.aging_Q_LLI_NE,self.aging_Q_LAM_PE,self.aging_Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE);
            end
            V_Rs = Rs * I;
            V_RNE = R_NE * I;
            V_RPE = R_PE * I;
            V_R3 = R3 * I;
            
            if I == 0
                V = V0;
            elseif I > 0
                V = -(V_Rs+V_RNE+V_RPE+V_R3) + V0 - self.dV0_hys(T,self.X_NE_surf(),self.X_PE_surf(),I)/2;
            else
                V = -(V_Rs+V_RNE+V_RPE+V_R3) + V0 + self.dV0_hys(T,self.X_NE_surf(),self.X_PE_surf(),I)/2;
            end
        end
        
        function R = getInternalResistance(self)
        % Internal resistance of cell at current state.
            
            Rs = self.R_s(self.T,self.X_NE_surf(),self.X_PE_surf(),self.I);
            R_NE = self.R_NE(self.T,self.X_NE_surf(),self.X_PE_surf(),self.I);
            R_PE = self.R_PE(self.T,self.X_NE_surf(),self.X_PE_surf(),self.I);
            R3 = self.R_3(self.T,self.X_NE_surf(),self.X_PE_surf(),self.I);
            R = Rs+R_NE+R_PE+R3;
        end
        
        function [Z_Re,Z_Im] = EIS(self,Z_freq)
        % Frequency-domain impedance as function of frequency.
        % Input parameters: Frequency [Hz]
            
            if(self.diffusionModel > 0)
                warning("LIBquiv: calculateSteadyStateVoltage(): Diffusion impedance is not considered.");
            end

            X_NE = self.X_NE_surf();
            X_PE = self.X_PE_surf();
            Omega = 2*pi.*Z_freq;
            Z_Rs = self.R_s(self.T,X_NE,X_PE,self.I);
            if self.R_NE(self.T,X_NE,X_PE,self.I) == 0 || self.C_NE == 0
                Z_RC1 = 0;
            else
                Z_RC1 = 1./((1./self.R_NE(self.T,X_NE,X_PE,self.I)) + 1./(-1i./(Omega*self.C_NE)));
            end
            if self.R_PE(self.T,X_NE,X_PE,self.I) == 0 || self.C_PE == 0
                Z_RC2 = 0;
            else
                Z_RC2 = 1./((1./self.R_PE(self.T,X_NE,X_PE,self.I)) + 1./(-1i./(Omega*self.C_PE)));
            end
            
            if self.R_3(self.T,X_NE,X_PE,self.I) == 0 || self.C_3 == 0
                Z_RC3 = 0;
            else
                Z_RC3 = 1./((1./self.R_3(self.T,X_NE,X_PE,self.I)) + 1./(-1i./(Omega*self.C_3)));
            end
            
            Z = Z_Rs+Z_RC1+Z_RC2+Z_RC3;
            % Impedance
            Z_Re = real(Z);
            Z_Im = imag(Z);
        end
        
        function plot(self,varargin)
        % Plot time traces of current and voltage.
            
            if ~isempty(varargin)
                figure(varargin{1});
            end

            % Determine time scaling and label
            if (self.t < 60*5)
                t_scaled = self.all_t;
                time_label = "Time  /  s";
            elseif (self.t < 3600)
                t_scaled = self.all_t / 60;
                time_label = "Time  /  min";
            else
                t_scaled = self.all_t / 3600;
                time_label = "Time  /  h";
            end

            % Plotting with yyaxis
            yyaxis left
            plot(t_scaled,self.all_V);
            ylabel("Voltage  /  V");

            yyaxis right
            plot(t_scaled,self.all_I);
            ylabel("Current  /  A");

            xlabel(time_label);
        end
        
        % =================================================================
        % Private functions
        % =================================================================
        
        function solveTransient(self,setpoint,value,dt,breakCriterion)
        % Simulation (CC, CV or CP) with MATLAB solvers ODE23t or ODE15s.    
            
            % Get initial state, scaling factor, mass matrix
            [y0, M] = self.prepareSimulation();
            
            % Set time
            timespan = [self.t self.t+dt];
            
            if(length(self.all_t) > 2 && self.all_t(end) > self.all_t(end-1))
                dt_init = self.all_t(end)-self.all_t(end-1);
            else
                dt_init = dt/10;
            end
            
            % Check break criterion
            hasBreak = self.checkBreakCriterion(0,y0',0,breakCriterion);
            if(hasBreak)
                warning("LIBquiv: Break criterion alreay fulfilled");
                return;
            end

            % Run solver
            options = odeset("RelTol",self.toleranceRel,"AbsTol",self.toleranceAbs,"InitialStep",dt_init,"Mass",M,"MStateDependence","none","OutputFcn",@(t,y,flag) checkBreakCriterion(self,t,y,flag,breakCriterion));
            if self.solverType == 0 % ODE 23t
                self.odesol = ode23t(@(t,y) odeFun(self,t,y,setpoint,value),timespan,y0,options);
            elseif self.solverType == 1 % ODE15s
                self.odesol = ode15s(@(t,y) odeFun(self,t,y,setpoint,value),timespan,y0,options);
            end
            t = self.odesol.x';
            y = self.odesol.y'.*self.yScale;

            % These lines are inserted in order to avoid doublets in entries upon consecutive simulation runs
            if length(t) > 1
                t(1) = [];
                y(1,:) = [];
            end

            % Store results
            self.storeSimulationResults(t,y);
            if(self.agingModel)
                self.agingCalculateQSOCXCN();  % Determine CN and other parameters of the aged cell after simulation
            end
        end
                       
        function [y0, M] = prepareSimulation(self)
        % Calculates scaling factors, initial values, mass matrix.

            % Set initial state
            y0 = [self.Q, self.I, self.SOC, self.V, self.T, self.V_RC_NE, self.V_RC_PE, self.V_RC_3, self.V_hys, self.SOC_shell];
            self.yScale = [self.C_N, self.C_N/3600, 1, 1, 1, 1, 1, 1, 1, 1];
            
            if(self.agingModel)
                y0 = [y0, self.aging_Q_PE, self.aging_Q_NE, self.aging_Q_LAM_PE, self.aging_Q_LAM_NE, self.aging_Q_LLI_PE, self.aging_Q_LLI_NE, self.aging_Q_SEI_NE, self.aging_Q_PLA_NE];
                self.yScale = [self.yScale,self.C_N,self.C_N,self.C_N/100,self.C_N/100,self.C_N/100,self.C_N/100,self.C_N/100,self.C_N/100];
            end
  
            y0 = y0 ./ self.yScale;
                                  
            % Set mass matrix
            M = zeros (self.noStates,self.noStates);
            M(1,1) = 1; % Define differential equations
            M(5,5) = self.thermalModel;
            M(6,6) = 1;
            M(7,7) = 1;
            M(8,8) = 1;
            if(self.hysteresisModel == 2)  % Hysteresis voltage as dynamic state
                M(9,9) = 1;
            else
                M(9,9) = 0;
            end
            if(self.diffusionModel > 0) % Use diffusion model? additional balance equation for core capacity needed
                M(10,10) = 1;
            else
                M(10,10) = 0;
            end
            if self.agingModel
                for n = 11:self.noStates
                    M(n,n) = 1;
                end
            end
        end
        
        function storeSimulationResults(self,t,y)
        % Copies results from solution vector into the class.
            
            self.Q = y(end,1);
            self.I = y(end,2);
            self.SOC = y(end,3);
            self.V = y(end,4);
            self.V_hys = y(end,9);
            self.T = y(end,5);
            self.V_RC_NE = y(end,6);
            self.V_RC_PE = y(end,7);
            self.V_RC_3 = y(end,8);
            self.SOC_shell = y(end,10);
            if(self.diffusionModel > 0)
                self.SOC_core = (self.SOC-self.f_shell*self.SOC_shell)/(1-self.f_shell);
            else
                self.SOC_core = self.SOC_shell;
            end
            self.t = t(end);

            self.all_Q(end+1:end+size(y,1),1) = y(:,1);
            self.all_I(end+1:end+size(y,1),1) = y(:,2);
            self.all_SOC(end+1:end+size(y,1),1) = y(:,3);
            self.all_V(end+1:end+size(y,1),1) = y(:,4);
            self.all_V_hys(end+1:end+size(y,1),1) = y(:,9);
            self.all_T(end+1:end+size(y,1),1) = y(:,5);
            self.all_V_RC_NE(end+1:end+size(y,1),1) = y(:,6);
            self.all_V_RC_PE(end+1:end+size(y,1),1) = y(:,7);
            self.all_V_RC_3(end+1:end+size(y,1),1) = y(:,8);
            self.all_SOC_shell(end+1:end+size(y,1),1) = y(:,10);
            if(self.diffusionModel > 0)
                self.all_SOC_core(end+1:end+size(y,1),1) = (y(:,3)-self.f_shell*y(:,10))./(1-self.f_shell);
            else
                self.all_SOC_core(end+1:end+size(y,1),1) = y(:,10);
            end
            self.all_t(end+1:end+size(y,1),1) = t;
            
            V0 = self.getOCVfromSOC(y(:,3),y(:,3),y(:,5));
            self.all_V0(end+1:end+size(y,1),1) = V0;
            
            if self.agingModel
                self.aging_Q_PE = y(end,11);
                self.aging_Q_NE = y(end,12);
                self.aging_Q_LAM_PE = y(end,13);
                self.aging_Q_LAM_NE = y(end,14);
                self.aging_Q_LLI_PE = y(end,15);
                self.aging_Q_LLI_NE = y(end,16);
                self.aging_Q_SEI_NE = y(end,17);
                self.aging_Q_PLA_NE = y(end,18);
                self.all_aging_Q_PE(end+1:end+size(y,1),1) = y(:,11);
                self.all_aging_Q_NE(end+1:end+size(y,1),1) = y(:,12);
                self.all_aging_Q_LAM_PE(end+1:end+size(y,1),1) = y(:,13);
                self.all_aging_Q_LAM_NE(end+1:end+size(y,1),1) = y(:,14);
                self.all_aging_Q_LLI_PE(end+1:end+size(y,1),1) = y(:,15);
                self.all_aging_Q_LLI_NE(end+1:end+size(y,1),1) = y(:,16);
                self.all_aging_Q_SEI_NE(end+1:end+size(y,1),1) = y(:,17);
                self.all_aging_Q_Pla_NE(end+1:end+size(y,1),1) = y(:,18);
            end
        end

        function f = odeFun(self,t,y,setpoint,value)
        % Calculate right-hand side.    
            
            if(any(isnan(y)))
                error("NaN in solution vector at time %e.",t);
            end
            % Get current state values
            y = y .* self.yScale';
            Q = y(1);
            I = y(2);
            SOC = y(3);
            V = y(4);
            T = y(5);
            V_RCNE = y(6);
            V_RCPE = y(7);
            V_RC3 = y(8);
            V_hys = y(9);
            SOC_shell = y(10);
            if self.agingModel
                Q_PE = y(11);
                Q_NE = y(12);
                Q_LAM_PE = y(13);
                Q_LAM_NE = y(14);
                Q_LLI_PE = y(15);
                Q_LLI_NE = y(16);
                Q_SEI_NE = y(17);
                Q_PLA_NE = y(18);
            end
            
            % Prepare solution vector
            f = zeros(self.noStates,1);
            
            % Differential equation for Q (dQ/dt=-I)
            f(1) = -I;
            
            % Algebraic equation for SOC 
            if(~self.agingModel)
                f(3) = SOC - Q/self.C_N;  % SOC = Q/C
            else
                f(3) = SOC - (Q-self.aging_Q_SOC_0)/(self.aging_Q_SOC_1-self.aging_Q_SOC_0);
            end
            
            % Get stoichiometries
            if(~self.agingModel)
                if self.diffusionModel == 1
                    X_NE = self.X_NE(SOC_shell);
                    X_PE = self.X_PE(SOC);
                elseif self.diffusionModel == 2
                    X_NE = self.X_NE(SOC);
                    X_PE = self.X_PE(SOC_shell);
                elseif self.diffusionModel == 3
                    X_NE = self.X_NE(SOC_shell);
                    X_PE = self.X_PE(SOC_shell);
                elseif self.diffusionModel == 0
                    X_NE = self.X_NE(SOC);
                    X_PE = self.X_PE(SOC);
                end
            else
                X_NE = Q_NE/(self.aging_C0_NE-Q_LAM_NE);
                X_PE = Q_PE/(self.aging_C0_PE-Q_LAM_PE);
            end

            % Get resistances and OCVs
            R_NE = self.R_NE(T,X_NE,X_PE,I);
            R_PE = self.R_PE(T,X_NE,X_PE,I);
            R3 = self.R_3(T,X_NE,X_PE,I);
            Rs = self.R_s(T,X_NE,X_PE,I);
            [V0,dS_NE,dS_PE,V0_PE,V0_NE] = self.getOCVfromX(X_NE,X_PE,T); % Get equilibrium cell voltage
            if(self.agingModel)
                Rs = Rs * self.aging_f_R_s(Rs,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE);
                R_NE = R_NE * self.aging_f_R_NE(R_NE,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE, Q_SEI_NE, Q_PLA_NE);
                R_PE = R_PE * self.aging_f_R_PE(R_PE,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE);
                R3 = R3 * self.aging_f_R_3(R3,Q_LLI_PE,Q_LLI_NE,Q_LAM_PE,Q_LAM_NE,self.aging_C0_PE,self.aging_C0_NE);
            end
            
            if setpoint == "I"
                % Algebraic equation for current
                f(2) = I - value;
                
                % Algebraic equation for cell voltage
                f(4) = V - (V0 + V_hys) + I * Rs + V_RCNE + V_RCPE + V_RC3;
                
            elseif setpoint == "V"
                % Algebraic equation for current
                f(2) = V - (V0 + V_hys) + I * Rs + V_RCNE + V_RCPE + V_RC3;
                
                % Algebraic equation for cell voltage
                f(4) =  V - value;
                
            elseif setpoint == "P"
                % Algebraic equation for power
                f(2) = I*V - value;
                
                % Algebraic equation for cell voltage
                f(4) = V - (V0 + V_hys) + I * Rs + V_RCNE + V_RCPE + V_RC3;
            else
                warning("LIBquiv: Unknown setpoint");
                eval(["f(2) = (" setpoint ") - " num2str(value) ";"]);
                f(4) = V - (V0 + V_hys) + I * Rs + V_RCNE + V_RCPE + V_RC3;
            end
            
            % Differential equation for temperature
            if(self.thermalModel == 1)
                P_rev = -T *I*(-dS_NE+dS_PE)/(self.F*self.z);
                P_irrev1 = 0;
                P_irrev2 = 0;
                P_irrev3 = 0;
                if R_NE~=0 && self.C_NE~=0
                    P_irrev1 = V_RCNE^2/R_NE;
                end
                if R_PE~=0 && self.C_PE~=0
                    P_irrev2 = V_RCPE^2/R_PE;
                end
                if R3~=0 && self.C_3~=0
                    P_irrev3 = V_RC3^2/R3;
                end
                P_irrev = I^2 * Rs + P_irrev1 + P_irrev2 + P_irrev3;
                
                f(5) = (P_irrev + P_rev - (T - self.T_ambient)/self.R_th)/self.C_th;
            else
                f(5) = T-self.T_ambient;
            end
            
            % Differential equation for voltage of RC elements
            if R_NE == 0 || self.C_NE == 0
                f(6) = 0;
            else
                f(6) = (I - V_RCNE/R_NE)/self.C_NE;
            end
            
            if R_PE == 0 || self.C_PE == 0
                f(7) = 0;
            else
                f(7) = (I - V_RCPE/R_PE)/self.C_PE;
            end
            
            if R3 == 0 || self.C_3 == 0
                f(8) = 0;
            else
                f(8) = (I - V_RC3/R3)/self.C_3;
            end
            
            % Differential or algebraic equation for hysteresis voltage
            if(self.hysteresisModel == 0)  % hysteresis off
                V_hys_set = 0;
                f(9) = V_hys - V_hys_set;
            elseif(self.hysteresisModel == 1) % instantaneous hysteresis modeled by tanh
                V_hys_set = - 0.5*self.dV0_hys(T,X_NE,X_PE,I)*tanh(200*I/(self.C_N/3600));
                f(9) = V_hys - V_hys_set;
            elseif(self.hysteresisModel == 2) % Plett one-state hysteresis model
                if(abs(I) > 0)
                    V_hys_set = - 0.5*self.dV0_hys(T,X_NE,X_PE,I)*sign(I);
                    self.V_hys_set = V_hys_set;
                else
                    V_hys_set = self.V_hys_set;
                end
                tau_hys = abs(self.C_N/self.gamma_hys/I);
                f(9) = -1/tau_hys * (V_hys - V_hys_set);
            end
            
            % Differential or algebraic equation for shell SOC
            if self.diffusionModel == 0 % No diffusion model: Algebraic equation SOC_shell = SOC = Q/C, same as overall SOC
                f(10) = SOC_shell - Q/self.C_N;
            else  % Differential equation for SOC_shell
                f(10) = 1/self.C_N/self.f_shell*(-I-self.D*(SOC_shell - (SOC-self.f_shell*SOC_shell)/(1-self.f_shell)));
            end

            % Aging balance equations for Q_PE, Q_NE, LAM_PE, LAM_ME, LLI_PE, LLI_NE, SEI_NE, PLA_NE
            if(self.agingModel)
                % Calculate half-cell potentials, including RC dynamics 
                V_PE = V0_PE - V_RCPE - I*R_PE;  
                V_NE = V0_NE + V_RCNE + I*R_NE;

                I_LAM_PE = self.aging_accelerationFactor*self.aging_I_LAM_PE(I,T,V_PE,X_PE,Q_LAM_PE);
                I_LAM_NE = self.aging_accelerationFactor*self.aging_I_LAM_NE(I,T,V_NE,X_NE,Q_LAM_NE,Q_LLI_NE);
                I_LLI_PE = self.aging_accelerationFactor*self.aging_I_LLI_PE(I,T,V_PE,X_PE,Q_LLI_PE);
                I_LLI_NE = self.aging_accelerationFactor*self.aging_I_LLI_NE(I,T,V_NE,X_NE,Q_LLI_NE,Q_LAM_NE);
                I_SEI_NE = self.aging_accelerationFactor*self.aging_I_SEI_NE(I,T,V_NE,X_NE,Q_LLI_NE,Q_LAM_NE,Q_SEI_NE);
                I_PLA_NE = self.aging_accelerationFactor*self.aging_I_PLA_NE(I,T,V_NE,X_NE,Q_LLI_NE,Q_LAM_NE);
                X_LAM_PE = self.aging_X_LAM_PE;
                X_LAM_NE = self.aging_X_LAM_NE;

                f(11) = I - I_LLI_PE - X_LAM_PE*I_LAM_PE;   % Q_PE
                f(12) = -I - I_LLI_NE - X_LAM_NE*I_LAM_NE - I_SEI_NE - I_PLA_NE;    % Q_NE
                f(13) = I_LAM_PE;   % LAM_PE
                f(14) = I_LAM_NE;   % LAM_NE
                f(15) = I_LLI_PE + X_LAM_PE*I_LAM_PE;   % LLI_PE
                f(16) = I_LLI_NE + X_LAM_NE*I_LAM_NE + I_SEI_NE + I_PLA_NE;   % LLI_NE
                f(17) = I_SEI_NE;   % SEI_NE
                f(18) = I_PLA_NE;   % PLA_NE
            end
            
            % Re-scale and return
            f = f ./self.yScale';
            if(any(isnan(f)))
                error("LIBquiv: NaN in right-hand side at time %e.",t);
            end
            if(any(isinf(f)))
                error("LIBquiv: INF in right-hand side at time %e.",t);
            end
        end
        
        function status = checkBreakCriterion(self,t,y,flag,breakCriterion)
        % Assess user-given break criteria.
            
            if(~isempty(flag))
                status = 0;
                return
            end
            y = y.*self.yScale';
            I = y(2);
            SOC = y(3);
            V = y(4);
            T = y(5);
            SOC_shell = y(10);
            if(eval(breakCriterion))
                status = 1;  % Return 1 to stop
            else
                status = 0;
            end
        end
        
        function [V0_out,dS_NE,dS_PE] = getOCVfromSOC(self,SOC_NE,SOC_PE,T_in)
        % Return equilibrium voltage and entropy change, as function of SOC.
            
            X_NE = self.X_NE(SOC_NE); % Which X at NE with inputed SOC
            X_PE = self.X_PE(SOC_PE); % Which X at PE with inputed SOC
            
            [V0_out,dS_NE,dS_PE] = self.getOCVfromX(X_NE,X_PE,T_in);
        end

        function [V0,dS_NE,dS_PE,V0_PE,V0_NE] = getOCVfromX(self,X_NE,X_PE,T_in)
        % Return equilibrium voltage and entropy change, as function of X.    

            dS0_Li = 29.12; % Entropy of metallic lithium (29.12 J/(mol*K))
            T_ref = 298.15; % Reference temperature for OCV calculation

            % Interpolation within array of 1001 data points
            i = X_NE*1000+1;
            fi = floor(i);
            fi(fi > 1000) = 1000;
            fi(fi < 1) = 1;
            V0_NE = (1-(i-fi)).*self.V0_NE_1001P(fi) + (i-fi).*self.V0_NE_1001P(fi+1);
            dV0dT_NE = (1-(i-fi)).*self.dV0dT_NE_1001P(fi) + (i-fi).*self.dV0dT_NE_1001P(fi+1);
            V0_NE = V0_NE + dV0dT_NE.*(T_in-T_ref);
            dS_NE = dV0dT_NE.*self.z.*self.F+dS0_Li;

            % Interpolation within array of 1001 data points
            i = X_PE*1000+1;
            fi = floor(i);
            fi(fi > 1000) = 1000;
            fi(fi < 1) = 1;
            V0_PE = (1-(i-fi)).*self.V0_PE_1001P(fi) + (i-fi).*self.V0_PE_1001P(fi+1);
            dV0dT_PE = (1-(i-fi)).*self.dV0dT_PE_1001P(fi) + (i-fi).*self.dV0dT_PE_1001P(fi+1);
            V0_PE = V0_PE + dV0dT_PE.*(T_in-T_ref);
            dS_PE = dV0dT_PE.*self.z.*self.F+dS0_Li;

            V0 = V0_PE-V0_NE; % Cell voltage
        end
        
        function [Q_SOC_0,Q_SOC_1,X_PE_SOC_0,X_PE_SOC_1,X_NE_SOC_0,X_NE_SOC_1] = agingCalculateQSOCXCN(self)
        % Aging model: SOC, X and C calibration.
            
            % Lower voltage limit
            dQ0 = (self.aging_Q_NE +self.aging_Q_PE)/2;
            dQ = fzero(@(dQ) self.agingDQFun(dQ) - self.aging_V_min,dQ0);
            Q_SOC_0 = self.Q + dQ;
            X_PE_SOC_0 = (self.aging_Q_PE-dQ)/(self.aging_C0_PE-self.aging_Q_LAM_PE);
            X_NE_SOC_0 = (self.aging_Q_NE+dQ)/(self.aging_C0_NE-self.aging_Q_LAM_NE);
            
            % Upper voltage limit
            dQ = fzero(@(dQ) self.agingDQFun(dQ) - self.aging_V_max,dQ0);
            Q_SOC_1 = self.Q + dQ;
            X_PE_SOC_1 = (self.aging_Q_PE-dQ)/(self.aging_C0_PE-self.aging_Q_LAM_PE);
            X_NE_SOC_1 = (self.aging_Q_NE+dQ)/(self.aging_C0_NE-self.aging_Q_LAM_NE);
            
            % Set internal states
            self.aging_Q_SOC_0 = Q_SOC_0;
            self.aging_Q_SOC_1 = Q_SOC_1;
            self.X_PE_lower = X_PE_SOC_1;
            self.X_PE_upper = X_PE_SOC_0;
            self.X_NE_lower = X_NE_SOC_0;
            self.X_NE_upper = X_NE_SOC_1;
            self.C_N = self.aging_Q_SOC_1 - self.aging_Q_SOC_0;
            self.SOC = (self.Q-self.aging_Q_SOC_0)/(self.aging_Q_SOC_1-self.aging_Q_SOC_0);
        end

        function V = agingDQFun(self,dQ)
        % Calculates cell voltage based on change in charge distribution.
            
            X_PE = (self.aging_Q_PE-dQ)/(self.aging_C0_PE-self.aging_Q_LAM_PE);
            X_NE = (self.aging_Q_NE+dQ)/(self.aging_C0_NE-self.aging_Q_LAM_NE);
            V = self.getOCVfromX(X_NE, X_PE, self.T);
        end
    end
end