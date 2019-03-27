my_file = open("/Users/Ash/Dropbox/IYM-011 - Project/Created Software/traceroute-master/Documents/history.html", "r")
contents = my_file.readlines()

print('COORDINATES FROM GOOGLE MAPS: ')
for line in contents:
    real_line = line.replace('\x00', '')

    if "google.com/maps/place" in real_line:
        print(real_line.split('@')[1].split('/data')[0])
