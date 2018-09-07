#------------------------------------------------------------------------------#
# C, O2, and CO2
# 2 phases: solid and gas
# Phase-field action
# Status: WORKING
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  # length scale -> microns
  type = GeneratedMesh
  dim = 2
  xmax = 5
  ymax = 0.5
  nx = 50
  ny = 5
  uniform_refine = 2
[]

#------------------------------------------------------------------------------#
[AuxVariables]
  [./f_dens]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./x_V]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

#------------------------------------------------------------------------------#
[AuxKernels]
  [./f_dens_aux]
    type = TotalFreeEnergy
    interfacial_vars = 'x_C x_O2 x_CO2'
    kappa_names = 'kappa_C kappa_O2 kappa_CO2'
    f_name = f_loc
    variable = f_dens
  [../]
  [./vac_conc_aux]
    type = MaterialRealAux
    property = vac_conc
    variable = x_V
  [../]
[]

#------------------------------------------------------------------------------#
[Modules]
  [./PhaseField]
    [./Conserved]
      [./x_C]
        solve_type = FORWARD_SPLIT
        kappa = kappa_C
        free_energy = f_loc
        mobility = M_C
        args = 'x_O2 x_CO2 eta'
      [../]
      [./x_O2]
        solve_type = FORWARD_SPLIT
        kappa = kappa_O2
        free_energy = f_loc
        mobility = M_O2
        args = 'x_C x_CO2 eta'
      [../]
      [./x_CO2]
        solve_type = FORWARD_SPLIT
        kappa = kappa_CO2
        free_energy = f_loc
        mobility = M_CO2
        args = 'x_O2 x_C eta'
      [../]
    [../]
    [./Nonconserved]
      [./eta]
        kappa = kappa_eta
        mobility = L
        free_energy = f_loc
        args = 'x_C x_O2 x_CO2'
      [../]
    [../]
  [../]
[]

#------------------------------------------------------------------------------#
# Coordinates for bounding box IC
[GlobalParams]
  x1 = 0
  x2 = 4.0
  y1 = 0
  y2 = 0.2
[]

#------------------------------------------------------------------------------#
[ICs]
  # O2
  [./IC_x_O2]
    type = BoundingBoxIC
    variable = x_O2
    inside = 1e-4
    outside = 0.209
  [../]

  # C
  [./IC_x_C]
    type = BoundingBoxIC
    variable = x_C
    inside = 0.99
    outside = 1e-4
  [../]

  # CO2
  [./IC_x_CO2]
    type = BoundingBoxIC
    variable = x_CO2
    inside = 1e-4
    outside = 3e-4
  [../]

  # eta
  [./IC_eta]
    type = BoundingBoxIC
    variable = eta
    inside = 0.0
    outside = 1.0
  [../]
[]

#------------------------------------------------------------------------------#
[Kernels]
  # Recombination of C and O2
  # Reactants: Use Recombination kernel
  [./recomb_C]
    type = Recombination
    variable = x_C
    v = x_O2
    mob_name = R_recomb
  [../]

  [./recomb_O2]
    type = Recombination
    variable = x_O2
    v = x_C
    mob_name = R_recomb
  [../]

  # Production of CO
  # Products: Use Production kernel
  [./prod_CO2]
    type = Production
    variable = x_CO2
    v = x_C
    w = x_O2
    mob_name = R_prod
  [../]
[]

