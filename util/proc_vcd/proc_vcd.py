#!/usr/bin/python

from Verilog_VCD import parse_vcd
#from Verilog_VCD import list_sigs
import sys
import csv

def create_csv(fn, word_len, *sig_tuple):
  """
  Create csv data from certain signals in a .vcd file.

  Keyword arguments:
    fn        -- the local path of the .vcd file
    word_len  -- the number of bits in the input/output data words
    sig_tuple -- any number of string arguments consisting of
                 the names of the signals in the .vcd file that
                 should be processed to create the .csv outputs
  """
  try:
    vcd_dict = parse_vcd(fn, siglist=list(sig_tuple))
    for sig_val in vcd_dict.values():
      csv_fn = ''
      sz = int(sig_val['nets'][0]['size'])
      for net_val in sig_val['nets']:
        if sz != int(net_val['size']):
          ipdb.set_trace()
        sz = int(net_val['size'])
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
            sig_data_int = (sz//word_len)*['inf']
          else:
            sig_data_raw = "%s%s" % ((sz-len(data_pt[1]))*'0', data_pt[1])
            sig_data = [sig_data_raw[i:i+word_len] for i in range(0, sz,
              word_len)]
            sig_data_int = [int(sig_data[i],2) if not int(sig_data[i][0]) else
                -1*(1 +
                  int(sig_data[i].replace("0","2").replace("1","0").replace("2","1"),2))
                for i in range(0,sz//word_len)]
            csvwriter.writerow([time_val] + sig_data_int)

  except:
    for e in sys.exc_info():
      print("Error: %s" % e)

def main():
  """
  Wrap create_csv(), to be called from command line.
  """
  if len(sys.argv) > 3:
    fn = sys.argv[1]
    word_len = int(sys.argv[2])
    sig_list = sys.argv[3:]
    create_csv(fn, word_len, *sig_list)

  else:
    print('Call with a filename, a word length, and a sequence',
        'of strings (the signals to generate data for)')


if __name__ == "__main__": main()


