[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1
  nz = 0
  xmax = 1.00
  elem_type = EDGE
  uniform_refine = 7
[]

[GlobalParams]
  block = 0
[]

[AuxVariables]
  [./total_energy]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./T]
    [./InitialCondition]
      type = FunctionIC
      variable = T
      function = 473
    [../]
  [../]
  [./xPu]
  [../]
  [./bnds]
  [../]
  [./elements]
  [../]
  [./etasum]
  [../]
[]

[AuxKernels]
  [./def_total_energy]
    type = KKSMultiFreeEnergy
    Fj_names         = ' f_aU f_zUPu f_gUPuZr'
    hj_names         = ' h_aU h_zUPu h_gUPuZr'
    gj_names         = ' g_aU g_zUPu g_gUPuZr'
    interfacial_vars = '   aU   zUPu   gUPuZr'
    kappa_names      = 'kappa  kappa    kappa'
    variable         = total_energy
    w                = 1.54e-2
  [../]
  [./def_xPu]
    type = ParsedAux
    variable   = xPu
    function   = '1-xU-xZr'
    args       = '  xU xZr'
    execute_on = 'initial timestep_end'
  [../]
  [./def_elements]
    type = ParsedAux
    variable   = elements
    function   = 'xU+xPu+xZr'
    args       = 'xU xPu xZr'
    execute_on = timestep_end
  [../]
  [./def_etasum]
    type = ParsedAux
    variable   = etasum
    function   = 'aU+zUPu+gUPuZr'
    args       = 'aU zUPu gUPuZr'
    execute_on = timestep_end
  [../]
[]

[Postprocessors]
  [./int_total_energy]
    type = ElementIntegralVariablePostprocessor
    variable = total_energy
    outputs = csv
  [../]
  [./total_xU]
    type = ElementIntegralVariablePostprocessor
    variable = xU
    outputs = csv
  [../]
  [./total_xPu]
    type = ElementIntegralVariablePostprocessor
    variable = xPu
    outputs = csv
  [../]
  [./total_xZr]
    type = ElementIntegralVariablePostprocessor
    variable = xZr
    outputs = csv
  [../]
  [./post_aU]
    type = ElementIntegralVariablePostprocessor
    variable = aU
    outputs = csv
  [../]
  [./post_zUPu]
    type = ElementIntegralVariablePostprocessor
    variable = zUPu
    outputs = csv
  [../]
  [./post_gUPuZr]
    type = ElementIntegralVariablePostprocessor
    variable = gUPuZr
    outputs = csv
  [../]
  [./detector]
    type = ChangeOverTimePostprocessor
    postprocessor = int_total_energy
    execute_on = timestep_end
  [../]
  [./etasum_max]
    type = ElementExtremeValue
    variable = etasum
    value_type = max
    execute_on = timestep_end
  [../]
  [./etasum_min]
    type = ElementExtremeValue
    variable = etasum
    value_type = min
    execute_on = timestep_end
  [../]
  [./elements_max]
    type = ElementExtremeValue
    variable = elements
    value_type = max
    outputs = csv
  [../]
  [./elements_min]
    type = ElementExtremeValue
    variable = elements
    value_type = min
    outputs = csv
  [../]
  [./timestep_size]
    type = TimestepSize
    outputs = csv
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
  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_shift_type'
  petsc_options_value = 'lu nonzero'
  scheme = bdf2
  l_max_its = 15
  l_tol = 1e-4
  nl_max_its = 200
  nl_rel_tol = 1e-9
  nl_abs_tol = 1e-9
  end_time = 1e6
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 1e-5
    iteration_window = 2
    optimal_iterations = 9
    growth_factor = 1.10
    cutback_factor = 0.75
  [../]
[]

[Outputs]
  execute_on = timestep_end
  exodus = true
  csv = true
  print_perf_log = true
[]

[Debug]
  show_var_residual_norms = false
[]

