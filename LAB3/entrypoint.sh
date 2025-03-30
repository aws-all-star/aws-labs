#!/bin/bash
#lab-3 entrypoint scripts
#created by Donghyun, Kim
#KT DS, Cloud Consulting Team, Team Manager

#Start MongoDB
docker-entrypoint.sh mongod &

#Wait for MongoDB to start
sleep 30

#MongoDB connection variables
MONGO_PORT="27017"
MONGO_DB="LAB2"
COLLECTION_NAME="KBL_Pitcher_2024"
CSV_FILE="KBL-Pitcher-2024.csv"

#Import the CSV file into the MongoDB collection
mongoimport --host db --port $MONGO_PORT --db $MONGO_DB --collection $COLLECTION_NAME --type csv --headerline --file $CSV_FILE

#Keep the container running
tail -f /dev/null
