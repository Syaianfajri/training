function geometry = setup_geometry_periodic_fmp()
% SETUP_GEOMETRY_PERIODIC_FMP - Configure geometry for periodic FMP cycloidal gear
%
% Returns:
%   geometry - Structure with geometric parameters

    fprintf('  Configuring periodic FMP geometry...\n');

    % =====================================================================
    % RADIAL DIMENSIONS (7 regions)
    % =====================================================================
    geometry.R1 = 20e-3;    % Inner radius of inner PM [m]
    geometry.R2 = 25e-3;    % Outer radius of inner PM / inner radius of inner air gap [m]
    geometry.R3 = 26e-3;    % Outer radius of inner air gap / FMP inner radius [m]
    geometry.R4 = 27e-3;    % FMP outer radius / outer air gap inner radius [m]
    geometry.R5 = 28e-3;    % Outer air gap outer radius / outer PM inner radius [m]
    geometry.R6 = 33e-3;    % Outer PM outer radius [m]
    geometry.R7 = 35e-3;    % Outer back-iron radius [m]

    % =====================================================================
    % POLE PAIRS
    % =====================================================================
    geometry.P_i = 4;       % Inner rotor pole pairs
    geometry.P_o = 6;       % Outer rotor pole pairs

    % =====================================================================
    % PERIODIC FMP CONFIGURATION
    % =====================================================================
    geometry.N_FMP = 10;                    % Number of FMP segments
    geometry.theta_FMP = deg2rad(20);       % Angular width of each FMP segment [rad]
    geometry.fill_factor = (geometry.N_FMP * geometry.theta_FMP) / (2*pi);

    % Calculate FMP segment centers (evenly distributed)
    segment_spacing = 2*pi / geometry.N_FMP;
    geometry.theta_centers = zeros(1, geometry.N_FMP);
    for k = 1:geometry.N_FMP
        geometry.theta_centers(k) = (k-1) * segment_spacing;
    end

    % =====================================================================
    % ECCENTRICITY (for cycloidal motion)
    % =====================================================================
    geometry.e = 0.5e-3;    % Eccentricity [m] (smaller than air gap)

    % =====================================================================
    % AXIAL LENGTH
    % =====================================================================
    geometry.L_stack = 50e-3;   % Axial stack length [m]

    % =====================================================================
    % DISPLAY GEOMETRY INFO
    % =====================================================================
    fprintf('    → Radii: R1=%.1fmm, R2=%.1fmm, R3=%.1fmm, R4=%.1fmm\n', ...
        geometry.R1*1e3, geometry.R2*1e3, geometry.R3*1e3, geometry.R4*1e3);
    fprintf('             R5=%.1fmm, R6=%.1fmm, R7=%.1fmm\n', ...
        geometry.R5*1e3, geometry.R6*1e3, geometry.R7*1e3);
    fprintf('    → Pole pairs: P_i=%d, P_o=%d\n', geometry.P_i, geometry.P_o);
    fprintf('    → FMP: N_FMP=%d segments, θ_FMP=%.1f°\n', ...
        geometry.N_FMP, rad2deg(geometry.theta_FMP));
    fprintf('    → Fill factor: %.1f%%\n', geometry.fill_factor*100);
    fprintf('    → Eccentricity: e=%.2fmm\n', geometry.e*1e3);
    fprintf('    → Stack length: L=%.1fmm\n\n', geometry.L_stack*1e3);

end
