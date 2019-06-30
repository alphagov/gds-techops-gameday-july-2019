#!/usr/bin/env python

import az_failure as a
import click
from pprint import pprint
import boto3
import click
import os
from datetime import datetime

POINTS = int(os.environ.get("POINTS", 1))
TEAM = os.environ.get("TEAM", "one")
COST = {
    "t3.nano": POINTS,
    "t3.micro": POINTS * 2,
    "t3.small": POINTS * 4,
    "t3.medium": POINTS * 8,
    "t2.medium": POINTS * 8,
}


def send_points(points):
    dynamodb = boto3.resource("dynamodb", region_name="eu-west-2")
    table_name = "gameday_team_points"
    table = dynamodb.Table(table_name)
    item = {
        "team": TEAM,
        "source": "cost",
        "points": points,
        "datetime": str(datetime.now()),
    }
    table.put_item(Item=item)


@click.command()
@click.option("--region", default="eu-west-2")
@click.option("--arn", default="")
def main(region, arn):
    if arn:
        session = a.assume_role(arn)
    else:
        session = boto3.session.Session()

    account = session.client("sts").get_caller_identity().get("Account")
    print(account)

    ec2 = session.client("ec2", region_name=region)
    instances = ec2.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["pending", "running"]}]
    )

    total = [
        COST[instance["InstanceType"]]
        for reservation in instances["Reservations"]
        for instance in reservation["Instances"]
    ]

    if len(total) > 5:
        total.append(POINTS *  * (len(total) - 5))
    print(total)
    send_points(-sum(total))


if __name__ == "__main__":
    main()
