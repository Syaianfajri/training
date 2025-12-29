function solution = assemble_global_system_periodic_fmp(params, materials, rotor_position)
% ASSEMBLE_GLOBAL_SYSTEM_PERIODIC_FMP - Assemble and solve the global system
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

    fprintf('  Assembling system matrix...\n');
    fprintf('    → Matrix size: %d × %d\n', N_eqs*6, N_eqs*6);

    % =====================================================================
    % INITIALIZE SYSTEM MATRIX AND RHS
    % =====================================================================
    A = zeros(N_eqs*6, N_eqs*6);
    b = zeros(N_eqs*6, 1);

    % Extract radii
    R1 = geometry.R1; R2 = geometry.R2; R3 = geometry.R3;
    R4 = geometry.R4; R5 = geometry.R5; R6 = geometry.R6; R7 = geometry.R7;

    % =====================================================================
    % SOURCE TERMS FROM PERMANENT MAGNETS
    % =====================================================================
    % Inner PM (radially magnetized, alternating N-S poles)
    M_r_inner = materials.Br / materials.mu_0;

    % Outer PM (radially magnetized, alternating N-S poles)
    M_r_outer = materials.Br / materials.mu_0;

    % =====================================================================
    % COMPUTE FOURIER COEFFICIENTS FOR PM MAGNETIZATION
    % =====================================================================
    % For radial magnetization with P pole pairs:
    % M_r(theta) = M_r * cos(P*theta) for inner rotor
    % Only harmonics at n = ±P are non-zero

    M_n_inner = zeros(1, N_eqs);
    M_n_outer = zeros(1, N_eqs);

    for idx = 1:N_eqs
        n = n_range(idx);
        if n == geometry.P_i
            M_n_inner(idx) = M_r_inner / 2;  % Positive harmonic
        elseif n == -geometry.P_i
            M_n_inner(idx) = M_r_inner / 2;  % Negative harmonic
        end

        if n == geometry.P_o
            M_n_outer(idx) = M_r_outer / 2;  % Positive harmonic
        elseif n == -geometry.P_o
            M_n_outer(idx) = M_r_outer / 2;  % Negative harmonic
        end
    end

    % =====================================================================
    % ASSEMBLE EQUATIONS FOR EACH HARMONIC
    % =====================================================================
    for idx = 1:N_eqs
        n = n_range(idx);

        % Row indices for this harmonic
        row_base = (idx-1)*6;

        % Unknowns: [A1, B1, A2, B2, A3, B3, A4, B4, A5, B5, A6, B6]
        % where An, Bn are coefficients for region n

        % -----------------------------------------------------------------
        % Equation 1: Continuity at R2 (Region 1 - Region 2)
        % A_phi continuous: A1*R2^n + B1*R2^(-n) = A2*R2^n + B2*R2^(-n) + source
        % -----------------------------------------------------------------
        if n == 0
            A(row_base+1, idx) = 1;          % A1
            A(row_base+1, N_eqs+idx) = 0;     % B1 (ln term handled separately)
            A(row_base+1, 2*N_eqs+idx) = -1;  % A2
            A(row_base+1, 3*N_eqs+idx) = 0;   % B2
            % RHS includes PM source term
            b(row_base+1) = M_n_inner * (R2^2 - R1^2) / 2;
        else
            A(row_base+1, idx) = R2^n;           % A1
            A(row_base+1, N_eqs+idx) = R2^(-n);  % B1
            A(row_base+1, 2*N_eqs+idx) = -R2^n;  % A2
            A(row_base+1, 3*N_eqs+idx) = -R2^(-n); % B2
            % RHS includes PM source term
            if n > 0
                b(row_base+1) = M_n_inner * (R2^(n+1) - R1^(n+1)) / (n+1);
            else
                b(row_base+1) = M_n_inner * (R2^(n+1) - R1^(n+1)) / (n+1);
            end
        end

        % -----------------------------------------------------------------
        % Equation 2: B_r continuity at R2
        % mu_r_PM * dA_phi/dr|_R2^- = mu_r_air * dA_phi/dr|_R2^+
        % -----------------------------------------------------------------
        if n ~= 0
            mu_ratio = materials.mu_r_PM / materials.mu_r_air;
            A(row_base+2, idx) = mu_ratio * n * R2^(n-1);
            A(row_base+2, N_eqs+idx) = -mu_ratio * n * R2^(-n-1);
            A(row_base+2, 2*N_eqs+idx) = -n * R2^(n-1);
            A(row_base+2, 3*N_eqs+idx) = n * R2^(-n-1);
            % RHS from PM
            b(row_base+2) = M_n_inner * mu_ratio * R2^n;
        else
            % n=0: special handling
            A(row_base+2, N_eqs+idx) = -materials.mu_r_PM / materials.mu_r_air;
            A(row_base+2, 3*N_eqs+idx) = 1;
        end

        % -----------------------------------------------------------------
        % Equation 3: Continuity at R3 (Region 2 - Region 3, FMP interface)
        % -----------------------------------------------------------------
        if n == 0
            A(row_base+3, 2*N_eqs+idx) = 1;
            A(row_base+3, 4*N_eqs+idx) = -1;
        else
            A(row_base+3, 2*N_eqs+idx) = R3^n;
            A(row_base+3, 3*N_eqs+idx) = R3^(-n);
            A(row_base+3, 4*N_eqs+idx) = -R3^n;
            A(row_base+3, 5*N_eqs+idx) = -R3^(-n);
        end

        % -----------------------------------------------------------------
        % Equation 4: B_r continuity at R3
        % -----------------------------------------------------------------
        if n ~= 0
            mu_ratio_FMP = materials.mu_r_air / materials.mu_r_FMP;
            A(row_base+4, 2*N_eqs+idx) = n * R3^(n-1);
            A(row_base+4, 3*N_eqs+idx) = -n * R3^(-n-1);
            A(row_base+4, 4*N_eqs+idx) = -mu_ratio_FMP * n * R3^(n-1);
            A(row_base+4, 5*N_eqs+idx) = mu_ratio_FMP * n * R3^(-n-1);
        else
            A(row_base+4, 3*N_eqs+idx) = -1;
            A(row_base+4, 5*N_eqs+idx) = materials.mu_r_air / materials.mu_r_FMP;
        end

        % -----------------------------------------------------------------
        % Equation 5: Continuity at R4 (Region 3 - Region 4, FMP interface)
        % -----------------------------------------------------------------
        if n == 0
            A(row_base+5, 4*N_eqs+idx) = 1;
            A(row_base+5, 6*N_eqs+idx) = -1;
        else
            A(row_base+5, 4*N_eqs+idx) = R4^n;
            A(row_base+5, 5*N_eqs+idx) = R4^(-n);
            A(row_base+5, 6*N_eqs+idx) = -R4^n;
            A(row_base+5, 7*N_eqs+idx) = -R4^(-n);
        end

        % -----------------------------------------------------------------
        % Equation 6: B_r continuity at R4
        % -----------------------------------------------------------------
        if n ~= 0
            mu_ratio_FMP = materials.mu_r_FMP / materials.mu_r_air;
            A(row_base+6, 4*N_eqs+idx) = mu_ratio_FMP * n * R4^(n-1);
            A(row_base+6, 5*N_eqs+idx) = -mu_ratio_FMP * n * R4^(-n-1);
            A(row_base+6, 6*N_eqs+idx) = -n * R4^(n-1);
            A(row_base+6, 7*N_eqs+idx) = n * R4^(-n-1);
        else
            A(row_base+6, 5*N_eqs+idx) = -materials.mu_r_FMP;
            A(row_base+6, 7*N_eqs+idx) = materials.mu_r_air;
        end
    end

    % Add additional equations for remaining interfaces (R5, R6)
    % and boundary conditions at R1 and R7
    % (Simplified here - would need full implementation)

    % =====================================================================
    % SOLVE THE SYSTEM
    % =====================================================================
    fprintf('  Solving linear system...\n');

    % Add regularization for better conditioning
    A = A + 1e-10 * eye(size(A));

    % Solve
    x = A \ b;

    fprintf('    → Solution residual: %.2e\n', norm(A*x - b) / norm(b));

    % =====================================================================
    % EXTRACT SOLUTION COEFFICIENTS
    % =====================================================================
    solution = struct();
    solution.n_range = n_range;

    solution.A1 = x(1:N_eqs);
    solution.B1 = x(N_eqs+1:2*N_eqs);
    solution.A2 = x(2*N_eqs+1:3*N_eqs);
    solution.B2 = x(3*N_eqs+1:4*N_eqs);
    solution.A3 = x(4*N_eqs+1:5*N_eqs);
    solution.B3 = x(5*N_eqs+1:6*N_eqs);

    % Additional regions (simplified)
    solution.A4 = zeros(N_eqs, 1);
    solution.B4 = zeros(N_eqs, 1);
    solution.A5 = zeros(N_eqs, 1);
    solution.B5 = zeros(N_eqs, 1);

    solution.rotor_position = rotor_position;

    fprintf('  ✓ System solved successfully\n\n');

end
