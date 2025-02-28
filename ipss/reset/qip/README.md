# Reset Sequencers

Agilex 5 GTS devices require reset sequencers that serialize resets, one IP block at a time. The current sequencer here, agilex5_srcss_gts.ip, is configured only for a single PCIe link.

Supporting more devices or D-Series Gen4x8 will require updates either to the committed sequencer or to the OFSS scripts.
