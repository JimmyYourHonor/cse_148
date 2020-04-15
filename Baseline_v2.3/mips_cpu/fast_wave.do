onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {IF Stage}
add wave -noupdate /fast_testbench/MIPS_CORE/clk
add wave -noupdate /fast_testbench/MIPS_CORE/rst_n
add wave -noupdate /fast_testbench/MIPS_CORE/i2i_hc/stall
add wave -noupdate -color {Slate Blue} -radix hexadecimal /fast_testbench/MIPS_CORE/if_pc_current/pc
add wave -noupdate -color {Slate Blue} -radix hexadecimal /fast_testbench/MIPS_CORE/if_pc_next/pc
add wave -noupdate /fast_testbench/MIPS_CORE/if_i_cache_output/valid
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/if_i_cache_output/data
add wave -noupdate -divider {IF to DEC}
add wave -noupdate /fast_testbench/MIPS_CORE/i2d_hc/flush
add wave -noupdate /fast_testbench/MIPS_CORE/i2d_hc/stall
add wave -noupdate -divider {DEC Stage}
add wave -noupdate /fast_testbench/MIPS_CORE/clk
add wave -noupdate -color {Slate Blue} -radix hexadecimal /fast_testbench/MIPS_CORE/i2d_pc/pc
add wave -noupdate /fast_testbench/MIPS_CORE/i2d_inst/valid
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/i2d_inst/data
add wave -noupdate -divider <NULL>
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/valid
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/alu_ctl
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/is_branch_jump
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/is_jump
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/is_jump_reg
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/dec_decoder_output/branch_target
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/is_mem_access
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/mem_action
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/uses_rs
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/rs_addr
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/uses_rt
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/rt_addr
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/uses_immediate
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/dec_decoder_output/immediate
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/uses_rw
add wave -noupdate /fast_testbench/MIPS_CORE/dec_decoder_output/rw_addr
add wave -noupdate -divider <NULL>
add wave -noupdate /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/branch_decoded/valid
add wave -noupdate /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/branch_decoded/is_jump
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/branch_decoded/target
add wave -noupdate /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/branch_decoded/prediction
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/branch_decoded/recovery_target
add wave -noupdate -divider <NULL>
add wave -noupdate -color Cyan -radix hexadecimal -childformat {{{/fast_testbench/MIPS_CORE/REG_FILE/regs[0]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[1]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[2]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[3]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[4]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[5]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[6]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[7]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[8]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[9]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[10]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[11]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[12]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[13]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[14]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[15]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[16]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[17]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[18]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[19]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[20]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[21]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[22]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[23]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[24]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[25]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[26]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[27]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[28]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[29]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[30]} -radix hexadecimal} {{/fast_testbench/MIPS_CORE/REG_FILE/regs[31]} -radix hexadecimal}} -expand -subitemconfig {{/fast_testbench/MIPS_CORE/REG_FILE/regs[0]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[1]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[2]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[3]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[4]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[5]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[6]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[7]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[8]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[9]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[10]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[11]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[12]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[13]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[14]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[15]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[16]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[17]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[18]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[19]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[20]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[21]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[22]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[23]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[24]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[25]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[26]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[27]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[28]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[29]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[30]} {-color Cyan -radix hexadecimal} {/fast_testbench/MIPS_CORE/REG_FILE/regs[31]} {-color Cyan -radix hexadecimal}} /fast_testbench/MIPS_CORE/REG_FILE/regs
add wave -noupdate /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/o_alu_input/valid
add wave -noupdate /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/o_alu_input/alu_ctl
add wave -noupdate /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/o_alu_input/op1
add wave -noupdate /fast_testbench/MIPS_CORE/DEC_STAGE_GLUE/o_alu_input/op2
add wave -noupdate -divider {DEC to EX}
add wave -noupdate /fast_testbench/MIPS_CORE/d2e_hc/flush
add wave -noupdate /fast_testbench/MIPS_CORE/d2e_hc/stall
add wave -noupdate -divider {EX Stage}
add wave -noupdate /fast_testbench/MIPS_CORE/clk
add wave -noupdate -color {Slate Blue} -radix hexadecimal /fast_testbench/MIPS_CORE/d2e_pc/pc
add wave -noupdate /fast_testbench/MIPS_CORE/ex_alu_output/valid
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/ex_alu_output/result
add wave -noupdate /fast_testbench/MIPS_CORE/ex_alu_output/branch_outcome
add wave -noupdate -divider <NULL>
add wave -noupdate /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_branch_result/valid
add wave -noupdate /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_branch_result/prediction
add wave -noupdate /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_branch_result/outcome
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_branch_result/recovery_target
add wave -noupdate /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_d_cache_input/valid
add wave -noupdate /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_d_cache_input/mem_action
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_d_cache_input/addr
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_d_cache_input/addr_next
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/EX_STAGE_GLUE/o_d_cache_input/data
add wave -noupdate -divider {EX to MEM}
add wave -noupdate /fast_testbench/MIPS_CORE/e2m_hc/flush
add wave -noupdate /fast_testbench/MIPS_CORE/e2m_hc/stall
add wave -noupdate -divider {MEM Stage}
add wave -noupdate /fast_testbench/MIPS_CORE/clk
add wave -noupdate -color {Slate Blue} -radix hexadecimal /fast_testbench/MIPS_CORE/e2m_pc/pc
add wave -noupdate /fast_testbench/MIPS_CORE/mem_d_cache_output/valid
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/mem_d_cache_output/data
add wave -noupdate -divider {MEM to WB}
add wave -noupdate /fast_testbench/MIPS_CORE/m2w_hc/flush
add wave -noupdate /fast_testbench/MIPS_CORE/m2w_hc/stall
add wave -noupdate -divider {WB Stage}
add wave -noupdate /fast_testbench/MIPS_CORE/clk
add wave -noupdate /fast_testbench/MIPS_CORE/m2w_write_back/uses_rw
add wave -noupdate /fast_testbench/MIPS_CORE/m2w_write_back/rw_addr
add wave -noupdate -radix hexadecimal /fast_testbench/MIPS_CORE/m2w_write_back/rw_data
add wave -noupdate -divider Hazards
add wave -noupdate /fast_testbench/MIPS_CORE/HAZARD_CONTROLLER/lw_hazard
add wave -noupdate /fast_testbench/MIPS_CORE/HAZARD_CONTROLLER/ic_miss
add wave -noupdate /fast_testbench/MIPS_CORE/HAZARD_CONTROLLER/ds_miss
add wave -noupdate /fast_testbench/MIPS_CORE/HAZARD_CONTROLLER/dec_overload
add wave -noupdate /fast_testbench/MIPS_CORE/HAZARD_CONTROLLER/ex_overload
add wave -noupdate /fast_testbench/MIPS_CORE/HAZARD_CONTROLLER/dc_miss
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {36408825 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 386
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {3531792904 ps} {3531863532 ps}
