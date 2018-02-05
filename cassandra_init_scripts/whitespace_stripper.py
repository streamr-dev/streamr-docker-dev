import csv
import sys

with open(sys.argv[1], 'r') as f:
  reader = csv.reader(f, delimiter='|', quoting=csv.QUOTE_NONE)
  for row in reader:
      print '|'.join([x.strip() for x in row])
