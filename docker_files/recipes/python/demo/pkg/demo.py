import os
print "one plus one equals %d" % (1 + 1)
if 'PYTHONHOME' in os.environ:
    print os.environ['PYTHONHOME']
print sorted(os.listdir("/etc"))

from datetime import date
d = date(2017, 7, 20)
print "Was this package initially built on Thursday? %s" % ('yes' if d.weekday() == 3 else 'no')
