function materials = setup_materials()
% SETUP_MATERIALS - Configure material properties
%
% Returns:
%   materials - Structure with material parameters

    fprintf('  Configuring materials...\n');

    % =====================================================================
    % PERMEABILITY OF FREE SPACE
    % =====================================================================
    materials.mu_0 = 4*pi*1e-7;     % [H/m]

    % =====================================================================
    % PERMANENT MAGNETS (NdFeB - High Grade)
    % =====================================================================
    % Using high-grade NdFeB to achieve 1-2 Tesla flux density
    materials.Br = 1.4;             % Remanent flux density [T] - INCREASED
    materials.mu_r_PM = 1.05;       % Relative permeability of PM

    % Magnetization direction (radial)
    materials.mag_direction = 'radial';

    % =====================================================================
    % FMP (Flux Modulating Parts) - High permeability iron
    % =====================================================================
    materials.mu_r_FMP = 5000;      % Relative permeability (high for good flux modulation)

    % =====================================================================
    % BACK IRON - High permeability steel
    % =====================================================================
    materials.mu_r_iron = 5000;     % Relative permeability

    % =====================================================================
    % AIR GAP
    % =====================================================================
    materials.mu_r_air = 1.0;       % Relative permeability of air

    % =====================================================================
    % WINDING CURRENT (for inner rotor)
    % =====================================================================
    % High current density to boost flux
    materials.J_current = 8e6;      % Current density [A/m²] - INCREASED
    materials.N_turns = 100;        % Number of turns per coil

    % =====================================================================
    % DISPLAY MATERIAL INFO
    % =====================================================================
    fprintf('    → PM remanent flux density: Br = %.2f T\n', materials.Br);
    fprintf('    → PM relative permeability: μr = %.2f\n', materials.mu_r_PM);
    fprintf('    → FMP relative permeability: μr = %d\n', materials.mu_r_FMP);
    fprintf('    → Current density: J = %.1f A/mm²\n', materials.J_current/1e6);
    fprintf('    → Number of turns: N = %d\n\n', materials.N_turns);

end
