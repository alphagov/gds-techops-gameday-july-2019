# Ops manual
## Links

Team docs: https://docs.zero.game.gds-reliability.engineering/docs

Gameday admin repo: https://github.com/tlwr/gds-techops-game day

Public register-a-doge repo: https://github.com/tlwr/register-a-doge

concourse: https://concourse.zero.game.gds-reliability.engineering/

retro notes: https://docs.google.com/document/d/1ViGh3SRa44se91_6X97fxTp0FVVRCN0B2blVRtMjE1g

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
failure. Direct them to the link.

Send out a slack message to all channels:
:AWS: :siren: AWS *eu-west-2* AZ is having intermittent issues. There may be disruption to your service! See the team docs for more details :siren: :AWS: 

### 11:05 - Ask for retro notes
Tell everyone that we want the results of their retro soon and we want
a plan of action to make the site more reliable.

Link to retro notes template:
https://docs.google.com/document/d/1ViGh3SRa44se91_6X97fxTp0FVVRCN0B2blVRtMjE1g/edit

Stakeholders will need to be availble during this time to hear retro
summaries and guide teams in the right direction.

Slack message:
:siren: Please send a representative(s) from your team with your retro notes and actions summary to the Garage to discuss with stakeholders. :siren:

TODO LINK TO STAKEHOLDER GUIDE

### 11:30 - Base traffic increases to 15 RPS
This is going to break most peoples infrastructure but they should be
able to out scale it. (NEEDS TESTING)

### 12:00 - Send out comms for GDPR
email / slack the teams for the GDPR request. Bonus points for the
quickest team to complete the task.

Slack message:
:gdpr: :siren: You need to make the required changes to comply with GDPR! https://forms.gle/4mNUScziA56Rk9bT6 :gdpr: :siren:

Answers to the google form are here: https://docs.google.com/spreadsheets/d/17omayXJRbdbA5fsyv5W5WL77ywcrpE-n8kI2emQFzTs/edit#gid=629081435

### 12:20 - Announce detection of forged doge registrations
People are forging doge registations! At 12:30 we are going to
increase the registration code algorithm difficulty to `5`.

Slack message:
:siren: It's been brought to out attention that people may be forging doge registrations! Please investigate. :siren:

### 12:30 - Increase algorithm difficulty

``` shell
sed -i pipelines/combined.yml 's/APP_DIFFICULTY: 4/APP_DIFFICULTY: 5/
make concourse_update_all
```

### 13:30 - Base traffic increases to 30 RPS
This is going to break most peoples infrastructure but they should be
able to out scale it. (NEEDS TESTING)



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
