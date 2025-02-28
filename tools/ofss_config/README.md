# OFSS Config Tool

## Overview
- For detailed description on how to run this tool, please refer to ofs-common/tools/ofss_config/README.md
- This directory only contains template OFSS files relevant to this platform.

### OFSS File Structure
#### \[default\] Section
Each element (separated by newline) under this section should be a path to an OFSS file to be included for configuration by the OFSS tool. Please ensure any environment variables (e.g. $OFS_ROOTDIR) is properly set up. Default configuration files are applied only when the IP they define is not specified on the OFSS tool configuration command line. If the user specifies [pcie/pcie_host_1pf_1vf.ofss](pcie/pcie_host_1pf_1vf.ofss), the \[default\] PCIe configuration will be ignored.

#### \[ip\] Section
This section contains a key value pair that allows the OFSS Config tool to determine which IP configuration is being passed in.  With current release, the supported values of IP are `ofss`, `iopll`, `pcie`, `memory`, `hssi`.

#### \[settings\] Section
This section contains IP specific settings.  Please refer to an existing IP OFSS file to see what IP settings are set.  For the IP type "ofss", the settings will be information of the OFS device (platform, family, fim, part #, device_id)

#### \<platform\>.ofss vs base/\<platform\>_base.ofss
`<platform>.ofss` lists the default IP configuration for the platform. It contains only a \[default\] section. `base/<platform>_base.ofss` contains board specific information, such as the FPGA part number.

