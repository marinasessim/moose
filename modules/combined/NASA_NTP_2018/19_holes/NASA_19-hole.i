
[Mesh]
  # centimeters
  type = FileMesh
  file = 19-hole.e
[]

# Blocks: 1 bulk; 2 outer cladding; 3 hole cladding
# Sidesets: 10 subchannel; 20 outer cladding; 30 top; 40 bottom

[Variables]
  # Adds variables needed for two ways of calculating effective thermal cond.
  [./T]
    # Temperature used for the direct calculation
    initial_condition = 1500
  [../]
[]

[Kernels]
  [./Conduction]
    # Kernel for direct calculation of thermal cond
    type = HeatConduction
    variable = T
  [../]
  [./Generation]
    #Volumetric het production
    # approximately 4 W/cm3 from Stewart2012
    type = HeatSource
    variable = T
    block = 1
    value = 5e3
  [../]
[]

[BCs]
  active = 'subchannel_T'
  [./top_bottom]
    type = PresetBC
    variable = T
    boundary = '30 40'
    value = 1500
  [../]
  [./subchannel_flux]
    # Set dT/dx on the subchannel
    type = NeumannBC
    variable = T
    boundary = 10
    value = -1e3
    #Residual is directly proportional to this value
  [../]
  [./subchannel_T]
    # Set dT/dx on the subchannel
    type = PresetBC
    variable = T
    boundary = 10
    value = 1500
  [../]
  [./outer_clad_fix_temp]
    type = PresetBC
    variable = T
    boundary = 20
    value = 1500
  [../]
[]

[Materials]
  [./W-UO2]
    # Both models return k in W/m-K, multiply by 1e-2 to match scale (centimeters)
    type = ParsedMaterial
    block = '1'
    constant_names = 'length_scale'
    constant_expressions = '1e-2'
    # @ 2000K, 25W/m-K
    function = 'length_scale*25'
    args = 'T'
    outputs = exodus
    f_name = thermal_conductivity
  [../]
  [./W]
    # Thermal conductivity of W by modified Hust–Lankford fit (300K < T < 3,000K)
    # Thermal conductivity of 95% dense UO2 according to Fink's model
    # Both models return k in W/m-K, multiply by 1e-2 to match scale (centimeters)
    type = ParsedMaterial
    block = '2 3'
    constant_names = 'length_scale'
    constant_expressions = '1e-2'
    function = 'length_scale*(149.441 - 45.466e-3*T + 13.193e-6 * pow(T,2) - 1.484e-9 * pow(T,3) + 3.866e6/pow(T,2))'
    args = 'T'
    outputs = exodus
    f_name = thermal_conductivity
  [../]
[]

[Postprocessors]
  [./subchannel_T]
    type = SideAverageValue
    variable = T
    boundary = 10
  [../]

  [./bulk_vol] # volumes are in cm3 because it is the mesh dimension
    type = VolumePostprocessor
    block = 1
  [../]
  [./hole_cladding_vol]
    type = VolumePostprocessor
    block = 2
  [../]
  [./outer_cladding_vol]
    type = VolumePostprocessor
    block = 3
  [../]

  [./bulk_max_T]
    type = ElementExtremeValue
    variable = T
    block = 1
  [../]
  [./bulk_ave_T]
    type = ElementAverageValue
    variable = T
    block = 1
  [../]

  [./outer_cladding_max_T]
    type = ElementExtremeValue
    variable = T
    block = 3
  [../]
  [./outer_cladding_mave_T]
    type = ElementAverageValue
    variable = T
    block = 1
  [../]
  [./outer_surface_T]
    type = SideAverageValue
    variable = T
    boundary = 20
  [../]
[]

[Executioner]
  type = Steady
  l_max_its = 40
  solve_type = PJFNK
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart -pc_hypre_boomeramg_strong_threshold'
  petsc_options_value = 'hypre boomeramg 31 0.7'
  l_tol = 1e-04
  nl_abs_tol = 1e-08
  line_search = none
[]

[Outputs]
  execute_on = timestep_end
  exodus = true
  csv = true
  print_perf_log = true
[]

[Debug]
  show_material_props = true
  show_var_residual = T
  show_var_residual_norms = true
[]
