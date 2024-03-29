import os
import inspect
import sys
import pytest
import base64


parentdir = os.path.dirname(os.getcwd())
print("parentdir:", parentdir)
sys.path.insert(0, parentdir)


@pytest.fixture()
def authenticated():
    """Setup a flask test client. This is used to connect to the test
    server and make requests.
    """

    print("Authenticated!")
    from game_play import app  # noqa

    app.config["SECRET_KEY"] = "testnotrandom"
    app.config["ENV"] = "unittest"
    app.config["TESTING"] = True
    app.config["verify_oidc"] = True
    authenticated = app.test_client()
    return authenticated


@pytest.fixture()
def unauthenticated():
    """Setup a flask test unauthenticated. This is used to connect to the test
    server and make requests.
    """

    print("Not authenticated...")
    from game_play import app  # noqa

    app.config["SECRET_KEY"] = "testnotrandom"
    app.config["ENV"] = "unittest"
    app.config["TESTING"] = True
    app.config["verify_oidc"] = False
    unauthenticated = app.test_client()
    return unauthenticated


def test_root_alb_heathcheck(unauthenticated):
    result = unauthenticated.get(
        "/", headers={"User-Agent": "TEST ELB-HealthChecker 2019"}
    )
    assert b"GTG" in result.data and 200 == result.status_code


def test_root_unauth(unauthenticated):
    result = unauthenticated.get("/")
    assert b"/docs" in result.data and 302 == result.status_code


def test_root(authenticated):
    result = authenticated.get("/")
    assert b"/docs" in result.data and 302 == result.status_code


def test_docs_unauth(unauthenticated):
    result = unauthenticated.get("/docs")
    assert b"/login" in result.data and 302 == result.status_code


def test_docs_auth(authenticated):
    result = authenticated.get("/docs")
    assert 200 == result.status_code


def test_scoreboard_auth(authenticated):
    result = authenticated.get("/scoreboard")
    assert b"/iframe" in result.data and 200 == result.status_code


def test_notfound(unauthenticated):
    result = unauthenticated.get("/non-exist")
    assert 404 == result.status_code


def test_docs_test_nots(authenticated):
    # this should return the test-notimestamp.md file
    result = authenticated.get("/docs/tests/test-notimestamp")
    assert b"AUWIOQ" in result.data and 200 == result.status_code


def test_docs_test_withts(authenticated):
    # this should return the test-timestamp_1560000000.md file,
    # not the without timestamp or the 9000000000 file.
    result = authenticated.get("/docs/tests/test-timestamp")
    assert b"UQIEJH" in result.data and 200 == result.status_code
