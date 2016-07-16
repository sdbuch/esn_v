For the `proc_vcd.py` script to work, the package `Verilog_VCD` must
be installed:

```sudo pip install Verilog_VCD```

The directory `pip` installs packages to needs to be added to the
`PYTHONPATH` environment variable as well, and an `__init__.py` file
needs to be created in the `Verilog_VCD` subdirectory under the
`pip` install directory.

For the `vcd_conv.sh` shell script to work, the `gtkwave`
package needs to be installed. On Linux systems, use the
following or modify to use your favorite package manager:

```sudo apt-get install gtkwave```

