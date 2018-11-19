#------------------------------------------------------------------------------#
# C, O2, CO2, and CO
# 2 phases: solid and gas
# Phase-field action
# Status: WORKING
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
[Mesh]
  # length scale -> microns
  type = GeneratedMesh
  dim = 3
  xmin = 0
  xmax = 0.5
  nx = 5

  ymin = 0
  ymax = 0.5
  ny = 5

  zmin = 0
  zmax = 5
  nz = 50

  uniform_refine = 2
  elem_type = HEX8
  parallel_type = DISTRIBUTED
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
    interfacial_vars = 'x_C x_O2 x_CO x_CO2'
    kappa_names = 'kappa_C kappa_O2 kappa_CO kappa_CO2'
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
        args = 'x_O2 x_CO x_CO2 eta'
      [../]

      [./x_O2]
        solve_type = FORWARD_SPLIT
        kappa = kappa_O2
        free_energy = f_loc
        mobility = M_O2
        args = 'x_C x_CO x_CO2 eta'
      [../]

      [./x_CO]
        solve_type = FORWARD_SPLIT
        kappa = kappa_CO
        free_energy = f_loc
        mobility = M_CO
        args = 'x_O2 x_C x_CO2 eta'
      [../]

      [./x_CO2]
        solve_type = FORWARD_SPLIT
        kappa = kappa_CO2
        free_energy = f_loc
        mobility = M_CO2
        args = 'x_O2 x_C x_CO eta'
      [../]
    [../]

    [./Nonconserved]
      [./eta]
        kappa = kappa_eta
        mobility = L
        free_energy = f_loc
        args = 'x_C x_O2 x_CO x_CO2'
      [../]
    [../]
  [../]
[]

#------------------------------------------------------------------------------#
[Functions]
  # Radius for cap semi-sphere
  # Height without the cap
  [./func_O2]
    type = ParsedFunction
    vars = 'h R invalue outvalue'
    vals = '4 0.2 1e-4 0.209'
    value = 'if((z<h & sqrt(x^2+y^2)<R), invalue, outvalue)'
    #if(z>=h & sqrt(x^2+y^2+(z-h)^2)<R, invalue, outvalue)
  [../]

  [./func_C]
    type = ParsedFunction
    vars = 'h R invalue outvalue'
    vals = '4 0.2 0.99 1e-4'
    value = 'if((z<h & sqrt(x^2+y^2)<R), invalue, outvalue)'
  [../]

  [./func_CO2]
    type = ParsedFunction
    vars = 'h R invalue outvalue'
    vals = '4 0.2 1e-4 3e-4'
    value = 'if((z<h & sqrt(x^2+y^2)<R), invalue, outvalue)'
  [../]

  [./func_eta]
    type = ParsedFunction
    vars = 'h R invalue outvalue'
    vals = '4 0.2 0 1'
    value = 'if((z<h & sqrt(x^2+y^2)<R), invalue, outvalue)'
  [../]
[]

#------------------------------------------------------------------------------#
[ICs]
  # O2
  [./IC_x_O2]
    type = FunctionIC
    function = func_O2
    variable = x_O2
    #invalue = 1e-4
    #outvalue = 0.209
  [../]

  # C
  [./IC_x_C]
    type = FunctionIC
    function = func_C
    variable = x_C
    #invalue = 0.99
    #outvalue = 1e-4
  [../]

  # CO2
 [./IC_x_CO2]
   type = FunctionIC
   function = func_CO2
   variable = x_CO2
   #invalue = 1e-4
   #outvalue = 3e-4
 [../]

 # eta
 [./IC_eta]
   type = FunctionIC
   function = func_eta
   variable = eta
   #invalue = 0.0
   #outvalue = 1.0
 [../]
[]

#------------------------------------------------------------------------------#
[Kernels]
  # Reactants: Use Recombination kernel
  [./recomb_C]
    type = Recombination
    variable = x_C # Reactant 1
    v = x_O2 # Reactant 2
    mob_name = R_C # Reaction Rate (negative)
  [../]
  [./recomb_O2]
    type = Recombination
    variable = x_O2 # Reactant 1
    v = x_C # Reactant 2
    mob_name = R_O2 # Reaction Rate (negative)
  [../]

  # Products: Use Production kernel
  [./prod_CO]
    type = Production
    variable = x_CO # Product
    v = x_C # Reactant 1
    w = x_O2 # Reactant 2
    mob_name = P_CO # Reaction rate (positive)
  [../]
  [./prod_CO2]
    type = Production
    variable = x_CO2 # Product
    v = x_C # Reactant 1
    w = x_O2 # Reactant 2
    mob_name = P_CO2 # Reaction rate (positive)
  [../]
[]

