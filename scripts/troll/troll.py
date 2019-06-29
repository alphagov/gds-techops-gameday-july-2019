#!/usr/bin/env troll

import requests
import os
import hashlib
from datetime import datetime
import json
import splunklib.client as client
import time
import splunklib.results as results
import boto3

APP_DIFFICULTY = int(os.environ.get("APP_DIFFICULTY", 17))
SPLUNK_HEC = os.environ.get(
    "SPLUNK_URL", "https://hec.zero.game.gds-reliability.engineering/services/collector"
)
SPLUNK_HOST = os.environ.get(
    "SPLUNK_URL", "splunk-admin.zero.game.gds-reliability.engineering"
)
SPLUNK_USER = os.environ.get("SPLUNK_USER", "admin")
SPLUNK_PASS = os.environ.get("SPLUNK_PASS", "")
TEAM = os.environ.get("TEAM", "one")
TROLL_POINTS = int(os.environ.get("TROLL_POINTS", 5))
ENV = os.environ.get("ENV", "dev")
SPLUNK_TOKEN = os.environ.get("SPLUNK_TOKEN", "")


def get_registration(name, difficulty):
    sha2 = ""
    code = 0

    while sha2[:difficulty] != "0" * difficulty:

        code += 1
        v = f"{name['first_name']}{name['last_name']}{code}".encode("utf-8")

        h = hashlib.sha256()
        h.update(v)

        sha2 = "".join(format(n, "08b") for n in h.digest())

    name["code"] = code
    name["registration"] = h.hexdigest()
    return name


def troll_name():
    now = str(datetime.now().timestamp())
    return {
        "first_name": f"Troll_{now.split('.')[0]}",
        "last_name": f"Face_{now.split('.')[1]}",
    }


def send_to_splunk(troll):
    headers = {"Authorization": f"Splunk {SPLUNK_TOKEN}"}
    data = json.dumps({"event": json.dumps(troll)})
    return requests.post(SPLUNK_HEC, data, headers=headers)


def check_in_splunk(troll):
    s = client.connect(
        host=SPLUNK_HOST, port="443", username=SPLUNK_USER, password=SPLUNK_PASS
    )

    q = f"search index=\"gameday-{TEAM}\" first_name=\"{troll['first_name']}\" last_name=\"{troll['last_name']}\""
    r = s.jobs.oneshot(q)

    # Get the results and display them using the ResultsReader
    reader = results.ResultsReader(r)
    r = []
    for item in reader:
        r.append(item)
    return r


def valid_registration(name):
    h = hashlib.sha256()
    v = f"{troll['first_name']}{troll['last_name']}{troll['code']}".encode("utf-8")
    h.update(v)

    assert troll["registration"] == h.hexdigest(), f"FAILED! Hashes don't match"

    h = "".join(format(n, "08b") for n in h.digest())

    assert h[:APP_DIFFICULTY] == "0" * APP_DIFFICULTY, f"FAILED! Incorrect difficulty!"

    return True


def send_points(points):
    dynamodb = boto3.resource("dynamodb", region_name="eu-west-2")
    table_name = "gameday_team_points"
    table = dynamodb.Table(table_name)
    item = {
        "team": TEAM,
        "source": "troll",
        "points": points,
        "datetime": str(datetime.now()),
    }
    table.put_item(Item=item)


troll = troll_name()

if ENV == "dev":
    troll = get_registration(troll, APP_DIFFICULTY)
    send_to_splunk(troll)
else:
    r = requests.post(
        f"https://{TEAM}.game.gds-reliability.engineering/register", troll
    )
    assert r.status_code == 200, "Could not send troll to team {TEAM}"

print(troll)
time.sleep(10)

r = check_in_splunk(troll)

if valid_registration(json.loads(r[0]["_raw"])):
    print(f"Awarding {TROLL_POINTS} points")
    send_points(TROLL_POINTS)
