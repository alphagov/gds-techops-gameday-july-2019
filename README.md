# GDS TechOps Gameday July 2019

This is a redacted open sourced version of our gameday which we ran on 1st July 2019 for GDS TechOps.

## Timeline
### 10:00 - Start base traffic job

https://concourse.zero.game.gds-reliability.engineering/teams/main/pipelines/team-one/jobs/base-traffic/

The base traffic will add load to the teams servers. It is made of 3
tasks each increasing the number of requests per second.

10:00-11:30 : 2RPS
11:30-13:00 : 15RPS
13:00-15:00 : 30RPS

Set up team slack channels with the organisers names in the topic section.
Ensure copies of the documents are in the team folders in the techops drive.

### 10:00 - Introduce the game

This section should be fun with lots of meme (much game, such
wow). Walk everyone through the objectives - 'Build a secure, reliable
register-a-doge platform' using GDS best practice.

Tell them to keep incident logs.

### 10:20 - Check teams have access
1. Found the docs.
2. Can access AWS.
3. Have found the infrastructure
4. Have found the app source code.
5. No problems

Send out intro slack message to all team channels:
:siren: You now have some time to set up as a team and get yourself familiar with the service. Please refer to the documentation. If you need help @ an organiser within your team channel as detailed in the channel topic. :siren:

### 10:30 - Accounce Minister announcement
Tell everyone there will be a minister announcement at 11:30 to layout
plans for mandatory registering of doges.

Send out a message to all team slack channels:
:siren: At 11:30 the minister will be announcing plans for mandatory registering of doges. :siren:

### 10:40 - Disable AZ A in all accounts
Run the `Disable AZ` job for all teams - LINK. This will stop any
instances running in eu-west-2a for an hour. This should force the
teams to rebuild with more redundancy.

Update the team docs with a link to an AWS failure. Don't tell anyone yet.

https://concourse.zero.game.gds-reliability.engineering/teams/main/pipelines/team-one/jobs/az_failure/

### 10:55 - Announce AZ failure
Let everyone know that AWS have contacted us about the AZ
failure. Direct them to the link TODO.

Send out a slack message to all channels:
:AWS: :siren: AWS *eu-west-2* AZ is having intermittent issues. There may be disruption to your service! See the team docs for more details :siren: :AWS:

### 11:05 - Ask for retro notes
Tell everyone that we want the results of their retro soon and we want
a plan of action to make the site more reliable.

Link to retro notes template:
redacted

Stakeholders will need to be availble during this time to hear retro
summaries and guide teams in the right direction.

Slack message:
:siren: Please send a representative(s) from your team with your retro notes and actions summary to the Garage to discuss with stakeholders. :siren:

TODO LINK TO STAKEHOLDER GUIDE

### 11:30 - Send out comms for GDPR
email / slack the teams for the GDPR request. Bonus points for the
quickest team to complete the task.

### 11:45 - Announce GDPR Request
Slack message:
:gdpr: :siren: You need to make the required changes to comply with GDPR! redacted :gdpr: :siren:

Answers to the google form are here: redacted

### 12:00 - Announce detection of forged doge registrations
People are submitting false doge registrations!

Slack message:
:siren: It's been brought to out attention that people may be submitting false doge registrations! Please investigate. :siren:

### 12:10 - Ask teams to send troll logs to splunk
Direct the teams to the false_registraions docs page for further details.

https://docs.zero.game.gds-reliability.engineering/docs/false_registrations

### 13:00 - Change of techops strategy

Ec2 is no longer cool. Lets move every thing to Serverless! That's
lambda not containers. To encourge teams to move we will be increasing
the cost of running ec2 instances.


## App difficulty
If a team is too far ahead / doing too well then we can make things
more difficult for them.  Increment the `APP_DIFFUCULTY` parameter for
the smoke test in `pipelines/combined.yml` and redploy the pipeline.

``` yaml
      - task: smoke
        timeout: 120s
        config:
          params:
            APP_URL: https://((team)).game.gds-reliability.engineering
            IDENTIFIER: gameday-((team))
            APP_DIFFICULTY: 4
```

``` shell
make concourse_update_((team))
```
## Scoreboard.
The scoreboard uses a dynamodb for it's datastore. If it slows down
then check the read/write capacity and increase as needed
https://eu-west-2.console.aws.amazon.com/dynamodb/home?region=eu-west-2#tables:selected=gameday_team_points;tab=metrics.


### Scoring

Serving requests from `/reqister` will earn points. This is part of
the `locust` concourse job.

Running ec2 instances will cost points. Bigger instances cost
more.

Going over 5 instances makes everything increase in price.

Once the GDPR job is activated having specific PII entries in the
database will cause a point penalty. The specific entries that
shouldn't be in the database are any people who have an `a` in their
first name and a `z` in their last name.

Correctly send a Troll request to splunk will earn points.
