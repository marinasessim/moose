# Exception test.
# Incorrect number of activation energies

[Mesh]
  type = GeneratedMesh
  dim = 1
[]

[Variables]
  [./a]
  [../]
  [./b]
  [../]
[]

[GlobalParams]
  PorousFlowDictator = dictator
[]

[Kernels]
  [./a]
    type = Diffusion
    variable = a
  [../]
  [./b]
    type = Diffusion
    variable = b
  [../]
[]

[UserObjects]
  [./dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'a b'
    number_fluid_phases = 1
    number_fluid_components = 3
    number_aqueous_kinetic = 1
  [../]
[]

[Modules]
  [./FluidProperties]
    [./simple_fluid]
      type = SimpleFluidProperties
    [../]
  [../]
[]

[AuxVariables]
  [./eqm_k]
    initial_condition = 1E-6
  [../]
  [./pressure]
  [../]
[]

[Materials]
  [./temperature_qp]
    type = PorousFlowTemperature
  [../]
  [./ppss_qp]
    type = PorousFlow1PhaseFullySaturated
    porepressure = pressure
  [../]
  [./massfrac_qp]
    type = PorousFlowMassFraction
    mass_fraction_vars = 'a b'
  [../]
  [./predis]
    type = PorousFlowAqueousPreDisChemistry
    at_nodes = false
    primary_concentrations = 'a b'
    num_reactions = 1
    equilibrium_constants = eqm_k
    primary_activity_coefficients = '1 1'
    reactions = '1 1'
    specific_reactive_surface_area = 1.0
    kinetic_rate_constant = 1.0e-8
    activation_energy = '1.5e4 1'
    molar_volume = 1
  [../]
  [./mineral]
    type = PorousFlowAqueousPreDisMineral
  [../]
  [./porosity_qp]
    type = PorousFlowPorosity
    porosity_zero = 0.1
  [../]
  [./simple_fluid_qp]
    type = PorousFlowSingleComponentFluid
    fp = simple_fluid
    phase = 0
  [../]
[]

[Executioner]
  type = Transient
  solve_type = Newton
  end_time = 1
[]