[Functions]
  [./f_aU]
    type = ParsedFunction
    value = 'if(x<(center-width/2),
             left,
             if(x>(center+width/2),
             right,
             left+(right-left)*(0.5+if(((((x-(center-width/2))/width)-0.5)*4)>0,1-1/(1+0.278393*((((x-(center-width/2))/width)-0.5)*4)+0.230389*((((x-(center-width/2))/width)-0.5)*4)^2+0.000972*((((x-(center-width/2))/width)-0.5)*4)^3+0.078108*((((x-(center-width/2))/width)-0.5)*4)^4)^4,-1*(1-1/(1+0.278393*abs((((x-(center-width/2))/width)-0.5)*4)+0.230389*abs((((x-(center-width/2))/width)-0.5)*4)^2+0.000972*abs((((x-(center-width/2))/width)-0.5)*4)^3+0.078108*abs((((x-(center-width/2))/width)-0.5)*4)^4)^4))/2)))'
    vars = 'center width left right'
    vals = '0.5    0.28  1.00 0.00'
  [../]
  [./f_zUPu]
    type = ParsedFunction
    value = 'if(x<(center-width/2),
             left,
             if(x>(center+width/2),
             right,
             left+(right-left)*(0.5+if(((((x-(center-width/2))/width)-0.5)*4)>0,1-1/(1+0.278393*((((x-(center-width/2))/width)-0.5)*4)+0.230389*((((x-(center-width/2))/width)-0.5)*4)^2+0.000972*((((x-(center-width/2))/width)-0.5)*4)^3+0.078108*((((x-(center-width/2))/width)-0.5)*4)^4)^4,-1*(1-1/(1+0.278393*abs((((x-(center-width/2))/width)-0.5)*4)+0.230389*abs((((x-(center-width/2))/width)-0.5)*4)^2+0.000972*abs((((x-(center-width/2))/width)-0.5)*4)^3+0.078108*abs((((x-(center-width/2))/width)-0.5)*4)^4)^4))/2)))'
    vars = 'center width left right'
    vals = '0.5    0.28  0.00 1.00'
  [../]
  [./f_xU]
    type = ParsedFunction
    value = 'if(x<(center-width/2),
             left,
             if(x>(center+width/2),
             right,
             left+(right-left)*(0.5+if(((((x-(center-width/2))/width)-0.5)*4)>0,1-1/(1+0.278393*((((x-(center-width/2))/width)-0.5)*4)+0.230389*((((x-(center-width/2))/width)-0.5)*4)^2+0.000972*((((x-(center-width/2))/width)-0.5)*4)^3+0.078108*((((x-(center-width/2))/width)-0.5)*4)^4)^4,-1*(1-1/(1+0.278393*abs((((x-(center-width/2))/width)-0.5)*4)+0.230389*abs((((x-(center-width/2))/width)-0.5)*4)^2+0.000972*abs((((x-(center-width/2))/width)-0.5)*4)^3+0.078108*abs((((x-(center-width/2))/width)-0.5)*4)^4)^4))/2)))'
    vars = 'center width left right'
    vals = '0.5    0.28  0.95 0.65'
  [../]
[]

[Variables]
  # m phases = 3
  [./aU]
    [./InitialCondition]
      type = FunctionIC
      function = f_aU
    [../]
  [../]
  [./zUPu]
    [./InitialCondition]
      type = FunctionIC
      function = f_zUPu
    [../]
  [../]
  [./gUPuZr]
    [./InitialCondition]
      type = ConstantIC
      value = 1e-6
    [../]
  [../]

  # n concentrations (and associated chemical potentials) = 2
  [./xU]
    [./InitialCondition]
      type = FunctionIC
      function = f_xU
    [../]
  [../]
  [./wU]
  [../]
  [./xZr]
    [./InitialCondition]
      type = ConstantIC
      value = 0.00
    [../]
  [../]
  [./wZr]
  [../]

  # m x n sub-concentrations = 6
  [./xU_aU]
    [./InitialCondition]
      type = ConstantIC
      value = 0.95
    [../]
  [../]
  [./xU_zUPu]
    [./InitialCondition]
      type = ConstantIC
      value = 0.65
    [../]
  [../]
  [./xU_gUPuZr]
    [./InitialCondition]
      type = ConstantIC
      value = 0.00
    [../]
  [../]
  [./xZr_aU]
    [./InitialCondition]
      type = ConstantIC
      value = 0.00
    [../]
  [../]
  [./xZr_zUPu]
    [./InitialCondition]
      type = ConstantIC
      value = 0.00
    [../]
  [../]
  [./xZr_gUPuZr]
    [./InitialCondition]
      type = ConstantIC
      value = 0.00
    [../]
  [../]

  # 1 constraint for multi-phase
  [./lambda]
  [../]
