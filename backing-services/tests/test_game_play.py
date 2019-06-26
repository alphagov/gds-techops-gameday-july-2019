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
    assert b"/docs" in result.data and 302 == result.status_code


def test_docs():
    result = app.test_client().get("/docs")
    assert 200 == result.status_code


def test_notfound():
    result = app.test_client().get("/non-exist")
    assert 404 == result.status_code


def test_docs_test_nots():
    # this should return the test-notimestamp.md file
    result = app.test_client().get("/docs/tests/test-notimestamp")
    assert b"AUWIOQ" in result.data and 200 == result.status_code


def test_docs_test_withts():
    # this should return the test-timestamp_1560000000.md file,
    # not the without timestamp or the 9000000000 file.
    result = app.test_client().get("/docs/tests/test-timestamp")
    assert b"UQIEJH" in result.data and 200 == result.status_code
