# Example of using the IdealGasFluidPropertiesPT userobject to provide fluid
# properties for an ideal gas. Use values for hydrogen (H2) at 1 MPa and 50 C.
#
# Input values:
# Cv = 10260 J/kg/K
# Cp = 14400 J/kg/K
# M = 2.01588e-3 kg/mol
# viscosity = 9.4393e-6 Pa.s
#
# Expected output:
# density = 750.2854 kg/m^3
# internal energy = 3315.52e3 J/kg
# enthalpy = 4653.36e3 J/kg

[Mesh]
  type = GeneratedMesh
  dim = 1
  nx = 1
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'pp'
    number_fluid_phases = 1
    number_fluid_components = 1
  [../]
[]

[Variables]
  [./pp]
    initial_condition = 1e6
  [../]
[]

[Kernels]
  [./dummy]
    type = Diffusion
    variable = pp
  [../]
[]

[AuxVariables]
  [./temp]
    initial_condition = 50.0
  [../]
[]

[Modules]
  [./FluidProperties]
    [./idealgas]
      type = IdealGasFluidPropertiesPT
      molar_mass = 2.01588e-3
      cv = 10260
      cp = 14400
      viscosity = 9.4393e-6
    [../]
  [../]
[]

[Materials]
  [./temperature]
    type = PorousFlowTemperature
    at_nodes = false
    temperature = temp
  [../]
  [./ppss]
    type = PorousFlow1PhaseFullySaturated
    at_nodes = false
    porepressure = pp
  [../]
  [./idealgass]
    type = PorousFlowSingleComponentFluid
    at_nodes = false
    temperature_unit = Celsius
    fp = idealgas
    phase = 0
  [../]
[]

[Executioner]
  type = Steady
  solve_type = Newton
[]

[Postprocessors]
  [./pressure]
    type = ElementIntegralVariablePostprocessor
    variable = pp
  [../]
  [./temperature]
    type = ElementIntegralVariablePostprocessor
    variable = temp
  [../]
  [./density]
    type = ElementIntegralMaterialProperty
    mat_prop = 'PorousFlow_fluid_phase_density_qp0'
  [../]
  [./viscosity]
    type = ElementIntegralMaterialProperty
    mat_prop = 'PorousFlow_viscosity_qp0'
  [../]
  [./internal_energy]
    type = ElementIntegralMaterialProperty
    mat_prop = 'PorousFlow_fluid_phase_internal_energy_qp0'
  [../]
  [./enthalpy]
    type = ElementIntegralMaterialProperty
    mat_prop = 'PorousFlow_fluid_phase_enthalpy_qp0'
  [../]
[]

[Outputs]
  execute_on = 'timestep_end'
  file_base = ideal_gas
  csv = true
[]
