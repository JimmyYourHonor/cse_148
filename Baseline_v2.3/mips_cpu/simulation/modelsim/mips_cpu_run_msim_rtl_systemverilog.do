transcript on
if ![file isdirectory mips_cpu_iputf_libs] {
	file mkdir mips_cpu_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

