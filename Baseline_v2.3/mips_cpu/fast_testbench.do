# fast_testbench.do
# Author: Zinsser Zhang
# Last Revision: 04/12/2018

# Compile the testbench
vlog -reportprogress 300 -work work ../../fast_testbench.sv

# Compile the simulation model of sdram
vlog -reportprogress 300 -work work ../../fast_sdram.sv

# Start the simulation of testbench with all the linking flags to other libs
vsim -t ns -L altera_mf_ver fast_testbench
