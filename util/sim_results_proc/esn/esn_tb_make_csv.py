#!/usr/bin/python

from proc_vcd import create_csv
import sys
from subprocess import check_call
from itertools import chain
import ipdb

vcd_fn = 'esn_top_tb_v4'
sig_list = ['esn_top_tb.W_out[255:0]', 'esn_top_tb.est[31:0]']

word_len_list = 2*[32]

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
    global vcd_fn
    global sig_list
    global word_len_list

    check_call(["vcd_conv.sh", "%s.vcd" % (vcd_fn,)])
    arg_list = list(chain(*zip(sig_list,word_len_list)))
    processed_vcd_fn = "%s_new.vcd" % (vcd_fn, )
    create_csv(processed_vcd_fn, *arg_list)


if __name__ == "__main__":
    main()
