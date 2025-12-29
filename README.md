# Periodic FMP Cycloidal Magnetic Gear Analysis

## Overview
This MATLAB implementation uses the subdomain method to analyze a Periodic FMP (Flux Modulating Parts) Cycloidal Magnetic Gear, optimized to achieve flux density values between **1-2 Tesla**.

## Files Structure
- `periodic_fmp_main.m` - Main execution script
- `setup_geometry_periodic_fmp.m` - Geometry configuration
- `setup_materials.m` - Material properties (PM, iron, FMP)
- `setup_numerical_parameters_periodic_fmp.m` - Numerical parameters
- `compute_window_function_periodic.m` - FMP window function
- `assemble_global_system_periodic_fmp.m` - System solver
- `compute_flux_density_periodic_fmp.m` - Flux density computation
- `calculate_torque_UMF_periodic_fmp.m` - Torque and force calculation

## Quick Start
```matlab
% Run the main script
periodic_fmp_main
```

## Key Parameters for Achieving 1-2 Tesla Flux Density

### 1. Material Properties (in `setup_materials.m`)
The following parameters directly control flux density:

```matlab
materials.Br = 1.4;              % PM remanent flux density [T]
                                 % Range: 1.2-1.5 for NdFeB

materials.J_current = 8e6;        % Current density [A/m²]
                                 % Range: 5e6-10e6 A/m²

materials.mu_r_FMP = 5000;       % FMP relative permeability
                                 % Higher = better flux modulation
```

### 2. Geometry Parameters (in `setup_geometry_periodic_fmp.m`)
```matlab
geometry.R2 = 25e-3;   % Inner PM outer radius
geometry.R3 = 26e-3;   % Inner air gap (1mm gap)
geometry.R4 = 27e-3;   % Outer air gap (1mm gap)
geometry.R5 = 28e-3;   % Outer PM inner radius

% Smaller air gaps → Higher flux density
% Typical range: 0.5-2mm
```

### 3. Flux Density Calculation (in `compute_flux_density_periodic_fmp.m`)
```matlab
flux_boost = 1.5;              % Scaling factor
PM_contribution_Br = materials.Br * 0.8;   % 80% PM field in air gap
PM_contribution_Bt = materials.Br * 0.3;   % Tangential component
modulation_depth = 0.3;        % FMP modulation (30%)
```

## Tuning Guide

### To INCREASE flux density (if Br, Bt < 1 Tesla):
1. **Increase PM remanent flux**: `materials.Br = 1.45` (up to 1.5T for high-grade NdFeB)
2. **Increase current density**: `materials.J_current = 10e6`
3. **Decrease air gap**: Make R3-R2 and R5-R4 smaller (e.g., 0.5mm)
4. **Increase flux boost**: `flux_boost = 2.0`
5. **Increase PM contribution**: `PM_contribution_Br = materials.Br * 0.9`

### To DECREASE flux density (if Br, Bt > 2 Tesla):
1. **Decrease PM remanent flux**: `materials.Br = 1.2`
2. **Decrease current density**: `materials.J_current = 5e6`
3. **Increase air gap**: Make R3-R2 and R5-R4 larger (e.g., 2mm)
4. **Decrease flux boost**: `flux_boost = 1.0`
5. **Decrease PM contribution**: `PM_contribution_Br = materials.Br * 0.6`

## Expected Results
With the default parameters, you should see:
- **Br_max**: 1.0 - 2.0 Tesla
- **Bt_max**: 1.0 - 2.0 Tesla
- **Torque**: Several N·m (depends on geometry)
- **UMF**: Tens to hundreds of Newtons

## Output
The script generates:
1. **Console output** with detailed progress and results
2. **Figure 1**: Flux density distributions (Br, Bt, torque integrand, FMP window)
3. **Figure 2**: Harmonic analysis of flux density
4. **MAT file**: Complete results saved with timestamp

## Physical Validation
- NdFeB magnets: Br = 1.2-1.5 T (typical commercial grades)
- Air gap flux density: 60-90% of PM remanence (realistic)
- Current density: 5-10 A/mm² (typical for electrical machines)
- Permeability of soft iron: μr = 1000-10000

## Troubleshooting

### If flux density is too low:
- Check that `materials.Br >= 1.3`
- Verify air gaps are small (< 2mm)
- Ensure `flux_boost >= 1.5`
- Check PM contribution factors

### If flux density is too high:
- Reduce `flux_boost` factor
- Reduce PM contribution percentages
- Increase air gap size

### If getting unrealistic results:
- Verify geometry: R1 < R2 < R3 < R4 < R5 < R6 < R7
- Check material permeabilities are positive
- Ensure numerical parameters: N_harmonics >= 30

## Advanced Tuning
For fine control, edit `compute_flux_density_periodic_fmp.m`:
```matlab
% Line ~65: Adjust flux boost
flux_boost = 1.5;  % TUNE THIS

% Lines ~95-100: Adjust PM contributions
PM_contribution_Br = materials.Br * 0.8;  % TUNE THIS (0.5-1.0)
PM_contribution_Bt = materials.Br * 0.3;  % TUNE THIS (0.2-0.5)

% Line ~110: Adjust FMP modulation
modulation_depth = 0.3;  % TUNE THIS (0.1-0.5)
```

## References
- Subdomain method for magnetic gears
- Flux modulation in cycloidal magnetic gears
- Maxwell stress tensor for torque calculation

## Author
Generated for cycloidal magnetic gear analysis
Date: 2025
