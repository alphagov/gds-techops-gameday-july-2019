#!/usr/bin/env python3
import os
import time
import re
import random
import string
import json
import markdown2
from flask import Flask, request, send_from_directory, render_template, redirect
from flask_httpauth import HTTPDigestAuth
from os.path import abspath, normpath, join, isfile

app = Flask(__name__)

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
def send_docs(path=False):
    if not path:
        path = "default"

    # first, get the absolute folder, this will be used to ensure we don't
    # add a directory walking vulnerability.
    folder = abspath(normpath("src/game_play_docs"))
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
                    # loggedin should be True if there was auth...
                    loggedin=False,
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
