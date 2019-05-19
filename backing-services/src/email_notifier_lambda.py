#!/usr/bin/env python3
import email_notifier


def lambda_handler(event, context):
    return serverless_wsgi.handle_request(email_notifier.app, event, context)
