from locust import HttpLocust, TaskSet, task
import boto3
from datetime import datetime
import hashlib
import re
import names
import os


class WebsiteTasks(TaskSet):
    difficulty = int(os.environ["APP_DIFFICULTY"])
    team = os.environ["TEAM"]
    points = int(os.environ["POINTS"])

    @task(2)
    def register(self):
        now = str(datetime.now().timestamp())
        name = {
            "first_name": f"{names.get_first_name()}_{now.split('.')[0]}",
            "last_name": f"{names.get_last_name()}_{now.split('.')[1]}",
        }
        response = self.client.post("/register", name)
        assert response.status_code == 200
        self.verify_receipt(response, name)

        self.add_points()

    @task(5)
    def index(self):
        self.client.get("/")

    @task(3)
    def stats(self):
        self.client.get("/stats")

    def verify_receipt(self, response, name):
        sha2 = re.search(r"([0-9a-fA-F]{64})", response.text)
        code = re.search(r"x(\d+)x", response.text)
        h = hashlib.sha256()
        v = f"{name['first_name']}{name['last_name']}{code[1]}".encode("utf-8")
        h.update(v)
        h = h.hexdigest()

        assert sha2[0] == h
        assert sha2[0][:self.difficulty] == "0" * self.difficulty

    def add_points(self):
        dynamodb = boto3.resource("dynamodb", region_name="eu-west-2")
        table_name = "gameday_team_points"
        table = dynamodb.Table(table_name)
        item = {
            "team": self.team,
            "source": "locust",
            "points": self.points,
            "datetime": str(datetime.now()),
        }
        table.put_item(Item=item)


class WebsiteUser(HttpLocust):
    task_set = WebsiteTasks
    min_wait = 500
    max_wait = 3000
    timeout = 30
