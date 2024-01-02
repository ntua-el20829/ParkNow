from pymongo import MongoClient

client = MongoClient()

# Access the "your_database" database (create it if it doesn't exist)
db = client['park_now']

# Access the "your_collection" collection (create it if it doesn't exist)
collection = db['parkings']

coordinates = [22.7280882,37.6522354]

nearest_parkings = collection.find(
    {
        "coordinates": {
            "$near": {
                "$geometry": {
                    "coordinates": coordinates
                },
                 "$maxDistance" : 2500
            }
        }
    }
).limit(5)  # Adjust the limit as needed

nearest_parkings.close()
