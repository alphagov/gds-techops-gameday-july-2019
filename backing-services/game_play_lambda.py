#!/usr/bin/env python3

"""game-play_lambda.py: Lambda handler for game-play."""

__license__ = "MIT"
__status__ = "Prototype"

import game_play

def lambda_handler(event, context):
    return serverless_wsgi.handle_request(game_play.app, event, context)
