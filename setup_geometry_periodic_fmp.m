function geometry = setup_geometry_periodic_fmp()
% SETUP_GEOMETRY_PERIODIC_FMP - Configure geometry for periodic FMP cycloidal gear
%
% Returns:
%   geometry - Structure with geometric parameters

    fprintf('  Configuring periodic FMP geometry...\n');

    % =====================================================================
    % RADIAL DIMENSIONS (7 regions with new naming convention)
    % =====================================================================
    geometry.R_i  = 10e-3;    % Inner shaft radius [m]
    geometry.R_ii = 20e-3;    % Inner PM inner radius [m]
    geometry.R_io = 26e-3;    % Inner PM outer radius (air-gap inner) [m]
    geometry.R_pi = 27e-3;    % FMP inner radius [m]
    geometry.R_po = 31e-3;    % FMP outer radius [m]
    geometry.R_oi = 32e-3;    % Outer PM inner radius (air-gap outer) [m]
    geometry.R_oo = 38e-3;    % Outer PM outer radius [m]
    geometry.R_o  = 48e-3;    % Outer back-iron radius [m]

    % Backward compatibility: map to old naming convention
    geometry.R1 = geometry.R_i;     % Region 1: Inner shaft
    geometry.R2 = geometry.R_ii;    % Region 2: Inner PM inner
    geometry.R3 = geometry.R_io;    % Region 3: Inner PM outer / Inner air-gap
    geometry.R4 = geometry.R_oi;    % Region 4: Outer air-gap / Outer PM inner
    geometry.R5 = geometry.R_oo;    % Region 5: Outer PM outer
    geometry.R6 = geometry.R_o;     % Region 6: Outer back-iron
    geometry.R7 = geometry.R_o;     % Region 7: (same as R6 for now)

    % FMP zone radii
    geometry.R_FMP_inner = geometry.R_pi;
    geometry.R_FMP_outer = geometry.R_po;

    % =====================================================================
    % POLE PAIRS
    % =====================================================================
    geometry.P_i = 10;       % Inner rotor pole pairs
    geometry.P_o = 11;       % Outer rotor pole pairs

    % =====================================================================
    % PERIODIC FMP CONFIGURATION
    % =====================================================================
    geometry.N_FMP = 8;                     % Number of FMP segments
    geometry.theta_FMP = deg2rad(90);       % Angular width of each FMP segment [rad]
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
    geometry.e = 5e-3;    % Eccentricity [m] (smaller than air gap)

    % =====================================================================
    % AXIAL LENGTH
    % =====================================================================
    geometry.L_stack = 26e-3;   % Axial stack length [m]

    % =====================================================================
    % DISPLAY GEOMETRY INFO
    % =====================================================================
    fprintf('    → Radii (new naming):\n');
    fprintf('       • R_i  = %.1f mm (Inner shaft)\n', geometry.R_i*1e3);
    fprintf('       • R_ii = %.1f mm (Inner PM inner)\n', geometry.R_ii*1e3);
    fprintf('       • R_io = %.1f mm (Inner PM outer / Air-gap inner)\n', geometry.R_io*1e3);
    fprintf('       • R_pi = %.1f mm (FMP inner)\n', geometry.R_pi*1e3);
    fprintf('       • R_po = %.1f mm (FMP outer)\n', geometry.R_po*1e3);
    fprintf('       • R_oi = %.1f mm (Outer PM inner / Air-gap outer)\n', geometry.R_oi*1e3);
    fprintf('       • R_oo = %.1f mm (Outer PM outer)\n', geometry.R_oo*1e3);
    fprintf('       • R_o  = %.1f mm (Outer back-iron)\n', geometry.R_o*1e3);
    fprintf('    → Air-gap widths:\n');
    fprintf('       • Inner air-gap: %.1f mm (R_io to R_pi)\n', (geometry.R_pi - geometry.R_io)*1e3);
    fprintf('       • Outer air-gap: %.1f mm (R_po to R_oi)\n', (geometry.R_oi - geometry.R_po)*1e3);
    fprintf('    → FMP zone thickness: %.1f mm (R_pi to R_po)\n', (geometry.R_po - geometry.R_pi)*1e3);
    fprintf('    → Pole pairs: P_i=%d, P_o=%d\n', geometry.P_i, geometry.P_o);
    fprintf('    → FMP: N_FMP=%d segments, θ_FMP=%.1f°\n', ...
        geometry.N_FMP, rad2deg(geometry.theta_FMP));
    fprintf('    → Fill factor: %.1f%%\n', geometry.fill_factor*100);
    fprintf('    → Eccentricity: e=%.2f mm\n', geometry.e*1e3);
    fprintf('    → Stack length: L=%.1f mm\n\n', geometry.L_stack*1e3);

end
