import re
myArea = Region(find(Pattern("Mux_column_top_from_output_groups.png").exact()))
myArea=Region(myArea.getX(), myArea.getY()+20, 370, 20)

my_capfile = capture(myArea)

myArea=Region(myArea.getX(), myArea.getY()+20, 370, 60)
findtext = myArea.text()


print('Raw read: ' + findtext)

my_match = re.search(r'.+\((\d+\.\s*\d+\.\s*\d+\.\s*\d+).(\d\d\d\d)\)', findtext)

print(my_match.group(1).replace(' ', '') + ' ' + my_match.group(2))

