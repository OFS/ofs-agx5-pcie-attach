# Memory system scripts directory

This directory contains the OFS Agilex 7 memory subsystem system scripts. For now, only M-Series devices have scripted support.

## Subsystem
* HBM
   - Running `make` will build a system with 8 top/bottom HBM channels each connected to 16 AXI channels and full crossbar support. The configuration can be modified by setting `ch` and `xbar` variables.
    ```bash
        make hbm="<dev:num> <dev:num>" xbar=<bool>
    ```
### Example:
    make hbm="0:4 1:4" xbar=false

This will create a system with 4 HBM channels/8 NoC channels top and bottom in a direct mapped configuration with `noc_0`, `hbm_0`, `noc_0_ctrl`, and `noc_1`, `hbm_1`, `noc_1_ctrl` components. The first element in the `:` seperated hbm value maps to the suffix given to the instantiated component and it's component ports connected in `$OFS_ROOTDIR/ofs-common/fpga_family/agilex/mem_ss/hbm_ss_top.sv`
