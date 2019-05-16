#!/usr/bin/env python3

"""email-notifier_lambda.py: Lambda handler for email-notifier."""

__license__ = "MIT"
__status__ = "Prototype"

import email_notifier

def lambda_handler(event, context):
    return serverless_wsgi.handle_request(email_notifier.app, event, context)
