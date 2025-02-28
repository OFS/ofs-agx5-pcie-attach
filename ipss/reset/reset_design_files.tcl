# Copyright (C) 2024 Intel Corporation.
# SPDX-License-Identifier: MIT

##
## Pick reset sequencers as needed
##

if {[get_global_assignment -name FAMILY] == "Agilex 5"} {
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/reset/qip/agilex5_srcss_gts.ip
}
