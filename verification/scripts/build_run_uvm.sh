echo "Running gen_sim_files.sh"
gmake -f Makefile_VCS.mk cmplib_adp 2>&1 | tee uvm1_gen_sim.log

echo "Hacking some files :D"
cp file_for_hack/ofs_ip_cfg_db.vh ../../sim/scripts/qip_gen_eseries-dk/syn/board/eseries-dk/syn_top/ofs_ip_cfg_db/
cp file_for_hack/ofs_ip_cfg_hssi_ss.vh ../../sim/scripts/qip_gen_eseries-dk/syn/board/eseries-dk/syn_top/ofs_ip_cfg_db/
cp file_for_hack/ofs_plat_host_chan_align_tx_tlps.sv ../../sim/scripts/qip_gen_eseries-dk/syn/board/eseries-dk/syn_top/afu_with_pim/afu/build/platform/ofs_plat_if/rtl/ifc_classes/host_chan/prims/gasket_pcie_ss/ofs_plat_host_chan_align_tx_tlps.sv
cp file_for_hack/ofs_plat_host_chan_align_rx_tlps.sv ../../sim/scripts/qip_gen_eseries-dk/syn/board/eseries-dk/syn_top/afu_with_pim/afu/build/platform/ofs_plat_if/rtl/ifc_classes/host_chan/prims/gasket_pcie_ss/ofs_plat_host_chan_align_rx_tlps.sv

echo "Compiling VCS"
gmake -f Makefile_VCS.mk build_adp DUMP=1 DEBUG=1 2>&1 | tee uvm2_compile.log

echo "Running mmio test"
gmake -f Makefile_VCS.mk run TESTNAME=mmio_test DUMP=1 DEBUG=1 | tee uvm3_testrun.log
