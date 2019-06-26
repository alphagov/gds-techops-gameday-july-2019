# Backing Services


## [game_play.py](src/game_play.py)
This will be the dashboarder for teams to log in, get updates and log flags.

[game_playr_lambda.py](src/game_play_lambda.py) is the serverless_wsgi Lambda
handler

Flask has [assets](src/assets/) (GOV.UK Design Kit) and [templates](src/templates/).

## [email_notifier.py](src/email_notifier.py)
This a _fake_ API that the Ruby app will use.  
Idea is an email notifying API that will log notifications instead of actually
emailing them, those will then be used in scoring.
- v1 will get initially set and deprecated at a certain point
- v2 will be live but use a different format, so will require engineering effort

[email_notifier_lambda.py](src/email_notifier_lambda.py) is the serverless_wsgi
Lambda handler


## Tests
Tests are [here](tests/).
Currently only `test_game_play.py` which tests `game_play.py`.
Need to get auth tests working, unlikely to work with Basic/Digest so need
to move to form-based auth (better anyway...)

## Make
`make` will build and produce a zip (also `make zip`)  
`make test` will sort out env. and run tox  
`make clean` will clean up..  
`make run` will build and run `game_play.py`
