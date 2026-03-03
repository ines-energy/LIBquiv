![LIBquiv_logo](./Logo.png)
# LIBquiv - Lithium-ion battery equivalent circuit simulation tool

**LIBquiv** is a flexible and user-friendly open-source MATLAB framework for time-domain simulation of physics-informed equivalent circuit models (ECMs) of lithium-ion batteries (LIBs).  
Designed with an object-oriented approach, LIBquiv balances computational efficiency with physical accuracy and intuitive usage, making it ideal for performance simulations, BMS algorithm development, thermal management simulations, and aging studies.  
LIBquiv is being developed since 2018 at Offenburg University of Applied Sciences, Institute of Sustainable Energy Systems (INES), Offenburg, Germany (see https://ines.hs-offenburg.de/en/institute-of-energy-systems-technology-ines ).

### Key features

* **Modular ECM architecture:** Supports 1 serial resistance and up to 3 RC-elements.
* **Physics-informed model features:** 
    * Lumped thermal modeling for temperature-dependent behavior.
    * Diffusion models for slow-timescale behavior.
    * OCV hysteresis models for path-dependent chemistries.
    * Aging models based on degradation modes for lifetime prediction.
* **Intuitive Syntax:** Control your virtual battery using commands that mirror real-world laboratory cyclers.

## Installation

**1. Clone the repository:**
```bash
git clone https://github.com/ines-energy/LIBquiv.git
```

**2. Add to MATLAB search path:**  
Open MATLAB and run the following command (replace `<PATH_TO_LIBQUIV>` with your actual local folder path):
```matlab
% Add the 'src' folder (not the file itself) to the MATLAB search path
addpath("<PATH_TO_LIBQUIV>\src\matlab\");
% Optional: persists the path for future sessions
savepath; 
```

## Quick start

LIBquiv is very intuitive to use. You can define charge, discharge, and rest protocols with simple method calls that mimic laboratory equipment:
```matlab
% temporarily add path to CALB example
addpath(".\examples\matlab\Calb180Ah")

% create virtual battery object (using the CALB cell from examples)
myLIB = Calb180Ah();

% initialize with 100 % SOC
myLIB.init(1);

% perform a 1 C CCCV discharge and charge with 1h rest
% CC discharge (I/A, t_max/s, cut-off condition)
myLIB.CC(180, 10000, "V < 2.5");

% CV discharge (V/V, t_max/s, cut-off condition)
myLIB.CV(2.5, 10000, "abs(I) < 1.8");

% CC charge (I/A, t_max/s, cut-off condition)
myLIB.CC(-180, 10000, "V > 3.65");

% CV charge (V/V, t_max/s, cut-off condition)
myLIB.CV(3.65, 10000, "abs(I) < 1.8");

% 1 h rest
myLIB.CC(0, 3600);

% plot V and I vs. time
myLIB.plot();
```
**Note:**   
To get more information about the class properties and methods, see the MATLAB help:
```matlab
doc LIBquiv
```
For comprehensive scripts and advanced parameterization, check the [examples](./examples/matlab/) directory.

## License
LIBquiv is fully open-source. For more information, see [LICENSE](./LICENSE.txt).