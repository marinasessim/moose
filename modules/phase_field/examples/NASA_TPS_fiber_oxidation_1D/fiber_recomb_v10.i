#------------------------------------------------------------------------------#
# 3 elements: carbon, oxygen and "vacancies"
# 2 phases: solid and gas
# Evolution kernels on oxygen and carbon variables
# Status: running but recombination kernel is not working
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  # length scale -> microns
  type = GeneratedMesh
  dim = 1
  xmax = 10
  nx = 1000
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
[Variables]
  # Oxygen
    [./x_O]
      [./InitialCondition]
        type = BoundingBoxIC
        x1 = 0
        x2 = 5
        y1 = 0
        y2 = 0
        inside = 0.0
        outside = 0.90
      [../]
    [../]

    # Carbon
      [./x_C]
        [./InitialCondition]
          type = BoundingBoxIC
          x1 = 0
          x2 = 5
          y1 = 0
          y2 = 0
          inside = 1.0
          outside = 0.0
        [../]
      [../]

  [./eta]
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 0
      x2 = 5
      y1 = 0
      y2 = 0
      inside = 0.0
      outside = 1.0
    [../]
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
    implicit = true
  [../]
[]

#------------------------------------------------------------------------------#
[Materials]
  [./reation_rate]
    type = DerivativeParsedMaterial
    f_name = RR
    #args = 'x_O x_C'
    function = '1'
    derivative_order = 1
  [../]

  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_eta'
    prop_values = '1 0.5'
  [../]

  [./kappas_CH]
    type = GenericConstantMaterial
    prop_names  = 'kappa_C kappa_O kappa_CO'
    prop_values = '1e-3 1e-3 0'
  [../]

  [./mobility_O]
    type = DerivativeParsedMaterial
    f_name = M_O
    material_property_names = h(eta)
    constant_names = 'M_g M_f'
    constant_expressions = '1 1'
    function = 'h * M_g+ (1 - h) * M_f'
    outputs = exodus
    output_properties = M_O
  [../]

  [./mobility_C]
    type = DerivativeParsedMaterial
    f_name = M_C
    material_property_names = h(eta)
    constant_names = 'M_g M_f'
    constant_expressions = '0.001 1'
    function = 'h * M_g+ (1 - h) * M_f'
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
    constant_names = 'Ef_v kb T'
    constant_expressions = '4.0 8.6173303e-5 1000.0'
    function = 'kb*T*x_C*plog(x_C,1e-4) +(Ef_v*(1-x_C) + kb*T*(1-x_C)*plog(1-x_C,1e-4)) +(Ef_v*x_O + kb*T*x_O*plog(x_O,1e-4))'
    derivative_order = 2
    #outputs = exodus
  [../]

  # Gas free energy
  [./free_energy_g]
    type = DerivativeParsedMaterial
    f_name = f_g
    args = 'x_O x_C'
    constant_names = 'A'
    constant_expressions = '1.0'
    function = 'A/2.0*((1-x_O)^2 + x_C^2)'
    derivative_order = 2
    #outputs = exodus
  [../]

  # Free energy density
  [./free_energy_loc]
    type = DerivativeParsedMaterial
    f_name = f_loc
    constant_names = 'W'
    constant_expressions = '1.0' #10 for Ef_v 4 20 for Ef_v 8
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
    function = 'h * (1-x_O) + (1-h) * (1-x_C)'
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
  l_tol = 1.0e-8

  nl_max_its = 20
  nl_rel_tol = 1.0e-8

  start_time = 0.0

  dtmax = 10
  dtmin = 1e-12

  #end_time = 100

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    percent_change = 0.1
    dt = 1e-6
    initial_direction = 1
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
  [../]
  [./total_C]
    type = ElementIntegralVariablePostprocessor
    variable = x_C
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

#------------------------------------------------------------------------------#
[Debug]
  show_var_residual_norms = true
[]
