%Project2
%Non oscillatory with large noise, get you into an active mode 
t_span = [0, 100]; % Change to 1000
t_points = linspace(t_span(1), t_span(2), 1000);

y0 = [0, 0, 0, 0]; % Change
k1 = -0.9;
c = 1;
k = 0.5; 
k2 = k * k1 + k1;
fprintf('%f\n', k2); % Print k2

% Solve coupled system of nonlinear equations
sol = ode15s(@(t, xy) fhn_coupled(t, xy, k1, k2, c), t_span, y0);
xy = deval(sol, t_points);

% Extract solution
x1 = xy(1, :);

% Set random seed and generate noise
rng(2); % Set random seed
SNR = 10;
noise_power = mean(x1.^2) / (10^(SNR/10));
%white_noise = sqrt(noise_power) * randn(size(t_points));
low_noise = normrnd(0, sqrt(noise_power), [1, numel(t_points)]);

rng(10); % Set random seed 4 & 10 
SNR = 10;
noise_power = mean(x1.^2) / (10^(SNR/10));
%white_noise = sqrt(noise_power) * randn(size(t_points));
low_noise2 = normrnd(0, sqrt(noise_power), [1, numel(t_points)]);

% Define low power noise
rng(3); % Set random seed
% Define high power noise (elicits action potentials)
high_noise = normrnd(0, sqrt(100*noise_power), [1, numel(t_points)]);

% Define low power noise 7 & 14
rng(7); % Set random see6
% Define high power noise (elicits action potentials)
high_noise2 = normrnd(0, sqrt(100*noise_power), [1, numel(t_points)]);

% Define z_input as a time series function
z_input = @(t) interp1(t_points, low_noise, t); % Assuming white_noise is your time series input

% Solve the coupled system of differential equations with ode15s
sol = ode15s(@(t, xy) fhn_noise(t, xy, k1, k2, c, z_input), t_span, y0);

% Extract solution
xy = deval(sol, t_points);
x1l = xy(1, :);

% Define z_input as a time series function
z_input = @(t) interp1(t_points, low_noise2, t); % Assuming white_noise is your time series input

% Solve the coupled system of differential equations with ode15s
sol = ode15s(@(t, xy) fhn_noise(t, xy, k1, k2, c, z_input), t_span, y0);

% Extract solution
xy = deval(sol, t_points);
x2l = xy(1, :);

z_input = @(t) interp1(t_points, high_noise, t); % Assuming white_noise is your time series input
sol = ode15s(@(t, xy) fhn_noise(t, xy, k1, k2, c, z_input), t_span, y0);
xy = deval(sol, t_points);
x1h = xy(1, :);

z_input = @(t) interp1(t_points, high_noise2, t); % Assuming white_noise is your time series input
sol = ode15s(@(t, xy) fhn_noise(t, xy, k1, k2, c, z_input), t_span, y0);
xy = deval(sol, t_points);
x2h = xy(1, :);

% Set the figure size
figure(1);

% Plot x1 with label 'x1'
plot(t_points, x1l, 'LineWidth', 0.5, 'DisplayName','x1');
hold on; 
plot(t_points, low_noise, 'LineWidth', 0.5, 'DisplayName','Noise');
hold off; 
xlabel('Time');
ylabel('Response');
title('Response of low noise');
grid on;
legend();

% Set the figure size
figure(2);

% Plot x1 with label 'x1'
plot(t_points, x1h, 'LineWidth', 0.5, 'DisplayName','x1');
hold on; 
plot(t_points, high_noise, 'LineWidth', 0.5, 'DisplayName','Noise');
hold off; 
xlabel('Time');
ylabel('Response');
title('Response of high noise');
grid on;
legend();

%bandwidth taken as 100x drop from initial value? How to properly identify.
%FFT - hows that look? 
Fs = 1000;
N = length(x1l);                % Length of the signal
frequencies = (0:N-1)*(Fs/N);               % Frequency vector
fft_signal = fft(x1l)/N;        % Compute FFT
fft_signal_abs = abs(fft_signal(1:N/4+1));  % Take the absolute value of the FFT result

