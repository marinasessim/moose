[Mesh]
  type = FileMesh
  file = sphere_mesh.e
  dim = 3
[]

[Problem]
  type = FEProblem
  coord_type = XYZ
[]

[AuxVariables]
  [./f_dens]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

[AuxKernels]
  [./f_dens]
    type = TotalFreeEnergy
    interfacial_vars = 'c eta'
    f_name = f_chem
    kappa_names = 'kappa_c kappa_eta'
    variable = f_dens
  [../]
[]

[Variables]
  [./c]
    order = FIRST
    family = LAGRANGE
  [../]

  [./w]
    order = FIRST
    family = LAGRANGE
  [../]

  [./eta]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  [./cIC]
    type = FunctionIC
    variable = c
    function = '0.5 + 0.05 * (cos(8*acos(z/100))*cos(15*atan(y/x)) + (cos(12*acos(z/100))*cos(10*atan(y/x)))^2 + cos(2.5*acos(z/100) - 1.5*atan(y/x))*cos(7*acos(z/100) -2*atan(y/x)))'
  [../]
[]

[Kernels]
  [./detadt]
    type = TimeDerivative
    variable = eta
  [../]

  [./ACBulk]
    type = AllenCahn
    variable = eta
    args = c
    f_name = f_chem
    mob_name = L

  [../]

  [./ACInterface]
    type = ACInterface
    variable = eta
    kappa_name = kappa_eta
  [../]

  [./c_c_res]
    type = SplitCHParsed
    variable = c
    f_name = f_chem
    kappa_name = kappa_c
    w = w
    args = eta
  [../]

  [./w_c_res]
    type = SplitCHWRes
    variable = w
    mob_name = M
  [../]

  [./time_c]
    type = CoupledTimeDerivative
    variable = w
    v = c
  [../]
[]

[Materials]
  [./constants_CH]
    type = GenericConstantMaterial
    prop_names  = 'L kappa_eta'
    prop_values = '1 2'
  [../]

  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'M kappa_c'
    prop_values = '5 2'
  [../]

  [./switching]
    type = SwitchingFunctionMaterial
    function_name = h
    eta = eta
    h_order = SIMPLE
  [../]

  [./barrier]
    type = BarrierFunctionMaterial
    function_name = g
    eta = eta
    g_order = SIMPLE
  [../]

  [./f_chem]
    type = DerivativeParsedMaterial
    f_name = f_chem
    constant_names = 'rho_s c_a c_b'
    args = 'c'
    constant_expressions = '5 0.3 0.7'
    function = 'rho_s * (c- c_a)^2 * (c_b - c)^2'
    derivative_order = 2
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

  dtmax = 1000
  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    percent_change = 0.2
    dt = 1
    initial_direction = 1
  [../]
[]

[Postprocessors]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = f_dens
  [../]
[]

[Outputs]
  [./Exodus]
    type = Exodus
    output_dimension = 3
  [../]
  exodus = true
  print_perf_log = true
[]

[Debug]
  show_var_residual_norms = true
[]
