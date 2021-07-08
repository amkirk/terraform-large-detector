# Large Detector Monitoring
This Terraform file can be used to create a dashboard group, dashboard, and detector. The detector will fire an alert when it is aborted because it hit a system limit. The dashboard will help you track down the problematic detector to take next steps.
## Before you get started
Update the main.tf file with your authtoken and desired notification settings.
> auth_token = "<<<YOURTOKENHERE>>>" <br/>
> notifications = ["Email,your-email-address@bar.com"]
