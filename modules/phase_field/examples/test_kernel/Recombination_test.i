#
# Test the non-split parsed function free enery Cahn-Hilliard Bulk kernel
# The free energy used here has the same functional form as the CHPoly kernel
# If everything works, the output of this test should replicate the output
# of marmot/tests/chpoly_test/CHPoly_test.i (exodiff match)
#

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmax = 10
  nx = 20
  ymax = 10
  ny = 20
  elem_type = QUAD4
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
    interfacial_vars = 'c_a'
    f_name = F
    kappa_names = 'kappa_c'
    variable = f_dens
  [../]
[]

[Variables]
  [./c_a]
    order = THIRD
    family = HERMITE
    [./InitialCondition]
      type = BoundingBoxIC
      x1 = 0
      y1 = 0
      x2 = 5.0
      y2 = 10.0
      inside = 1
      outside = 0.1
    [../]
  [../]
[]

[Kernels]
  [./ie_c]
    type = TimeDerivative
    variable = c_a
  [../]
  [./CHSolid]
    type = CahnHilliard
    variable = c_a
    f_name = F
    mob_name = M
  [../]
  [./CHInterface]
    type = CHInterface
    variable = c_a
    mob_name = M
    kappa_name = kappa_c
  [../]
[]



[Materials]
  [./CH_constants]
    type = GenericConstantMaterial
    prop_names  = 'M kappa_c'
    prop_values = '1 0.1'
  [../]
  [./free_energy]
    type = DerivativeParsedMaterial
    f_name = F
    args = 'c_a'
    function = '(1-c_a)^2 * (1+c_a)^2'
  [../]
[]

[Executioner]
  type = Transient
  scheme = 'bdf2'

  solve_type = 'NEWTON'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 31'

  l_max_its = 15
  l_tol = 1.0e-4
  nl_max_its = 10
  nl_rel_tol = 1.0e-11

  start_time = 0.0
  num_steps = 5
  dt = 0.1
[]

[Postprocessors]
  [./dt]
    type = TimestepSize
  [../]
  [./c_a]
    type = ElementIntegralVariablePostprocessor
    variable = c_a
  [../]
  [./active_time]
    type = PerformanceData
    event =  ACTIVE
  [../]
[]

[Outputs]
  exodus = true
  console = true
[]
