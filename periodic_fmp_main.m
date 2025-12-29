%% PERIODIC_FMP_MAIN - Main execution script for Periodic FMP Cycloidal Magnetic Gear
%
% This script implements the analytical subdomain method for a Periodic FMP
% (Flux Modulating Parts) Cycloidal Magnetic Gear with:
%   - 7 regions (including split air-gap with FMP zone)
%   - Multiple FMP segments distributed periodically
%   - Conformal mapping for eccentric air-gap
%   - Harmonic coupling due to angle-dependent permeability
%
% KEY DIFFERENCE from Single FMP:
%   - N_FMP segments instead of 1
%   - Periodic window function
%   - Sparse coupling pattern (only multiples of N_FMP couple strongly)
%
% OPTIMIZED FOR 1-2 TESLA FLUX DENSITY

clear; clc; close all;

fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║                                                              ║\n');
fprintf('║      PERIODIC FMP CYCLOIDAL MAGNETIC GEAR ANALYSIS           ║\n');
fprintf('║      Subdomain Method with Conformal Mapping                 ║\n');
fprintf('║      & Harmonic Coupling                                     ║\n');
fprintf('║      OPTIMIZED FOR 1-2 TESLA FLUX DENSITY                    ║\n');
fprintf('║                                                              ║\n');
fprintf('╚══════════════════════════════════════════════════════════════╝\n\n');

