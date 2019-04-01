import gmplot
import requests
import subprocess
import IP2Location
from math import sin, cos, sqrt, atan2, radians

# use two databases to show the difference

#Get the own IP
Cmd = 'https://api.ipify.org?format=json'
res = requests.get(Cmd)
IP = res.json()['ip']

IP2LocObj = IP2Location.IP2Location()
IP2LocObj.open("/Users/IP2Location-Python-master/data/IP2LOCATION-LITE-DB5.BIN")
rec = IP2LocObj.get_all(IP)

Cmd = 'https://api.ipgeolocation.io/ipgeo?apiKey=XXXXX&ip='+IP
res = requests.get(Cmd)

gmap_ipgeolocation = gmplot.GoogleMapPlotter(float(res.json()['latitude']), float(res.json()['longitude']), 16)
gmap_ip2location = gmplot.GoogleMapPlotter(rec.latitude, rec.longitude, 16)

gmap_ipgeolocation.apikey = "XXX"
gmap_ip2location.apikey = "XXX"

print rec.latitude
print rec.longitude
print(res.json())

traceroute = subprocess.Popen(["traceroute", '-w', '100','XXX'],stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

IPs = []
index = 0

for line in iter(traceroute.stdout.readline, ""):
	index +=1
	start = " ("
	end = ") "
	if index > 2:
		#print(line)
		#print(line[line.find(start)+len(start):line.rfind(end)])
		IPs.append(line[line.find(start)+len(start):line.rfind(end)])
		#print(IPs)


#IPs = []

Longs_ipgeo = [float(res.json()['longitude'])]
Lats_ipgeo = [float(res.json()['latitude'])]
Longrads_ipgeo =[radians(float(res.json()['longitude']))]
Latrads_ipgeo = [radians(float(res.json()['latitude']))]

Longs_ip2 = [rec.longitude]
Lats_ip2 = [rec.latitude]
Longrads_ip2 = [radians(rec.longitude)]
Latrads_ip2 =  [radians(rec.latitude)]

for x in IPs:

	Cmd = 'https://api.ipgeolocation.io/ipgeo?apiKey=XXXX&ip=' + x
	rec = IP2LocObj.get_all(x)
	#print(Cmd)

	res = requests.get(Cmd)
	#print(res.json())
	Longs_ipgeo.append(float(res.json()['longitude']))
	Lats_ipgeo.append(float(res.json()['latitude']))
	Longrads_ipgeo.append(radians(float(res.json()['longitude'])))
	Latrads_ipgeo.append(radians(float(res.json()['latitude'])))

	Longs_ip2.append(rec.longitude)
	Lats_ip2.append(rec.latitude)
	Longrads_ip2.append(radians(rec.longitude))
	Latrads_ip2.append(radians(rec.latitude))

	#print(Long)
	#print(Lat)
	#print(Longrads)
	#print(Latrads)


#print(Lat)
#print(Long)

gmap_ipgeolocation.scatter(Lats_ipgeo, Longs_ipgeo ,'# FF0000', size = 400, marker = True )#
gmap_ipgeolocation.plot(Lats_ipgeo, Longs_ipgeo, 'cornflowerblue', edge_width = 2.5, marker = True)
gmap_ipgeolocation.draw('/Users/XXX/gmap_ipgeo.html')

gmap_ip2location.scatter(Lats_ip2, Longs_ip2 ,'# FF0000', size = 40, marker = True )#
gmap_ip2location.plot(Lats_ip2, Longs_ip2, 'cornflowerblue', edge_width = 2.5, marker = True)
gmap_ip2location.draw('/Users/XXX/gmap_ip2.html')


# approximate radius of earth in km
R = 6373.0
running_ipgeo = 0
running_ip2 = 0
for x in range(0,len(Longrads_ipgeo)-1):

	dlon_ipgeo = Longrads_ipgeo[x + 1] - Longrads_ipgeo[x]
	dlat_ipgeo = Latrads_ipgeo[x + 1] - Latrads_ipgeo[x]

	dlon_ip2 = Longrads_ip2[x + 1] - Longrads_ip2[x]
	dlat_ip2 = Latrads_ip2[x + 1] - Latrads_ip2[x]

	a_ipgeo = sin(dlat_ipgeo / 2)**2 + cos(Lats_ipgeo[x]) * cos(Lats_ipgeo[x+1]) * sin(dlon_ipgeo / 2)**2
	a_ip2 = sin(dlat_ip2 / 2)**2 + cos(Lats_ip2[x]) * cos(Lats_ip2[x+1]) * sin(dlon_ip2 / 2)**2

	c_ipgeo = 2 * atan2(sqrt(a_ipgeo), sqrt(1 - a_ipgeo))
	c_ip2 = 2 * atan2(sqrt(a_ip2), sqrt(1 - a_ip2))

	distance_ipgeo = R * c_ipgeo
	distance_ip2 = R * c_ip2

	running_ipgeo = running_ipgeo + distance_ipgeo
	running_ip2 = running_ip2 + distance_ip2

	print("Distance from last node (ipgeo):", distance_ipgeo)
	print("Distance from last node (ip2):", distance_ip2)

print("Total distance travelled (ipgeo):", running_ipgeo)
print("Total distance travelled (ip2):", running_ip2)
