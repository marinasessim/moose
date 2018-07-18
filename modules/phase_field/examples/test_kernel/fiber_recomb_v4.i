#------------------------------------------------------------------------------#
# 2 elements: Carbon and Oxygen
# 2 phases: solid and gas
# Evolution kernels on Oxygen Variables
# Recombination kernel active
# Carbon constrained to 1 - x_O
# Status: Running, correct profile
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  # length scale -> microns
  type = GeneratedMesh
  dim = 1
  xmax = 100
  nx = 100
  uniform_refine = 4
[]

#------------------------------------------------------------------------------#
[AuxVariables]
  [./f_dens]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./x_C]
    order = FIRST
    family = LAGRANGE
  [../]
  [./x_total]
    order = FIRST
    family = LAGRANGE
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
  [./x_C_aux]
    type = ParsedAux
    variable = x_C
    function = '1 - x_O'
    args = 'x_O'
  [../]
  [./x_total_aux]
    type = ParsedAux
    variable = x_total
    function = 'x_O + x_C'
    args = 'x_O x_C'
  [../]
[]

#------------------------------------------------------------------------------#
[Variables]
  # 2 species: Carbon and Oxygen
  # Oxygen
  [./w_O]
    order = FIRST
    family = LAGRANGE
  [../]
    [./x_O]
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
        type = BoundingBoxIC
        x1 = 0
        x2 = 50
        y1 = 0
        y2 = 0
        inside = 0.02
        outside = 1.0
      [../]
    [../]

  # 2 phases: solid and gas
  [./eta]
    # eta tracks gas phase because of switching function material presets
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 0
      x2 = 50
      y1 = 0
      y2 = 0
      inside = 0
      outside = 1
    [../]
  [../]
[]

#------------------------------------------------------------------------------#
[Kernels]
  #Oxygen concentration evolution
  [./x_O_res]
    type = SplitCHParsed
    variable = x_O
    f_name = f_loc
    kappa_name = kappa_O
    w = w_O
    args = 'x_C eta'
  [../]
  [./w_O_res]
    type = SplitCHWRes
    variable = w_O
    mob_name = M_O
  [../]
  [./time_O]
    type = CoupledTimeDerivative
    variable = w_O
    v = x_O
  [../]

  #Order parameter
  [./deta_dt]
    type = TimeDerivative
    variable = eta
  [../]
  [./ACBulk]
    type = AllenCahn
    variable = eta
    args = 'x_O'
    f_name = f_loc
    mob_name = L
  [../]
  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]

  # Recombination of C and O
  [./recomb]
    type = Recombination
    variable = x_O
    v = x_C
    mob_name = RR
  [../]
[]


#------------------------------------------------------------------------------#
[Materials]
  [./reation_rate]
    type = GenericConstantMaterial
    prop_names = 'RR'
    prop_values = '1'
  [../]

  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_eta'
    prop_values = '1 2'
  [../]

  [./constants_CH]
    type = GenericConstantMaterial
    prop_names  = 'M_C M_O kappa_C kappa_O'
    prop_values = '0.01 0.01 0 0'
    #Smaller mob fixed negative composition on gas side
    #Increasing W brought it back, but symetric
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
    function = 'kb*T*x_C*plog(x_C,1e-4) + (Ef_v*x_O + kb*T*x_O*plog(x_O,1e-4))'
    derivative_order = 2
    #outputs = exodus
  [../]

  # Gas free energy
  [./free_energy_g]
    type = DerivativeParsedMaterial
    f_name = f_g
    args = 'x_O'
    constant_names = 'A'
    constant_expressions = '1.0'
    function = 'A/2.0*((1-x_O)^2)'
    derivative_order = 2
    #outputs = exodus
  [../]

  # Free energy density
  [./free_energy_loc]
    type = DerivativeParsedMaterial
    f_name = f_loc
    constant_names = 'W'
    constant_expressions = '20.0'
    args = 'x_C x_O eta'
    material_property_names = 'h(eta) g(eta) f_g(x_O) f_f(x_C,x_O)'
    function = 'h * f_g + (1 - h) * f_f + W * g'
    derivative_order = 2
    #outputs = exodus
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
  solve_type = 'NEWTON'
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
  dtmin = 1e-9

  end_time = 10

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    percent_change = 0.1
    dt = 1e-3
    initial_direction = 1
  [../]
[]

#------------------------------------------------------------------------------#
[Postprocessors]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = f_dens
  [../]
  [./dt]
    type = TimestepSize
  [../]
[]

#------------------------------------------------------------------------------#
[Outputs]
  exodus = true
  csv = true
  print_perf_log = true
[]

#------------------------------------------------------------------------------#
[Debug]
  show_var_residual_norms = true
[]
