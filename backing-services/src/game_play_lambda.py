#!/usr/bin/env python3
import game_play
import serverless_wsgi


def lambda_handler(event, context):
    return serverless_wsgi.handle_request(game_play.app, event, context)
