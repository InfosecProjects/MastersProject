import re
import binascii
file = open('/Users/XXX/chrome_1928.dmp')
content = file.readlines()

for line in content:
    match = re.findall(r'latitude', line)

    if match:
      print 'found: ' + line
      print 'hex  : ' + binascii.hexlify(line)
      print ('\n\n')
    else:
      pass

