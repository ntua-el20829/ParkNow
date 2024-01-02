import json 
import random
from pymongo import MongoClient


client = MongoClient()

# Access the "your_database" database (create it if it doesn't exist)
db = client['park_now']

# Access the "your_collection" collection (create it if it doesn't exist)
collection = db['parkings']

collection.create_index([('coordinates', '2dsphere')])

GEOJSON_PATH = './dummy_data.geojson'


with open(GEOJSON_PATH, 'r') as file:
    geojson_data = json.load(file)

features = geojson_data['features']


documents = []

dummy_val = 0 
#parsinag the json (collecting and creating the documents to be inserted)
for feature in features:
    # Access geometry and properties
    geometry = feature['geometry']
    properties = feature['properties']
    id = feature['id']
    coordinates = [geometry['coordinates'][0],geometry['coordinates'][1]]
    document = { 
            "_id": dummy_val,
            "coordinates": coordinates, 
            "fee" :random.randint(1,10)   , 
            "capacity": random.randint(40,500),  
            "name": f"parking_{dummy_val}",                         
            }
    documents.append(document)
    dummy_val+=1
collection.insert_many(documents,ordered=False)

