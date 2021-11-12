rm -rfv `ls |grep -v ".*\.sv\|.*\.sh\|.*\.md"`;
source /mnt/vol_NFS_rh003/estudiantes/archivos_config/synopsys_tools.sh
vcs -Mupdate testbench.sv -o salida -full64 -sverilog -timescale=1ns/1ps -l log_test -ntb_opts uvm-1.2 +lint=TFIPC-L -kdb -lca +UVM_VERBOSITY=UVM_HIGH -cm line+tgl+cond+fsm+branch+assert;
./salida -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_LOW +UVM_TESTNAME=test_escenario1
./salida -cm line+tgl+cond+fsm+branch+assert +UVM_VERBOSITY=UVM_LOW +UVM_TESTNAME=test_escenario2
verdi -cov -covdir salida.vdb
rm -rfv `ls |grep -v ".*\.sv\|.*\.sh\|.*\.md"`;