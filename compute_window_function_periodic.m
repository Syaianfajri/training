function [Lambda, Lambda_n] = compute_window_function_periodic(theta, geometry, N_harmonics)
% COMPUTE_WINDOW_FUNCTION_PERIODIC - Compute periodic FMP window function
%
% Inputs:
%   theta       - Angular positions [rad]
%   geometry    - Geometry structure
%   N_harmonics - Number of harmonics
%
% Outputs:
%   Lambda   - Window function values at theta
%   Lambda_n - Fourier coefficients

    % Initialize window function (0 = air, 1 = FMP present)
    Lambda = zeros(size(theta));

    % For each FMP segment
    for k = 1:geometry.N_FMP
        % Center of this segment
        theta_c = geometry.theta_centers(k);

        % Half-width
        half_width = geometry.theta_FMP / 2;

        % Mark regions where FMP is present
        % Handle angular wrapping
        for i = 1:length(theta)
            % Angular distance from segment center
            d_theta = angle_diff(theta(i), theta_c);

            if abs(d_theta) <= half_width
                Lambda(i) = 1;
            end
        end
    end

    % Compute Fourier coefficients if requested
    if nargout > 1
        Lambda_n = zeros(1, 2*N_harmonics+1);
        n_range = -N_harmonics:N_harmonics;

        for idx = 1:length(n_range)
            n = n_range(idx);
            % Fourier coefficient using trapezoidal integration
            integrand = Lambda .* exp(-1j * n * theta);
            Lambda_n(idx) = trapz(theta, integrand) / (2*pi);
        end
    end

end

function d = angle_diff(theta1, theta2)
% Compute angular difference accounting for 2*pi wrapping
    d = theta1 - theta2;
    d = mod(d + pi, 2*pi) - pi;  % Wrap to [-pi, pi]
end