[]

[BCs]
[]

[Kernels]
  # 1 + m constraints for multi-phase = 4
  [./lambda_lagrange]
    # ======================================================LAGRANGE_CONSTRAINT
    type = SwitchingFunctionConstraintLagrange
    variable = lambda
    etas     = '  aU   zUPu   gUPuZr'
    h_names  = 'h_aU h_zUPu h_gUPuZr'
    epsilon  = 1e-7
  [../]
  [./aU_lagrange]
    type = SwitchingFunctionConstraintEta
    variable =   aU
    h_name   = h_aU
    lambda   = lambda
  [../]
  [./zUPu_lagrange]
    type = SwitchingFunctionConstraintEta
    variable =   zUPu
    h_name   = h_zUPu
    lambda   = lambda
  [../]
  [./gUPuZr_lagrange]
    type = SwitchingFunctionConstraintEta
    variable =   gUPuZr
    h_name   = h_gUPuZr
    lambda   = lambda
  [../]

  # n constraints to sum sub-concentrations to concentrations = 2
  [./xU_kks_conc]
    # ==========================================================KKS_CONSTRAINTS
    type = KKSMultiPhaseConcentration
    variable = xU_gUPuZr
    cj       = 'xU_aU xU_zUPu xU_gUPuZr'
    hj_names = ' h_aU  h_zUPu  h_gUPuZr'
    etas     = '   aU    zUPu    gUPuZr'
    c        = xU
  [../]
  [./xZr_kks_conc]
    type = KKSMultiPhaseConcentration
    variable = xZr_gUPuZr
    cj       = 'xZr_aU xZr_zUPu xZr_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    etas     = '    aU     zUPu     gUPuZr'
    c        = xZr
  [../]

  # m - 1 constraints to enforce equality of phase chemical potentials
  # with respect to xU sub-concentrations = 2
  [./xU_kks_chempot1]
    type = KKSPhaseChemicalPotential
    variable = xU_aU
    fa_name  = f_aU
    args_a   = 'T xU_aU xZr_aU'
    cb       = xU_zUPu
    fb_name  = f_zUPu
    args_b   = 'T xU_zUPu xZr_zUPu'
  [../]
  [./xU_kks_chempot2]
    type = KKSPhaseChemicalPotential
    variable = xU_zUPu
    fa_name  = f_zUPu
    args_a   = 'T xU_zUPu xZr_zUPu'
    cb       = xU_gUPuZr
    fb_name  = f_gUPuZr
    args_b   = 'T xU_gUPuZr xZr_gUPuZr'
  [../]

  # m - 1 constraints to enforce equality of phase chemical potentials
  # with respect to xZr sub-concentrations = 2
  [./xZr_kks_chempot1]
    type = KKSPhaseChemicalPotential
    variable = xZr_aU
    fa_name  = f_aU
    args_a   = 'T xU_aU xZr_aU'
    cb       = xZr_zUPu
    fb_name  = f_zUPu
    args_b   = 'T xU_zUPu xZr_zUPu'
  [../]
  [./xZr_kks_chempot2]
    type = KKSPhaseChemicalPotential
    variable = xZr_zUPu
    fa_name  = f_zUPu
    args_a   = 'T xU_zUPu xZr_zUPu'
    cb       = xZr_gUPuZr
    fb_name  = f_gUPuZr
    args_b   = 'T xU_gUPuZr xZr_gUPuZr'
  [../]

  # 3 * n kernels for split CH equation = 6
  [./xU_CH_cres]
    # ====================================================================xU_CH
    type = KKSSplitCHCRes
    variable = xU
    w        = wU
    h_name   = h_aU
    ca       = xU_zUPu
    fa_name  = f_zUPu
    args_a   = 'T xU_zUPu xZr_zUPu'
    cb       = xU_aU
    fb_name  = f_aU
  [../]
  [./xU_CH_wres]
    type = SplitCHWRes
    variable = wU
    mob_name = M_U
  [../]
  [./xU_CH_dt]
    type = CoupledTimeDerivative
    variable = wU
    v        = xU
  [../]
  [./xZr_CH_cres]
    # ===================================================================xZr_CH
    type = KKSSplitCHCRes
    variable = xZr
    w        = wZr
    h_name   = h_aU
    ca       = xZr_zUPu
    fa_name  = f_zUPu
    args_a   = 'T xU_zUPu xZr_zUPu'
    cb       = xZr_aU
    fb_name  = f_aU
  [../]
  [./xZr_CH_wres]
    type = SplitCHWRes
    variable = wZr
    mob_name = M_Zr
  [../]
  [./xZr_CH_dt]
    type = CoupledTimeDerivative
    variable = wZr
    v        = xZr
  [../]

  # m * 5 kernels for AC equation: aU
  [./aU_AC_bulk_F]
    # ====================================================================aU_AC
    type = KKSMultiACBulkF
    variable = aU
    eta_i    = aU
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    gi_name  = g_aU
    args     = ' xU_aU  xU_zUPu  xU_gUPuZr
                xZr_aU xZr_zUPu xZr_gUPuZr
                           zUPu     gUPuZr'
    mob_name = L
    wi       = 1.54e-2
  [../]
  [./aU_AC_bulk_xU]
    type = KKSMultiACBulkC
    variable = aU
    eta_i    = aU
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    cj_names = ' xU_aU  xU_zUPu  xU_gUPuZr'
    args     = 'xZr_aU xZr_zUPu xZr_gUPuZr
                           zUPu     gUPuZr'
  [../]
  [./aU_AC_bulk_xZr]
    type = KKSMultiACBulkC
    variable = aU
    eta_i    = aU
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    cj_names = 'xZr_aU xZr_zUPu xZr_gUPuZr'
    args     = ' xU_aU  xU_zUPu  xU_gUPuZr
                           zUPu     gUPuZr'
  [../]
  [./aU_AC_int]
    type = ACInterface
    variable   = aU
    mob_name   = L
    kappa_name = kappa
  [../]
  [./aU_AC_dt]
    type = TimeDerivative
    variable = aU
  [../]

  # m * 5 kernels for AC equation: zUPu
  [./zUPu_AC_bulk_F]
    # ==================================================================zUPu_AC
    type = KKSMultiACBulkF
    variable = zUPu
    eta_i    = zUPu
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    gi_name  = g_zUPu
    args     = ' xU_aU  xU_zUPu  xU_gUPuZr
                xZr_aU xZr_zUPu xZr_gUPuZr
                    aU              gUPuZr'
    mob_name = L
    wi       = 1.54e-2
  [../]
  [./zUPu_AC_bulk_xU]
    type = KKSMultiACBulkC
    variable = zUPu
    eta_i    = zUPu
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    cj_names = ' xU_aU  xU_zUPu  xU_gUPuZr'
    args     = 'xZr_aU xZr_zUPu xZr_gUPuZr
                    aU              gUPuZr'
  [../]
  [./zUPu_AC_bulk_xZr]
    type = KKSMultiACBulkC
    variable = zUPu
    eta_i    = zUPu
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    cj_names = 'xZr_aU xZr_zUPu xZr_gUPuZr'
    args     = ' xU_aU  xU_zUPu  xU_gUPuZr
                    aU              gUPuZr'
  [../]
  [./zUPu_AC_int]
    type = ACInterface
    variable   = zUPu
    mob_name   = L
    kappa_name = kappa
  [../]
  [./zUPu_AC_dt]
    type = TimeDerivative
    variable = zUPu
  [../]

  # m * 5 kernels for AC equation: gUPuZr
  [./gUPuZr_AC_bulk_F]
    # ================================================================gUPuZr_AC
    type = KKSMultiACBulkF
    variable = gUPuZr
    eta_i    = gUPuZr
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    gi_name  = g_gUPuZr
    args     = ' xU_aU  xU_zUPu  xU_gUPuZr
                xZr_aU xZr_zUPu xZr_gUPuZr
                    aU     zUPu'
    mob_name = L
    wi       = 1.54e-2
  [../]
  [./gUPuZr_AC_bulk_xU]
    type = KKSMultiACBulkC
    variable = gUPuZr
    eta_i    = gUPuZr
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    cj_names = ' xU_aU  xU_zUPu  xU_gUPuZr'
    args     = 'xZr_aU xZr_zUPu xZr_gUPuZr
                    aU     zUPu'
  [../]
  [./gUPuZr_AC_bulk_xZr]
    type = KKSMultiACBulkC
    variable = gUPuZr
    eta_i    = gUPuZr
    Fj_names = '  f_aU   f_zUPu   f_gUPuZr'
    hj_names = '  h_aU   h_zUPu   h_gUPuZr'
    cj_names = 'xZr_aU xZr_zUPu xZr_gUPuZr'
    args     = ' xU_aU  xU_zUPu  xU_gUPuZr
                    aU     zUPu'
  [../]
  [./gUPuZr_AC_int]
    type = ACInterface
    variable   = gUPuZr
    mob_name   = L
    kappa_name = kappa
  [../]
  [./gUPuZr_AC_dt]
    type = TimeDerivative
    variable = gUPuZr
  [../]
