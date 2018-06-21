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

  [./bnds]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[AuxKernels]
  [./f_dens]
    type = TotalFreeEnergy
    interfacial_vars = 'c eta_1 eta_2 eta_3 eta_4'
    f_name = f_chem
    kappa_names = 'kappa_c kappa_eta kappa_eta kappa_eta kappa_eta'
    variable = f_dens
  [../]

  [./bnds_aux]
    type = BndsCalcAux
    variable = bnds
    execute_on = timestep_end
    v = 'eta_1 eta_2 eta_3 eta_4'
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

  [./eta_1]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta_2]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta_3]
    order = FIRST
    family = LAGRANGE
  [../]
  [./eta_4]
    order = FIRST
    family = LAGRANGE
  [../]
[]

[ICs]
  [./cIC]
    type = FunctionIC
    variable = c
    function = '0.5+0.05*(cos(8*acos(z/100))*cos(15*atan(y/x))+(cos(12*acos(z/100))*cos(10*atan(y/x)))^2+cos(2.5*acos(z/100)-1.5*atan(y/x))*cos(7*acos(z/100)-2*atan(y/x)))'
  [../]

  [./eta_1_IC]
    type = FunctionIC
    variable = eta_1
    function = '0.1*(cos(1*acos(z/100)-4)*cos((0.7+1)*atan(y/x))+cos((11+1)*acos(z/100))*cos((11+1)*atan(y/x))+1.5*(cos((4.6+0.1*1)*acos(z/100)+(4.05+0.1*1)*atan(y/x))*cos((3.1+0.1*1)*acos(z/100)-(0.4+0.1*1)*atan(y/x)))^2)^2'
  [../]

  [./eta_2_IC]
    type = FunctionIC
    variable = eta_2
    function = '0.1*(cos(2*acos(z/100)-4)*cos((0.7+2)*atan(y/x))+cos((11+2)*acos(z/100))*cos((11+2)*atan(y/x))+1.5*(cos((4.6+0.1*2)*acos(z/100)+(4.05+0.1*2)*atan(y/x))*cos((3.1+0.1*2)*acos(z/100)-(0.4+0.1*2)*atan(y/x)))^2)^2'
  [../]

  [./eta_3_IC]
    type = FunctionIC
    variable = eta_3
    function = '0.1*(cos(3*acos(z/100)-4)*cos((0.7+3)*atan(y/x))+cos((11+3)*acos(z/100))*cos((11+3)*atan(y/x))+1.5*(cos((4.6+0.1*3)*acos(z/100)+(4.05+0.1*3)*atan(y/x))*cos((3.1+0.1*3)*acos(z/100)-(0.4+0.1*3)*atan(y/x)))^2)^2'
  [../]

  [./eta_4_IC]
    type = FunctionIC
    variable = eta_4
    function = '0.1*(cos(4*acos(z/100)-4)*cos((0.7+4)*atan(y/x))+cos((11+4)*acos(z/100))*cos((11+4)*atan(y/x))+1.5*(cos((4.6+0.1*4)*acos(z/100)+(4.05+0.1*4)*atan(y/x))*cos((3.1+0.1*4)*acos(z/100)-(0.4+0.1*4)*atan(y/x)))^2)^2'
  [../]
[]

