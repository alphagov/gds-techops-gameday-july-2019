#!/usr/bin/env python3

"""game-play.py: Lambda for the game play dashboard."""

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
    send_from_directory,
    render_template,
    redirect,
)
from flask_httpauth import HTTPBasicAuth

app = Flask(__name__)
auth = HTTPBasicAuth()

MASTER_TITLE = "GTG-GPE: GDS TO GAME - GAME PLAY ENGINE"
DEFAULT_OK_RESPONSE = "OK"

users = {
    # instead of accounts, some dynamically generated thing...
    "john": "hello",
    "susan": "bye"
}

@auth.get_password
def get_pw(username):
    if username in users:
        return users.get(username)
    return None


@app.route('/')
def home():
    ua = request.headers.get('User-Agent')

    if 'ELB-HealthChecker' in ua:
        print("This is a Health Check Request")
        return "GTG"

    return (
        render_template(
            "home.html",
            title=f"{MASTER_TITLE} - Home",
            govukfrontendver="2.9.0",
        ),
        200,
    )


@app.route("/assets/<path:path>")
def send_assets(path):
    return send_from_directory("assets", path)


@app.route("/dashboard", methods = ['GET'])
@auth.login_required
def api():
    return (
        render_template(
            "dashboard.html",
            title=f"{MASTER_TITLE} - Dashboard",
            govukfrontendver="2.9.0",
        ),
        200,
    )


@app.errorhandler(404)
def handle_bad_request(e):
    return (
        render_template(
            "error.html",
            title=f"{MASTER_TITLE} - Error",
            error=e,
            govukfrontendver="2.9.0",
        ),
        404,
    )


@app.errorhandler(500)
def handle_bad_request(e):
    return (
        render_template(
            "error.html",
            title=f"{mastertitle} - Error",
            error=e,
            govukfrontendver="2.9.0",
        ),
        500,
    )


if __name__ == "__main__":
    app.config["ENV"] = "development"
    app.config["TESTING"] = True
    app.config["DEBUG"] = True
    app.run(port=5000)