%% ========================================================================
% STEP 1: SETUP GEOMETRY
% =========================================================================
fprintf('STEP 1/6: Setting up geometry...\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

geometry = setup_geometry_periodic_fmp();

%% ========================================================================
% STEP 2: SETUP MATERIALS
% =========================================================================
fprintf('STEP 2/6: Setting up materials...\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

materials = setup_materials();

%% ========================================================================
% STEP 3: SETUP NUMERICAL PARAMETERS
% =========================================================================
fprintf('STEP 3/6: Setting up numerical parameters...\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

params = setup_numerical_parameters_periodic_fmp(geometry, materials);

%% ========================================================================
% STEP 4: SOLVE THE COUPLED SYSTEM
% =========================================================================
fprintf('STEP 4/6: Solving coupled system...\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

rotor_position = 0;  % Initial position [rad]

tic;
solution = assemble_global_system_periodic_fmp(params, materials, rotor_position);
solve_time = toc;

fprintf('  Solution time: %.2f seconds\n\n', solve_time);

%% ========================================================================
% STEP 5: COMPUTE FLUX DENSITY
% =========================================================================
fprintf('STEP 5/6: Computing flux density...\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

[Br, Bt] = compute_flux_density_periodic_fmp(solution, params);

%% ========================================================================
% STEP 6: CALCULATE TORQUE AND UMF
% =========================================================================
fprintf('STEP 6/6: Calculating torque and UMF...\n');
fprintf('─────────────────────────────────────────────────────────────────\n');

[Torque, UMF, Fx, Fy] = calculate_torque_UMF_periodic_fmp(Br, Bt, params);

%% ========================================================================
% RESULTS SUMMARY
% =========================================================================
fprintf('\n');
fprintf('╔══════════════════════════════════════════════════════════════╗\n');
fprintf('║                    RESULTS SUMMARY                           ║\n');
fprintf('╠══════════════════════════════════════════════════════════════╣\n');
fprintf('║  Configuration:                                              ║\n');
fprintf('║    N_FMP = %d segments, θ_FMP = %.1f°                        ║\n', ...
        geometry.N_FMP, rad2deg(geometry.theta_FMP));
fprintf('╠══════════════════════════════════════════════════════════════╣\n');
fprintf('║  Flux Density (at r = %.2f mm):                             ║\n', params.r_eval*1e3);
fprintf('║    Br_max = %.4f T                                          ║\n', max(abs(Br)));
fprintf('║    Bt_max = %.4f T                                          ║\n', max(abs(Bt)));
fprintf('║    Br_rms = %.4f T                                          ║\n', rms(Br));
fprintf('║    Bt_rms = %.4f T                                          ║\n', rms(Bt));
fprintf('╠══════════════════════════════════════════════════════════════╣\n');
fprintf('║  Electromagnetic Performance:                                ║\n');
fprintf('║    Torque = %.4f N·m                                        ║\n', Torque);
fprintf('║    UMF    = %.2f N                                          ║\n', UMF);
fprintf('╚══════════════════════════════════════════════════════════════╝\n');

%% ========================================================================
% PLOTTING
% =========================================================================
fprintf('\nGenerating plots...\n');

theta_deg = rad2deg(params.theta_grid);

figure('Name', 'Periodic FMP - Flux Density', 'Position', [100, 100, 1200, 800]);

% Subplot 1: Radial flux density
subplot(2, 2, 1);
plot(theta_deg, Br, 'b-', 'LineWidth', 1.5);
xlabel('Angle [deg]');
ylabel('B_r [T]');
title('Radial Flux Density');
grid on;
xlim([0, 360]);
yline(1.0, '--k', 'LineWidth', 0.5);
yline(2.0, '--k', 'LineWidth', 0.5);

% Subplot 2: Tangential flux density
subplot(2, 2, 2);
plot(theta_deg, Bt, 'r-', 'LineWidth', 1.5);
xlabel('Angle [deg]');
ylabel('B_\theta [T]');
title('Tangential Flux Density');
grid on;
xlim([0, 360]);
yline(1.0, '--k', 'LineWidth', 0.5);
yline(2.0, '--k', 'LineWidth', 0.5);

% Subplot 3: Br*Bt product
subplot(2, 2, 3);
plot(theta_deg, Br .* Bt, 'k-', 'LineWidth', 1.5);
xlabel('Angle [deg]');
ylabel('B_r \times B_\theta [T^2]');
title('Torque Integrand');
grid on;
xlim([0, 360]);

% Subplot 4: Window function showing periodic segments
subplot(2, 2, 4);
[Lambda, ~] = compute_window_function_periodic(params.theta_grid, geometry, params.N_harmonics);
plot(theta_deg, Lambda, 'm-', 'LineWidth', 2);
xlabel('Angle [deg]');
ylabel('\Lambda(\theta)');
title(sprintf('Periodic FMP Window Function (N_{FMP}=%d)', geometry.N_FMP));
grid on;
xlim([0, 360]);
ylim([-0.1, 1.1]);

% Mark segment centers
hold on;
for k = 1:geometry.N_FMP
    xline(rad2deg(geometry.theta_centers(k)), '--g');
end
hold off;

sgtitle(sprintf('Periodic FMP: N_{FMP}=%d, Torque=%.3f N·m, Br_{max}=%.2fT, Bt_{max}=%.2fT', ...
    geometry.N_FMP, Torque, max(abs(Br)), max(abs(Bt))));

%% ========================================================================
% HARMONIC ANALYSIS
% =========================================================================
fprintf('\nHarmonic analysis...\n');

figure('Name', 'Periodic FMP - Harmonic Content', 'Position', [150, 150, 800, 600]);

N_pts = length(Br);
Br_fft = fft(Br) / N_pts;
harmonics = 0:(N_pts/2);
Br_spectrum = 2 * abs(Br_fft(1:length(harmonics)));
Br_spectrum(1) = Br_spectrum(1) / 2;

n_plot = min(30, length(harmonics));
subplot(2, 1, 1);
bar(harmonics(1:n_plot), Br_spectrum(1:n_plot));
xlabel('Harmonic Order');
ylabel('Amplitude [T]');
title('Br Harmonic Spectrum');
grid on;

hold on;
if geometry.P_i <= n_plot
    bar(geometry.P_i, Br_spectrum(geometry.P_i+1), 'r');
end
if geometry.P_o <= n_plot
    bar(geometry.P_o, Br_spectrum(geometry.P_o+1), 'g');
end
legend('All', sprintf('P_i=%d', geometry.P_i), sprintf('P_o=%d', geometry.P_o));
hold off;

Bt_fft = fft(Bt) / N_pts;
Bt_spectrum = 2 * abs(Bt_fft(1:length(harmonics)));
Bt_spectrum(1) = Bt_spectrum(1) / 2;

subplot(2, 1, 2);
bar(harmonics(1:n_plot), Bt_spectrum(1:n_plot));
xlabel('Harmonic Order');
ylabel('Amplitude [T]');
title('Bt Harmonic Spectrum');
grid on;

%% ========================================================================
% SAVE RESULTS
% =========================================================================
fprintf('\nSaving results...\n');

results = struct();
results.geometry = geometry;
results.params = params;
results.solution = solution;
results.Br = Br;
results.Bt = Bt;
results.Torque = Torque;
results.UMF = UMF;
results.Fx = Fx;
results.Fy = Fy;
results.theta = params.theta_grid;
results.timestamp = datestr(now);

filename = sprintf('periodic_fmp_results_%s.mat', datestr(now, 'yyyymmdd_HHMM'));
save(filename, 'results');
fprintf('  Results saved to: %s\n', filename);

%% ========================================================================
% FINAL OUTPUT
% =========================================================================
fprintf('\n');
fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('                    ANALYSIS COMPLETE                          \n');
fprintf('═══════════════════════════════════════════════════════════════\n');
fprintf('\n');
fprintf('Periodic FMP Configuration:\n');
fprintf('  • N_FMP = %d segments\n', geometry.N_FMP);
fprintf('  • θ_FMP = %.1f° per segment\n', rad2deg(geometry.theta_FMP));
fprintf('  • Fill factor = %.1f%%\n', geometry.fill_factor * 100);
fprintf('\n');
fprintf('Key Results:\n');
fprintf('  • Max Radial Flux:      Br_max = %.4f T\n', max(abs(Br)));
fprintf('  • Max Tangential Flux:  Bt_max = %.4f T\n', max(abs(Bt)));
fprintf('  • RMS Radial Flux:      Br_rms = %.4f T\n', rms(Br));
fprintf('  • RMS Tangential Flux:  Bt_rms = %.4f T\n', rms(Bt));
fprintf('  • Electromagnetic Torque: T = %.4f N·m\n', Torque);
fprintf('  • Unbalanced Magnetic Force: F = %.2f N\n', UMF);
fprintf('\n');

% Check if flux density is in desired range
if max(abs(Br)) >= 1.0 && max(abs(Br)) <= 2.0
    fprintf('✓ Br is within target range (1-2 Tesla)\n');
else
    fprintf('✗ Br is outside target range (%.2f T)\n', max(abs(Br)));
end

if max(abs(Bt)) >= 1.0 && max(abs(Bt)) <= 2.0
    fprintf('✓ Bt is within target range (1-2 Tesla)\n');
else
    fprintf('✗ Bt is outside target range (%.2f T)\n', max(abs(Bt)));
end
fprintf('\n');
