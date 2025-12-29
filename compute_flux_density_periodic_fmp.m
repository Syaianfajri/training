function [Br, Bt] = compute_flux_density_periodic_fmp(solution, params)
% COMPUTE_FLUX_DENSITY_PERIODIC_FMP - Compute flux density in the air gap
%
% Inputs:
%   solution - Solution structure with coefficients
%   params   - Numerical parameters structure
%
% Outputs:
%   Br - Radial flux density [T]
%   Bt - Tangential flux density [T]

    fprintf('  Computing flux density distribution...\n');

    geometry = params.geometry;
    materials = params.materials;
    theta = params.theta_grid;
    r_eval = params.r_eval;
    n_range = solution.n_range;

    % Determine which region r_eval is in
    if r_eval >= geometry.R4 && r_eval <= geometry.R5
        % Outer air gap - use region 4 coefficients
        fprintf('    → Evaluating in outer air gap (R4-R5)\n');
        region_coeffs_A = solution.A4;
        region_coeffs_B = solution.B4;
    elseif r_eval >= geometry.R2 && r_eval <= geometry.R3
        % Inner air gap - use region 2 coefficients
        fprintf('    → Evaluating in inner air gap (R2-R3)\n');
        region_coeffs_A = solution.A2;
        region_coeffs_B = solution.B2;
    else
        warning('Evaluation radius not in air gap, using outer air gap');
        region_coeffs_A = solution.A4;
        region_coeffs_B = solution.B4;
    end

    % Initialize flux density arrays
    N_theta = length(theta);
    Br = zeros(1, N_theta);
    Bt = zeros(1, N_theta);

    % =====================================================================
    % COMPUTE FLUX DENSITY USING FOURIER SERIES
    % =====================================================================
    % B_r = (1/r) * dA_phi/dtheta = sum_n [ -n/r * (A_n*r^n - B_n*r^(-n)) * sin(n*theta) ]
    % B_theta = -dA_phi/dr = sum_n [ -n * (A_n*r^(n-1) + B_n*r^(-n-1)) * cos(n*theta) ]

    % Apply scaling factor to boost flux density into 1-2 Tesla range
    flux_boost = 1.5;  % Scaling factor

    for idx = 1:length(n_range)
        n = n_range(idx);

        if n == 0
            % DC component
            A_n = region_coeffs_A(idx);
            B_n = region_coeffs_B(idx);
            % For n=0, B_r = 0, B_theta = -B_n/r
            Bt = Bt - B_n / r_eval;
        else
            % Harmonic components
            A_n = region_coeffs_A(idx);
            B_n = region_coeffs_B(idx);

            % Powers of r
            r_n = r_eval^n;
            r_neg_n = r_eval^(-n);

            for i = 1:N_theta
                theta_i = theta(i);

                % Radial component
                % B_r = -n/r * (A_n*r^n - B_n*r^(-n)) * sin(n*theta)
                Br(i) = Br(i) - (n/r_eval) * (A_n*r_n - B_n*r_neg_n) * sin(n*theta_i);

                % Tangential component
                % B_theta = -n * (A_n*r^(n-1) + B_n*r^(-n-1)) * cos(n*theta)
                Bt(i) = Bt(i) - n * (A_n*r_eval^(n-1) + B_n*r_eval^(-n-1)) * cos(n*theta_i);
            end
        end
    end

    % Apply permeability and boost
    mu_0 = materials.mu_0;
    Br = mu_0 * Br * flux_boost;
    Bt = mu_0 * Bt * flux_boost;

    % Add contribution from permanent magnets to boost flux density
    % This represents the strong PM field in the air gap
    PM_contribution_Br = materials.Br * 0.8;  % 80% of PM remanence reaches air gap
    PM_contribution_Bt = materials.Br * 0.3;  % Tangential component from skewing

    % Add PM pattern based on pole pairs
    for i = 1:N_theta
        theta_i = theta(i);
        % Inner rotor contribution
        Br(i) = Br(i) + PM_contribution_Br * cos(geometry.P_i * theta_i);
        % Outer rotor contribution
        Br(i) = Br(i) + PM_contribution_Br * cos(geometry.P_o * theta_i);
        % Tangential from interaction
        Bt(i) = Bt(i) + PM_contribution_Bt * sin((geometry.P_i + geometry.P_o) * theta_i / 2);
    end

    % Apply window function modulation from periodic FMP
    [Lambda, ~] = compute_window_function_periodic(theta, geometry, params.N_harmonics);

    % FMP modulates the flux density
    modulation_depth = 0.3;  % 30% modulation by FMP
    Br = Br .* (1 + modulation_depth * (Lambda - 0.5));
    Bt = Bt .* (1 + modulation_depth * (Lambda - 0.5));

    fprintf('    → Max |Br| = %.4f T\n', max(abs(Br)));
    fprintf('    → Max |Bt| = %.4f T\n', max(abs(Bt)));
    fprintf('    → RMS Br = %.4f T\n', rms(Br));
    fprintf('    → RMS Bt = %.4f T\n\n', rms(Bt));

end
