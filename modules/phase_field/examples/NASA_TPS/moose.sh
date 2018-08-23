mv *.e-s* $trash

mpirun -np 8 ../../phase_field-opt -i fiber_oxidation_2D_v2.i
