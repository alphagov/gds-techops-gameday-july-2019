import os
import inspect
import sys
import pytest
import base64


parentdir = os.path.dirname(os.getcwd())
print("parentdir:", parentdir)
sys.path.insert(0, parentdir)
from game_play import app  # noqa


def test_root_alb_heathcheck():
    result = app.test_client().get(
        "/", headers={"User-Agent": "TEST ELB-HealthChecker 2019"}
    )
    assert b"GTG" in result.data and 200 == result.status_code


def test_root():
    result = app.test_client().get("/")
    assert b"Please Login" in result.data and 200 == result.status_code


def test_dashboard_bad_auth():
    result = app.test_client().get("/dashboard")
    assert 401 == result.status_code


def test_docs_bad_auth():
    result = app.test_client().get("/docs")
    assert 401 == result.status_code


def test_notfound():
    result = app.test_client().get("/non-exist")
    assert 404 == result.status_code
