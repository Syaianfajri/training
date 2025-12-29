function params = setup_numerical_parameters_periodic_fmp(geometry, materials)
% SETUP_NUMERICAL_PARAMETERS_PERIODIC_FMP - Configure numerical parameters
%
% Inputs:
%   geometry  - Geometry structure
%   materials - Materials structure
%
% Returns:
%   params - Structure with numerical parameters

    fprintf('  Configuring numerical parameters...\n');

    % =====================================================================
    % HARMONIC TRUNCATION
    % =====================================================================
    params.N_harmonics = 50;        % Number of harmonics to include

    % =====================================================================
    % ANGULAR DISCRETIZATION
    % =====================================================================
    params.N_theta = 360;           % Number of angular points
    params.theta_grid = linspace(0, 2*pi, params.N_theta);

    % =====================================================================
    % EVALUATION RADIUS (middle of outer air gap for flux calculation)
    % =====================================================================
    params.r_eval = (geometry.R4 + geometry.R5) / 2;

    % =====================================================================
    % COPY GEOMETRY AND MATERIALS
    % =====================================================================
    params.geometry = geometry;
    params.materials = materials;

    % =====================================================================
    % HARMONIC ORDERS
    % =====================================================================
    params.n_range = -params.N_harmonics:params.N_harmonics;

    % =====================================================================
    % REGION INFORMATION
    % =====================================================================
    params.regions = struct();
    params.regions.R1_inner_PM = [geometry.R1, geometry.R2];
    params.regions.R2_inner_air = [geometry.R2, geometry.R3];
    params.regions.R3_FMP = [geometry.R3, geometry.R4];
    params.regions.R4_outer_air = [geometry.R4, geometry.R5];
    params.regions.R5_outer_PM = [geometry.R5, geometry.R6];
    params.regions.R6_back_iron = [geometry.R6, geometry.R7];

    % =====================================================================
    % DISPLAY NUMERICAL INFO
    % =====================================================================
    fprintf('    → Number of harmonics: N = %d\n', params.N_harmonics);
    fprintf('    → Angular discretization: N_θ = %d points\n', params.N_theta);
    fprintf('    → Evaluation radius: r_eval = %.2f mm\n', params.r_eval*1e3);
    fprintf('    → Total unknowns: ~%d\n\n', (2*params.N_harmonics+1)*6);

end
