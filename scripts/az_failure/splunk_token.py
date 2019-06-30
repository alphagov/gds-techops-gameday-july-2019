#!/usr/bin/env python3

import uuid
import os
import random
import requests
import json
import zlib
import base64
import boto3

TEAM = os.environ.get("TEAM", "one")

# KEY is Splunk index name
SPLUNK_HEC = os.environ.get(
    "SPLUNK_HEC", "https://hec.zero.game.gds-reliability.engineering/services/collector"
)
TOKENS = {
    "gameday-one": "3a4ce60f-ac1f-4a9b-b316-1b39bc8a4112",
    "gameday-two": "399ffc35-3f59-4e12-8cb8-843998bb6d2d",
    "gameday-three": "ce5d5586-5669-4f08-833f-9d0617921115",
    "gameday-four": "548b9512-827e-471b-84a1-3ac95d21bf61",
    "gameday-five": "280a71a5-c447-4ef7-801d-9f7dd0e0d658",
    "gameday-six": "05575357-561f-43a1-a42f-0b317187884d",
    "gameday-seven": "53daeadd-8377-4c02-8631-86a9272c878f",
}
# Pick a key, any key
_uuids = [str(uuid.uuid4()) for i in range(65)]
_uuids.append(TOKENS[f"gameday-{TEAM}"])
random.shuffle(_uuids)

# encode the data
_json = json.dumps(_uuids).encode("utf-8")
_compressed = zlib.compress(_json)
_b64 = base64.b64encode(_compressed)

# store in SSM
client = boto3.client("ssm", region_name="us-east-1")
client.put_parameter(
    Name="SplunkKey", Type="SecureString", Value=_b64.decode("ascii"), Overwrite=True
)


# Get the data back
response_ = client.get_parameter(Name="SplunkKey", WithDecryption=True)

print(response_)

# decode data
b64_ = response_["Parameter"]["Value"]
compressed_ = base64.b64decode(b64_)
json_ = zlib.decompress(compressed_)
uuids_ = json.loads(json_)

# Find the right key
count = 0
for i in uuids_:
    headers = {"Authorization": f"Splunk {i}"}
    data = json.dumps({"event": "foo"})
    r = requests.post(SPLUNK_HEC, data, headers=headers)
    count += 1
    if r.status_code == 200:
        print(i, count)
        break