[]

[Materials]
  [./kappas]
    # ===================================================================KAPPAS
    type = GenericConstantMaterial
    prop_names = kappa
    prop_values = 1.17e-5
  [../]
  [./mobilities]
    # ===============================================================MOBILITIES
    type = GenericConstantMaterial
    prop_names = ' M_U     M_Zr    L'
    prop_values = '1.00e-3 1.00e-3 1.00e-0'
  [../]
  [./constants_and_conversions]
    # ================================================CONSTANTS_AND_CONVERSIONS
    # R is in [J/K/mol]
    # molar masses are in [g/mol] and taken from http://www.lenntech.com/calculators/molecular/molecular-weight-calculator.htm
    type = GenericConstantMaterial
    prop_names = ' R         nJ_J um_m Wm_U   Wm_Pu  Wm_Zr'
    prop_values = '8.3144598 1e9  1e6  238.03 244.00 91.22'
  [../]
  [./molar_volumes]
    # ============================================================MOLAR_VOLUMES
    type = GenericConstantMaterial
    prop_names = Vm_ref
    prop_values = 1.21e-5
  [../]
  [./h_aU]
    # ================================================================SWITCHING
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = aU
    function_name = h_aU
  [../]
  [./h_zUPu]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = zUPu
    function_name = h_zUPu
  [../]
  [./h_gUPuZr]
    type = SwitchingFunctionMaterial
    h_order = HIGH
    eta = gUPuZr
    function_name = h_gUPuZr
  [../]
  [./g_aU]
    # ==================================================================BARRIER
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = aU
    function_name = g_aU
  [../]
  [./g_zUPu]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = aU
    function_name = g_zUPu
  [../]
  [./g_gUPuZr]
    type = BarrierFunctionMaterial
    g_order = SIMPLE
    eta = gUPuZr
    function_name = g_gUPuZr
  [../]
  [./ghser_aU]
    # ====================================================================GHSER
    # all ghser free energy fits are in [J/mol] and are from the SGTE TDB
    type = DerivativeParsedMaterial
    f_name = ghser_aU
    function = 'if(T>=298.15&T<955.0,-4.42605e-6*T^3+0.00125156*T^2-26.9182*T*log(T)+130.955151*T-8407.734+38568/T,if(T>=955.0&T<3000.0,-48.66*T*log(T)+292.121093*T-22521.8,0))'
    args = T
    enable_auto_optimize = false
    derivative_order = 2
  [../]
  [./ghser_gU]
    type = DerivativeParsedMaterial
    f_name = ghser_gU
    function = 'if(T>=298.15&T<1049.0,9.67907e-7*T^3-0.00835595*T^2-27.5152*T*log(T)+131.5381*T-752.767+204611/T,if(T>=1049.0&T<3000.0,-38.2836*T*log(T)+202.685635*T-4698.365,0))'
    args = T
    enable_auto_optimize = false
    derivative_order = 2
  [../]
  [./ghser_bPu]
    type = DerivativeParsedMaterial
    f_name = ghser_bPu
    function = 'if(T>=298.15&T<679.5,-0.00653*T^2-27.416*T*log(T)+123.249151*T-4873.654,if(T>=679.5&T<1464.0,1.524942e-6*T^3-0.0154772*T^2-15.7351*T*log(T)+43.566585*T+2435.094-864940/T,if(T>=1464.0&T<3000.0,-42.248*T*log(T)+228.221615*T-13959.062,0)))'
    args = T
    enable_auto_optimize = false
    derivative_order = 2
  [../]
  [./ghser_ePu]
    type = DerivativeParsedMaterial
    f_name = ghser_ePu
    function = 'if(T>=298.15&T<745.0,2.061667e-6*T^3-0.009105*T^2-27.094*T*log(T)+116.603882*T-1358.984+20863/T,if(T>=745.0&T<956.0,-33.72*T*log(T)+156.878957*T-2890.817,if(T>=956.0&T<2071.0,1.426922e-6*T^3-0.02023305*T^2+6.921*T*log(T)-132.788248*T+29313.619-4469245/T,if(T>=2071.0&T<3000.0,-42.248*T*log(T)+227.421855*T-15400.585,0))))'
    args = T
    enable_auto_optimize = false
    derivative_order = 2
  [../]
  [./ghser_aZr]
    type = DerivativeParsedMaterial
    f_name = ghser_aZr
    function = 'if(T>=130.0&T<2128.0,-0.00437791*T^2-24.1618*T*log(T)+125.64905*T-7827.595+34971/T,if(T>=2128.0&T<6000.0,-42.144*T*log(T)+262.724183*T-26085.921-1.342896e+31/T^9,0))'
    args = T
    enable_auto_optimize = false
    derivative_order = 2
  [../]
  [./ghser_bZr]
    type = DerivativeParsedMaterial
    f_name = ghser_bZr
    function = 'if(T>=298.15&T<2128.0,-7.6143e-11*T^4-9.729e-9*T^3-0.000340084*T^2-25.607406*T*log(T)+124.9457*T-525.539+25233/T,if(T>=2128.0&T<6000.0,-42.144*T*log(T)+264.284163*T-30705.955+1.276058e+32/T^9,0))'
    args = T
    enable_auto_optimize = false
    derivative_order = 2
  [../]
  [./f_aU]
    # ============================================================FREE_ENERGIES
    # phase free energies are calculated in [J/mol] and converted to [nJ/um^3]
    type = DerivativeParsedMaterial
    f_name = f_aU
    function = 'nJ_J/Vm_ref/(um_m)^3*(
                xU_aU*ghser_aU+(1-xU_aU-xZr_aU)*(652.7+ghser_bPu)+xZr_aU*(5000+ghser_aZr)
                +R*T*(xU_aU*plog(xU_aU,1e-7)+(1-xU_aU-xZr_aU)*plog((1-xU_aU-xZr_aU),1e-7)+xZr_aU*plog(xZr_aU,1e-7))
                +(1-xU_aU-xZr_aU)*xU_aU*(6176.5)
                +xU_aU*xZr_aU*(25802)
                +(1-xU_aU-xZr_aU)*xZr_aU*(30000))'
    args = 'T xU_aU xZr_aU'
    material_property_names = 'nJ_J Vm_ref um_m ghser_aU(T) ghser_bPu(T) ghser_aZr(T) R'
    derivative_order = 2
  [../]
  [./f_zUPu]
    type = DerivativeParsedMaterial
    f_name = f_zUPu
    function = 'nJ_J/Vm_ref/(um_m)^3*(
                xU_zUPu*(337.8+ghser_gU)+(1-xU_zUPu-xZr_zUPu)*(500+ghser_bPu)+xZr_zUPu*(6000+ghser_bZr)
                +R*T*(xU_zUPu*plog(xU_zUPu,1e-7)+(1-xU_zUPu-xZr_zUPu)*plog((1-xU_zUPu-xZr_zUPu),1e-7)+xZr_zUPu*plog(xZr_zUPu,1e-7))
                +(1-xU_zUPu-xZr_zUPu)*xU_zUPu*((a1+a2*T)+(b1+b2*T)*((1-xU_zUPu-xZr_zUPu)-xU_zUPu)+(c1+c2*T)*((1-xU_zUPu-xZr_zUPu)-xU_zUPu)^2)
                +xU_zUPu*xZr_zUPu*(15000)
                +(1-xU_zUPu-xZr_zUPu)*xZr_zUPu*(5000))'
    args = 'T xU_zUPu xZr_zUPu'
    material_property_names = 'nJ_J Vm_ref um_m ghser_gU(T) ghser_bPu(T) ghser_bZr(T) R'
    constant_names = '      a1      a2     b1     b2      c1      c2'
    constant_expressions = '-1.50e4 1.55e1 2.00e4 -2.50e1 -1.20e4 8.00e0'
    derivative_order = 2
  [../]
  [./f_gUPuZr]
    type = DerivativeParsedMaterial
    f_name = f_gUPuZr
    function = 'nJ_J/Vm_ref/(um_m)^3*(
                xU_gUPuZr*ghser_gU+(1-xU_gUPuZr-xZr_gUPuZr)*ghser_ePu+xZr_gUPuZr*ghser_bZr
                +R*T*(xU_gUPuZr*plog(xU_gUPuZr,1e-7)+(1-xU_gUPuZr-xZr_gUPuZr)*plog((1-xU_gUPuZr-xZr_gUPuZr),1e-7)+xZr_gUPuZr*plog(xZr_gUPuZr,1e-7))
                +(1-xU_gUPuZr-xZr_gUPuZr)*xU_gUPuZr*((19374-17.250*T)+(-4939.5)*((1-xU_gUPuZr-xZr_gUPuZr)-xU_gUPuZr))
                +xU_gUPuZr*xZr_gUPuZr*((57907-45.448*T)+(6004.2)*(xU_gUPuZr-xZr_gUPuZr)+(1575.8)*(xU_gUPuZr-xZr_gUPuZr)^2)
                +(1-xU_gUPuZr-xZr_gUPuZr)*xZr_gUPuZr*((5730.0-3.4108*T)+(2759.7)*((1-xU_gUPuZr-xZr_gUPuZr)-xZr_gUPuZr)+(2081.5)*((1-xU_gUPuZr-xZr_gUPuZr)-xZr_gUPuZr)^2))'
    args = 'T xU_gUPuZr xZr_gUPuZr'
    material_property_names = 'nJ_J Vm_ref um_m ghser_gU(T) ghser_ePu(T) ghser_bZr(T) R'
    derivative_order = 2
  [../]
[]
