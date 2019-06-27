#!/usr/bin/env python3
import os
import game_play
import serverless_wsgi


def lambda_handler(event, context):

    print(event)
    print(context)

    sk = os.getenv("SECRET_KEY", "FALSE")
    if sk is not "FALSE":
        game_play.app.server_key = sk
        game_play.app.config["SECRET_KEY"] = sk

    return serverless_wsgi.handle_request(game_play.app, event, context)
