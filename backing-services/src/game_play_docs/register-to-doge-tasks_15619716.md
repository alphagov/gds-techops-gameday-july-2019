[back...](/docs/register-to-doge)  

## Register to Doge / Tasks

You are a multidisciplinary service team who have just inherited a legacy service called “Register a Doge”, as Shiba Inus 🐶 are now a restricted animal. After a quick-and-dirty migration the service was moved into AWS (region _eu-west-2_).

There is no documentation for how this works 😞 but the source code is open source <https://github.com/tlwr/register-a-doge> and you have access to the AWS account (see [team details](register-to-doge-teams) for your account number) via the role “gameday”.

During the handover you learned that there is a **single** EC2 instance running the dockerised application, which connects to an RDS database over the public internet. Any logs that exist are in CloudWatch, and any access to the instance is done via the AWS console using the AWS Simple Systems Manager Session Manager. Any instance provisioning is done via **Cloud-Init**.

There is no infrastructure-as-code set up for this application. The only record of how the machine was built is the **Cloud-Init** (user-data).

First, you must familiarise yourself with the application, ensure you can:

- **Log in** to the AWS account
- **Gain SSH access** to the box using AWS SSM Session Manager
- **Access the database** from your local machine using credentials obtained from the instance (don’t lose these)
- **See logs and metrics** using AWS CloudWatch Logs and AWS CloudWatch Metrics

**The source code for the application can be found here:**  
<https://github.com/tlwr/register-a-doge>

**Teams, including account details:** [here](register-to-doge-teams)

**There is some monitoring run by a different department, which you can view but not access:**  
<https://concourse.zero.game.gds-reliability.engineering/>

## Time
You have until **2pm**. During the day there will be a need to complete incident report(s). At 2pm we will reconvene in the Garage to review how all the teams got on.

Make sure you have a lunch break at some point, but remember this is an ‘incident’ so you may want to ensure your whole team doesn’t go at the same time - you never know what problems may crop up...


---
\# Released at 10am / 1561971600
