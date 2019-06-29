#!/usr/bin/env python
import psycopg2
import boto3
from datetime import datetime
import os
import time


def delete_points():
    dynamodb = boto3.resource("dynamodb", region_name="eu-west-2")
    table_name = "gameday_team_points"
    table = dynamodb.Table(table_name)
    item = {
        "team": os.environ["TEAM"],
        "source": "GDPR",
        "points": -int(os.environ["POINTS"]),
        "datetime": str(datetime.now()),
    }
    table.put_item(Item=item)


while True:
    conn = psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
    )
    cur = conn.cursor()
    r = cur.execute(
        "SELECT count(*) FROM registrations WHERE first_name LIKE '%a%' and last_name LIKE '%z%'"
    )
    r = cur.fetchone()
    print(f"Number of GDPR Infractions: {r[0]}")
    if r[0] > 0:
        delete_points()
    time.sleep(60)
