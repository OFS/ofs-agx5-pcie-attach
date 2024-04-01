# PCIE SS AXI-S Components

Unit tests for individual components used in the PCIe SS AXI-S pipeline. The components tested here are composed into the TX and RX pipelines between the OFS pcie_wrapper() and the PCIe SS IP.

A PCIe-specific BFM drives the tests: [simple_pcie_ss_stream_bfm](../../../../ofs-common@commit/sim/bfm/simple_pcie_ss_stream_bfm/). The BFM generates random TLP streams, encoded to match the PCIe SS API. The BFM supports:

* Both in-band and side-band headers
* Any data bus width that is a multiple of 256 bits
* Configurable number of segments

Instructions for running unit tests are in the [sim](../..) directory's [readme.txt](../../readme.txt).

## Tests

[top_tb.sv](top_tb.sv) drives the component tests. It invokes a series of tests sequentially. Most component modules are tested with variations of header position, width and segments.

## Debugging

The tests are all bound together in a single image to simplify the setup and reduce compilation time. Each individual test logs to separate files during simulation. If you are debugging a specific failure consider temporarily commenting out all instances of \`RUN_TEST in [top_tb.sv](top_tb.sv) other than the test being debugged.