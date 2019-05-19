#!/usr/bin/env python3
import os
import re
import random
import string
import json
import markdown2
from flask import Flask, request, send_from_directory, render_template, redirect
from flask_httpauth import HTTPDigestAuth
from os.path import abspath, normpath, join, isfile

app = Flask(__name__)
app.config["SECRET_KEY"] = "secret key here"
auth = HTTPDigestAuth()

DEFAULT_OK_RESPONSE = "OK"

users = {
    # instead of accounts, some dynamically generated thing...
    "john": "hello",
    "susan": "bye",
}


@auth.get_password
def get_pw(username):
    if username in users:
        return users.get(username)
    return None


@app.route("/")
def home():
    ua = request.headers.get("User-Agent")

    if "ELB-HealthChecker" in ua:
        print("This is a Health Check Request")
        return "GTG"

    if "session" in request.cookies:
        return redirect("/dashboard")
    else:
        return (render_template("home.html", title="Home", gfe_ver="2.9.0"), 200)


@app.route("/assets/<path:path>")
def send_assets(path):
    return send_from_directory("assets", path)


@app.route("/logout")
def logout():
    resp = redirect("/")
    resp.set_cookie("session", expires=0)
    return resp


@app.route("/dashboard", methods=["GET"])
@auth.login_required
def dashboard():
    return (
        render_template(
            "dashboard.html", title="Dashboard", gfe_ver="2.9.0", loggedin=True  # noqa
        ),
        200,
    )


@app.route("/docs")
@app.route("/docs/<path:path>")
@auth.login_required
def send_docs(path=False):
    if not path:
        path = "default"
    file = abspath(normpath(join("src/game_play_docs", f"{path}.md")))
    print(file)
    if os.getcwd() in file and isfile(file):
        f = open(file, "r")
        contents = f.read()
        md = markdown2.markdown(contents)
        return (
            render_template(
                "docs.html",
                title="Documentation",
                gfe_ver="2.9.0",
                loggedin=True,
                content=md,
            ),
            200,
        )
    return redirect("/notfound")


@app.errorhandler(404)
def handle_bad_request_404(e):
    return (
        render_template("error.html", title="Error", error=e, gfe_ver="2.9.0"),  # noqa
        404,
    )


@app.errorhandler(500)
def handle_bad_request_500(e):
    return (
        render_template("error.html", title="Error", error=e, gfe_ver="2.9.0"),  # noqa
        500,
    )


if __name__ == "__main__":
    app.config["ENV"] = "development"
    app.config["TESTING"] = True
    app.config["DEBUG"] = True
    app.run(port=5000)