#------------------------------------------------------------------------------#
[Materials]
  #----------------------------------------------------------------------------#
  # Reaction rates
  [./reation_rate_recomb] # Reactant
    type = DerivativeParsedMaterial
    f_name = R_recomb
    args = 'x_O2 x_C'
    function = 'if(x_O2<0.0,0,if(x_C<0.0,0,-15))'
    derivative_order = 1
    outputs = exodus
  [../]
  [./reation_rate_prod] # Product
    type = DerivativeParsedMaterial
    f_name = R_prod
    args = 'x_O2 x_C'
    function = 'if(x_O2<0.0,0,if(x_C<0.0,0,15))'
    derivative_order = 1
    outputs = exodus
  [../]

  #----------------------------------------------------------------------------#
  # Order parameter stuff
  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_eta'
    prop_values = '20 1.0e-2' #L=5
  [../]
  [./switching]
    type = SwitchingFunctionMaterial
    function_name = h
    eta = 'eta'
    h_order =  HIGH
    outputs = exodus
    output_properties = h
  [../]
  [./barrier]
    type = BarrierFunctionMaterial
    eta = 'eta'
    function_name = g
    g_order = SIMPLE
    outputs = exodus
    output_properties = g
  [../]

  #----------------------------------------------------------------------------#
  # O
  [./mobility_O2]
    type = DerivativeParsedMaterial
    f_name = M_O2
    material_property_names = h(eta)
    constant_names = 'M_g M_f'
    constant_expressions = '100 1'
    function = 'M_g'
    outputs = exodus
    output_properties = M_O2
  [../]
  [./kappa_O2]
    type = GenericConstantMaterial
    prop_names  = 'kappa_O2'
    prop_values = '0.5e-2'
  [../]

  #----------------------------------------------------------------------------#
  # C
  [./mobility_C]
    type = DerivativeParsedMaterial
    f_name = M_C
    material_property_names = h(eta)
    constant_names = 'M_g M_f'
    constant_expressions = '0.001 1' #M_f = 0.1
    function = 'M_f'
    outputs = exodus
    output_properties = M_C
  [../]
  [./kappa_C]
    type = GenericConstantMaterial
    prop_names  = 'kappa_C'
    prop_values = '0.5e-2'
  [../]

  #----------------------------------------------------------------------------#
  # CO
  [./mobility_CO2]
    type = DerivativeParsedMaterial
    f_name = M_CO2
    material_property_names = h(eta)
    constant_names = 'M_g M_f'
    constant_expressions = '100 1'
    function = 'M_g'
    outputs = exodus
    output_properties = M_CO2
  [../]
  [./kappa_CO2]
    type = GenericConstantMaterial
    prop_names  = 'kappa_CO2'
    prop_values = '0.5e-2'
  [../]

  #----------------------------------------------------------------------------#
  # Gibbs energy of the solid phase
  [./free_energy_f]
    type = DerivativeParsedMaterial
    f_name = f_s
    args = 'x_C x_O2 x_CO2'
    constant_names = 'Ef_v kb T tol'
    constant_expressions = '4.0 8.6173303e-5 1000.0 1e-4'

    function  = 'kb*T*x_C*plog(x_C,tol)
              + (Ef_v*(1-x_C-x_O2-x_CO2) + kb*T*(1-x_C-x_O2-x_CO2)*plog(1-x_C-x_O2-x_CO2,tol))
              + (Ef_v*x_O2 + kb*T*x_O2*plog(x_O2,tol))
              + (Ef_v*x_CO2 + kb*T*x_CO2*plog(x_CO2,tol))'

    derivative_order = 2
    #outputs = exodus
  [../]

  #----------------------------------------------------------------------------#
  # Gibbs energy of the gas phase
  [./free_energy_g]
    type = DerivativeParsedMaterial
    f_name = f_g
    args = 'x_O2 x_C x_CO2'
    constant_names = 'A O2_eq CO2_eq'
    constant_expressions = '10.0 0.209 3e-4'
    function = 'A/2.0 * ((O2_eq - x_O2)^2 + x_C^2 +(CO2_eq - x_CO2)^2)'
    derivative_order = 2
    #outputs = exodus
  [../]

  #----------------------------------------------------------------------------#
  # Gibbs energy density
  [./free_energy_loc]
    type = DerivativeParsedMaterial
    f_name = f_loc
    constant_names = 'W'
    constant_expressions = '10.0' #10 for Ef_v=4; 20 for Ef_v=8
    args = 'x_C x_O2 x_CO2 eta'
    material_property_names = 'h(eta) g(eta) f_g(x_O2,x_C,x_CO2) f_s(x_C,x_O2,x_CO2)'
    function = 'h * f_g + (1 - h) * f_s + W * g'
    derivative_order = 2
    #outputs = exodus
  [../]

  #----------------------------------------------------------------------------#
  # Vacancy concentration
  [./vac_conc_mat]
    type = ParsedMaterial
    f_name = vac_conc
    args = 'x_C x_O2 x_CO2'
    material_property_names = 'h(eta)'
    function = '(1-h) * (1-x_C-x_O2-x_CO2)'
    outputs = exodus
    output_properties = vac_conc
  [../]
[]

#------------------------------------------------------------------------------#
[BCs]
  [./x_O2_top]
    type = PresetBC
    variable = x_O2
    value = 0.209
    boundary = top
  [../]
#   [./x_CO2_top]
#     type = PresetBC
#     variable = x_CO2
#     value = 3e-4
#     boundary = top
#   [../]
[]

#------------------------------------------------------------------------------#
[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

#------------------------------------------------------------------------------#
[Executioner]
  type = Transient
  scheme = 'bdf2'
  solve_type = NEWTON
  #petsc_options_iname = '-pc_type -sub_pc_type'
  #petsc_options_value = 'asm lu'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'

  l_max_its = 10
  l_tol = 1.0e-4

  nl_max_its = 30
  nl_rel_tol = 1.0e-8
  nl_abs_tol = 1.0e-10

  dtmax = 0.1
  dtmin = 1e-12

  end_time = 2

  [./Adaptivity]
    max_h_level = 3
    coarsen_fraction = 0.1
    refine_fraction = 0.8
  [../]

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    growth_factor = 1.2
    cutback_factor = 0.8
    optimal_iterations = 8
    iteration_window = 0
  [../]
[]

#------------------------------------------------------------------------------#
[Postprocessors]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = f_dens
  [../]
  [./total_O2]
    type = ElementIntegralVariablePostprocessor
    variable = x_O2
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./total_C]
    type = ElementIntegralVariablePostprocessor
    variable = x_C
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./total_CO2]
    type = ElementIntegralVariablePostprocessor
    variable = x_CO2
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./total_V]
    type = ElementIntegralVariablePostprocessor
    variable = x_V
  [../]
  [./dt]
    type = TimestepSize
  [../]
  [./time]
    type = PerformanceData
    event = ALIVE
  [../]
[]

#------------------------------------------------------------------------------#
[Outputs]
  exodus = true
  csv = true
  perf_graph = true
  file_base = ./oxidation_2D_v3/fiber_oxidation_2D_v3_out
[]

#------------------------------------------------------------------------------#
[Debug]
  show_var_residual_norms = true
[]
