% add path to LIBquiv class
addpath("../../../src/matlab/");

% create virtual battery object
myLIB = Enertech20Ah;


% Cycle the cell
% -------------------------------------------------------------------------

% initialize with 100 % SOC
myLIB.init(1);

% 1 h rest
myLIB.CC(0, 3600);

% constant-power (CP) discharge (P/W, t_max/s, cut-off condition)
myLIB.CP(10, 100000, "V < 3.0");

% 1 h rest
myLIB.CC(0, 3600);

% constant-current (CC) charge (I/A, t_max/s, cut-off condition)
myLIB.CC(-20, 100000, "V > 4.2");

% constant-voltage (CV) charge (V/V, t_max/s, cut-off condition)
myLIB.CV(4.2, 100000, "abs(I) <= 0.2");

% 2 h rest
myLIB.CC(0, 7200);

% constant-current (CC) discharge until 50 % SOC is reached (I/A, t_max/s, cut-off condition)
myLIB.CC(6.67, 10000, "SOC < 0.5");


% Plot results
% -------------------------------------------------------------------------

% plot V and I vs. time
figure(1)
myLIB.plot();

% plot SOC vs. time
figure(2)
plot(myLIB.all_t/3600, myLIB.all_SOC*100)
xlabel('Time / h'); ylabel('State of charge / %');