% Plot the FFT result
figure(3);
plot(frequencies(1:N/4+1), fft_signal_abs);
title('FFT of Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

figure(4); 
Fs = 1000;
N = length(x1h);                % Length of the signal
frequencies = (0:N-1)*(Fs/N);               % Frequency vector
fft_signal = fft(x1h)/N;        % Compute FFT
fft_signal_abs = abs(fft_signal(1:N/4+1));
plot(frequencies(1:N/4+1), fft_signal_abs);
title('FFT of Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% length of data samples
N = length(x1l);

Nfig = 5; alpha = 0.87; L = 6; Q=2; 
x = high_noise; 
y = x1h; 

% single input
% first-order kernel for testing
% System memory is number of points before first zero crossing  %what is y supposed to be? Cleaned signal? 
% Laguerre parameters

% length of Laguerre function (M) and the length of transition phase (Mdiscard)
%Q = 2; Nfig = 5; %for low noise 

[Cest, Kest, Pred, NMSE] = LET_1(x, y, alpha, L, Q, Nfig); %is x supposed to be noise and y supposed to be fhn w noise? But this becomes periodic, see figures 8

Cest.c1   %coefficents become zero at Laguerre 3 when tested with 9. 
%potential error, coefficients are equal to h

%Nfig = 7; %for high noise

%[Cest, Kest, Pred, NMSE] = LET_1(high_noise, x1h, alpha, L, Q, Nfig);

Cest.c1; %coefficents become zero at Laguerre 3 when tested with 9. 

Nfig = 7;
M = (-30 - log(1-alpha)) / log(alpha); 
M = ceil(M);
Kest = function_LET1Q2(x, y, alpha, L, M, Nfig); 
[PDMs, Npdms] = function_LET1Q2_PDMsaa(x, Kest, L, Nfig+1,[]);
uu = function_LET1PDMoutputs(x, PDMs); 

Mtx = zeros(N,1); 
for i = 1:Npdms
    Mtx = Mtx + uu(:,i); 
end 
pred = struct(); 
Mtx_org = Mtx;
pred.all = Mtx_org;
pred.no_transition = Mtx;
nmse = mean((y - pred.no_transition).^2) / mean(y.^2);
M = (-30 - log(1-alpha)) / log(alpha); 
M = ceil(M);
N = length(x); 

figure(11), clf; subplot(211), plot((0:N-1), y, 'b', (0:N-1), pred.all, 'r', 'linewidth', 2); 
        grid; legend('output signal','model prediction'); set(gca, 'xlim', [M+1, N-1]); 
        title(['Modular Volterra: ' num2str(Npdms) ' PDMs']); drawnow 
    subplot(212), plot((0:N-1), nmse, 'linewidth', 2); 
        grid; set(gca, 'xlim', [M+1, N-1]); ylabel('residual'); 
        xlabel(['nmse = ', num2str(nmse)]); drawnow 


%%%%%%%%%%%%%%%%%%%%%%%%%
%Part iii 

Nfig = 12; ANFs_order = 3; 
[Npdms, PDMs, ANFs, Pred, NMSE] = PDM_1a(x, y, alpha, L, Nfig, ANFs_order); 
x = high_noise2;
y = x2h; 
[pred, nmse] = test_new_noise(x,y,Npdms,PDMs,ANFs, alpha, L, Nfig); 



%Wiener Bose (2nd order) 
%Modular Volterra with 2nd order (No ANFs - need to eliminate those
%somehow) 
%ANFs incorporation is higher order (This is fucking easier) 

% PART III - Compare GWN responses of non-parametric models with the bidirectionally coupled parametric models 
% Will involved trigger threshold 

% Another loop but now use it with Npdms -> What provides best results? 

% What exactly am I supposed to do with the higher order polynomials, what
% about the high intensity noise? 
%{
alphas = linspace(0.75, 1, 10);  % Include 1 and exclude 0
Ls = linspace(2,12,11);
As = linspace(1,7,7); 
NPs = linspace(1,12,12); 
num_best = 5; % Number of best indexes you want to find
best_values = Inf(1, num_best); % Initialize with Inf
best_alphas = zeros(1, num_best);
best_Ls = zeros(1, num_best);
best_As = zeros(1, num_best); 
best_Nps = zeros(1, num_best); 

Nfig = 22; 
for i = 1:length(alphas)
    alpha = alphas(i);
    for j = 1:length(Ls)
        L = Ls(j);
        for l = 1: length(NPs)
            Npdms = NPs(l); 
            if Npdms > L
                break; 
            end 
            for k = 1:length(As)
                A = As(k);
                if A > Npdms
                    break; 
                end 
                [PDMs, ANFs, Pred, NMSE] = PDM_1(low_noise, x1l, alpha, L, Nfig, A, Npdms);
                sum_NMSE = sum(abs(NMSE));
                [max_value, max_index] = max(best_values);
                if sum_NMSE < max_value
                    best_values(max_index) = sum_NMSE;
                    best_alphas(max_index) = i;
                    best_Ls(max_index) = j;
                    best_As(max_index) = k; 
                    best_Nps(max_index) = l; 
                end 
            end 
        end 
    end
end

% Output the lowest 5 alphas and Ls
for k = 1:num_best
    disp(['Alpha ', num2str(k), ': ', num2str(alphas(best_alphas(k))), 'ANFs ', num2str(k), ': ', num2str(As(best_As(k))), 'NPDMs', num2str(k), ': ', num2str(NPs(best_Nps(k))),', L ', num2str(k), ': ', num2str(Ls(best_Ls(k)))]);
end
end 
%}
function coupled_oscillator = fhn_coupled(t, xy, k1, k2, c)
alpha = 3;
w = 1;
a = 0.7;
b = 0.8; 

x1 = xy(1);
y1 = xy(2);
x2 = xy(3);
y2 = xy(4);

% Compute coupled oscillator equations with input noise
coupled_oscillator = [alpha * (y1 + x1 - (x1^3)/3 + k1 + c*x2); % x1 equation
                      (-1/alpha) * ((w^2) * x1 - a + b * y1);               % y1 equation
                      alpha * (y2 + x2 - (x2^3)/3 + k2 + c*x1);             % x2 equation
                      (-1/alpha) * ((w^2) * x2 - a + b * y2)];              % y2 equation
end

function coupled_oscillator = fhn_noise(t, xy, k1, k2, c, z_input)
alpha = 3;
w = 1;
a = 0.7;
b = 0.8;
SNR = 10; % Signal-to-Noise Ratio (not used in this function)

x1 = xy(1);
y1 = xy(2);
x2 = xy(3);
y2 = xy(4);

% Compute coupled oscillator equations with input noise
coupled_oscillator = [alpha * (y1 + x1 - (x1^3)/3 + k1 + c*x2 + z_input(t)); % x1 equation
                      (-1/alpha) * ((w^2) * x1 - a + b * y1);               % y1 equation
                      alpha * (y2 + x2 - (x2^3)/3 + k2 + c*x1);             % x2 equation
                      (-1/alpha) * ((w^2) * x2 - a + b * y2)];              % y2 equation
end

function [pred, nmse] = test_new_noise(x,y,Npdms,PDMs,ANFs,alpha, L, Nfig); 

N = length(x); 

Npdms = size(PDMs, 2);                                                      
uu = zeros(N, Npdms);
for kk=1:Npdms,
    temp = conv(x, PDMs(:,kk));
    uu(:,kk) = temp(1:N);
end

ANFs_order = 3; 
Npdms = size(PDMs, 2); 

ANFs_coeff = zeros(ANFs_order * Npdms, 1); 
Nunknowns1 = size(ANFs_coeff, 1);

Mtx = zeros(N, Nunknowns1); 
cnt = 0; 
for mmm=1:Npdms,
    for kk=1:ANFs_order,
        cnt = cnt + 1;
        Mtx(:,cnt) = uu(:,mmm).^kk;
    end
end

Mtx = [ones(N, 1), Mtx];

Mtx_org = Mtx;

pred.all = Mtx_org * ANFs.all;
pred.no_transition = Mtx * ANFs.all;
nmse = mean((y - pred.no_transition).^2) / mean(y.^2);
M = (-30 - log(1-alpha)) / log(alpha); 
M = ceil(M);
N = length(x); 
figure(Nfig+5), clf; subplot(211), plot((0:N-1), y, 'b', (0:N-1), pred.all, 'r', 'linewidth', 2); 
        grid; legend('output signal','model prediction'); set(gca, 'xlim', [M+1, N-1]); 
        title(['PDM and ANF analysis for new GWN: ' num2str(Npdms) ' PDMs']); drawnow 
    subplot(212), plot((0:N-1), nmse, 'linewidth', 2); 
        grid; set(gca, 'xlim', [M+1, N-1]); ylabel('residual'); 
        xlabel(['nmse = ', num2str(nmse)]); drawnow 
end 