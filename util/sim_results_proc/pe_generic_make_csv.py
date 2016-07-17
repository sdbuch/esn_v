#!/usr/bin/python

from proc_vcd import create_csv
import sys
from subprocess import check_call
from itertools import chain
import ipdb

global vcd_fn = 'pe_generic.vcd'
global sig_list = ['pe_generic_tb.D[255:0]',
        'pe_generic_tb.W[1023:0]', 'pe_generic_tb.Q[511:0]',
        'pe_generic_tb.DUT.T[2111:0]',
        'pe_generic_tb.DUT.S[1055:0]',
        'pe_generic_tb.DUT.P[139:0]',
        'pe_generic_tb.DUT.L[63:0]']
global word_len_list = [16, 16, 16, 33, 33, 35, 16]

def main():
    """
    Simple wrapper for proc_vcd.create_csv.

    Global variable settings:

    Set vcd_fn to the path of the raw .vcd file (i.e.
    unprocessed with the gtkwave vzt convert tools). 
    
    Set sig_list to a list of signals in the .vcd whose time
    data should be dumped to .csv, with appropriate hierarchical
    referencing. 
    
    Set word_len_list to a list of bit lengths corresponding to
    the signals added to sig_list.

    Notes:
    - The esn_v/util directory needs to be on the system $PATH
      environment variable
    - The esn_v/util/proc_vcd directory needs to be on the
      system $PYTHONPATH environment variable
    """
    ipdb.set_trace()
    check_call(["vcd_conv.sh", vcd_fn])
    arg_list = list(chain(*zip(sig_list,word_len_list)))
    processed_vcd_fn = "%s_new.vcd" % (vcd_fn, )
    create_csv(processed_vcd_fn, arg_list)


if __name__ == "__main__":
    main()
