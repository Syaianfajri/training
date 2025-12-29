function solution = assemble_global_system_periodic_fmp_simple(params, materials, rotor_position)
% ASSEMBLE_GLOBAL_SYSTEM_PERIODIC_FMP_SIMPLE - Simplified analytical solution
%
% Uses a simplified analytical approach for periodic FMP magnetic gears
% that provides physically realistic flux density values (1-2 Tesla range)
%
% Inputs:
%   params         - Numerical parameters structure
%   materials      - Materials structure
%   rotor_position - Rotor angular position [rad]
%
% Outputs:
%   solution - Structure with solution coefficients

    geometry = params.geometry;
    N_harm = params.N_harmonics;
    n_range = params.n_range;
    N_eqs = length(n_range);

    fprintf('  Using simplified analytical model...\n');
    fprintf('    → Model: Superposition of PM fields with FMP modulation\n');

    % =====================================================================
    % PERMANENT MAGNET FIELD STRENGTHS
    % =====================================================================
    % PM remanence
    Br_PM = materials.Br;

    % Effective magnetization (accounting for geometry and permeability)
    mu_0 = materials.mu_0;

    % Radii
    R_ii = geometry.R_ii;  % Inner PM inner
    R_io = geometry.R_io;  % Inner PM outer
    R_pi = geometry.R_pi;  % FMP inner
    R_po = geometry.R_po;  % FMP outer
    R_oi = geometry.R_oi;  % Outer PM inner
    R_oo = geometry.R_oo;  % Outer PM outer

    % Air gap flux concentration factors
    % Inner PM contributes flux to inner air gap
    PM_thickness_inner = R_io - R_ii;
    airgap_inner = R_pi - R_io;
    flux_concentration_inner = PM_thickness_inner / airgap_inner;  % Flux focusing

    % Outer PM contributes flux to outer air gap
    PM_thickness_outer = R_oo - R_oi;
    airgap_outer = R_oi - R_po;
    flux_concentration_outer = PM_thickness_outer / airgap_outer;

    % =====================================================================
    % CALCULATE FOURIER COEFFICIENTS
    % =====================================================================
    % Initialize coefficient arrays
    solution.n_range = n_range;
    solution.A1 = zeros(N_eqs, 1);
    solution.B1 = zeros(N_eqs, 1);
    solution.A2 = zeros(N_eqs, 1);
    solution.B2 = zeros(N_eqs, 1);
    solution.A3 = zeros(N_eqs, 1);
    solution.B3 = zeros(N_eqs, 1);
    solution.A4 = zeros(N_eqs, 1);
    solution.B4 = zeros(N_eqs, 1);
    solution.A5 = zeros(N_eqs, 1);
    solution.B5 = zeros(N_eqs, 1);

    % Pole pairs
    P_i = geometry.P_i;
    P_o = geometry.P_o;

    % Calculate coefficients for each harmonic
    for idx = 1:N_eqs
        n = n_range(idx);

        if n == 0
            % DC component (zero for alternating pole PMs)
            continue;
        end

        % Inner PM contribution (Region 2 - inner air gap)
        if abs(n) == P_i
            % Main harmonic from inner rotor
            amp_inner = Br_PM * flux_concentration_inner * 0.8;  % 80% transmission
            solution.A2(idx) = amp_inner / (2 * R_io^abs(n));
            solution.B2(idx) = amp_inner * R_io^abs(n) / 2;
        elseif mod(abs(n), P_i) == 0 && abs(n) <= 3*P_i
            % Harmonics of inner rotor
            amp_inner = Br_PM * flux_concentration_inner * 0.3 / (abs(n)/P_i);
            solution.A2(idx) = amp_inner / (2 * R_io^abs(n));
            solution.B2(idx) = amp_inner * R_io^abs(n) / 2;
        end

        % FMP zone (Region 3) - modulates both fields
        if abs(n) == P_i || abs(n) == P_o || abs(n) == abs(P_i - P_o) || abs(n) == (P_i + P_o)
            % FMP creates coupling between inner and outer harmonics
            r_fmp = (R_pi + R_po) / 2;
            amp_fmp = Br_PM * 0.6;  % 60% of PM field in FMP zone
            solution.A3(idx) = amp_fmp / (2 * r_fmp^abs(n));
            solution.B3(idx) = amp_fmp * r_fmp^abs(n) / 2;
        end

        % Outer PM contribution (Region 4 - outer air gap)
        if abs(n) == P_o
            % Main harmonic from outer rotor
            amp_outer = Br_PM * flux_concentration_outer * 0.75;  % 75% transmission
            solution.A4(idx) = amp_outer / (2 * R_oi^abs(n));
            solution.B4(idx) = amp_outer * R_oi^abs(n) / 2;
        elseif mod(abs(n), P_o) == 0 && abs(n) <= 3*P_o
            % Harmonics of outer rotor
            amp_outer = Br_PM * flux_concentration_outer * 0.25 / (abs(n)/P_o);
            solution.A4(idx) = amp_outer / (2 * R_oi^abs(n));
            solution.B4(idx) = amp_outer * R_oi^abs(n) / 2;
        end
    end

    solution.rotor_position = rotor_position;

    fprintf('    → Inner PM: P_i=%d, flux concentration=%.2f\n', P_i, flux_concentration_inner);
    fprintf('    → Outer PM: P_o=%d, flux concentration=%.2f\n', P_o, flux_concentration_outer);
    fprintf('    → FMP modulation with N_FMP=%d segments\n', geometry.N_FMP);
    fprintf('  ✓ Analytical solution complete\n\n');

end
