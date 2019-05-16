#!/usr/bin/env python3

"""email-notifier.py: This Lambda will take requests to be 'emailed'; however,
this will actually go into the scoring system where quantity of completed requests."""

__license__ = "MIT"
__status__ = "Prototype"

import os
import re
import random
import string
import json
from flask import (
    Flask,
    request,
)
from flask_httpauth import HTTPTokenAuth

app = Flask(__name__)
auth = HTTPTokenAuth('Bearer')

DEFAULT_OK_RESPONSE = "OK"

@auth.verify_token
def verify_token(token):
    print("Got verify_token request:", token)

    # something like an encoded account number that gets checked to see if
    # valid child account that should be querying this API

    if token == "test":
        return True
    return False


@app.route("/")
def root():
    ua = request.headers.get('User-Agent')

    if 'ELB-HealthChecker' in ua:
        print("This is a Health Check Request")
        return "GTG"

    return DEFAULT_OK_RESPONSE


@app.route("/api", methods = ['GET', 'POST'])
@auth.login_required
def api():
    return DEFAULT_OK_RESPONSE


@app.route("/api/v1", methods = ['GET', 'POST'])
@auth.login_required
def api_v1():
    # where the Ruby app will initially be configured to send requests
    return DEFAULT_OK_RESPONSE


@app.route("/api/v2", methods = ['GET', 'POST'])
@auth.login_required
def api_v2():
    # 'new' api that needs to be made live before v1 is deprecated
    return DEFAULT_OK_RESPONSE


if __name__ == "__main__":
    app.config["ENV"] = "development"
    app.config["TESTING"] = True
    app.config["DEBUG"] = True
    app.run(port=5000)
