transcript on
if ![file isdirectory mips_cpu_iputf_libs] {
	file mkdir mips_cpu_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
vlib mips_cpu_iputf_libs/error_adapter_0
vmap error_adapter_0 ./mips_cpu_iputf_libs/error_adapter_0
vlib mips_cpu_iputf_libs/avalon_st_adapter
vmap avalon_st_adapter ./mips_cpu_iputf_libs/avalon_st_adapter
vlib mips_cpu_iputf_libs/sdram_controller_s1_rsp_width_adapter
vmap sdram_controller_s1_rsp_width_adapter ./mips_cpu_iputf_libs/sdram_controller_s1_rsp_width_adapter
vlib mips_cpu_iputf_libs/rsp_mux
vmap rsp_mux ./mips_cpu_iputf_libs/rsp_mux
vlib mips_cpu_iputf_libs/rsp_demux
vmap rsp_demux ./mips_cpu_iputf_libs/rsp_demux
vlib mips_cpu_iputf_libs/cmd_mux
vmap cmd_mux ./mips_cpu_iputf_libs/cmd_mux
vlib mips_cpu_iputf_libs/cmd_demux
vmap cmd_demux ./mips_cpu_iputf_libs/cmd_demux
vlib mips_cpu_iputf_libs/sdram_controller_s1_burst_adapter
vmap sdram_controller_s1_burst_adapter ./mips_cpu_iputf_libs/sdram_controller_s1_burst_adapter
vlib mips_cpu_iputf_libs/router_003
vmap router_003 ./mips_cpu_iputf_libs/router_003
vlib mips_cpu_iputf_libs/router
vmap router ./mips_cpu_iputf_libs/router
vlib mips_cpu_iputf_libs/sdram_controller_s1_agent_rsp_fifo
vmap sdram_controller_s1_agent_rsp_fifo ./mips_cpu_iputf_libs/sdram_controller_s1_agent_rsp_fifo
vlib mips_cpu_iputf_libs/sdram_controller_s1_agent
vmap sdram_controller_s1_agent ./mips_cpu_iputf_libs/sdram_controller_s1_agent
vlib mips_cpu_iputf_libs/d_cache_read_avalon_master_agent
vmap d_cache_read_avalon_master_agent ./mips_cpu_iputf_libs/d_cache_read_avalon_master_agent
vlib mips_cpu_iputf_libs/sdram_controller_s1_translator
vmap sdram_controller_s1_translator ./mips_cpu_iputf_libs/sdram_controller_s1_translator
vlib mips_cpu_iputf_libs/d_cache_read_avalon_master_translator
vmap d_cache_read_avalon_master_translator ./mips_cpu_iputf_libs/d_cache_read_avalon_master_translator
vlib mips_cpu_iputf_libs/rst_controller
vmap rst_controller ./mips_cpu_iputf_libs/rst_controller
vlib mips_cpu_iputf_libs/mm_interconnect_0
vmap mm_interconnect_0 ./mips_cpu_iputf_libs/mm_interconnect_0
vlib mips_cpu_iputf_libs/sdram_controller
vmap sdram_controller ./mips_cpu_iputf_libs/sdram_controller
vlib mips_cpu_iputf_libs/pll_0
vmap pll_0 ./mips_cpu_iputf_libs/pll_0
vlib mips_cpu_iputf_libs/d_cache_read
vmap d_cache_read ./mips_cpu_iputf_libs/d_cache_read
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_avalon_st_adapter_error_adapter_0.sv" -work error_adapter_0                      
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_avalon_st_adapter.v"                  -work avalon_st_adapter                    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_width_adapter.sv"                               -work sdram_controller_s1_rsp_width_adapter
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_address_alignment.sv"                           -work sdram_controller_s1_rsp_width_adapter
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_burst_uncompressor.sv"                          -work sdram_controller_s1_rsp_width_adapter
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_rsp_mux.sv"                           -work rsp_mux                              
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_arbitrator.sv"                                  -work rsp_mux                              
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_rsp_demux.sv"                         -work rsp_demux                            
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_cmd_mux.sv"                           -work cmd_mux                              
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_arbitrator.sv"                                  -work cmd_mux                              
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_cmd_demux.sv"                         -work cmd_demux                            
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_burst_adapter.sv"                               -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_burst_adapter_uncmpr.sv"                        -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_burst_adapter_13_1.sv"                          -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_burst_adapter_new.sv"                           -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_incr_burst_converter.sv"                               -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_wrap_burst_converter.sv"                               -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_default_burst_converter.sv"                            -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_address_alignment.sv"                           -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_avalon_st_pipeline_stage.sv"                           -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_avalon_st_pipeline_base.v"                             -work sdram_controller_s1_burst_adapter    
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_router_003.sv"                        -work router_003                           
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0_router.sv"                            -work router                               
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_avalon_sc_fifo.v"                                      -work sdram_controller_s1_agent_rsp_fifo   
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_slave_agent.sv"                                 -work sdram_controller_s1_agent            
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_burst_uncompressor.sv"                          -work sdram_controller_s1_agent            
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_master_agent.sv"                                -work d_cache_read_avalon_master_agent     
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_slave_translator.sv"                            -work sdram_controller_s1_translator       
vlog -sv "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_merlin_master_translator.sv"                           -work d_cache_read_avalon_master_translator
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_reset_controller.v"                                    -work rst_controller                       
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/altera_reset_synchronizer.v"                                  -work rst_controller                       
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_mm_interconnect_0.v"                                    -work mm_interconnect_0                    
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_sdram_controller.v"                                     -work sdram_controller                     
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_sdram_controller_test_component.v"                      -work sdram_controller                     
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/sdram_pll_0.vo"                                               -work pll_0                                
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/custom_master.v"                                              -work d_cache_read                         
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/burst_write_master.v"                                         -work d_cache_read                         
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/burst_read_master.v"                                          -work d_cache_read                         
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/write_master.v"                                               -work d_cache_read                         
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/submodules/latency_aware_read_master.v"                                  -work d_cache_read                         
vlog     "C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/sdram/simulation/sdram.v"                                                                                                            

vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/cache_bank.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/mips_core_pkg.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_cpu_pkg.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/llsc_module.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/mips_core_interfaces.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/pass_done_interface.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/memory_interfaces.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/i_cache.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/fetch_unit.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/decoder.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/d_cache.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/branch_controller.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/alu.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/reg_file.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/pipeline_registers.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/hazard_controller.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/glue_circuits.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/forward_unit.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_core/mips_core.sv}
vlog -sv -work work +incdir+C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu {C:/Users/jfujf/Desktop/cse_148/Baseline_v2.3/mips_cpu/mips_cpu.sv}

