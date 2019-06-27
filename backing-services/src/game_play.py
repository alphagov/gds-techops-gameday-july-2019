#!/usr/bin/env python3
import os
import time
import re
import random
import string
import json
import markdown2
from flask_httpauth import HTTPDigestAuth
from os.path import abspath, normpath, join, isfile
from oidc import login_required, is_logged_in
from flask import (
    Flask,
    session,
    request,
    send_from_directory,
    render_template,
    redirect,
)


app = Flask(__name__)
app.config["verify_oidc"] = True
DEFAULT_OK_RESPONSE = "OK"

@app.route("/")
def home():
    ua = request.headers.get("User-Agent")

    if "ELB-HealthChecker" in ua:
        print("This is a Health Check Request")
        return "GTG"

    return redirect("/docs")


@app.route("/assets/<path:path>")
def send_assets(path):
    return send_from_directory("assets", path)


@app.route("/docs")
@app.route("/docs/<path:path>")
@login_required(app)
def send_docs(login_details, path=False):
    if not path:
        path = "default"

    # first, get the absolute folder, this will be used to ensure we don't
    # add a directory walking vulnerability.
    folder = abspath("game_play_docs")
    # build a list of files in the game_play_docs folder
    onlyfiles = list()
    for (dirpath, dirnames, filenames) in os.walk(folder):
        onlyfiles += [join(dirpath, file) for file in filenames]

    # this block checks for files and returns the appropriate file based on
    # the timestamp - so if the file ends with a "_DIGIT.md" then the digit
    # is parsed and sets ret_file if older than the current timestamp.
    ret_file = False
    for file in sorted(onlyfiles):
        if file.startswith(join(folder, path)) and file.endswith(".md"):
            file = file.replace(folder, "")
            if "_" in file:
                timestamp = file.replace(".md", "").split("_")[-1:][0]
                if timestamp.isdigit():
                    if float(timestamp) < time.time():
                        ret_file = file
            else:
                ret_file = file

    if ret_file:
        # if we have a file, lstrip any backslashes off the file and prepend
        # the folder variable, normpath and then check it's the right folder
        file = normpath(join(folder, ret_file.lstrip("/")))
        if folder in file and isfile(file):
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


@app.route("/login")
def send_login():
    return (render_template("login.html", title="Login", gfe_ver="2.9.0"), 200)  # noqa


@app.route("/logout")
def send_logout():
    session.clear()
    resp = redirect("/login", code=302)
    resp.set_cookie("session", "", expires=0)
    resp.set_cookie("AWSELBAuthSessionCookie", "", expires=0)
    resp.set_cookie("AWSELBAuthSessionCookie-0", "", expires=0)
    return resp


@app.route("/login_success")
@login_required(app)
def send_login_success(login_details):
    image = ""
    if "picture" in login_details:
        image = login_details["picture"]

    return (
        render_template(
            "login_success.html",
            title="Success!",
            gfe_ver="2.9.0",
            login_picture=image,
            loggedin=True,
        ),
        200,
    )


@app.route("/auth")
def handle_auth():
    print("handle_auth")
    if is_logged_in(app):
        return redirect("/login_success", code=302)
    else:
        return redirect("/login", code=302)


if __name__ == "__main__":
    app.secret_key = "notrandomkey"
    app.config["ENV"] = "development"
    app.config["TESTING"] = True
    app.config["DEBUG"] = True
    app.config["verify_oidc"] = False
    app.run(port=5000)
