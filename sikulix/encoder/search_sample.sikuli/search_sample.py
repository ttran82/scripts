import re
Settings.OcrTextSearch=True
Settings.OcrTextRead=True
findtext = find("1437546934820.png").below(20).text()


print findtext
print len(findtext)

my_match = re.search(r'.+\[(\d+\.\d+\.\d+\.\d+) I (\d+)\]', findtext)
if not my_match:
    print 'failed to read multicast output'
else:
    print my_match.group(1)
    print my_match.group(2)