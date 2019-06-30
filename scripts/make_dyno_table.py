import boto3
from datetime import datetime
from boto3.dynamodb.conditions import Key
import hashlib
import json
import decimal

dynamodb = boto3.client("dynamodb", region_name="eu-west-2")


table_name = "gameday_team_points"
try:
    response = dynamodb.describe_table(TableName=table_name)
except:
    table = dynamodb.create_table(
        TableName=table_name,
        KeySchema=[
            {"AttributeName": "team", "KeyType": "HASH"},
            {"AttributeName": "datetime", "KeyType": "RANGE"},
        ],
        AttributeDefinitions=[
            {"AttributeName": "team", "AttributeType": "S"},
            {"AttributeName": "datetime", "AttributeType": "S"},
        ],
        ProvisionedThroughput={"ReadCapacityUnits": 5, "WriteCapacityUnits": 5},
    )
    table.meta.client.get_waiter("table_exists").wait(TableName=table_name)

# dynamodb.delete_table(TableName=table_name)
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(table_name)

item = {"team": "one", "source": "test", "points": 1, "datetime": str(datetime.now())}
table.put_item(Item=item)
item = {"team": "two", "source": "test", "points": 3, "datetime": str(datetime.now())}


table.put_item(Item=item)

response = table.scan()
items = []
items += response["Items"]

while "LastEvaluatedKey" in response:
    items + response["Items"]
    response = table.scan(ExclusiveStartKey=response["LastEvaluatedKey"])

points = {"one": [{"points": 0}], "two": [{"points": 0}]}

for i in items:
    score = points[i["team"]][0]["points"] + i["points"]
    points[i["team"]].append({"points": score, "datetime": i["datetime"]})

print(points)
