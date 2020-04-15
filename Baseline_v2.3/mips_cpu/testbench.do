# testbench.do
# Author: Zinsser Zhang
# Last Revision: 04/08/2018

# Compile the testbench
vlog -reportprogress 300 -work work ../../testbench.sv

# Compile the simulation model of sdram
vlog -reportprogress 300 -work work ../../ip/sdr_sdram/sdr.v

# Start the simulation of testbench with all the linking flags to other libs
vsim -t ns -L error_adapter_0 -L avalon_st_adapter -L sdram_controller_s1_rsp_width_adapter -L rsp_mux -L rsp_demux -L cmd_mux -L cmd_demux -L sdram_controller_s1_burst_adapter -L router_003 -L router -L sdram_controller_s1_agent_rsp_fifo -L sdram_controller_s1_agent -L d_cache_read_avalon_master_agent -L sdram_controller_s1_translator -L d_cache_read_avalon_master_translator -L rst_controller -L mm_interconnect_0 -L sdram_controller -L pll_0 -L d_cache_read -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver testbench
