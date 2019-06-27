import jwt
import requests
import base64
import json
from flask import request, redirect, session
from functools import wraps

# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html

PUBLIC_KEYS = {}


def get_kid(encoded_jwt):
    """Get the ALB (K)ey (ID) from a JWT
    :param encoded_jwt: The encoded_jwt from the request headers
    :returns: a key id
    :rtype: str
    Example 'kid': '307a30c3-8280-4ff5-a78d-6bc5263ffbe8'
    """
    jwt_headers = encoded_jwt.split(".")[0]
    decoded_jwt_headers = base64.b64decode(jwt_headers)
    decoded_jwt_headers = decoded_jwt_headers.decode("utf-8")
    decoded_json = json.loads(decoded_jwt_headers)
    kid = decoded_json["kid"]
    return kid


def get_public_key(kid, region="eu-west-2"):
    """Get an ALB public key from a keyID
    :param kid: A string with a kid
    :returns: a public key
    :rtype: str
    """
    url = f"https://public-keys.auth.elb.{region}.amazonaws.com/{kid}"
    req = requests.get(url)
    public_key = req.text
    return public_key


def login(encoded_jwt, verify=True):
    """Process a JWT token to check that it is valid
    :param encoded_jwt:
    :param verify:
    :returns:
    :rtype:
    """
    print(encoded_jwt)
    kid = get_kid(encoded_jwt)
    public_key = PUBLIC_KEYS.get(kid, None)
    if not public_key:
        public_key = get_public_key(kid)
        PUBLIC_KEYS[kid] = public_key
    payload = jwt.decode(
        encoded_jwt, public_key, algorithms=["ES256"], options={"verify_exp": verify}
    )
    return payload


def is_logged_in(app):
    if app.config.get("ENV", "production") == "production":
        if app.config["verify_oidc"]:
            login_details = login(
                request.headers["X-Amzn-Oidc-Data"],
                verify=app.config.get("verify_oidc", True),
            )
            session.new = True
            session["production_session"] = True
            session["login_details"] = login_details
            return True

    session.new = True
    session["auth_debug"] = True
    return True


def login_required(app):
    """Decorator for flask routes to login using oidc.
    :param app: Flask app to use
    :returns: A decorated function
    :rtype: func
    """

    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if app.config.get("ENV", "production") == "production":
                if "production_session" in session and "login_details" in session:
                    if session["production_session"] and session["login_details"]:
                        return f(session["login_details"], *args, **kwargs)
            else:
                if "auth_debug" in session and session["auth_debug"]:
                    return f({}, *args, **kwargs)

            return redirect("/login", code=302)

        return decorated_function

    return decorator
