[Games](/docs) | [Register to Doge Home](/docs/register-to-doge) | [Teams](/docs/register-to-doge-teams) | [Tasks](/docs/register-to-doge-tasks) | **Service Manual** | [Why _'Register to Doge'_ ?](/docs/register-to-doge-why)

## Register to Doge / Service Manual

### Application

The application source code is available here: <https://github.com/tlwr/register-a-doge> 🐶

Register to Doge is written in [Ruby](https://www.ruby-lang.org/en/documentation/) (v2.6.3) with [Sinatra](http://sinatrarb.com/) - a DSL (Domain-Specific Language) for writing web applications.
The database engine is [PostgreSQL](https://www.postgresql.org/).

----

### Hosting

#### AWS

Amazon Web Service (cloud provider) is used to host the application in a **single** EC2 (Elastic Compute Cloud) instance.

SSM (Simple Systems Manager) Session Manager is used to access the instance.

The database is hosted on RDS (Relational Database Service), an AWS service that manages underlying infrastructure and provides access to a database.

CloudWatch provides log visibility.

There is no infrastructure-as-code set up - building of the instance is done using **Cloud-Init** (user-data) - see [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) for details.


----

### Monitoring

There is some monitoring run by a different department, which you can view but not access:
<https://concourse.zero.game.gds-reliability.engineering/>

----

### Incident

<<<<<<< HEAD
1. Edit the Incident Report in your team folder: redacted
>>>>>>> 9042693... Updated docs link in docs
  - Share with your team
  - Be sure to include all information and times of any decisions
  - If you can, include any decisions you decide not to follow
2. Once an incident is finished, ensure all information is captured.
3. Edit the Incident Retro in your team folder: redacted
  - Share with your team
  - Spend 15 minutes going through with a facilitator
