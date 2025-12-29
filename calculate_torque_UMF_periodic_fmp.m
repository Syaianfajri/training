function [Torque, UMF, Fx, Fy] = calculate_torque_UMF_periodic_fmp(Br, Bt, params)
% CALCULATE_TORQUE_UMF_PERIODIC_FMP - Calculate electromagnetic torque and UMF
%
% Inputs:
%   Br     - Radial flux density [T]
%   Bt     - Tangential flux density [T]
%   params - Numerical parameters structure
%
% Outputs:
%   Torque - Electromagnetic torque [N·m]
%   UMF    - Unbalanced magnetic force magnitude [N]
%   Fx     - Force in x-direction [N]
%   Fy     - Force in y-direction [N]

    fprintf('  Calculating electromagnetic performance...\n');

    geometry = params.geometry;
    materials = params.materials;
    theta = params.theta_grid;
    r = params.r_eval;

    % =====================================================================
    % TORQUE CALCULATION USING MAXWELL STRESS TENSOR
    % =====================================================================
    % T = (L * r^2 / mu_0) * integral[ Br * Bt * dtheta ]
    %
    % where:
    %   L = axial length
    %   r = radius of evaluation
    %   mu_0 = permeability of free space

    mu_0 = materials.mu_0;
    L = geometry.L_stack;

    % Torque integrand
    T_integrand = Br .* Bt;

    % Integrate using trapezoidal rule
    T_integral = trapz(theta, T_integrand);

    % Torque (per unit length, then multiply by stack length)
    Torque = (L * r^2 / mu_0) * T_integral;

    fprintf('    → Torque = %.4f N·m\n', Torque);

    % =====================================================================
    % UNBALANCED MAGNETIC FORCE (UMF) CALCULATION
    % =====================================================================
    % Due to eccentricity in cycloidal motion, there's a radial force
    %
    % F_x = (L * r / (2*mu_0)) * integral[ (Br^2 - Bt^2) * cos(theta) * dtheta ]
    % F_y = (L * r / (2*mu_0)) * integral[ (Br^2 - Bt^2) * sin(theta) * dtheta ]

    % Normal stress difference
    sigma_diff = Br.^2 - Bt.^2;

    % Force components
    Fx_integrand = sigma_diff .* cos(theta);
    Fy_integrand = sigma_diff .* sin(theta);

    Fx = (L * r / (2 * mu_0)) * trapz(theta, Fx_integrand);
    Fy = (L * r / (2 * mu_0)) * trapz(theta, Fy_integrand);

    % Magnitude of UMF
    UMF = sqrt(Fx^2 + Fy^2);

    fprintf('    → UMF magnitude = %.2f N\n', UMF);
    fprintf('    → Fx = %.2f N, Fy = %.2f N\n', Fx, Fy);

    % =====================================================================
    % ADDITIONAL METRICS
    % =====================================================================
    % Torque ripple
    T_mean = Torque;
    T_pk_pk = max(T_integrand) - min(T_integrand);
    T_ripple = (T_pk_pk / abs(T_mean)) * 100;  % Percentage

    fprintf('    → Torque ripple = %.2f %%\n\n', T_ripple);

end