[Kernels]
  [./detadt1]
    type = TimeDerivative
    variable = 'eta_1'
  [../]

  [./ACBulk1]
    type = AllenCahn
    variable = 'eta_1'
    args = 'c eta_2 eta_3 eta_4'
    f_name = f_chem
    mob_name = L
  [../]

  [./ACInterface1]
    type = ACInterface
    variable = 'eta_1'
    kappa_name = kappa_eta
  [../]

  [./detadt2]
    type = TimeDerivative
    variable = 'eta_2'
  [../]

  [./ACBulk2]
    type = AllenCahn
    variable = 'eta_2'
    args = 'c eta_1 eta_3 eta_4'
    f_name = f_chem
    mob_name = L
  [../]

  [./ACInterface2]
    type = ACInterface
    variable = 'eta_2'
    kappa_name = kappa_eta
  [../]

  [./detadt3]
    type = TimeDerivative
    variable = 'eta_3'
  [../]

  [./ACBulk3]
    type = AllenCahn
    variable = 'eta_3'
    args = 'c eta_1 eta_2 eta_4'
    f_name = f_chem
    mob_name = L
  [../]

  [./ACInterface3]
    type = ACInterface
    variable = 'eta_3'
    kappa_name = kappa_eta
  [../]

  [./detadt4]
    type = TimeDerivative
    variable = 'eta_4'
  [../]

  [./ACBulk4]
    type = AllenCahn
    variable = 'eta_4'
    args = 'c eta_1 eta_2 eta_3'
    f_name = f_chem
    mob_name = L
  [../]

  [./ACInterface4]
    type = ACInterface
    variable = 'eta_4'
    kappa_name = kappa_eta
  [../]

  [./c_c_res]
    type = SplitCHParsed
    variable = c
    f_name = f_chem
    kappa_name = kappa_c
    w = w
    args = 'eta_1 eta_2 eta_3 eta_4'
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
    prop_values = '5 3'
  [../]

  [./constants_AC]
    type = GenericConstantMaterial
    prop_names  = 'M kappa_c'
    prop_values = '5 3'
  [../]

  [./switching]
    type = DerivativeParsedMaterial
    f_name = h
    args = 'eta_1 eta_2 eta_3 eta_4'
    function = 'eta_1^3*(6.0*eta_1^2 -15.0*eta_1 +10.0) +eta_2^3*(6.0*eta_2^2 -15.0*eta_2 +10.0) +eta_3^3*(6.0*eta_3^2 -15.0*eta_3 +10.0) +eta_4^3*(6.0*eta_4^2 -15.0*eta_4 +10.0)'
  [../]

  [./barrier]
    type = DerivativeParsedMaterial
    f_name = g
    args = 'eta_1 eta_2 eta_3 eta_4'
    constant_names = 'alpha'
    constant_expressions = '5'
    function = 'eta_1^2*(1-eta_1)^2 + eta_2^2*(1-eta_2)^2 +eta_3^2*(1-eta_3)^2 +eta_4^2*(1-eta_4)^2 + alpha*(2*eta_1^2*eta_2^2 +2*eta_1^2*eta_3^2 +2*eta_1^2*eta_4^2 + 2*eta_2^2*eta_3^2 +2*eta_2^2*eta_4^2 +2*eta_3^2*eta_4^2)'
  [../]

  [./f_a]
    type = DerivativeParsedMaterial
    f_name = f_a
    args = 'c'
    constant_names = 'rho c_a'
    constant_expressions = '2 0.3'
    function = 'rho * (c - c_a)^2'
    derivative_order = 2
  [../]

  [./f_b]
    type = DerivativeParsedMaterial
    f_name = f_b
    args = 'c'
    constant_names = 'rho c_b'
    constant_expressions = '2 0.7'
    function = 'rho * (c - c_b)^2'
    derivative_order = 2
  [../]

  [./f_chem]
    type = DerivativeParsedMaterial
    f_name = f_chem
    constant_names = 'W'
    constant_expressions = '1.0'
    args = 'c eta_1 eta_2 eta_3 eta_4'
    material_property_names = 'h(eta_1,eta_2,eta_3,eta_4) g(eta_1,eta_2,eta_3,eta_4) f_a(c) f_b(c)'
    function = 'h * f_b + (1 - h) * f_a + W * g'
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

  dtmax = 1e6

  [./TimeStepper]
    type = SolutionTimeAdaptiveDT
    percent_change = 0.2
    dt = 1
    initial_direction = 1
  [../]
[]

[Postprocessors]
  [./dt]
    type = TimestepSize
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
