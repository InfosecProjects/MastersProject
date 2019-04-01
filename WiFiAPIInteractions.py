import requests

headers = {'Content-Type': 'application/json', }
google_params = (('key', 'XXX'), )
mozilla_params = (('key', 'test'), )

my_file = open("/Users/XXX/new-json.json", "r")
#os.remove("/Users/XXX/json-wifi_parsed.json")
my_file_p = open("/Users/XXX/json-wifi_parsed.json2", "w")

my_file_p.writelines('{\n "considerIp": "false",\n"wifiAccessPoints": [\n')

contents = my_file.readlines()
for x in range(0,len(contents)):
    contents[x] = contents[x].replace('\x00','')
    if "MAC Address" in contents[x]:
        my_file_p.writelines("{\n")
        my_file_p.writelines((contents[x].replace("MAC Address","macAddress")))
    elif "RSSI" in contents[x]:

        my_file_p.writelines((contents[x].replace("RSSI","signalStrength")))
        my_file_p.writelines('"signalToNoiseRatio": 50')
        my_file_p.writelines(("},\n"))

my_file_p.writelines('\n]\n}')
my_file_p.flush()


data = open("/Users/XXX/json-wifi_parsed.json")


response2 = requests.post('https://location.services.mozilla.com/v1/geolocate', headers=headers, params=mozilla_params, data=data)
print("input file: wifi-ssids.json")
print("Mozilla API: " + response2.content + "\n\n")

data.seek(0)
response = requests.post('https://www.googleapis.com/geolocation/v1/geolocate', headers=headers, params=google_params, data=data)
print("input file: wifi-ssids.json")
print("Google API: " + response.content)

