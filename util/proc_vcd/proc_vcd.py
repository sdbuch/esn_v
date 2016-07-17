#!/usr/bin/python

from Verilog_VCD import parse_vcd
#from Verilog_VCD import list_sigs
import sys
import csv
import ipdb

def create_csv(fn, *sig_list):
  """
  Create csv data from certain signals in a .vcd file.

  Keyword arguments:
    fn        -- the local path of the .vcd file
    sig_list  -- any number of string-int argument pairs
                 consisting of the names of the signals in the
                 .vcd file that should be processed to create
                 the .csv outputs and their corresponding word
                 lengths


  Examples:
      from python interpreter:
    create_csv('sim_results.vcd', 'my_tb.D[255:0]', 16,
        'my_tb.Q[255:0]', 16) 
      creates csv data for two 256-bit bus signals, D and Q,
      each consisting of concatenated 16 bit values, based on
      the contents of sim_results.vcd generated from a run of
      my_tb
    
      from command line:
    proc_vcd.py sim_results.vcd tb.D[255:0] 16 tb.Q[255:0] 16
      does the same as the previous example
  """
  try:
    sig_names, sig_word_lens = zip(*[(sig_list[i],
        sig_list[i+1]) for i in range(0, len(sig_list), 2)])

    if __name__ == "__main__":
        # command line workaround
        sig_word_lens = tuple([int(k) for k in sig_word_lens])
    vcd_dict = parse_vcd(fn, siglist=list(sig_list))

    for sig_val in vcd_dict.values():
      csv_fn = ''
      bus_len = int(sig_val['nets'][0]['size'])

      for net_val in sig_val['nets']:
        if bus_len != int(net_val['size']):
          ipdb.set_trace()
        bus_len = int(net_val['size'])
        sig_idx = [i for i in range(0, len(sig_names)) if
                net_val['hier'] + '.' + net_val['name'] in
                sig_names[i]][0]
        word_len = sig_word_lens[sig_idx]
        csv_fn = "%s_%s-%s" % (csv_fn, net_val['hier'],
            net_val['name'].replace("[","").replace("]",""))
        csv_fn = "%s%s" % (csv_fn, ".csv")
        
      with open(csv_fn, 'wb') as csvfile:
        csvwriter = csv.writer(csvfile, delimiter=',', quotechar='"',
            quoting=csv.QUOTE_MINIMAL)

        for data_pt in sig_val['tv']:
          # parse time value
          time_val = float(data_pt[0])
          # check for out of band values
          if any([k in iter(data_pt[1]) for k in ['z', 'x', '?']]):
            # this could be improved to throw away only the out of band bits
            sig_data_int = (bus_len//word_len)*['inf']

          else:
            sig_data_raw = "%s%s" % ((bus_len-len(data_pt[1]))*'0', data_pt[1])
            sig_data = [sig_data_raw[i:i+word_len] for i in
                    range(0, bus_len, word_len)]
            sig_data_int = [int(sig_data[i],2) if not int(sig_data[i][0]) else
                -1*(1 +
                  int(sig_data[i].replace("0","2").replace("1","0").replace("2","1"),2))
                for i in range(0,bus_len//word_len)]
            csvwriter.writerow([time_val] + sig_data_int)

  except:
    for e in sys.exc_info():
      print("Error: %s" % e)

def main():
  """
  Wrap create_csv(), to be called from command line.
  """
  if len(sys.argv) > 2:
    fn = sys.argv[1]
    sig_list = sys.argv[2:]
    create_csv(fn, *sig_list)

  else:
    print('Call with a filename, a word length, and a sequence',
        'of strings (the signals to generate data for)')


if __name__ == "__main__": main()


