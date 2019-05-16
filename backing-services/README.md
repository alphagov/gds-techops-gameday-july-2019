# Backing Services


## [game_play.py](game_play.py)
This will be the dashboarder for teams to log in, get updates and log flags.

[game_playr_lambda.py](game_play_lambda.py) is the serverless_wsgi Lambda
handler

Flask has [assets](assets/) (GOV.UK Design Kit) and [templates](templates/).

## [email_notifier.py](email_notifier.py)
This a _fake_ API that the Ruby app will use.  
Idea is an email notifying API that will log notifications instead of actually
emailing them, those will then be used in scoring.
- v1 will get initially set and deprecated at a certain point
- v2 will be live but use a different format, so will require engineering effort

[email_notifier_lambda.py](email_notifier_lambda.py) is the serverless_wsgi
Lambda handler


## Make
Currently, only done a PowerShell script... XD  
Hence the WIP, will pull on my work laptop and make a makefile.  
As well as actually making some tests and setting up tox...
