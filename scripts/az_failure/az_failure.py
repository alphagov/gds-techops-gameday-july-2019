#!/usr/bin/env python3

import logging
import boto3
from botocore.exceptions import ClientError
import time
import click

logging.basicConfig(
    level=logging.INFO,
    format="[%(asctime)s] p%(process)s {%(pathname)s:%(lineno)d} %(levelname)s - %(message)s",
    datefmt="%Y%m%d %H:%M:%S",
)


@click.command()
@click.option("--region", default="eu-west-2")
@click.option("--az", default="a")
@click.option("--duration", default=60)
@click.option("--arn", default='')
def main(region, az, duration, arn):
    """Stop all instances in an AZ for the specified duration."""
    if arn:
        session = assume_role(arn)
    else:
        session = boto3.session.Session()

    account = session.client("sts").get_caller_identity().get("Account")
    logging.info(f"Disabling {account}/{region}{az} for {duration} minutes")
    for i in range(duration * 2):
        terminate_instances(list_instances(region, az, session), region, session)
        time.sleep(30)


def assume_role(arn):
    client = boto3.client("sts")
    response = client.assume_role(RoleArn=arn, RoleSessionName="az_failure")

    return boto3.session.Session(
        aws_access_key_id=response["Credentials"]["AccessKeyId"],
        aws_secret_access_key=response["Credentials"]["SecretAccessKey"],
        aws_session_token=response["Credentials"]["SessionToken"],
    )


def list_instances(region, az, session):
    ec2 = session.client("ec2", region_name=region)
    return ec2.describe_instances(
        Filters=[
            {"Name": "availability-zone", "Values": [f"{region}{az}"]},
            {"Name": "instance-state-name", "Values": ["pending", "running"]},
        ]
    )


def terminate_instances(instances, region, session):
    ec2 = session.client("ec2", region_name=region)
    for reservation in instances["Reservations"]:
        for instance in reservation["Instances"]:
            try:
                ec2.stop_instances(InstanceIds=[instance["InstanceId"]])
                logging.info(f'Stopped: {instance["InstanceId"]}')
            except ClientError:
                logging.error('Failed to stop: {instance["InstanceId"]}')
    else:
        logging.info(f"No running instances!")


if __name__ == "__main__":
    main()
