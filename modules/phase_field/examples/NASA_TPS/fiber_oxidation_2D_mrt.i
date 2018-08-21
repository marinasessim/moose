#------------------------------------------------------------------------------#
# 3 elements: carbon, oxygen and "vacancies"
# 2 phases: solid and gas
# Phase-field action
# Status: running
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

[GlobalParams]
  x1 = 0
  x2 = 4.0
  y1 = 0
  y2 = 0.2
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
  [./x_total]
  [../]
[]

#------------------------------------------------------------------------------#
[AuxKernels]
  [./f_dens_aux]
    type = TotalFreeEnergy
    interfacial_vars = 'x_C x_O'
    kappa_names = 'kappa_C kappa_O'
    f_name = f_loc
    variable = f_dens
  [../]
  [./vac_conc_aux]
    type = MaterialRealAux
    property = V
    variable = x_V
  [../]
  [./x_total_aux]
    type = ParsedAux
    variable = x_total
    function = 'x_O + x_C'
    args = 'x_O x_C'
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
        args = 'x_O eta'
      [../]
      [./x_O]
        solve_type = FORWARD_SPLIT
        kappa = kappa_O
        free_energy = f_loc
        mobility = M_O
        args = 'x_C eta'
      [../]
    [../]
    [./Nonconserved]
      [./eta]
        kappa = kappa_eta
        mobility = L
        free_energy = f_loc
        args = 'x_C x_O'
      [../]
    [../]
  [../]
[]

#------------------------------------------------------------------------------#
[ICs]
  # Oxygen
  [./IC_x_O]
    type = BoundingBoxIC
    variable = x_O
    inside = 0.0
    outside = 0.2
  [../]
  # Carbon
  [./IC_x_C]
    type = BoundingBoxIC
    variable = x_C
    inside = 0.99
    outside = 0.0
  [../]
  # Eta
  [./IC_eta]
    type = BoundingBoxIC
    variable = eta
    inside = 0.0
    outside = 1.0
  [../]
[]

#------------------------------------------------------------------------------#
[Kernels]
  # Recombination of C and O
  [./recomb_CO]
    type = Recombination
    variable = x_C
    v = x_O
    mob_name = RR
  [../]
  [./recomb_OC]
    type = Recombination
    variable = x_O
    v = x_C
    mob_name = RR
  [../]
[]

#------------------------------------------------------------------------------#
[Materials]
  [./reation_rate]
    type = DerivativeParsedMaterial
    f_name = RR
    args = 'x_O x_C'
    function = 'if(x_O<0.0,0,if(x_C<0.0,0,-15))' #RR= -10
    derivative_order = 1
    outputs = exodus
  [../]
  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_eta'
    prop_values = '20 1.0e-2' #L=5
  [../]
  [./kappas_CH]
    type = GenericConstantMaterial
    prop_names  = 'kappa_C kappa_O kappa_CO'
    prop_values = '0.5e-2 0.5e-2 0'
  [../]
  [./mobility_O]
    type = DerivativeParsedMaterial
    f_name = M_O
    material_property_names = h(eta)
    constant_names = 'M_g M_f'
    constant_expressions = '100 1'
    function = 'M_g'
    outputs = exodus
    output_properties = M_O
  [../]
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
  # Bulk free energy
  [./free_energy_f]
    type = DerivativeParsedMaterial
    f_name = f_f
    args = 'x_C x_O'
    constant_names = 'Ef_v kb T tol'
    constant_expressions = '4.0 8.6173303e-5 1000.0 1e-4'
    function = 'kb*T*x_C*plog(x_C,tol) + (Ef_v*(1-x_C-x_O) + kb*T*(1-x_C-x_O)*plog(1-x_C-x_O,tol)) + (Ef_v*x_O + kb*T*x_O*plog(x_O,tol))'
    derivative_order = 2
    #outputs = exodus
  [../]
  # Gas free energy
  [./free_energy_g]
    type = DerivativeParsedMaterial
    f_name = f_g
    args = 'x_O x_C'
    constant_names = 'A'
    constant_expressions = '10.0'
    function = 'A/2.0 * ((0.2 - x_O)^2 + x_C^2)'
    derivative_order = 2
    #outputs = exodus
  [../]
  # Free energy density
  [./free_energy_loc]
    type = DerivativeParsedMaterial
    f_name = f_loc
    constant_names = 'W'
    constant_expressions = '10.0' #10 for Ef_v=4; 20 for Ef_v=8
    args = 'x_C x_O eta'
    material_property_names = 'h(eta) g(eta) f_g(x_O,x_C) f_f(x_C,x_O)'
    function = 'h * f_g + (1 - h) * f_f + W * g'
    derivative_order = 2
    #outputs = exodus
  [../]
  [./vac_conc]
    type = ParsedMaterial
    f_name = V
    args = 'x_C x_O'
    material_property_names = 'h(eta)'
    function = '(1-h) * (1-x_C-x_O)'
  [../]
[]

[BCs]
  [./x_O_right]
    type = PresetBC
    variable = x_O
    value = 0.2
    boundary = right
  [../]
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

  dtmax = 1
  dtmin = 1e-12

  end_time = 2

  [./Adaptivity]
    max_h_level = 2
    coarsen_fraction = 0.1
    refine_fraction = 0.8
  [../]
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-5
    growth_factor = 1.1
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
  [./total_O]
    type = ElementIntegralVariablePostprocessor
    variable = x_O
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./total_C]
    type = ElementIntegralVariablePostprocessor
    variable = x_C
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./total_x]
    type = ElementIntegralVariablePostprocessor
    variable = x_total
  [../]
  [./dt]
    type = TimestepSize
  [../]
[]

#------------------------------------------------------------------------------#
[Outputs]
  exodus = true
  csv = true
  perf_graph = true
[]
