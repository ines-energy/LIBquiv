% add path to LIBquiv class
addpath("../../../src/matlab/");

% create virtual battery object
myLIB = Eikto150Ah;


% Cycle the cell
% -------------------------------------------------------------------------

% initialize with 75 % SOC
myLIB.init(0.75);

% constant-power (CP) discharge (P/W, t_max/s, cut-off condition)
myLIB.CP(100, 20000, "V < 2.8");

% 1 h rest
myLIB.CC(0, 3600);

% constant-current (CC) charge (I/A, t_max/s, cut-off condition)
myLIB.CC(-300, 10000, "V > 3.6");

% constant-voltage (CV) charge (V/V, t_max/s, cut-off condition)
myLIB.CV(3.6, 10000, "abs(I) < 1.5");

% 2 h rest
myLIB.CC(0, 7200);

% constant-current (CC) discharge until 50 % SOC is reached (I/A, t_max/s, cut-off condition)
myLIB.CC(50, 10000, "SOC < 0.5");

% plot V and I vs. time
figure(1)
myLIB.plot();

% plot SOC vs. time
figure(2)
plot(myLIB.all_t/3600, myLIB.all_SOC*100)
xlabel('Time / h'); ylabel('State of charge / %');

% plot T vs. time
figure(3)
plot(myLIB.all_t/3600, myLIB.all_T-273.15)
xlabel('Time / h'); ylabel('Temperature / °C');


% Electrochemical impedance spectrum (EIS)
% -------------------------------------------------------------------------

% clear simulation results
myLIB.clear

% initialize with 50 % SOC
myLIB.init(0.5);

% Impedance
Z_freq = 10.^(-3:0.1:6)';
[Z_Re,Z_Im] = myLIB.EIS(Z_freq);

% Nyquist plot
figure(4);
plot(Z_Re,-Z_Im);
xlabel('Re(Z) / \Omega');
ylabel('-Im(Z) / \Omega');
axis equal

% Bode plot
figure(5)
semilogx(Z_freq,Z_Re);
xlabel('Frequency / Hz');
ylabel('Re(Z) / \Omega');

figure(6)
semilogx(Z_freq,-Z_Im);
xlabel('Frequency / Hz');
ylabel('-Im(Z) / \Omega');