from pprint import pprint
import json


file1 = open('terraform.tfstate','r')
file1 = file1.read()
file1 = json.loads(file1)
data = file1['outputs']

for i in data:
    bla = data[i]['value'][0][0]
    print(bla)
