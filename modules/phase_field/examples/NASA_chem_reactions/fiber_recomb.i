###############################################################################
#                                                                             #
# Multiphase (c_c, c_o) multiorder (eta_c,eta_o)
# Status: running
#                                                                             #
###############################################################################

[GlobalParams]
  penalty = 1e3
[]

[Mesh]
  # length scale -> microns
  type = GeneratedMesh
  dim = 1
  xmax = 100
  nx = 100
  uniform_refine = 4
[]

[AuxVariables]
  [./f_dens]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./cross_energy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[AuxKernels]
  [./f_dens]
    type = TotalFreeEnergy
    interfacial_vars = 'c_c c_o'
    kappa_names = 'kappa_c kappa_o'
    f_name = f_loc
    variable = f_dens
    additional_free_energy = cross_energy
  [../]

  [./cross_terms]
    type = CrossTermGradientFreeEnergy
    variable = cross_energy
    interfacial_vars = 'eta_c eta_o'
    kappa_names = 'kappa_cc kappa_co
                   kappa_co kappa_oo'
  [../]
[]

[Variables]
  [./w_c]
    order = FIRST
    family = LAGRANGE
  [../]

  [./w_o]
    order = FIRST
    family = LAGRANGE
  [../]

  [./c_c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type =   BoundingBoxIC
      x1 = 0
      x2 = 50
      y1 = 0
      y2 = 0
      inside = 0.9
      outside = 0.1
    [../]
  [../]

    [./c_o]
      order = FIRST
      family = LAGRANGE
      [./InitialCondition]
        type =   BoundingBoxIC
        x1 = 50
        x2 = 100
        y1 = 0
        y2 = 0
        inside = 0.9
        outside = 0.1
      [../]
    [../]

  [./eta_c]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 0
      x2 = 50
      y1 = 0
      y2 = 0
      inside = 1
      outside = 0
    [../]
  [../]

  [./eta_o]
    order = FIRST
    family = LAGRANGE
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 50
      x2 = 100
      y1 = 0
      y2 = 0
      inside = 1
      outside = 0
    [../]
  [../]
[]

[Kernels]
  # Carbon concentration
  [./c_c_res]
    type = SplitCHParsed
    variable = c_c
    f_name = f_loc
    kappa_name = kappa_c
    w = w_c
    args = 'eta_c eta_o'
  [../]
  [./w_c_res]
    type = SplitCHWRes
    variable = w_c
    mob_name = M
  [../]
  [./time_c]
    type = CoupledTimeDerivative
    variable = w_c
    v = c_c
  [../]

  #Oxygen concentration
  [./c_o_res]
    type = SplitCHParsed
    variable = c_o
    f_name = f_loc
    kappa_name = kappa_o
    w = w_o
    args = 'eta_c eta_o'
  [../]
  [./w_o_res]
    type = SplitCHWRes
    variable = w_o
    mob_name = M
  [../]
  [./time_o]
    type = CoupledTimeDerivative
    variable = w_o
    v = c_o
  [../]

  #Carbon order parameter
  [./deta_c_dt]
    type = TimeDerivative
    variable = eta_c
  [../]
  [./ACBulk_c]
    type = AllenCahn
    variable = eta_c
    args = 'c_c c_o eta_o'
    f_name = f_loc
    mob_name = L
  [../]
  [./ACInterface_c]
    type = ACMultiInterface
    variable = eta_c
    etas = 'eta_c eta_o'
    kappa_names = 'kappa_cc kappa_co'
  [../]
  [./penalty_c]
    type = SwitchingFunctionPenalty
    variable = eta_c
    etas    = 'eta_c eta_o'
    h_names = 'h_c   h_o'
  [../]

  # Oxygen order parameter
  [./deta_o_dt]
    type = TimeDerivative
    variable = eta_o
  [../]
  [./ACBulk_o]
    type = AllenCahn
    variable = eta_o
    args = 'c_c c_o eta_c'
    f_name = f_loc
    mob_name = L
  [../]
  [./ACInterface_o]
    type = ACMultiInterface
    variable = eta_o
    etas = 'eta_c eta_o'
    kappa_names = 'kappa_co kappa_oo'
  [../]
  [./penalty_o]
    type = SwitchingFunctionPenalty
    variable = eta_o
    etas    = 'eta_c eta_o'
    h_names = 'h_c   h_o'
  [../]
[]

[Materials]
  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_cc kappa_co kappa_oo'
    prop_values = '1 2 2 2'
  [../]

  [./constants_CH]
    type = GenericConstantMaterial
    prop_names  = 'M kappa_c kappa_o'
    prop_values = '0.01 0 0'
    #Smaller mob fixed negative composition on gas side
    #Increasing W brought it back, but symetric
  [../]

  [./eta_sum]
    type = ParsedMaterial
    f_name = etasum
    args = 'eta_c eta_o'
    material_property_names = 'h_c h_o'
    function = 'h_c+h_o'
  [../]

  [./switching_c]
    type = SwitchingFunctionMaterial
    function_name = h_c
    eta = 'eta_c'
    h_order =  HIGH
    outputs = exodus
    output_properties = h_c
  [../]

  [./switching_o]
    type = SwitchingFunctionMaterial
    function_name = h_o
    eta = 'eta_o'
    h_order =  HIGH
    outputs = exodus
    output_properties = h_o
  [../]

  [./barrier]
    type = MultiBarrierFunctionMaterial
    etas = 'eta_c eta_o'
    function_name = g
    g_order = SIMPLE
    outputs = exodus
    output_properties = g
  [../]

  #Carbon bulk free energy
  [./free_energy_f]
    type = DerivativeParsedMaterial
    f_name = f_f
    args = 'c_c c_o'
    constant_names = 'Ef_v kb T'
    constant_expressions = '4.0 8.6173303e-5 1000.0'
    function = 'kb*T*c_c*plog(c_c,1e-4) + (Ef_v*c_o + kb*T*c_o*plog(c_o,1e-4))'
    derivative_order = 2
    #outputs = exodus
  [../]

  #Oxygen gas phase free energy
  [./free_energy_g]
    type = DerivativeParsedMaterial
    f_name = f_g
    args = 'c_o'
    constant_names = 'A'
    constant_expressions = '1.0'
    function = 'A*0.5*((1-c_o)^2)'
    derivative_order = 2
    #outputs = exodus
  [../]

  [./free_energy_loc]
    type = DerivativeParsedMaterial
    f_name = f_loc
    constant_names = 'W'
    constant_expressions = '20.0'
    args = 'c_c c_o eta_c eta_o'
    material_property_names = 'h_c(eta_c) h_o(eta_o) g(eta_c) f_g(c_o) f_f(c_c)'
    function = 'h_c * f_g + (1 - h_o) * f_f + W * g'
    derivative_order = 2
    #outputs = exodus
  [../]

  [./conservation]
    type = ParsedMaterial
    args = 'c_c c_o'
    function = 'c_c + c_o'
    f_name = mass
    outputs = exodus
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

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

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    percent_change = 0.1
    dt = 1e-3
    initial_direction = 1
  [../]
[]

[Postprocessors]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = f_dens
  [../]
  [./dt]
    type = TimestepSize
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