#------------------------------------------------------------------------------#
[Materials]
  #----------------------------------------------------------------------------#
  [./R_O2] # Reactant
    type = DerivativeParsedMaterial
    f_name = R_O2
    args = 'x_O2 x_C'
    constant_names = 'L'
    constant_expressions = '-7.5'
    function = 'if(x_O2<0.0,0,if(x_C<0.0,0,L))'
    derivative_order = 1
    outputs = exodus
  [../]

  [./R_C] # Reactant
    type = DerivativeParsedMaterial
    f_name = R_C
    args = 'x_O2 x_C'
    constant_names = 'L'
    constant_expressions = '-10'
    function = 'if(x_O2<0.0,0,if(x_C<0.0,0,L))'
    derivative_order = 1
    outputs = exodus
  [../]

  [./P_CO] # Product
    type = DerivativeParsedMaterial
    f_name = P_CO
    args = 'x_O2 x_C'
    constant_names = 'L'
    constant_expressions = '5'
    function = 'if(x_O2<0.0,0,if(x_C<0.0,0,L))'
    derivative_order = 1
    outputs = exodus
  [../]

  [./P_CO2] # Product
    type = DerivativeParsedMaterial
    f_name = P_CO2
    args = 'x_O2 x_C'
    constant_names = 'L'
    constant_expressions = '5'
    function = 'if(x_O2<0.0,0,if(x_C<0.0,0,L))'
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
    h_order = HIGH
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
    constant_expressions = '100 1' #M_f = 0.1
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
  [./mobility_CO]
    type = DerivativeParsedMaterial
    f_name = M_CO
    material_property_names = h(eta)
    constant_names = 'M_g M_f'
    constant_expressions = '100 1'
    function = 'M_g'
    outputs = exodus
    output_properties = M_CO
  [../]
  [./kappa_CO]
    type = GenericConstantMaterial
    prop_names  = 'kappa_CO'
    prop_values = '0.5e-2'
  [../]

  #----------------------------------------------------------------------------#
  # CO2
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
  # Vacancy concentration
  [./vac_conc_mat] # Vacancy concentration in solid phase
    type = ParsedMaterial
    f_name = vac_conc
    args = 'x_C x_O2 x_CO x_CO2'
    material_property_names = 'h(eta)'
    function = '(1-h) * (1-x_C-x_O2-x_CO-x_CO2)'
    outputs = exodus
    output_properties = vac_conc
  [../]

  #----------------------------------------------------------------------------#
  # Gibbs energy of the solid phase
  [./free_energy_s]
    type = DerivativeParsedMaterial
    f_name = f_s
    args = 'x_C x_O2 x_CO x_CO2'
    constant_names = 'Ef_v kb T tol'
    constant_expressions = '4.0 8.6173303e-5 1000.0 1e-4'

    # NEVER EVER USE THE MATERIAL FOR VAC CONC
    # Parsed material vs. Derivi

    function  = 'kb*T*x_C*plog(x_C,tol)
              + (Ef_v*(1-x_C-x_O2-x_CO-x_CO2) + kb*T*(1-x_C-x_O2-x_CO-x_CO2)*plog((1-x_C-x_O2-x_CO-x_CO2),tol))
              + (2*Ef_v*x_O2 + kb*T*x_O2*plog(x_O2,tol))
              + (2*Ef_v*x_CO + kb*T*x_CO*plog(x_CO,tol))
              + (2*Ef_v*x_CO2 + kb*T*x_CO2*plog(x_CO2,tol))'

    derivative_order = 2
    #outputs = exodus
  [../]

  #----------------------------------------------------------------------------#
  # Gibbs energy of the gas phase
  [./free_energy_g]
    type = DerivativeParsedMaterial
    f_name = f_g
    args = 'x_O2 x_C x_CO x_CO2'
    constant_names =        'A_O2   A_C   A_CO  A_CO2   O2_eq   C_eq   CO_eq   CO2_eq'
    constant_expressions =  '1.0   20.0  1.0  1.0    0.209   0.0    3e-4    3e-4'

    function  ='A_O2/2.0 * (O2_eq - x_O2)^2
              + A_C/2.0 * (C_eq - x_C)^2
              + A_CO/2.0 * (CO_eq - x_CO)^2
              + A_CO2/2.0 * (CO2_eq - x_CO2)^2'

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
    args = 'x_C x_O2 x_CO x_CO2 eta'
    material_property_names = 'h(eta) g(eta) f_g(x_O2,x_C,x_CO,x_CO2) f_s(x_C,x_O2,x_CO,x_CO2)'

    function = 'h*f_g +(1-h)*f_s +W*g'

    derivative_order = 2
    #outputs = exodus
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

  nl_max_its = 20
  nl_rel_tol = 1.0e-8
  #nl_abs_tol = 1.0e-10

  dtmax = 1e-2
  dtmin = 1e-12
  end_time = 2

  [./Adaptivity]
    max_h_level = 3
    coarsen_fraction = 0.1
    refine_fraction = 0.5
  [../]

  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-6
    growth_factor = 10.0
    cutback_factor = 0.8
    optimal_iterations = 12
    iteration_window = 0


  [../]
[]

#------------------------------------------------------------------------------#
[Postprocessors]
  [./total_F]
    type = ElementIntegralVariablePostprocessor
    variable = f_dens
  [../]
  [./total_V]
    type = ElementIntegralVariablePostprocessor
    variable = x_V
    execute_on = 'INITIAL TIMESTEP_END'
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
  [./total_CO]
    type = ElementIntegralVariablePostprocessor
    variable = x_CO
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./total_CO2]
    type = ElementIntegralVariablePostprocessor
    variable = x_CO2
    execute_on = 'INITIAL TIMESTEP_END'
  [../]
  [./dt]
    type = TimestepSize
  [../]
  [./alive_time]
    type = PerformanceData
    event = ALIVE
  [../]
[]

#------------------------------------------------------------------------------#
[Outputs]
  exodus = true
  csv = true
  perf_graph = true
  file_base = ./multi_3D_v1/fiber_oxidation_multi_3D_v1_out
[]

#------------------------------------------------------------------------------#
[Debug]
  show_var_residual_norms = true
[]
